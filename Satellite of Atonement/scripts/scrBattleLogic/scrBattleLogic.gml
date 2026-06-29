//=====================================BATTLE INITIATION=====================================
function scrStartBattle(_enemy_list) {
	global.battle_enemies					= _enemy_list;
	global.battle_phase							= BATTLE_PHASE.SELECT_COMMAND;
	global.battle_turn_order				= [];
	global.battle_actions						= [];//party actions chosen this turn
	global.battle_cmd_index				= 0;//which party member is choosing
	global.battle_cmd_cursor				= 0;//CMND/MACRO/FLEE cursor
	global.battle_icon_cursor				= 0;//icon row cursor
	global.battle_sub_cursor				= 0; //sub-submenu cursor (spell/skill/item list)
	global.battle_sub_page					= 0;//current page in sub-submenu
	global.battle_target_cursor			= 0;
	global.battle_selecting_target		= false;
	global.battle_sub_open					= false;// magic/skill/item submenu open
	global.battle_damage_display		= [];// { x, y, value, timer }
	global.battle_action_display			= "";//current action name display
	global.battle_action_timer			= 0;
	global.battle_flee_result					= -1;// -1 = not tried, 0 = failed, 1 = success
	global.battle_intro_timer				= 45;
	
	//initialize party actions array
	global.battle_actions = [];
	for (var i = 0; i < array_length(global.party); i++) {
		array_push(global.battle_actions, undefined);
	}
	
	//reset defend flags
	for (var i = 0; i < array_length(global.party); i++) {
		global.party[i].battle_defending = false;
	}
	
	global.battle_sub_list = [];
	global.battle_sub_mode = "";
	global.battle_pending_entry = undefined;
	
	global.state = GAME_STATE.BATTLE;
	instance_create_depth(0, 0, -100, oBattleManager);
	show_debug_message("Battle started with " + string(array_length(_enemy_list)) + " enemies");
}

//=======================================TURN ORDER=======================================
//returns sorted array of { kind: "party"|"enemy", index, spd, macro_group }
function scrBuildTurnOrder() {
	var order = [];
	
	for (var i = 0; i < array_length(global.party); i++) {
		var m = global.party[i];
		if (m.current_hp <= 0) continue;
		var s = m.get_effective_stats();
		array_push(order, {
			kind					: "party",
			index					: i,
			spd					: s.spd,
			macro_group : -1//-1 = no macro
		});
	}
	
	for (var i = 0; i < array_length(global.battle_enemies); i++) {
		var e = global.battle_enemies[i];
		if (e.is_dead) continue;
		array_push(order, {
			kind					: "enemy",
			index					: i,
			spd					: e.spd,
			macro_group : -1,
		});
	}
	
	//sort by spd descending, ties broken randomly
	array_sort(order, function(a, b) {
		if (a.spd != b.spd) return b.spd - a.spd;
		return random(2) > 1 ? 1 : -1;
	});
	
	return order;
}

function scrEnemyPickAllActions() {
	for (var i = 0; i < array_length(global.battle_enemies); i++) {
		var e = global.battle_enemies[i];
		if (e.is_dead) continue;
		
		//filter moves by MP availability
		var valid_moves = [];
		for (var j = 0; j < array_length(e.moves); j++) {
			var m = e.moves[j];
			if (m.type == "magic" && e.current_mp < m.mp_cost) continue;
			array_push(valid_moves, m);
		}
		
		if (array_length(valid_moves) > 0) {
			e.action = e.choose_move(valid_moves);//uses filtered list
		} else {
			e.action = undefined;
		}
	}
}
	
//============================================FLEE============================================
function scrAttemptFlee() {
	var party_spd = 0;
	var enemy_spd = 0;
	for (var i = 0; i < array_length(global.party); i++) {
		party_spd += global.party[i].get_effective_stats().spd;
	}
	for (var i = 0; i < array_length(global.battle_enemies); i++) {
		enemy_spd += global.battle_enemies[i].spd;
	}
	var avg_party = party_spd / array_length(global.party);
	var avg_enemy = enemy_spd / array_length(global.battle_enemies);
	
	//chance = 50% + SPD advantage, clamped 10%-90%
	var chance = 0.5 + (avg_party - avg_enemy) / 100;
	chance = clamp(chance, 0.1, 0.9);
	return random(1) < chance;
}
//=================================DAMAGE CALCULATION=================================
function scrCalcPhysicalDamage(_atk, _def) {
	var base = _atk - _def;
	base = max(1, base);//minimum 1 damage
	//add slight random variance +/-10%
	return floor(base * (0.9 + random(0.2)));
}

function scrCalcMagicDamage(_mAtk, _mDef, _mpower, _element, _target) {
	var base = floor(_mAtk * (_mpower / 100)) - _mDef;
	base = max(1, base);
	//apply weakness/resistance
	if (_target.is_weak_to != undefined && _target.is_weak_to(_element)) base = floor(base * 1.5);
	if (_target.is_resistant_to != undefined && _target.is_resistant_to(_element)) base = floor(base * 0.5);
	return floor (base * (0.9 + random(0.2)));
}


//==================================COMMAND PHASE==================================
function scrBattleCommandPhase() {
	//top level: CMND/MACRO/FLEE
	if (array_length(global.battle_sub_list) > 0) {
		show_debug_message("SUBLIST NAV RUNNING during target select: " + string(global.battle_selecting_target));
	}
	
	if (global.battle_selecting_target) {
		scrBattleTargetSelectionPhase();
		return;
	}
	
	if (!global.battle_sub_open && global.battle_cmd_index == 0 && global.battle_phase == BATTLE_PHASE.SELECT_COMMAND) {
		scrEnemyPickAllActions();
		
		if (global.keyUpPressed) global.battle_cmd_cursor = (global.battle_cmd_cursor - 1 + 3) mod 3;
		if (global.keyDownPressed) global.battle_cmd_cursor = (global.battle_cmd_cursor + 1) mod 3;
		
		if (global.keyC) {
			switch (global.battle_cmd_cursor) {
				
				case 0://CMND - begin character command selection
					global.battle_cmd_index = 0;
					global.battle_sub_open = true;
					global.battle_icon_cursor = 0;
					io_clear();
					global.keyC = false;
					break;
				
				case 1://MACRO
					var alive_enemies = [];
					for (var mi = 0; mi < array_length(global.battle_enemies); mi++) {
						if (!global.battle_enemies[mi].is_dead) array_push(alive_enemies, mi);
					}
					if (array_length(alive_enemies) > 0) {
						for (var mi = 0; mi < array_length(global.battle_actions); mi++) {
							if (global.party[mi].current_hp <= 0) {
								global.battle_actions[mi] = { type: "dead", target: -1 };
								continue;
							}
							var tgt = alive_enemies[irandom(array_length(alive_enemies) - 1)];
							global.battle_actions[mi] = { type: "attack", target: tgt, target_side: "enemy", all_targets: false };
						}
					}
					global.battle_sub_open = false;
					global.battle_cmd_index = 0;
					global.battle_turn_order = scrBuildTurnOrder();
					global.battle_phase = BATTLE_PHASE.EXECUTE_TURN;
					io_clear();
					global.keyC = false;
					break;
					
				case 2://FLEE
				show_debug_message("FLEE selected | attempting flee...");
				var flee_result = scrAttemptFlee();
				show_debug_message("FLEE result: " + string(flee_result));
					if (flee_result) {
						show_debug_message("FLEE succeeded - calling scrEndBattle");
						global.battle_flee_result = 1;
						scrEndBattle(false);
						exit;//stop execution immediately after destroying oBattleManager
					} else {
						show_debug_message("FLEE failed - executing turn");
						global.battle_flee_result = 0;
						global.battle_phase = BATTLE_PHASE.EXECUTE_TURN;
						global.battle_turn_order = scrBuildTurnOrder();
					}
					io_clear();
					global.keyC = false;
					break;
				
			}
		}
		return;
	}
	
	//character icon selection
	if (global.battle_sub_open && !global.battle_selecting_target) {
		var cur_member = global.party[global.battle_cmd_index];
		
		if (global.keyLeftPressed) global.battle_icon_cursor = max(0, global.battle_icon_cursor - 1);
		if (global.keyRightPressed) global.battle_icon_cursor = min(4, global.battle_icon_cursor + 1);
		
		if (global.keyC && array_length(global.battle_sub_list) == 0) {
			switch (global.battle_icon_cursor) {
				
				case 0://attack
					global.battle_sub_mode = "attack";
					global.battle_target_list = [];
					for (var ei = 0; ei < array_length(global.battle_enemies); ei++) {
						if (!global.battle_enemies[ei].is_dead) array_push(global.battle_target_list, ei);
					}
					global.battle_target_cursor = 0;
					global.battle_selecting_target = true;
					break;
					
				case 1://magic
					if (array_length(cur_member.spells) == 0) break;
					global.battle_sub_list = scrBattleBuildSpellList(global.battle_cmd_index);
					if (array_length(global.battle_sub_list) > 0) {
						global.battle_sub_mode = "spell";
						global.battle_sub_cursor = 0;
						global.battle_sub_page = 0;
						io_clear();
						global.keyC	= false;
					}
				break;
				
				case 2://skill
					if (array_length(cur_member.skills) == 0) break;
					global.battle_sub_list = scrBattleBuildSkillList(global.battle_cmd_index);
					if (array_length(global.battle_sub_list) > 0) {
						global.battle_sub_mode = "skill";
						global.battle_sub_cursor = 0;
						global.battle_sub_page = 0;
						io_clear();
						global.keyC	= false;
					}
				break;
				
				case 3://item
					global.battle_sub_list = scrBattleBuildItemList(global.battle_cmd_index);
					if (array_length(global.battle_sub_list) > 0) {
						global.battle_sub_mode = "item";
						global.battle_sub_cursor = 0;
						global.battle_sub_page = 0;
						io_clear();
						global.keyC	= false;
					}
					break;
				
				case 4://defend
					global.battle_actions[global.battle_cmd_index] = {
						type: "defend", target: -1,
						target_side: "ally", all_targets: false
					};
					scrAdvanceCmdIndex();
					io_clear();
					global.keyC	= false;
				break;
			}
		}
			
			//sublist navigation
		if (array_length(global.battle_sub_list) > 0) {
			var sl_size = array_length(global.battle_sub_list);
			var sl_page = global.battle_sub_page;
			var sl_has_next = (sl_page * 5 + 5) < sl_size;
			var sl_show_next = sl_has_next || (sl_page > 0);
			var sl_max_cursor = sl_show_next ? 5 : min(4, sl_size - sl_page * 5 - 1);
				
			if (global.keyUpPressed) {
				global.battle_sub_cursor--;
				if (global.battle_sub_cursor < 0) global.battle_sub_cursor = sl_max_cursor;
				io_clear()
			}
			if (global.keyDownPressed) {
				global.battle_sub_cursor++;
				if (global.battle_sub_cursor > sl_max_cursor) global.battle_sub_cursor = 0;
				io_clear()
			}
				
			if (global.keyC) {
				if (sl_show_next && global.battle_sub_cursor == 0) {
					//next/first
					if (sl_has_next) {
						global.battle_sub_page++;
					} else {
						global.battle_sub_page = 0;
					}
					global.battle_sub_cursor = 0;
				} else {
					var actual_idx = sl_page * 5 + global.battle_sub_cursor - (sl_show_next ? 1 : 0);
					if (actual_idx >= 0 && actual_idx < sl_size) {
						var entry = global.battle_sub_list[actual_idx];
							
						//"all" target types apply immediately
						if (entry.data.target_type == "all_enemies" || entry.data.target_type == "all_allies" || entry.data.target_type == "all_party" || entry.data.target_type == "functional") {
							var _side = (entry.data.target_type == "all_enemies") ? "enemy" : "ally";
							global.battle_actions[global.battle_cmd_index] = {
								type: global.battle_sub_mode,
								target: -1,
								target_side: _side,
								all_targets: true,
								spell_index: entry.kind == "spell" ? entry.index : -1,
								skill_index: entry.kind == "skill" ? entry.index : -1,
								item_index: entry.kind == "item" ? entry.index : -1
							};
							global.battle_sub_list = [];
							global.battle_pending_entry = undefined;
							scrAdvanceCmdIndex();
						} else {
							//single target - enter target selection
							global.battle_pending_entry = entry;
							global.battle_sub_list = [];
							global.battle_target_list = [];
							var _ct_order = [2, 1, 0, 3];
							if (entry.data.target_type == "single_enemy") {
								for (var ei = 0; ei < array_length(global.battle_enemies); ei++) {
									if (!global.battle_enemies[ei].is_dead) array_push(global.battle_target_list, ei);
								}
							} else if (entry.data.target_type == "single_ally") {
								var is_revive = (entry.kind == "item" && entry.data.effect_type == "revive");
								for (var ci = 0; ci < 4; ci++) {
									var pai = _ct_order[ci];// [2, 1, 0, 3]
									if (is_revive) {
										if (global.party[pai].is_dead) array_push(global.battle_target_list, pai);
									} else {
										if (global.party[pai].current_hp > 0) array_push(global.battle_target_list, pai);
									}
								}
							} else {
								for (var ci = 0; ci < 4; ci++) {
									var pai = _ct_order[ci];
									if (global.party[pai].current_hp > 0) array_push(global.battle_target_list, pai);
								}
							}
							global.battle_target_cursor = 0;
							global.battle_selecting_target = true;
						}
					}
				}
				io_clear();
				global.keyC = false;
			}
		}
		
		if (global.keyB) {
			if (array_length(global.battle_sub_list) > 0) {
				global.battle_sub_list = [];
				global.battle_pending_entry = undefined;
			} else if (global.battle_cmd_index > 0) {
				global.battle_cmd_index--;
				global.battle_actions[global.battle_cmd_index] = undefined;
			} else {
				global.battle_sub_open = false;
			}
			io_clear();
			global.keyB = false;
		}
	}
}

function scrAdvanceCmdIndex() {
	global.battle_cmd_index++;
	//skip dead members
	while (global.battle_cmd_index < array_length(global.party) && global.party[global.battle_cmd_index].current_hp <= 0) {
	global.battle_actions[global.battle_cmd_index] = { type: "dead", target: -1 };
	global.battle_cmd_index++;
	}

	if (global.battle_cmd_index >= array_length(global.party)) {
		//all commands selected- build turn order and execute
		global.battle_sub_open			= false;
		global.battle_cmd_index		= 0;
		global.battle_turn_order		= scrBuildTurnOrder();
		global.battle_phase					=	BATTLE_PHASE.EXECUTE_TURN;
	} else {
		global.battle_icon_cursor = 0;
	}
}

//=====================================EXECUTE PHASE=====================================
function scrBattleExecutePhase() {
	//wait until all damage popups are cleared before the next action
	if (array_length(global.battle_damage_display) > 0) {
		return;
	}
	
	if (array_length(global.battle_damage_display) == 0 && global.battle_action_delay <= 0) {
	global.battle_attack_target = -1;
	global.battle_attack_target_side = "";
	global.battle_attacker = -1;
	global.battle_attacker_side = "";
	global.battle_all_target_side = "";
}
	
	//short pause after popups clear before next action
	if (global.battle_action_delay > 0) {
		global.battle_action_delay--;
		return;
	}
	
	//all turns resolved - check for win/loss
	if (array_length(global.battle_turn_order) == 0) {
		scrCheckBattleEnd();
		return;
	}
	
	//resolve the next combatant's action
	var turn = global.battle_turn_order[0];
	array_delete(global.battle_turn_order, 0, 1);
	show_debug_message("Executing turn for: " + turn.kind + " index: " + string(turn.index));
	
	if (turn.kind == "party") {
		scrResolvePartyAction(turn);
	} else {
		scrResolveEnemyAction(turn);
	}
	
	//pause before the next action
	global.battle_action_delay = 15;//0.25s at 60fps
}

function scrResolvePartyAction(_turn) {
	var member = global.party[_turn.index];
	if (member.current_hp <= 0) return;//dead skip
	
	var action = global.battle_actions[_turn.index];
	if (!action) return;
	
	//acting party member stays visible
	global.battle_attacker = _turn.index;
	global.battle_attacker_side = "ally";
	
	switch (action.type) {
		case "attack":
			if (action.target < 0 || action.target >= array_length(global.battle_enemies)) return;
			var enemy = global.battle_enemies[action.target];
			if (!enemy || enemy.is_dead) return;
			
			//mark who is being attacked so only they are visible
			global.battle_attack_target = action.target;
			global.battle_attack_target_side = "enemy";
			
			var dmg = scrCalcPhysicalDamage(member.get_effective_stats().atk, enemy.def);
			enemy.current_hp -= dmg;
			if (enemy.current_hp < 0) enemy.current_hp = 0;
			
			//damage popup
			var _num_e = array_length(global.battle_enemies);
			var _start_x = 160 - (_num_e - 1) * 32;
			array_push(global.battle_damage_display, {
				x: _start_x + action.target * 64,//calculate from enemy position
				y: 120 -16,
				value: dmg,
				timer: 90,
				enemy_idx: action.target
			});
			
			//check death
			if (enemy.current_hp <= 0) {
				enemy.is_dead = true;
				scrRetargetDeadEnemy(action.target);
			}
		break;
			
		case "defend":
			member.battle_defending = true;
		break;
		
		case "magic":
		case "skill":
		case "item":
			var target_entity = undefined;
			var _hits_enemy = (action.target_side == "enemy");
			
			if (action.all_targets) {
				global.battle_all_target_side = action.target_side;
				if (_hits_enemy) {
					for (var ei = 0; ei < array_length(global.battle_enemies); ei++) {
						if (!global.battle_enemies[ei].is_dead) {
							applyBattleAction(member, action, global.battle_enemies[ei]);
						}
					}
				} else {
					for (var pai = 0; pai < array_length(global.party); pai++) {
						if (global.party[pai].current_hp > 0) {
							applyBattleAction(member, action, global.party[pai]);
						}
					}
				}
				return;
			}
			
			if (_hits_enemy) {
				if (action.target >= 0 && action.target < array_length(global.battle_enemies)) {
					target_entity = global.battle_enemies[action.target];
				}
			} else {
				if (action.target >= 0 && action.target < array_length(global.party)) {
					target_entity = global.party[action.target];
				}
			}
			
			if (target_entity != undefined) {
				global.battle_attack_target = action.target;
				global.battle_attack_target_side = action.target_side;
				applyBattleAction(member, action, target_entity);
			}
			break;
	}
}

function applyBattleAction(_user, _action, _target) {
	switch(_action.type) {
		case "magic":
			if (_action.spell_index < 0 || _action.spell_index >= array_length(_user.spells)) return;
			var spell = _user.spells[_action.spell_index];
			if (_user.current_mana < spell.mp_cost) return;
			_user.current_mana -= spell.mp_cost;
		
			if (spell.effect_type == "damage" ) {
				var dmg = scrCalcMagicDamage(_user.get_effective_stats().mAtk, _target.mDef, spell.mpower, spell.element, _target );
				
				if (_target.current_hp <= 0 && variable_struct_exists(_target, "is_dead")) {
					_target.is_dead = true;
					//find this enemy's index to retarget
					for (var _ei = 0; ei < array_length(global.battle_enemies); _ei++) {
						if (global.battle_enemies[_ei] == _target) {
							scrRetargetDeadEnemy(_ei);
							break;
						}
					}
				}
				_target.current_hp -= dmg;
				if (_target.current_hp < 0) _target.current_hp = 0;
				var _num_e = array_length(global.battle_enemies);
				var _start_x = 160 - (_num_e - 1) * 32;  // 32 = enemy_spacing/2
				array_push(global.battle_damage_display, {
					x: _start_x + _action.target * 64,  // 64 = enemy_spacing
					y: 104,
					value: dmg,
					timer: 60,
					enemy_idx: _action.target
				});
			} else if (spell.effect_type == "heal_hp") {
				if (!_target.has_status("poison")) {
					var heal_amt = floor(spell.mpower * 0.5);
					_target.current_hp = min(_target.current_hp + heal_amt, _target.base_max_hp);
				}
			}
		break;
		
		case "skill":
			if (_action.skill_index < 0 || _action.skill_index >= array_length(_user.skills)) return;
			var skill = _user.skills[_action.skill_index];
			if (skill.uses_left <= 0) return;
			skill.uses_left--;
			
			if (_target.current_hp <= 0 && variable_struct_exists(_target, "is_dead")) {
					_target.is_dead = true;
					//find this enemy's index to retarget
					for (var _ei = 0; ei < array_length(global.battle_enemies); _ei++) {
						if (global.battle_enemies[_ei] == _target) {
							scrRetargetDeadEnemy(_ei);
							break;
						}
					}
				}
			
			if (skill.effect_type == "damage") {
				var dmg = scrCalcPhysicalDamage(_user.get_effective_stats().atk, _target.def);
				_target.current_hp -= dmg;
				if (_target.current_hp < 0) _target.current_hp = 0;
				var _num_e = array_length(global.battle_enemies);
				var _start_x = 160 - (_num_e - 1) * 32;
				array_push(global.battle_damage_display, {
					x: _start_x + _action.target * 64,
					y: 104,
					value: dmg, timer: 60,
					enemy_idx: _action.target
				});
			} else if (skill.effect_type == "restore_mp") {
				if (!_target.has_status("poison")) {
					var rest_amt = floor(10 + _user.get_effective_stats().mental * 0.5);
					_target.current_mana = min(_target.current_mana + rest_amt, _target.base_max_mana);
				}
			} else if (skill.effect_type == "heal_hp") {
				if (!_target.has_status("poison")) {
					var heal_amt = floor(10 + _user.get_effective_stats().mental * 0.5);
					_target.current_hp = min(_target.current_hp + heal_amt, _target.base_max_hp);
				}
			}
			//functional skills handled elsewhere
		break;
			
		case "item":
			if (_action.item_index < 0 || _action.item_index >= array_length(_user.inventory)) return;
			_user.use_item(_action.item_index, _target);
			break;
	}
}


function scrResolveEnemyAction(_turn) {
	var enemy = global.battle_enemies[_turn.index];
	if (enemy.is_dead) return;
	
	//acting enemy stays visible
	global.battle_attacker = _turn.index;
	global.battle_attacker_side = "enemy";
	//future all-allies enemy attack
	//global.battle_all_target_side = "ally";
	
	//enemy.action was set at turn start by scrEnemyPickAllActions()
	var move = enemy.action;
	if (!move) return;
	
	//pick random alive party member
	var alive = [];
	for (var i = 0; i < array_length(global.party); i++) {
		if (global.party[i].current_hp > 0) array_push(alive, i);
	}
	if (array_length(alive) == 0) return;
	var target_idx = alive[irandom(array_length(alive) - 1)];
	var target = global.party[target_idx];
	
	//mark who is being attacked so only they stay visible
	global.battle_attack_target = target_idx;
	global.battle_attack_target_side = "ally";
	
	//poison
	if (move.type == "status") {
		global.party[target_idx].add_status("poison");
		show_debug_message(target.name + " poisoned!");
		//status popup on party card
		var _co = [2, 1, 0, 3];
		var _ci = -1;
		for (var _c = 0; _c < 4; _c++) {
			if (_co[_c] == target_idx) { _ci = _c; break; }
		}
		if (_ci >= 0) {
			array_push(global.battle_damage_display, {
				x: floor((320 - (4 * 80)) / 2) + (_ci * 80) + 40,
				y: 170,
				value: 0, label: "Poison!", timer: 90
			});
		}
		return;
	}
	
	//all-party attack
	if (move.target == "all_enemies") {
		for (var ai = 0; ai < array_length(alive); ai++) {
			var at = alive[ai];
			var ally = global.party[at];
			var ad = (move.type == "magic")
				? scrCalcMagicDamage(enemy.mAtk, ally.get_effective_stats().mDef, move.enPower, "none", ally)
				: scrCalcPhysicalDamage(move.enPower, ally.get_effective_stats().def);
			if (ally.battle_defending) ad = floor(ad * 0.5);
			ally.current_hp -= ad;
			if (ally.current_hp < 0) ally.current_hp = 0;
			if (ally.current_hp <= 0) ally.check_death();
			var _co = [2, 1, 0, 3];
			var _ci = -1;
			for (var _c = 0; _c < 4; _c++) {
				if (_co[_c] == at) { _ci = _c; break; }
			}
			if (_ci >= 0) {
				array_push(global.battle_damage_display, {
					x: floor((320 - (4 * 80)) / 2) + (_ci * 80) + 40,
					y: 170,
					value: ad, timer : 60
				});
			}
		}
		return;
	}
	
	var dmg = 0;
	//damage calc
	if (move.type == "magic") {
		dmg = scrCalcMagicDamage(enemy.mAtk, target.get_effective_stats().mDef, move.enPower, "none", target);
	} else {
		dmg = scrCalcPhysicalDamage(enemy.atk, global.party[target_idx].get_effective_stats().def);
	}
	
	if (global.party[target_idx].current_hp <= 0) {
		global.party[target_idx].is_dead = true;
		scrRetargetDeadAlly(target_idx);
	}
	
	if (target.battle_defending) dmg = floor(dmg * 0.5);
	target.current_hp -= dmg;
	if (target.current_hp < 0)  target.current_hp = 0;
	if (target.current_hp <= 0) target.check_death();
	
	//damage popup on party card
	var _co = [2, 1, 0, 3];
	var _ci = -1;
	for (var _c = 0; _c < 4; _c++) {
		if (_co[_c] == target_idx) { _ci = _c; break; }
	}
	if (_ci >= 0) {
		array_push(global.battle_damage_display, {
			x: floor((320 - (4 * 80)) / 2) + (_ci * 80) + 40,
			y: 170,
			value: dmg, timer: 60
		});
	}
}
function scrCheckBattleEnd() {
	var enemies_dead = true;
	for (var i = 0; i < array_length(global.battle_enemies); i++) {
		if (!global.battle_enemies[i].is_dead) { enemies_dead = false; break; }
	}
	if (enemies_dead) {
		global.battle_phase = BATTLE_PHASE.WIN_LOSS;
		return;
	}
	
	var party_dead = true;
	for (var i = 0; i < array_length(global.party); i++) {
		if (global.party[i].current_hp > 0) { party_dead = false; break; }
	}
	if (party_dead) {
		scrCheckGameOver();
		return;
	}
	
	//next turn
	global.battle_phase = BATTLE_PHASE.SELECT_COMMAND;
	global.battle_actions = [];
	for (var i = 0; i < array_length(global.party); i++) array_push(global.battle_actions, undefined);
	global.battle_cmd_index = 0;
	global.battle_sub_open = false;
	global.battle_flee_result = -1;
	for (var i = 0; i < array_length(global.party); i++) {
		global.party[i].battle_defending = false;
	}
}
			

//============================================WIN/LOSS=============================================
function scrBattleWinLoss() {
	//sum exp and money
	var total_xp = 0;
	var total_money = 0;
	for (var i = 0; i < array_length(global.battle_enemies); i++) {
		total_xp += global.battle_enemies[i].xp;
		total_money += global.battle_enemies[i].money;
	}
	global.money += total_money;
	//distributes xp, placeholder full level up logic later
	for (var i = 0; i < array_length(global.party); i++) {
		if (global.party[i].current_hp > 0) {
			global.party[i].experience += total_xp;
		}
	}
	show_debug_message("Battle won! EXP: " + string(total_xp) + " Money: " + string(total_money));
	scrEndBattle(true);
}

function scrEndBattle(_victory) {
	show_debug_message("scrEndBattle called | victory: " + string(_victory));
	global.battle_enemies = [];
	global.battle_actions = [];
	global.battle_turn_order = [];
	global.battle_sub_open = false;
	global.battle_cmd_index = 0;
	global.battle_flee_result = -1;
	global.encounter_steps = 0;
	show_debug_message("scrEndBattle globals cleared");
	global.state = GAME_STATE.OVERWORLD;
	show_debug_message("scrEndBattle state set to OVERWORLD");
	
	if (instance_exists(oBattleManager)) {
		show_debug_message("scrEndBattle destroying oBattleManager");
		instance_destroy(oBattleManager);
		show_debug_message("scrEndBattle oBattleManager destroyed");
	} else {
		show_debug_message("scrEndBattle WARNING: oBattleManager does not exist");
	}
	show_debug_message("Battle ended | victory: " + string(_victory));
}
//====================================TARGET SELECTION=====================================
function scrBattleTargetSelectionPhase() {
	show_debug_message("TARGET PHASE | cursor: " + string(global.battle_target_cursor) + " | mov keys L:" + string(global.keyLeftPressed) + " R:" + string(global.keyRightPressed) + " U:" + string(global.keyUpPressed) + " D:" + string(global.keyDownPressed));
	var list_size = array_length(global.battle_target_list);
	if (list_size == 0) {
		global.battle_selecting_target = false;
		return;
	}
	
	var _mov = 0;
	if (global.keyLeftPressed || global.keyUpPressed) _mov = -1;
	if (global.keyRightPressed || global.keyDownPressed) _mov = 1;
	
	if (_mov != 0) {
		global.battle_target_cursor = (global.battle_target_cursor + _mov + list_size) mod list_size;
		io_clear();
	}
	
	if (global.keyC) {
		var target = global.battle_target_list[global.battle_target_cursor];
		
		var _side = "enemy";
		if (global.battle_sub_mode != "attack" && global.battle_pending_entry != undefined) {
			var _tt = global.battle_pending_entry.data.target_type;
			_side = (_tt == "single_ally" || _tt == "single_party") ? "ally" : "enemy";
		}
		
		var action = { 
			type: global.battle_sub_mode,
			target: target,
			target_side: _side,
			all_targets: false,
			spell_index: -1,
			skill_index: -1,
			item_index: -1
			};
		
		if (global.battle_sub_mode == "attack" && global.battle_pending_entry != undefined) {
			//plain attack
			action.spell_index = global.battle_pending_entry.kind == "spell" ? global.battle_pending_entry.index : -1;
			action.skill_index = global.battle_pending_entry.kind == "skill" ? global.battle_pending_entry.index : -1;
			action.item_index = global.battle_pending_entry.kind == "item" ? global.battle_pending_entry.index : -1;
		}
		
		global.battle_actions[global.battle_cmd_index] = action;
		global.battle_selecting_target = false;
		global.battle_sub_list = [];
		global.battle_pending_entry = undefined;
		scrAdvanceCmdIndex();
		io_clear()
		global.keyC = false;
	}
	
	if (global.keyB) {
		global.battle_selecting_target = false;
		//return to sublist if we came from one, else back to icon row
		if (global.battle_sub_mode != "attack") {
			//rebuild list
			var member = global.party[global.battle_cmd_index];
			if (global.battle_sub_mode == "spell") global.battle_sub_list = scrBattleBuildSpellList(global.battle_cmd_index);
			else if (global.battle_sub_mode == "skill") global.battle_sub_list = scrBattleBuildSkillList(global.battle_cmd_index);
			else if (global.battle_sub_mode == "item") global.battle_sub_list = scrBattleBuildItemList(global.battle_cmd_index);
		}
		global.battle_target_list = [];
		io_clear();
		global.keyB = false;
	}
}

//=================================BUILD SUB-LISTS=================================
function scrBattleBuildSpellList(_char_idx) {
	var member = global.party[_char_idx];
	var result = [];
	for (var i = 0; i < array_length(member.spells); i++) {
		var sp = member.spells[i];
		if (member.current_mana <= sp.mp_cost) continue;
		array_push(result, { kind:"spell", label:sp.name, index:i, data:sp });
	}
	return result;
}

function scrBattleBuildSkillList(_char_idx) {
	var member = global.party[_char_idx];
	var result = [];
	for (var i = 0; i < array_length(member.skills); i++) {
		var sk = member.skills[i];
		if (sk.uses_left <= 0) continue;
		array_push(result, { kind:"skill", label:sk.name, index:i, data:sk });
	}
	return result;
}

function scrBattleBuildItemList(_char_idx) {
	var member = global.party[_char_idx];
	var result = [];
	for (var i = 0; i < array_length(member.inventory); i++) {
		var item = member.inventory[i];
		if (item.type != "consumable") continue;
		array_push(result, { kind:"item", label:item.name, index:i, data:item });
	}
	return result;
}
//====================================RETARGETING====================================
//called after an enemy dies - redirect any queued ally actions aimed at it
function scrRetargetDeadEnemy(_dead_idx) {
	//build a list of living enemies
	var alive_enemies = [];
	for (var i = 0; i < array_length(global.battle_enemies); i++) {
		if (!global.battle_enemies[i].is_dead) array_push(alive_enemies, i);
	}
	if (array_length(alive_enemies) == 0) return;//nothing to retarget to
	
	for (var i = 0; i < array_length(global.battle_actions); i ++) {
		var act = global.battle_actions[i];
		if (act == undefined) continue;
		//only redirect single target actions aimed at a dead enemy
		if (act.all_targets) continue;
		if (act.target_side == "enemy" && act.target == _dead_idx) {
			act.target = alive_enemies[irandom(array_length(alive_enemies) - 1)];
		}
	}
}

//called after an ally falls, redirect any queued enemy actions
function scrRetargetDeadAlly(_dead_idx) {
	//built the list of living party members
	var alive_party = [];
	for (var i = 0; i < array_length(global.party); i++) {
		if (global.party[i].current_hp > 0) array_push(alive_party, i);
	}
	if (array_length(alive_party) == 0) return;
	
	//enemy actions store target on the enemy struct
	//retarget any enemy whose chosen target was a fallen ally
	for (var i = 0; i < array_length(global.battle_enemies); i++) { 
		var e = global.battle_enemies[i];
		if (e.is_dead) continue;
		if (variable_struct_exists(e, "action target") && e.action_target == _dead_idx) {
			e.action_target = alive_party[irandom(array_length(alive_party) - 1)];
		}
	}
}