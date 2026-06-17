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
	
	//initialize party actions array
	global.battle_actions = [];
	for (var i = 0; i < array_length(global.party); i++) {
		array_push(global.battle_actions, undefined);
	}
	
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
			e.action = e.choose_move();//uses filtered list
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

function scrCalcMagicDamage(_mAtk, mDef, _mpower, _element, _target) {
	var base = floor(_mAtk * (mpower / 100)) - _mDef;
	base = max(1, base);
	//apply weakness/resistance
	if (_target.is_weak_to != undefined && _target.is_weak_to(_element)) base = floor(base * 1.5);
	if (_target.is_resistant_to != undefined && _target.is_resistant_to(_element)) base = floor(base * 0.5);
	return floor (base * (0.9 + random(0.2)));
}


//==================================COMMAND PHASE==================================
function scrBattleCommandPhase() {
	//top level: CMND/MACRO/FLEE
	
	if (global.battle_target_active) {
		scrBattleTargetSelectionPhase();
		return;
	}
	
	if (!global.battle_sub_open && global.battle_cmd_index == 0 && global.battle_phase == BATTLE_PHASE.SELECT_COMMAND) {
		
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
				
				case 1://MACRO - placeholder
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
		
		if (global.keyC) {
			switch (global.battle_icon_cursor) {
				
				case 0://attack
					global.battle_actions[global.battle_cmd_index] = {
						type: "attack", target: -1
					};
					scrAdvanceCmdIndex();
					break;
					
				case 1://magic
					if (array_length(cur_member.spells) == 0) break;
					global.battle_phase =	BATTLE_PHASE.SELECT_COMMAND;
					//open spell submenu -handled in draw
					global.battle_sub_open = true;
					global.battle_sub_cursor = 0;
					global.battle_sub_page = 0;
					break;
				
				case 2://skill
				if (array_length(cur_member.skills) == 0) break;
				global.battle_sub_cursor = 0;
				global.battle_sub_page = 0;
					break;
				
				case 3://item
					global.battle_sub_cursor = 0;
					global.battle_sub_page = 0;
					break;
				
				case 4://defend
					global.battle_actions[global.battle_cmd_index] = {
						type: "defend", target: -1
					};
					scrAdvanceCmdIndex();
					break;
				
			}
			io_clear();
			global.keyC = false;
		}
		
		if (global.keyB) {
			if (global.battle_cmd_index > 0) {
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

	if (global.battle_action_delay > 0) {
		global.battle_action_delay--;
		return;
	}
	
	if (array_length(global.battle_turn_order) == 0) {
		//turn complete, check win/loss
		scrCheckBattleEnd();
		return;
	}
	
	var turn = global.battle_turn_order[0];
	
	if (turn.kind == "party") {
		if (global.party[turn.index].current_hp <= 0) {
			array_delete(global.battle_turn_order, 0, 1);
			return;
		}
		scrResolvePartyAction(turn);
	} else {
		scrResolveEnemyAction(turn);
	}
	
	array_delete(global.battle_turn_order, 0, 1);
	
	//after each action, set delay for visual feedback
	global.battle_action_delay = 30;//0.5s at 60fps
}

function scrResolvePartyAction(_turn) {
	var member = global.party[_turn.index];
	if (member.current_hp <= 0) return;//dead skip
	
	var action = global.battle_actions[_turn.index];
	if (!action) return;
	
	switch (action.type) {
		case "attack":
			var enemy = global.battle_enemies[action.target];
			if (!enemy || enemy.is_dead) return;
			
			var dmg = scrCalcPhysicalDamage(member.get_effective_stats().atk, enemy.def);
			enemy.current_hp -= dmg;
			if (enemy.current_hp < 0) enemy.current_hp = 0;
			
			//damage popup
			array_push(global.battle_damage_display, {
				x: enemy_draw_x,//calculate from enemy position
				y: enemy_draw_y - 16,
				value: dmg,
				timer: 90
			});
			
			//check death
			if (enemy.current_hp <= 0) {
				enemy.is_dead = true;
				//death message handled in draw
			}
			break;
			//other action types later
	}
}

function scrResolveEnemyAction(_turn) {
	var enemy = global.battle_enemies[_turn.index];
	if (enemy.is_dead) return;
	
	//enemy.action was set at turn start by scrEnemyPickAllActions()
	var move = enemy.action;
	if (!move) return;
	
	//pick random alive party member
	var alive = [];
	for (var i = 0; i < array_length(global.party); i++) {
		if (global.party[1].current_hp > 0) array_push(alive, i);
	}
	if (array_length(alive) == 0) return;
	var target_idx = choose[alive];
	
	//damage calc
	var dmg = scrCalcPhysicalDamage(enemy.atk, global.party[target_idx].get_effective_stats().def);
	global.party[target_idx].current_hp -= dmg;
	if (global.party[target_idx].current_hp < 0) global.party[target_idx].current_hp = 0;
	
	//damage popup on party card
	//calculate position from card layout
	
	//check death
	if (global.party[target_idx].current_hp <= 0) {
		global.party[target_idx].check_death();
	}
}
function scrCheckBattleEnd() {
	var enemies_dead = true;
	for (var i = 0; i < array_length(global.battle_enemeis); i++) {
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
		global.battle_phase = BATTLE_PHASE.WIN_LOSS;//will handle as loss in winloss
		return;
	}
	
	//next turn
	global.battle_phase = BATTLE_PHASE.SELECT_COMMAND;
	global.battle_actions = [];
	for (var i = 0; i < array_length(global.party); i++) array_push(global.battle_actions, undefined);
	global.battle_cmd_inxed = 0;
	global.battle_sub_open = false;
	global.battle_flee_result = -1;
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
	//left/right cycles through targets
	//C confirms and stores action with target index for scrAdvanceCmdIndex()
	//B cancels and returns to icon slection for current character
}