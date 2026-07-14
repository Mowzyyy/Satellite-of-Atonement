//====================================BATTLE MACROS====================================
/*Macro Entry: { party_idx, action }
action:					{ type: "attack" }
								{ type: "defend" }
								{ type: "magic",	index }			index into that char's spells
								{ type: "skill",		index}			index into that char's skills
entry order in the array is the exact act order
*/

function scrInitMacros() {
	global.macros = array_create(8, undefined);//8 player defined slots
}

//built in auto attack, always available, not stored in slots
function scrMacroAutoAttack() {
	var entries = [];
	for (var i = 0; i < array_length(global.party); i++) {
		if (global.party[i].is_dead) continue;
		array_push(entries, { member_name: global.party[i].name, action: { type: "attack" } });
	}
	return { name: "AutoAtk", entries: entries };
}

function scrPartyIndexByName(_name) {
	for (var i = 0; i < array_length(global.party); i++) {
		if (global.party[i].name == _name) return i;
	}
	return -1;
}

function scrFindSpellIndex(_member, _name) {
	for (var i = 0; i < array_length(_member.spells); i++) {
		if (_member.spells[i].name == _name) return i;
	}
	return -1;
}

function scrFindSkillIndex(_member, _name) {
	for (var i = 0; i < array_length(_member.skills); i++) {
		if (_member.skills[i].name == _name) return i;
	}
	return -1;
}

function scrMacroNew (_name) {
	return { name: _name, entries: [] };
}

function scrMacroPickEnemyTarget() {
	var best = -1;
	var best_hp = infinity;
	
	for (var i = 0; i < array_length(global.battle_enemies); i++) {
		var e = global.battle_enemies[i];
		if (e.is_dead) continue;
		if (e.current_hp < best_hp) {
			best_hp = e.current_hp;
			best = i;
		}
	}
	return best;
}

function scrMacroPickAllyTarget() {
	//Modify later
	var best = -1;
	var best_frat = infinity;
	for (var i = 0; i < array_length(global.party); i++) {
		var m = global.party[i];
		if (m.current_hp <= 0) continue;
		var frat = m.current_hp / m.base_max_hp;
		if (frat < best_frat) { best_frat = frac; best = i; }
	}
	return best;
}

//build party turn entries so that each member acts no earlier than everyone before them in the macro
function scrMacroBuildTurnEntries(_macro) {
	var result = [];
	var cap = infinity;
	for (var i = 0; i < array_length(_macro.entries); i++) {
		var entry = _macro.entries[i];
		var member = global.party[entry.party_idx];
		if (member.is_dead) continue;
		
		var spd = member.get_effective_stats().spd;
		var eff = min(spd, cap - 1);
		cap = eff;
		array_push(result, { kind: "party", index: entry.party_idx, spd: eff });
	}
	return result;
}

function scrMacroMenuLogic() {
	switch (global.macro_state) {
		
		case MACRO_STATE.SELECT_SLOT:
			if (global.keyUpPressed)			{ menu_cursor = (menu_cursor - 1 + 8) mod 8; io_clear(); }
			if (global.keyDownPressed)		{ menu_cursor = (menu_cursor + 1) mod 8; io_clear(); }
			
			if (global.keyC) {
				global.macro_slot = menu_cursor;
				global.macro_new = [];
				global.macro_state = MACRO_STATE.SELECT_MEMBER;
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MACRO_SELECT_MEMBER);
				menu_cursor =0;
				io_clear();
				global.keyC = false;
				show_debug_message("MACRO: editing slot " + string(global.macro_slot));
			}
		break;
		
		case MACRO_STATE.SELECT_MEMBER:
		//build list of members not yet placed in this macro
			var available = [];
			for (var q = 0; q < array_length(global.party); q++) {
				var placed = false;
				for (var j = 0; j < array_length(global.macro_new); j++) {
					if (global.macro_new[j].member_name == global.party[q].name) { placed = true; break; }
				}
				if (!placed) array_push(available, q);
			}
			var num_avail = array_length(available);
			
			//everyone assigned - confirm
			if (num_avail == 0) {
				global.macro_state = MACRO_STATE.CONFIRM;
				global.macro_confirm_cursor = 0;
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MACRO_CONFIRM);
				menu_cursor = 0;
				io_clear();
				break;
			}
			
			if (global.keyUpPressed)   { menu_cursor = (menu_cursor - 1 + num_avail) mod num_avail; io_clear(); }
			if (global.keyDownPressed) { menu_cursor = (menu_cursor + 1) mod num_avail; io_clear(); }
			menu_cursor = clamp(menu_cursor, 0, num_avail - 1);
			
			if (global.keyC) {
				global.macro_pending_member = available[menu_cursor];
				global.macro_state = MACRO_STATE.SELECT_ACTION;
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MACRO_SELECT_ACTION);
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
			}
		break;
		
		case MACRO_STATE.SELECT_ACTION:
			var member = global.party[global.macro_pending_member];
			//ATTACK, DEFEND always; MAGIC/SKILL only if the member has any
			var opts = scrMacroActionOptions(member);
			var num_opts = array_length(opts);
		
			if (global.keyUpPressed)			{ menu_cursor = (menu_cursor - 1 + num_opts) mod num_opts; io_clear(); }
			if (global.keyDownPressed)		{ menu_cursor = (menu_cursor + 1) mod num_opts; io_clear(); }
		
			if (global.keyC) {
				var choice = opts[menu_cursor];
				if (choice == "ATTACK" || choice == "DEFEND") {
					array_push(global.macro_new, {
						member_name: member.name,
						action: { type: (choice == "ATTACK") ? "attack" : "defend" }
					});
					//back to member selection
					ds_stack_pop(global.submenu_history);//pop SELECT_ACTION
					global.macro_state = MACRO_STATE.SELECT_MEMBER;
					menu_cursor = 0;
				} else {
					//MAGIC or SKILL - build the what list
					global.macro_what_list = [];
					if (choice == "MAGIC") {
						for (var i = 0; i < array_length(member.spells); i++) {
							array_push(global.macro_what_list, { kind: "magic", label: member.spells[i].name });
						}
					} else {
						for (var i = 0; i < array_length(member.skills); i++) {
							array_push(global.macro_what_list, { kind: "skill", label: member.skills[i].name });
						}
					}
					global.macro_state = MACRO_STATE.SELECT_WHAT;
					ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MACRO_SELECT_WHAT);
					menu_cursor = 0;
				}
				io_clear();
				global.keyC = false;
			}
	break;
		
	case MACRO_STATE.SELECT_WHAT:
			var wl_size = array_length(global.macro_what_list);
			if (wl_size == 0) { global.macro_state = MACRO_STATE.SELECT_ACTION; break; }
			
			if (global.keyUpPressed)   { menu_cursor = (menu_cursor - 1 + wl_size) mod wl_size; io_clear(); }
			if (global.keyDownPressed) { menu_cursor = (menu_cursor + 1) mod wl_size; io_clear(); }
			
			if (global.keyC) {
				var w = global.macro_what_list[menu_cursor];
				var member2 = global.party[global.macro_pending_member];
				array_push(global.macro_new, {
					member_name: member2.name,
					action: { type: w.kind, what: w.label }
				});
				//pop SELECT_WHAT and SELECT_ACTION, back to member selection
				ds_stack_pop(global.submenu_history);
				ds_stack_pop(global.submenu_history);
				global.macro_state = MACRO_STATE.SELECT_MEMBER;
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
			}
		break;
		
		case MACRO_STATE.CONFIRM:
			if (global.keyUpPressed || global.keyDownPressed) {
				global.macro_confirm_cursor = 1 - global.macro_confirm_cursor;
				io_clear();
			}
			
			if (global.keyC) {
				if (global.macro_confirm_cursor == 1) {
					//yes - store the macro
					global.macros[global.macro_slot] = {
						name: "MACRO " + string(global.macro_slot + 1),
						entries: global.macro_new
					};
					show_debug_message("MACRO: saved slot " + string(global.macro_slot));
				} else {
					show_debug_message("MACRO: discarded");
				}
				//reset and return to slot select
				global.macro_new = [];
				global.macro_pending_member = -1;
				global.macro_confirm_cursor = 0;
				while (ds_stack_top(global.submenu_history) != SUBMENU_HISTORY.MACRO_SELECT_SLOT && ds_stack_size(global.submenu_history) > 1) {
					ds_stack_pop(global.submenu_history);
				}
				global.macro_state =	MACRO_STATE.SELECT_SLOT;
				menu_cursor = global.macro_slot;
				io_clear();
				global.keyC = false;
			}
		break;
	}
}

function scrMacroActionOptions(_member) {
	var opts = ["ATTACK", "DEFEND"];
	if (array_length(_member.spells) > 0) array_push(opts, "MAGIC");
	if (array_length(_member.skills) > 0) array_push(opts, "SKILL");
	return opts;
}

//builds the runtime list: AutoAtk preset + all defined slots
function scrBattleMacroList() {
	var list = [ scrMacroAutoAttack() ];
	for (var i = 0; i < 8; i++) {
		if (global.macros[i] != undefined) array_push(list, global.macros[i]);
	}
	return list;
}

function scrBattleMacroSelectPhase() {
	var list = scrBattleMacroList();
	var n = array_length(list);
	
	if (global.keyUpPressed)   { global.battle_macro_cursor = (global.battle_macro_cursor - 1 + n) mod n; io_clear(); }
	if (global.keyDownPressed) { global.battle_macro_cursor = (global.battle_macro_cursor + 1) mod n; io_clear(); }
	
	if (global.keyC) {
		scrApplyBattleMacro(list[global.battle_macro_cursor]);
		global.battle_macro_open = false;
		io_clear();
		global.keyC = false;
		return;
	}
	
	if (global.keyB) {
		global.battle_macro_open = false;
		io_clear();
		global.keyB = false;
	}
}

function scrApplyBattleMacro(_macro) {
	var ordered = [];//party indices in macro act order
	
	//clear all actions first
	for (var i = 0; i < array_length(global.battle_actions); i++) global.battle_actions[i] = undefined;
	
	for (var e = 0; e < array_length(_macro.entries); e++) {
		var entry = _macro.entries[e];
		var pai = scrPartyIndexByName(entry.member_name);
		if (pai == -1) continue;
		var member = global.party[pai];
		if (member.current_hp <= 0) {
			global.battle_actions[pai] = { type: "dead", target: -1 };
			continue;
		}
		
		var act = scrMacroResolveAction(member, entry.action);
		global.battle_actions[pai] = act;
		array_push(ordered, pai);
	}
	
	//members alive but not covered by the macro default to attack, appended last
	for (var i = 0; i < array_length(global.party); i++) {
		if (global.battle_actions[i] != undefined) continue;
		if (global.party[i].current_hp <= 0) {
			global.battle_actions[i] = { type: "dead", target: -1 };
			continue;
		}
		global.battle_actions[i] = scrMacroResolveAction(global.party[i], { type: "attack" });
		array_push(ordered, i);
	}
	
	global.battle_turn_order = scrBuildTurnOrderForMacro(ordered);
	global.battle_sub_open = false;
	global.battle_cmd_index = 0;
	global.battle_phase = BATTLE_PHASE.EXECUTE_TURN;
}

//converts a stored macro action into a battle struct
//macro_auto:true marks targets to be resolved at execution time (lowest hp)
function scrMacroResolveAction(_member, _stored) {
	var base = {
		type: "attack", target: -1, target_side: "enemy", all_targets: false,
		spell_index: -1, skill_index: -1, item_index: -1, macro_auto: true
	};
	
	switch (_stored.type) {
		case "attack":
			return base;
		
		case "defend":
			return {	type: "defend", target: -1, target_side: "ally", all_targets: false,
								spell_index: -1, skill_index: -1, item_index: -1, macro_auto: false };
		
		case "magic": 
			var sp_i = scrFindSpellIndex(_member, _stored.what);
			if (sp_i == -1) return base;
			
			var sp = _member.spells[sp_i];
			var _all = (sp.target_type == "all_enemies" || sp.target_type == "all_allies" || sp.target_type == "all_party");
			var _side = (sp.target_type == "all_enemies" || sp.target_type == "single_enemy") ? "enemy" : "ally";
			return {	type: "magic", target: -1, target_side: _side, all_targets: _all,
								spell_index: sp_i, skill_index: -1, item_index: -1, macro_auto: !_all };
								
			case "skill":
				var sk_i = scrFindSkillIndex(_member, _stored.what);
				if (sk_i == -1) return base;
				
				var sk = _member.skills[sk_i];
				var _all2 = (sk.target_type == "all_enemies" || sk.target_type == "all_allies" || sk.target_type == "all_party");
				var _side2 = (sk.target_type == "all_enemies" || sk.target_type == "single_enemy") ? "enemy" : "ally";
				return {	type: "skill", target: -1, target_side: _side2, all_targets: _all2,
									spell_index: -1, skill_index: sk_i, item_index: -1, macro_auto: !_all2 };
	}
	return base;
}

//each macro member acts strictly after everyone before them
function scrBuildTurnOrderForMacro(_ordered_indices) {
	var order = [];
	var cap = infinity;

	for (var i = 0; i < array_length(_ordered_indices); i++) {
			var pai = _ordered_indices[i];
			var m = global.party[pai];
			if (m.current_hp <= 0) continue;
			var s = m.get_effective_stats().spd;
			var eff = min(s, cap - 1);
			cap = eff;
			array_push(order, { kind: "party", index: pai, spd: eff, macro_group: 0 });
	}

	for (var i = 0; i < array_length(global.battle_enemies); i++) {
		var en = global.battle_enemies[i];
		if (en.is_dead) continue;
		array_push(order, { kind: "enemy", index: i, spd: en.spd, macro_group: -1 });
	}

	array_sort(order, function(a, b) {
		if (a.spd != b.spd) return b.spd - a.spd;
		return random(2) > 1 ? 1 : -1;
	});
	return order;
}