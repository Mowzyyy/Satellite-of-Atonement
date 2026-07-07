//============================BATTLE GUI============================
if (global.state == GAME_STATE.BATTLE) {
	var lh = 9;//line height for battle cards
	var lpad = 6;
	
	//card dimenisons
	var card_w = 80;
	var card_h = 48;
	var card_gap = 0;
	var total_card_w = (4 * card_w) + (3 * card_gap);
	var card_start_x = floor((320 - total_card_w) / 2);
	var card_y = 240 - card_h;
	
	//draw order - midleft, midright, farleft, farright
	var card_order = [2, 1, 0, 3];
	
	//draw the battle background behind everything
	if (global.battle_background !=-1 && sprite_exists(global.battle_background)) {
		draw_sprite_stretched(global.battle_background, 0, 0, 0, 320, 240);
	} else {
		//defauilt solid background
		draw_set_color(c_dkgray);
		draw_rectangle(0, 0, 320, 240, false);
		draw_set_color(c_white);
	}
	
	//target selection helpers
	var _tgt_sel = global.battle_selecting_target;
	var _tgt_enemy = _tgt_sel && (global.battle_sub_mode == "attack" || (global.battle_pending_entry != undefined && global.battle_pending_entry.data.target_type == "single_enemy"));
	var _tgt_ally = _tgt_sel && !_tgt_enemy;
	
	//enemy sprites centered drawn first
	var enemy_spacing = 64;
	var num_enemies = array_length(global.battle_enemies);
	var enemy_start_x = 160 - (num_enemies - 1) * enemy_spacing / 2;
	var enemy_y = 120;
	for (var ei = 0; ei < num_enemies; ei++) {
		var e = global.battle_enemies[ei];
		//keep dead enemy visible while its damage popup is still showing
		if (e.is_dead) continue;

		
		//during an attack only show the targeted enemy
		if (global.battle_attack_target != -1 || global.battle_attacker != -1 || global.battle_all_target_side != "") {
			var _is_target   = (global.battle_attack_target_side == "enemy" && global.battle_attack_target == ei);
			var _is_attacker = (global.battle_attacker_side == "enemy" && global.battle_attacker == ei);
			var _is_all_side  = (global.battle_all_target_side == "enemy");
			if (!_is_target && !_is_attacker) continue;
		}
		
		//target select flash
		if (e.sprite_combat != -1 && sprite_exists(e.sprite_combat)) {
			if (e.is_dying) {
				var _sw = sprite_get_width(e.sprite_combat);
				var _sh = sprite_get_height(e.sprite_combat);
				var _ox = _sw / 2;
				var _frame = 90 - e.death_timer;
				var _creep = floor((_sh * (_frame + 1)) / 90);
				var _offset = 8;
				for (var _col = 0; _col < _sw; _col++) {
					var _col_creep = _creep + ((_col + _frame) mod 2) * _offset;
					var _vis_h = _sh - _col_creep;
					if (_vis_h > 0) {
					draw_sprite_part(e.sprite_combat, 0,
									_col, 0,
									1, _vis_h,
									enemy_start_x + ei * enemy_spacing + _col - _ox,
									enemy_y - _sh);
					}
				}
			} else {
				draw_sprite(e.sprite_combat, 0, enemy_start_x + ei * enemy_spacing, enemy_y);
			}
		}
	}
	
	//character combat sprites above cards
	for (var ci = 0; ci < array_length(global.party); ci++) {
		var pin = card_order[ci];
		var member = global.party[pin];
		
		//during an attack only show the targeted ally
		if (global.battle_attack_target != -1 || global.battle_attacker != -1 || global.battle_all_target_side != "") {
			var _is_target   = (global.battle_attack_target_side == "ally" && global.battle_attack_target == pin);
			var _is_attacker = (global.battle_attacker_side == "ally" && global.battle_attacker == pin);
			var _is_all_side  = (global.battle_all_target_side == "ally");
			if (!_is_target && !_is_attacker) continue;
		}
		
		var card_x = card_start_x + (ci * (card_w + card_gap));
		//sprite offset - 4px from middle-facing side
		var spr_x = card_x + card_w / 2;
		var spr_y = card_y;//bottom of sprite touches top of card
		var inst = instance_find(global.partyOrder[pin], 0);
		if (inst != noone && instance_exists(inst)) {
			var spr_combat = inst.sprite_combat;
			if (spr_combat != -1 && sprite_exists(spr_combat)) {
				var _show_sprite = !global.battle_sub_open || pin == global.battle_cmd_index;
				if (_tgt_ally && global.battle_target_list[global.battle_target_cursor] == pin) {
					_show_sprite = (blink_timer mod 50) < 25;
				}
				draw_sprite_ext(spr_combat, 0, spr_x, spr_y, 1, 1, 0, c_white, _show_sprite ? 1 : 0);
			}
		}
	}
	
	for (var ci = 0; ci < array_length(global.party); ci++) {
		var pin						= card_order[ci];//partyindex
		var member			= global.party[pin];
		var card_x				= card_start_x + (ci * (card_w + card_gap));
		var s							= member.get_effective_stats();
		var is_dead				= member.current_hp <= 0;
		var txt_col				= is_dead ? c_red : c_white;
		
		if (global.battle_sub_open && pin != global.battle_cmd_index && !is_dead) {
			txt_col = c_gray;
		}
		if (_tgt_ally && global.battle_target_list[global.battle_target_cursor] == pin) { 
			txt_col = c_yellow;
		}
		
		//card background
		draw_sprite_stretched(sBasicGUI, 0, card_x, card_y, card_w, card_h);
		
		//name left, action icon right
		draw_set_color(txt_col);
		draw_set_halign(fa_left);
		draw_text(card_x + lpad, card_y + lh * 1, member.name);
		
		//action icon
		var action_spr = is_dead ? sCombatDead : sCombatDefault;
		if (global.battle_actions[pin] != undefined && !is_dead) {
			switch (global.battle_actions[pin].type) {
				case "attack"		: action_spr = sAttackIcon;	break;
				case "defend"	: action_spr = sDefendIcon;	break;
				case "magic"		: action_spr = sMagicIcon;		break;
				case "skill"			: action_spr = sSkillIcon;			break;
				case "item"			: action_spr = sItemIcon;		break;
			}
		}
		
		//blink if currently selecting for this party member
		var is_selecting = global.battle_sub_open && global.battle_cmd_index == pin && global.battle_phase == BATTLE_PHASE.SELECT_COMMAND;
		var show_icon = !is_selecting || (blink_timer mod 40) < 20;
		if (show_icon) {
			draw_sprite(action_spr, 0, card_x + card_w - 22, card_y + lh * 1 - 4);
		} else {
			draw_sprite(sCombatDefault, 0, card_x + card_w - 22, card_y + lh * 1 - 4);
		}
		
		if (member.has_status("poison")) {
			draw_set_halign(fa_right);
			draw_set_color(c_purple);
			draw_text(card_x + card_w - lpad - 16, card_y + lh * 2, "P");
			draw_set_color(txt_col);
			draw_set_halign(fa_left);
		}
		
		//hp and mp
		draw_set_halign(fa_left);
		draw_text(card_x + lpad, card_y + lh * 3, "HP:");
		draw_set_halign(fa_right);
		draw_text(card_x + card_w - lpad, card_y + lh * 3, string(member.current_hp));
		draw_set_halign(fa_left);
		draw_text(card_x + lpad, card_y + lh * 4, "MP:");
		draw_set_halign(fa_right);
		draw_text(card_x + card_w - lpad, card_y + lh * 4, string(member.current_mana));
		draw_set_halign(fa_left);
		draw_set_color(c_white);
	}
	
	
	//icon submenu - shown when a character is selecting their action
	if (global.battle_sub_open && global.battle_cmd_index < array_length(global.party)) {
		var ci_active = -1;
		for (var ci = 0; ci < 4; ci++) {
			if (card_order[ci] == global.battle_cmd_index) { ci_active = ci; break; }
		}
		if (ci_active >= 0) {
			var sub_w = 128;
			var sub_h = 32;
			var act_card_x = card_start_x + (ci_active * (card_w + card_gap));
			
			//offset left for right-side cards
			var sub_x = (ci_active >= 2) ? act_card_x - sub_w - 4 : act_card_x + card_w + 4;
			var sub_y = card_y - sub_h - 1;
			
			draw_sprite_stretched(sBasicGUI, 0, sub_x, sub_y, sub_w, sub_h);
			
			//five icons evenly spaced
			var icons = [sAttackIcon, sMagicIcon, sSkillIcon, sItemIcon, sDefendIcon];
			var icon_spacing = 24
			for (var ic = 0; ic < 5; ic++) {
				var icon_x = sub_x + 8 + (ic * icon_spacing);
				var icon_y = sub_y + sub_h / 2 - 8;
				var is_sel_ic = (global.battle_icon_cursor == ic);
				var show_ic = !is_sel_ic || (blink_timer mod 40) < 20;
				
				if (show_ic) {
					draw_sprite(icons[ic], 0, icon_x, icon_y);
				} else {
					draw_sprite(sCombatDefault, 0, icon_x, icon_y);
				}
				
				//yellow highlight under selected icon
				if (is_sel_ic) {
					draw_set_color(c_yellow);
					draw_rectangle(icon_x - 1, icon_y + 17, icon_x + 15, icon_y + 18, false);
					draw_set_color(c_white);
					if (_tgt_enemy && global.battle_target_cursor < array_length(global.battle_target_list)) {
						var t_ei = global.battle_target_list[global.battle_target_cursor];
						var _flash = (blink_timer mod 30) < 15;
						if (_flash) {
							draw_sprite_ext(global.battle_enemies[t_ei].sprite_combat, 0, enemy_start_x + t_ei * enemy_spacing, enemy_y, 1, 1, 0, c_white, 1);
						}
					}
				}
			}
		}
	}
	
	//sublist panel - spells/skills/items
	if (global.battle_sub_open && !global.battle_selecting_target && array_length(global.battle_sub_list) > 0) {
		var sl_list = global.battle_sub_list;
		var sl_size = array_length(sl_list);
		var sl_page = global.battle_sub_page;
		var sl_page_start = sl_page * 5;
		var sl_has_next = (sl_page_start + 5) < sl_size;
		var sl_is_last = !sl_has_next && sl_page > 0;
		var sl_show_next = sl_has_next || (sl_page > 0);
		
		//dynamic height
		var sl_item_h = 9;
		var sl_top_pad = 12;
		var sl_items_on_page = min(5, sl_size - sl_page_start);
		var sl_w = 100;
		var sl_h = sl_top_pad + (sl_show_next ? sl_item_h : 0) + sl_items_on_page * sl_item_h + 4;
		
		//align to icon submenu
		var _ci_active = -1;
		for (var _ci = 0; _ci < 4; _ci++) {
			if (card_order[_ci] == global.battle_cmd_index) { _ci_active = _ci; break; }
		}
		var _sub_w = 128, _sub_h = 32;
		var _act_card_x = card_start_x + (_ci_active * (card_w + card_gap));
		var _sub_x = (_ci_active >= 2) ? _act_card_x - _sub_w - 4 : _act_card_x + card_w + 4;
		var _sub_y = card_y - _sub_h - 1;

		var sl_x = _sub_x + (_sub_w - sl_w) / 2;
		var sl_y = _sub_y + (_sub_h - sl_h) / 2;
		
		draw_sprite_stretched(sBasicGUI, 0, sl_x, sl_y, sl_w, sl_h);
		
		//next/first label
		if (sl_show_next) {
			var next_lbl = sl_page > 0 && !sl_has_next ? "*FIRST*" : "*NEXT*";
			var next_col = (global.battle_sub_cursor == 0) ? c_yellow : c_white;
			draw_text_color(sl_x + 18, sl_y + sl_top_pad, next_lbl, next_col, next_col, next_col, next_col, 1);
		}
		
		//item rows
		for (var sli = 0; sli < 5; sli++) {
			var slot_idx = sl_page_start + sli;
			if (slot_idx >= sl_size) break;
			var entry = sl_list[slot_idx];
			var cursor_i = sl_show_next ? sli + 1 : sli;
			var line_col = (global.battle_sub_cursor == cursor_i) ? c_yellow : c_white;
			draw_text_color(sl_x + 18, sl_y + sl_top_pad + (cursor_i * sl_item_h), entry.label, line_col, line_col, line_col, line_col, 1);
		 }
		 
		 //blinking cursor
		var _blink_on = (blink_timer mod 40) < 20;
		draw_sprite((_blink_on ? sCursor : sBlink), 0, sl_x + 6, sl_y + sl_top_pad + (global.battle_sub_cursor * sl_item_h));
	}
				
	
	//enemy name boxes
	var enemy_types = [];
	for (var ei = 0; ei < array_length(global.battle_enemies); ei++) {
		var e = global.battle_enemies[ei];
		if (e.is_dead || e.is_dying) continue;
		//check if this name is already in the list
		var found = false;
		for (var eti = 0; eti < array_length(enemy_types); eti++) {
			if (enemy_types[eti] == e.name) { found = true; break; }
		}
		if (!found) array_push(enemy_types, e.name);
	}
	
	var ebox_w = 96;
	var ebox_h = 24;
	var ebox_gap = 4;
	for (var eti = 0; eti < array_length(enemy_types); eti++) {
		var col_idx = eti mod 2;
		var row_idx = eti div 2;
		var ebox_x = (col_idx == 0) ? 20 : 320 - 20 - ebox_w;
		var ebox_y = 9 + row_idx * (ebox_h + ebox_gap);
		draw_sprite_stretched(sBasicGUI, 0, ebox_x, ebox_y, ebox_w, ebox_h);
		draw_set_halign(fa_left);
		draw_text(ebox_x + 8, ebox_y + 12, enemy_types[eti]);
	}
	
	//damage display boxes
	for (var di = 0; di < array_length(global.battle_damage_display); di++) {
		var d = global.battle_damage_display[di];
		var d_w = 48;
		var d_h = 20;
		var display_txt = (variable_struct_exists(d, "label") && d.label != "") ? d.label : string(d.value);
		var txt_w = string_width(display_txt) + 12;
		var box_w = max(d_w, txt_w);
		draw_sprite_stretched(sBasicGUI, 0, d.x - box_w / 2, d.y, box_w, d_h);
		draw_set_halign(fa_center);
		draw_set_valign(fa_center);
		draw_text(d.x, d.y + d_h / 2, display_txt);
		draw_set_valign(fa_top);
		draw_set_halign(fa_left);
	}
	
	//CMND/MACRO/FLEE box - only show when no subselection is active
	//hidden during command selection, target selection, damage, etc
	var _show_cmd_box = (global.battle_phase == BATTLE_PHASE.SELECT_COMMAND)
											&& (global.battle_intro_timer <= 0)
											&& !global.battle_sub_open
											&& !global.battle_selecting_target
											&& (global.battle_cmd_index == 0)
											&& (array_length(global.battle_sub_list) == 0);
	if (_show_cmd_box) {
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		var cmd_w = 72;
		var cmd_h = 56;
		var cmd_x = 320 / 4 - cmd_w - 4;
		var cmd_y = 120 - cmd_h - 4;
		draw_sprite_stretched(sBasicGUI, 0, cmd_x, cmd_y, cmd_w, cmd_h);
		
		var cmd_opts = ["CMND", "MACRO", "FLEE"];
		for (var i = 0; i < 3; i++) {
			var col = (global.battle_cmd_cursor == i) ? c_yellow : c_white;
			draw_text_color(cmd_x + 18, cmd_y + 8 + (i * 16), cmd_opts[i], col, col, col, col, 1);
		}
		
		var _blink_on = (blink_timer mod 40) < 20;
		draw_sprite((_blink_on ? sCursor : sBlink), 0, cmd_x + 6, cmd_y + 12 + (global.battle_cmd_cursor * 16));
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
	
	//macro list - shown when MACRO is selected
	if (global.battle_macro_open) {
		var ml = scrBattleMacroList();
		var ml_n = array_length(ml);
		var ml_w = 88;
		var ml_h =ceil((14 + ml_n * 10) / 8) * 8;
		var ml_x = (320 / 4 - 72 - 4) + 72 + 4;//right edge of the cmd box + 4
		var ml_y = 120 - ml_h - 4;
		
		draw_sprite_stretched(sBasicGUI, 0, ml_x, ml_y, ml_w, ml_h);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		for (var mi = 0; mi < ml_n; mi++) {
			var mcol = (global.battle_macro_cursor == mi) ? c_yellow : c_white;
			draw_text_color(ml_x + 16, ml_y + 8 + mi * 10, ml[mi].name, mcol, mcol, mcol, mcol, 1);
		}
		
		var _mblink = (blink_timer mod 40) < 20;
		draw_sprite((_mblink ? sCursor : sBlink), 0, ml_x + 5, ml_y + 8 + global.battle_macro_cursor * 10);
	}
}

//============================ BATTLE MESSAGE BOX ============================
if (global.battle_phase ==BATTLE_PHASE.RESULTS && global.battle_msg_index < array_length(global.battle_msgs)) {
	var msg = global.battle_msgs[global.battle_msg_index];
	var mbox_x, mbox_w;
	var mbox_h = (msg.kind == "levelup") ? 56 : 24;
	var mbox_bottom = 191;
	var mbox_y = mbox_bottom - mbox_h;
	
	if (msg.kind == "levelup") {
		mbox_w = 304;
		mbox_x = 8;
	} else {
		var _t = variable_struct_exists(msg, "text") ? msg.text : "";
		var _tw = string_width(_t);
		mbox_w = max(48, ceil((_tw + 20) / 8) * 8);
		mbox_x = floor((320 - mbox_w) / 2);
	}
	
	draw_sprite_stretched(sBasicGUI, 0, mbox_x, mbox_y, mbox_w, mbox_h);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	if (msg.kind == "levelup") {
		draw_text(mbox_x + 10, mbox_y + 6, msg.name + " reached level " + string(msg.after.level) + "!");

		
		//stat lines: before-> after, two columns of three
		
		var b = msg.before;
		var a = msg.after;
		var col1_x = mbox_x + 10;
		var col2_x = mbox_x + 158;
		var row_y = mbox_y + 18;
		var row_h = 11;
	
		draw_text(col1_x, row_y + row_h * 0, "HP "	+ string(b.max_hp)	+ " > " + string(a.max_hp));
		draw_text(col1_x, row_y + row_h * 1, "MP "	+ string(b.max_mp)	+ " > " + string(a.max_mp));
		draw_text(col1_x, row_y + row_h * 2, "Atk "	+ string(b.atk)			+ " > " + string(a.atk));
	    draw_text(col2_x, row_y + row_h * 0, "Def "	+ string(b.def)			+ " > " + string(a.def));
	    draw_text(col2_x, row_y + row_h * 1, "Spd "	+ string(b.spd)			+ " > " + string(a.spd));
	    draw_text(col2_x, row_y + row_h * 2, "Mntl "	+ string(b.mental)		+ " > " + string(a.mental));
	} else{
		var _t2 = variable_struct_exists(msg, "text") ? msg.text : "";
		draw_set_halign(fa_center);
		draw_text(mbox_x + mbox_w / 2, mbox_y + 8, _t2);
		draw_set_halign(fa_left);
	}
	
	//blinking talk cursor botright
	var _blink_on = (blink_timer mod 40) < 20;
	draw_sprite(_blink_on ? sTalk : sTalkBlink, 0, mbox_x + mbox_w - 12, mbox_y + mbox_h - 8);
}