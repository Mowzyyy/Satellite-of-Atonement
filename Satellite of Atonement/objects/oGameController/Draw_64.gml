draw_set_font(ftDefault);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(c_white);

if (global.transition_alpha > 0) {
	draw_set_alpha(global.transition_alpha);
	draw_set_color(c_black);
	draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

if (global.is_restarting) exit;

//============================Global Menu GUI============================
if (global.state == GAME_STATE.IN_GAME_MENU) {
	//draw the 6 cards
	for (var i = 0; i < 6; i++) {
		var cx = global.card_positions[i].x;
		var cy = global.card_positions[i].y;
		
		//draw 9-slice card bg
		draw_sprite_stretched(sBasicGUI, 0, cx, cy, global.card_w, global.card_h);
	}
		

	//only draw if the main menu list is on the MAIN page
	//middle cards: menu list split vertically
	if (global.menu_page == MENU_PAGE.MAIN) {
		var top_middle = global.card_positions[1];//top middle card
		var bot_middle = global.card_positions[4];//bottom middle card
		
		//top middle: first 4 options
		for (var i = 0; i < 5; i++) {
			var col = (menu_cursor == i) ? c_yellow : c_white;
			var _y = top_middle.y + 12 + (i * 20);
			draw_text_color(top_middle.x + 8 + 12, _y, global.menu_list[i], col, col, col, col, 1);
		}
		
		//bottom middle card: remaining 5 options
		for (var i = 5; i < 10; i++) {
			var col = (menu_cursor == i) ? c_yellow : c_white;
			var _y = bot_middle.y + 12 + ((i-5) * 20);
			draw_text_color(bot_middle.x + 8 + 12, _y, global.menu_list[i], col, col, col, col, 1);
		}
		
		//blinking cursor on the active options
		var cursor_card = (menu_cursor < 5) ? global.card_positions[1] : global.card_positions[4];
		var line_in_card = (menu_cursor < 5) ? menu_cursor : menu_cursor - 5;
		var cursor_y = cursor_card.y + 12 + (line_in_card * 20);
	
		//keep the cursor 4 pixels to the left of content
		var text_x = cursor_card.x + 12 + 12;//matches the text x position
		var cursor_x = text_x - 8 - 8; //4 px left of text with 8px offset
		
		var _blink_on = (blink_timer mod 40) < 20;
		var _cursor_spr = _blink_on ? sCursor : sBlink;
		draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
	}
		
		//SHOW SIDE CARDS - Character portraits and basic stats on Main Menu Screen
		var _show_side_cards = false;
		if (global.menu_page == MENU_PAGE.MAIN) _show_side_cards = true;
		if (global.menu_page == MENU_PAGE.INVENTORY && global.inventory_state == INVENTORY_STATE.SELECT_WHO) _show_side_cards = true;
		if (global.menu_page == MENU_PAGE.INVENTORY && global.inventory_state == INVENTORY_STATE.SELECT_ACTION) _show_side_cards = true;
		if (global.menu_page == MENU_PAGE.INVENTORY && global.inventory_state == INVENTORY_STATE.SELECT_TARGET) _show_side_cards = true;
		if (global.menu_page == MENU_PAGE.INVENTORY && global.inventory_state == INVENTORY_STATE.SELECT_GIVE_TARGET) _show_side_cards = true;
		if (global.menu_page == MENU_PAGE.STATS && global.stats_state == STATS_STATE.SELECT_WHO) _show_side_cards = true;
		if (global.menu_page == MENU_PAGE.EQUIP && global.equip_state == EQUIP_STATE.SELECT_WHO) _show_side_cards = true;
		if (global.menu_page == MENU_PAGE.SKILLS && global.skill_state == SKILL_STATE.SELECT_WHO) _show_side_cards = true;
		if (global.menu_page == MENU_PAGE.SKILLS && global.skill_state == SKILL_STATE.SELECT_TARGET) _show_side_cards = true;
		
	//side cards - party members
	if (_show_side_cards) {
		for (var p = 0; p <  array_length(global.partyOrder); p++) {
			var party_obj = global.partyOrder[p];
			var member = global.party[p];
			var stats = member.get_effective_stats();
			var card_idx = global.party_card_map[p];
			var c = global.card_positions[card_idx];
			
			var lh = 14;//line height in pixels
			var lpad = 6;//line padding inside card
			
			//portrait at topleft of card
			var portrait_spr = sChatPortDefault;
			if (party_obj == oLeon) portrait_spr = sChatPortLeon;
			if (party_obj == oCoat) portrait_spr = sChatPortCoat;
			if (party_obj == oOsei) portrait_spr = sChatPortOsei;
			if (party_obj == oAnna) portrait_spr = sChatPortAnna;
			if (party_obj == oData) portrait_spr = sChatPortData;
			//draw_sprite(portrait_spr, 0, portrait_cx, bot_mid.y + lpad * 1);
			drawPortraitController(member, portrait_spr, c.x + lpad * 3 + 4, c.y + lpad * 1);
			
			//HP and MP beneath protrait
			var hp_col = member.is_dead ? c_red : c_white;
			draw_set_halign(fa_left);
			draw_set_color(hp_col)
			draw_text(c.x + lpad, c.y + lh * 5 - 6, "H");
			draw_set_halign(fa_right);
			draw_text(c.x + global.card_w - lpad, c.y + lh * 5 - 6, string(member.current_hp) + "/" + string(stats.maxhp));
			draw_set_halign(fa_left);
			draw_text(c.x + lpad, c.y + lh * 6 - 6, "M");
			draw_set_halign(fa_right);
			draw_text(c.x + global.card_w - lpad, c.y + lh * 6 - 6, string(member.current_mana) + "/" + string(stats.max_mana));
			draw_set_color(c_white);
			draw_set_halign(fa_left);
			
			//Name left, level right
			draw_set_halign(fa_left);
			draw_text(c.x + lpad, c.y + lh * 7 - 6, member.name);
			draw_set_halign(fa_right);
			draw_text(c.x + global.card_w - lpad, c.y + lh * 7 - 6, "Lv" + string(member.level));
			draw_set_halign(fa_left);
			
		}
	}
		
//============================INVENTORY SUBMENU DRAWING============================
	if (global.menu_page == MENU_PAGE.INVENTORY) {
		var top_left = global.card_positions[0];
		var top_mid = global.card_positions[1];
		var top_right = global.card_positions[2];
		var bot_left = global.card_positions[3];
		var bot_mid = global.card_positions[4];
		var bot_right = global.card_positions[5];
		var selected_obj = global.partyOrder[global.selected_party];
		var selected_name = get_party_display_name(selected_obj);
		var lh = 14;
		var lpad = 6;
		
	
		switch (global.inventory_state) {
		
			case INVENTORY_STATE.SELECT_WHO:
				//top card: "ITEM" and "WHOSE?"
				draw_set_halign(fa_center);
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 1, "ITEM");
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, "Whose?");
				draw_set_halign(fa_left);
		
				//bottom card: party member list
				for (var i_inv = 0; i_inv < array_length(global.partyOrder); i_inv++) {
					var col = (menu_cursor == i_inv) ? c_yellow : c_white;
					draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i_inv*20), get_party_display_name(global.partyOrder[i_inv]), col, col, col, col, 1);
				}
			
				//blinking cursor
				var cursor_y = bot_mid.y + 20 + (menu_cursor * 20);
				var cursor_x = bot_mid.x + 24 -12;//12 pixels left of text
				var _blink_on = (blink_timer mod 40) < 20;
				var _cursor_spr = _blink_on ? sCursor : sBlink;
				draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
			break;
			
			case INVENTORY_STATE.SELECT_ITEM:
				// Top middle prompt
				draw_set_halign(fa_center);
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 1, "ITEM");
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, selected_name);
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 3, "What?");
				draw_set_halign(fa_left);

				// 4 cards in fixed order: top-left, bottom-left, top-right, bottom-right
				var inv = global.party[global.selected_party].inventory;
				var inv_size = array_length(inv);
				var cards = [0, 3, 2, 5];
				var items_per_card = 5;

				// Draw static 5 items on each card
				for (var card_idx = 0; card_idx < 4; card_idx++) {
				    var c = global.card_positions[cards[card_idx]];
					for (var i_locinv = 0; i_locinv < items_per_card; i_locinv++) {
						var global_slot = (card_idx * items_per_card) + i_locinv;
						if (global_slot >= inv_size) continue;
						
						//draw all items, display equipped items as blue
						var item_y  = c.y + 12 + (i_locinv * 20);
						var is_eqp  = global.party[global.selected_party].is_equipped(inv[global_slot].name);
						var is_sel  = (menu_cursor == global_slot);
						var r = is_sel ? 255 : (is_eqp ? 100 : 255);
						var g = is_sel ?   255 : (is_eqp ? 100 : 255);
						var b = is_sel ?   0 : (is_eqp ? 255 :   255);
						var item_col = make_color_rgb(r, g, b);
						draw_text_color(c.x + 20, item_y, inv[global_slot].name, item_col, item_col, item_col, item_col, 1);
					}
				}
				
				if (inv_size == 0) {
					draw_set_halign(fa_center);
					draw_text(bot_mid.x + global.card_w / 2, bot_mid.y + 40, "Empty");
					draw_set_halign(fa_left);
				}

				// Blinking cursor jumps card-to-card
				var card_index = floor(menu_cursor / items_per_card);
				var local_i = menu_cursor mod items_per_card;
				var cursor_card = global.card_positions[cards[card_index]];
				var cursor_y = cursor_card.y + 12 + (local_i * 20);
				var cursor_x = cursor_card.x + 8; // 4px left of text
				var _blink_on = (blink_timer mod 40) < 20;
				var _cursor_spr = _blink_on ? sCursor : sBlink;
				draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
			break;
				
			case INVENTORY_STATE.SELECT_ACTION:
				//Get name of item and display where "ITEM" once was
				var sel_inv = global.party[global.selected_party].inventory;
				var sel_item_name = (global.selected_item < array_length(sel_inv)) ? sel_inv[global.selected_item].name : "???";
				draw_set_color(c_yellow);
				draw_set_halign(fa_center);
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 1, sel_item_name);
				draw_set_color(c_white);
				
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, selected_name);
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 3, "What?");
				draw_set_halign(fa_left);
				
				
				var actions = ["Use", "Give", "Toss"];
				for (var i_act = 0; i_act < 3; i_act++) {
					var col = (menu_cursor == i_act) ? c_yellow : c_white;
					var action_y = bot_mid.y + 20 + (i_act * 20);
					draw_text_color(bot_mid.x + 24, action_y, actions[i_act], col, col, col, col, 1);
				}
				
				//blinking cursor
				var cursor_y = bot_mid.y + 20 + (menu_cursor * 20);
				var cursor_x = bot_mid.x + 12;//12 pixels left of text
				var _blink_on = (blink_timer mod 40) < 20;
				var _cursor_spr = _blink_on ? sCursor : sBlink;
				draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
			break;
				
			case INVENTORY_STATE.SELECT_TARGET:
			draw_set_halign(fa_center);
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 1, "ITEM");
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, selected_name);
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 3, "On Whom?");
				draw_set_halign(fa_left);
					
				for (var i_invtsel = 0; i_invtsel < array_length(global.partyOrder); i_invtsel++) {
					var col = (menu_cursor == i_invtsel) ? c_yellow : c_white;
					var name_y = bot_mid.y + 20 + (i_invtsel * 20);
					draw_text_color(bot_mid.x + 24, name_y, get_party_display_name(global.partyOrder[i_invtsel]), col, col, col, col, 1);
				}
				
				//blinking cursor
				var cursor_y = bot_mid.y + 20 + (menu_cursor * 20);
				var cursor_x = bot_mid.x + 24 -12;//12 pixels left of text
				var _blink_on = (blink_timer mod 40) < 20;
				var _cursor_spr = _blink_on ? sCursor : sBlink;
				draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
			break;
			
			case INVENTORY_STATE.SELECT_GIVE_TARGET:
				draw_set_halign(fa_center);
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 1, "ITEM");
				draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, selected_name);
				if (global.inventory_full_msg) {
					draw_set_color(c_red);
					var full_msg = global.party[global.selected_party].is_equipped(
						global.party[global.selected_party].inventory[global.selected_item].name
						) ? "EQP'D!" : "FULL!";
					draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 3, full_msg);
					draw_set_color(c_white);
				} else {
					draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 3, "To Whom?")
				}
				draw_set_halign(fa_left);
				
				for (var i_give = 0; i_give < array_length(global.partyOrder); i_give++) {
					//grey out the giver
					var is_giver = (i_give == global.selected_party);
					var col = is_giver ? c_dkgray : ((menu_cursor == i_give) ? c_yellow : c_white);
					draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i_give * 20), get_party_display_name(global.partyOrder[i_give]), col, col, col, col, 1);
				}
				var cursor_y = bot_mid.y + 20 + (menu_cursor * 20);
				var cursor_x = bot_mid.x + 12;
				var _blink_on = (blink_timer mod 40) < 20;
				draw_sprite((_blink_on ? sCursor : sBlink), 0, cursor_x, cursor_y);
				break;
		}
	}
	
	//==============================STATS SUBMENU DRAWING==============================
	if(global.menu_page == MENU_PAGE.STATS) {
	
		var top_left = global.card_positions[0];
		var top_mid = global.card_positions[1];
		var top_right = global.card_positions[2];
		var bot_left = global.card_positions[3];
		var bot_mid = global.card_positions[4];
		var bot_right = global.card_positions[5];
		
		//Line height and left/right apdding used across all cards
		var lh = 14;//line height in pixels
		var lpad = 6;//line padding inside card
		var rpad = global.card_w - 6;//right aligned x inside card
		
		//Top middle card - label
		if(global.stats_state == STATS_STATE.SELECT_WHO) {
			//top-middle - label
			draw_set_halign(fa_center);
			draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh, "STATS");
			draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, "Whose?");
			draw_set_halign(fa_left);
			
			//bottom middle card - party list
			for (var i_stat = 0; i_stat < array_length(global.partyOrder); i_stat++) {
				var col = (global.selected_stat_char == i_stat) ? c_yellow : c_white;
				var name = get_party_display_name(global.partyOrder[i_stat]);
				draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i_stat * 20), name, col, col, col, col, 1);
			}
				//blinking cursor
				var cursor_y = bot_mid.y + 20 + (global.selected_stat_char * 20);
				var cursor_x = bot_mid.x + 24 -12;//12 pixels left of text
				var _blink_on = (blink_timer mod 40) < 20;
				var _cursor_spr = _blink_on ? sCursor : sBlink;
				draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
		}
		
		//View Stats screen page - full 6-card layout for the selected character
		if(global.stats_state == STATS_STATE.VIEW_STATS) {
			var char_idx = global.selected_stat_char;
			var member = global.party[char_idx];
			var stats = member.get_effective_stats();
			
			//top mid card - title name money
			draw_set_halign(fa_center);
			var mid_cx = top_mid.x + global.card_w / 2;
			draw_text(mid_cx, top_mid.y + lh * 1, "Stats");
			draw_text(mid_cx, top_mid.y + lh * 2, member.name);
			draw_set_halign(fa_left);
			draw_text(top_mid.x + lpad, top_mid.y + lh * 5, "MONEY");
			draw_set_halign(fa_right);
			draw_text(top_mid.x + rpad, top_mid.y + lh * 6, string(global.money));
			draw_set_halign(fa_left);
			
			//top left card - level exp req exp
			draw_text(top_left.x + lpad, top_left.y + lh * 1, "Level");
			draw_set_halign(fa_right);
			draw_text(top_left.x + rpad, top_left.y + lh * 2, string(member.level));
			draw_set_halign(fa_left);
			draw_text(top_left.x + lpad, top_left.y + lh * 3, "EXP");
			draw_set_halign(fa_right);
			draw_text(top_left.x + rpad, top_left.y + lh * 4, string (member.experience));
			draw_set_halign(fa_left);
			draw_text(top_left.x + lpad, top_left.y + lh * 5, "Req EXP");
			draw_set_halign(fa_right);
			draw_text(top_left.x + rpad, top_left.y + lh * 6, string(member.exp_to_lvup));
			draw_set_halign(fa_left);
			
			//bot left card - spd atk def
			draw_text(bot_left.x + lpad, bot_left.y + lh * 1, "Speed");
			draw_set_halign(fa_right);
			draw_text(bot_left.x + rpad, bot_left.y + lh * 2, string(stats.spd));
			draw_set_halign(fa_left);
			draw_text(bot_left.x + lpad, bot_left.y + lh * 3, "Attack");
			draw_set_halign(fa_right);
			draw_text(bot_left.x + rpad, bot_left.y + lh * 4, string(stats.atk));
			draw_set_halign(fa_left);
			draw_text(bot_left.x + lpad, bot_left.y + lh * 5, "Defense");
			draw_set_halign(fa_right);
			draw_text(bot_left.x + rpad, bot_left.y + lh * 6, string(stats.def));
			draw_set_halign(fa_left);
			
			//top right card - mental matk mdef
			draw_text(top_right.x + lpad, top_right.y + lh * 1, "Mental");
			draw_set_halign(fa_right);
			draw_text(top_right.x + rpad, top_right.y + lh * 2, string(stats.mental));
			draw_set_halign(fa_left);
			draw_text(top_right.x + lpad, top_right.y + lh * 3, "M. Atk");
			draw_set_halign(fa_right);
			draw_text(top_right.x + rpad, top_right.y + lh * 4, string(stats.mAtk));
			draw_set_halign(fa_left);
			draw_text(top_right.x + lpad, top_right.y + lh * 5, "M. Def");
			draw_set_halign(fa_right);
			draw_text(top_right.x + rpad, top_right.y + lh * 6, string(stats.mDef));
			draw_set_halign(fa_left);
			
			//bot right card - bio age species
			draw_set_halign(fa_center);
			draw_text(bot_right.x + global.card_w / 2, bot_right.y + lh * 1, member.bio);
			draw_set_halign(fa_left);
			draw_text(bot_right.x + lpad, bot_right.y + lh * 3, "Age");
			draw_set_halign(fa_right);
			draw_text(bot_right.x + rpad, bot_right.y + lh * 4, string(member.age));
			draw_set_halign(fa_left);
			draw_text(bot_right.x + lpad, bot_right.y + lh * 5, "Species");
			draw_set_halign(fa_right);
			draw_text(bot_right.x + rpad, bot_right.y + lh * 6, member.species);
			draw_set_halign(fa_left);
			
			//bot m id - portrait + hp mp name level
			
			//portrait centered at top of card
			var portrait_cx = bot_mid.x + lpad * 2;
			//swap in per-character portrait sprites when they're made, fallback to default sPortraitDefault
			var portrait_spr = sPortraitDefault;
			if (global.partyOrder[char_idx] == oLeon) portrait_spr = sPortraitLeon;
			if (global.partyOrder[char_idx] == oCoat) portrait_spr = sPortraitCoat;
			if (global.partyOrder[char_idx] == oOsei) portrait_spr = sPortraitOsei;
			if (global.partyOrder[char_idx] == oAnna) portrait_spr = sPortraitAnna;
			if (global.partyOrder[char_idx] == oData) portrait_spr = sPortraitData;
			drawPortraitController(member, portrait_spr, portrait_cx, bot_mid.y + lpad * 1);
			
			//hp and mp beneath portrait
			draw_set_halign(fa_left);
			draw_text(bot_mid.x + lpad, bot_mid.y + lh * 6 - 6, "H");
			draw_set_halign(fa_right);
			draw_text(bot_mid.x + global.card_w - lpad, bot_mid.y + lh * 6 - 6, string(member.current_hp) + "/" + string(stats.maxhp));
			draw_set_halign(fa_left);
			draw_text(bot_mid.x +lpad, bot_mid.y + lh * 7 - 6, "M");
			draw_set_halign(fa_right);
			draw_text(bot_mid.x + global.card_w - lpad, bot_mid.y + lh * 7 - 6, string(member.current_mana) + "/" + string(stats.max_mana));
			draw_set_halign(fa_left);
		}
	
	}
	
	//==============================QUIT SUBMENU DRAWING==============================
	if (global.menu_page == MENU_PAGE.QUIT) {
		var top_left = global.card_positions[0];
		var top_mid = global.card_positions[1];
		var top_right = global.card_positions[2];
		var bot_left = global.card_positions[3];
		var bot_mid = global.card_positions[4];
		var bot_right = global.card_positions[5];
		var lh = 14;
		
		//top middle - prompt
		draw_set_halign(fa_center);
		draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, "Quit");
		draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 3, "Game?");
		draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 5, "RETURNS");
		draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 6, "TO TITLE");
		draw_set_halign(fa_left);
		
		//warning text spread across the four sidecards
		draw_set_halign(fa_center);
		draw_text(top_left.x + global.card_w / 2, top_left.y + lh * 3, "UNSAVED");
		draw_text(top_right.x + global.card_w / 2, top_right.y + lh * 3, "PROGRESS");
		draw_text(bot_left.x + global.card_w / 2, bot_left.y + lh * 3, "WILL BE");
		draw_text(bot_right.x + global.card_w / 2, bot_right.y + lh * 3, "LOST!!!");
		draw_set_halign(fa_left);
		
		//botmid no/yes
		var quit_opts = ["No", "Yes"];
		for (var i_quit = 0; i_quit < 2; i_quit++) {
			var col = (menu_cursor == i_quit) ? c_yellow : c_white;
			draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i_quit * 20), quit_opts[i_quit], col, col, col, col, 1);
		}
		
		//blinking cursor
				var cursor_y = bot_mid.y + 20 + (menu_cursor * 20);
				var cursor_x = bot_mid.x + 24 -12;//12 pixels left of text
				var _blink_on = (blink_timer mod 40) < 20;
				var _cursor_spr = _blink_on ? sCursor : sBlink;
				draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
	}
	
	//reset draw settings
	draw_set_halign(fa_left);
	draw_set_valign(fa_center);
	draw_set_color(c_white);
}
//==============================ORDER SUBMENU DRAWING==============================
if (global.menu_page == MENU_PAGE.ORDER) {
	var top_left = global.card_positions[0];
	var top_mid = global.card_positions[1];
	var top_right = global.card_positions[2];
	var bot_left = global.card_positions[3];
	var bot_mid = global.card_positions[4];
	var bot_right = global.card_positions[5];
		
	//Line height and left/right apdding used across all cards
	var lh = 14;//line height in pixels
	var lpad = 6;//line padding inside card
	var rpad = global.card_w - 6;//right aligned x inside card
	
	//top mid - party order header - shows okay when full
	draw_set_halign(fa_center);
	var mid_cx = top_mid.x + global.card_w / 2;
	draw_text(mid_cx, top_mid.y + lh * 1, "PARTY");
	draw_text(mid_cx, top_mid.y + lh * 2, "ORDER");
	if (global.order_state == ORDER_STATE.CONFIRM) {
		draw_text(mid_cx, top_mid.y + lh * 5, "OKAY?");
	}
	draw_set_halign(fa_left);
	
	//topleft - current order
	draw_set_halign(fa_center);
	draw_text(top_left.x + global.card_w / 2, top_left.y + lh * 1, "CURRENT");
	draw_set_halign(fa_left);
	for (var i_ord = 0; i_ord < array_length(global.partyOrder); i_ord++) {
		var name_cur = get_party_display_name(global.partyOrder[i_ord]);
		draw_text(top_left.x + lpad, top_left.y + lh * (2 + i_ord), string(i_ord + 1));
		draw_set_halign(fa_right);
		draw_text(top_left.x + global.card_w - lpad, top_left.y + lh * (2 + i_ord), name_cur);
		draw_set_halign(fa_left);
	}
	
	//topright - new order being built
	draw_set_halign(fa_center);
	draw_text(top_right.x + global.card_w / 2, top_right.y + lh * 1, "NEW");
	draw_set_halign(fa_left);
	for (var i_new = 0; i_new < array_length(global.partyOrder); i_new++) {
		draw_text(top_right.x + lpad, top_right.y + lh * (2 + i_new), string(i_new + 1));
		draw_set_halign(fa_right);
		if (i_new < array_length(global.order_new)) {
			draw_text(top_right.x + global.card_w - lpad, top_right.y + lh * ( 2 + i_new), get_party_display_name(global.order_new[i_new]));
		}
		draw_set_halign(fa_left);
	}
	
	//build available list for botmid and botleft preview
	var i_availDraw = 0;
	var availableDraw = [];
	for (var i_ord = 0; i_ord < array_length(global.partyOrder); i_ord++) {
		var placed = false;
		for (var j_avail = 0; j_avail < array_length(global.order_new); j_avail++) {
			if (global.order_new[j_avail] == global.partyOrder[i_ord]) {
				placed = true;
				break;
			}
		}
		if (!placed) array_push(availableDraw, global.partyOrder[i_ord]);
	}
	var num_availDraw = array_length(availableDraw);
	
	//botmid - available party list or yesno
	if (global.order_state == ORDER_STATE.SELECT) {
		for (var i_sel = 0; i_sel < num_availDraw; i_sel++) {
			var col = (menu_cursor == i_sel) ? c_yellow : c_white;
			var name_avail = get_party_display_name(availableDraw[i_sel]);
			draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i_sel * 20), name_avail, col, col, col, col, 1);
		}
		
		//blinking cursor
		var cursor_y = bot_mid.y + 20 + (menu_cursor * 20);
		var cursor_x = bot_mid.x + 24 -12;//12 pixels left of text
		var _blink_on = (blink_timer mod 40) < 20;
		var _cursor_spr = _blink_on ? sCursor : sBlink;
		draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
				
		//botleft - portrait preview of highlighted char
		if (num_availDraw > 0) {
			menu_cursor = clamp(menu_cursor, 0, num_availDraw - 1);
			var preview_obj = availableDraw[menu_cursor];
			//find matching party struct
			var preview_member = global.party[0];
			for (var i_pm = 0; i_pm < array_length(global.partyOrder); i_pm++) {
				if (global.partyOrder[i_pm] == preview_obj) {
					preview_member = global.party[i_pm];
					break;
				}
			}
			var preview_stats = preview_member.get_effective_stats();
			
			//portrait topleft of card
			var prev_portrait = sPortraitDefault;
			if (preview_obj == oLeon) prev_portrait = sChatPortLeon;
			if (preview_obj == oCoat) prev_portrait = sChatPortCoat;
			if (preview_obj == oOsei) prev_portrait = sChatPortOsei;
			if (preview_obj == oAnna) prev_portrait = sChatPortAnna;
			if (preview_obj == oData) prev_portrait = sChatPortData;
			drawPortraitController(preview_member, prev_portrait, bot_left.x + lpad * 3 + 4, bot_left.y + lpad * 1);
			
			//HP, MP, name, level matching main pause menu layout
			draw_set_halign(fa_left);
			draw_text(bot_left.x + lpad, bot_left.y + lh * 5 - 6, "H");
			draw_set_halign(fa_right);
			draw_text(bot_left.x + global.card_w - lpad, bot_left.y + lh * 5 - 6, string(preview_member.current_hp) + "/" + string(preview_stats.maxhp));
			draw_set_halign(fa_left);
			draw_text(bot_left.x + lpad, bot_left.y + lh * 6 - 6, "M");
			draw_set_halign(fa_right);
			draw_text(bot_left.x + global.card_w - lpad, bot_left.y + lh * 6 - 6, string(preview_member.current_mana) + "/" + string(preview_stats.max_mana));
			//Name left, level right
			draw_set_halign(fa_left);
			draw_text(bot_left.x + lpad, bot_left.y + lh * 7 - 6, preview_member.name);
			draw_set_halign(fa_right);
			draw_text(bot_left.x + global.card_w - lpad, bot_left.y + lh * 7 - 6, "Lv" + string(preview_member.level));
			draw_set_halign(fa_left);
		}
	}
	
	if (global.order_state == ORDER_STATE.CONFIRM) {
		var confirm_opts = ["No", "Yes"];
		for (var i_conf = 0; i_conf < 2; i_conf++) {
			var col = (global.order_confirm_cursor == i_conf) ? c_yellow : c_white;
			draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i_conf * 20), confirm_opts[i_conf], col, col, col, col, 1);
		}
		var cursor_y = bot_mid.y + 20 + (global.order_confirm_cursor * 20);
		var cursor_x = bot_mid.x + 12;
		var _blink_on = (blink_timer mod 40) < 20;
		draw_sprite((_blink_on ? sCursor : sBlink), 0, cursor_x, cursor_y);
	}
	
	//botright - overworld sprites stacked vertically as selected
	for (var i_spr = array_length(global.order_new) - 1; i_spr >=0 ; i_spr--) {
		var spr_obj = global.order_new[i_spr];
		var spr_to_draw = -1;
		if (instance_exists(spr_obj)) spr_to_draw = instance_find(spr_obj, 0).sprite_index;
		if (spr_to_draw != -1) {
			draw_sprite_ext(spr_to_draw, 3, bot_right.x + global.card_w / 2 - 8, bot_right.y + lh * 7 - 6 - (i_spr * 18) - 16, 1, 1, 0, c_white, 1);
		}
	}
}

//================================EQUIP SUBMENU DRAWING================================
if (global.menu_page == MENU_PAGE.EQUIP) {
	var top_left = global.card_positions[0];
	var top_mid = global.card_positions[1];
	var top_right = global.card_positions[2];
	var bot_left = global.card_positions[3];
	var bot_mid = global.card_positions[4];
	var bot_right = global.card_positions[5];
	var lh = 14;
	var lpad = 6;
	var rpad = global.card_w - 6;
	
	//topmid - equip header
	draw_set_halign(fa_center);
	draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 1, "EQUIP");
	draw_set_halign(fa_left);
	
	//select WHO
	if (global.equip_state == EQUIP_STATE.SELECT_WHO) {
		draw_set_halign(fa_center);
		draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, "Who?");
		draw_set_halign(fa_left);
		
		for (var i_eq = 0; i_eq < array_length(global.partyOrder); i_eq++) {
			var col = (global.equip_char == i_eq) ? c_yellow : c_white;
			draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i_eq * 20), get_party_display_name(global.partyOrder[i_eq]), col, col, col, col, 1);
		}
		var cursor_y = bot_mid.y + 20 + (global.equip_char * 20);
		var cursor_x = bot_mid.x + 12;
		var _blink_on = (blink_timer mod 40) < 20;
		draw_sprite((_blink_on ? sCursor : sBlink), 0, cursor_x, cursor_y);
	}
	
	//SELECT_SLOT and SELECT_HAND
	if (global.equip_state == EQUIP_STATE.SELECT_SLOT || global.equip_state == EQUIP_STATE.SELECT_HAND) {
		var member = global.party[global.equip_char];
		var stats = member.get_effective_stats();
		
		//topmid - character name and What? prompt
		draw_set_halign(fa_center);
		draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, member.name);
		draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 3, "What?");
		draw_set_halign(fa_left);
		
		//topleft - head, rhand, lhand
		var r_col = c_white;
		var l_col = c_white;
		if (global.equip_state == EQUIP_STATE.SELECT_HAND) {
			r_col = (global.equip_hand_cursor == 0) ? c_yellow : c_white;
			l_col = (global.equip_hand_cursor == 1) ? c_yellow : c_white;
			//blinking cursor on selected hand
			var hand_line = (global.equip_hand_cursor == 0) ? 4 : 6;
			var hand_cur_y = top_left.y + lh * hand_line;
			var _blink_on = (blink_timer mod 40) < 20;
			draw_sprite((_blink_on ? sCursor : sBlink), 0, top_left.x, hand_cur_y);
		}
		
		draw_text(top_left.x + lpad, top_left.y + lh * 1, "Head");
		draw_set_halign(fa_right);
		draw_text(top_left.x + rpad, top_left.y + lh * 2, member.head.name == "No Item" ? "" : member.head.name);
		draw_set_halign(fa_left);
		
		draw_text_color(top_left.x + lpad, top_left.y + lh * 3, "R Hand", r_col, r_col, r_col, r_col, 1);
		draw_set_halign(fa_right);
		draw_text_color(top_left.x + rpad, top_left.y + lh * 4, member.r_Hand.name == "No Item" ? "" : member.r_Hand.name, r_col, r_col, r_col, r_col, 1);
		draw_set_halign(fa_left);
		
		draw_text_color(top_left.x + lpad, top_left.y + lh * 5, "L Hand", l_col, l_col, l_col, l_col, 1);
		draw_set_halign(fa_right);
		draw_text_color(top_left.x + rpad, top_left.y + lh * 6, member.l_Hand.name == "No Item" ? "" : member.l_Hand.name, l_col, l_col, l_col, l_col, 1);
		draw_set_halign(fa_left);
		
		//botleft - torso/feet/accessory
		draw_text(bot_left.x + lpad, bot_left.y + lh * 1, "Torso");
		draw_set_halign(fa_right);
		draw_text(bot_left.x + rpad, bot_left.y + lh * 2, member.body.name == "No Item" ? "" : member.body.name);
		draw_set_halign(fa_left);
		
		draw_text(bot_left.x + lpad, bot_left.y + lh * 3, "Feet");
		draw_set_halign(fa_right);
		draw_text(bot_left.x + rpad, bot_left.y + lh * 4, member.feet.name == "No Item" ? "" : member.feet.name);
		draw_set_halign(fa_left);
		
		draw_text(bot_left.x + lpad, bot_left.y + lh * 5, "Artifact");
		draw_set_halign(fa_right);
		draw_text(bot_left.x + rpad, bot_left.y + lh * 6, member.accessory.name == "No Item" ? "" : member.accessory.name);
		draw_set_halign(fa_left);
		
		//bot-right - live stats
		var stat_labels = ["Atk", "Def", "Spd", "Mntl", "mAtk", "mDef"];
		var stat_values = [stats.atk, stats.def, stats.spd, stats.mental, stats.mAtk, stats.mDef];
		for (var i_st = 0; i_st < 6; i_st++) {
			draw_set_halign(fa_left);
			draw_text(bot_right.x + lpad, bot_right.y + lh * (1 + i_st), stat_labels[i_st]);
			draw_set_halign(fa_right);
			draw_text(bot_right.x + rpad, bot_right.y + lh * (1 + i_st), string(stat_values[i_st]));
		}
		draw_set_halign(fa_left);	
		//botmid - character portrait
		var portrait_spr = sChatPortDefault;
		var p_obj = global.partyOrder[global.equip_char];
		if (p_obj == oLeon) portrait_spr = sChatPortLeon;
		if (p_obj == oCoat) portrait_spr = sChatPortCoat;
		if (p_obj == oOsei) portrait_spr = sChatPortOsei;
		if (p_obj == oAnna) portrait_spr = sChatPortAnna;
		if (p_obj == oData) portrait_spr = sChatPortData;
		drawPortraitController(member, portrait_spr, bot_mid.x + lpad * 3 + 4, bot_mid.y + lpad * 1);
		draw_set_halign(fa_left);
		draw_text(bot_mid.x + lpad, bot_mid.y + lh * 5 - 6, "H");
		draw_set_halign(fa_right);
		draw_text(bot_mid.x + global.card_w - lpad, bot_mid.y + lh * 5 - 6, string(member.current_hp) + "/" + string(stats.maxhp));
		draw_set_halign(fa_left);
		draw_text(bot_mid.x + lpad, bot_mid.y + lh * 6 - 6, "M");
		draw_set_halign(fa_right);
		draw_text(bot_mid.x + global.card_w - lpad, bot_mid.y + lh * 6 - 6, string(member.current_mana) + "/" + string(stats.max_mana));
		draw_set_halign(fa_left);
		draw_text(bot_mid.x + lpad, bot_mid.y + lh * 7 - 6, member.name);
		draw_set_halign(fa_right);
		draw_text(bot_mid.x + global.card_w - lpad, bot_mid.y + lh * 7 - 6, "Lv" + string(member.level));
		draw_set_halign(fa_left);
		
		//topright - scrollable equipment inventory
		if (global.equip_state == EQUIP_STATE.SELECT_SLOT) {
			var equip_list = scrEquipBuildList(global.equip_char);
			var list_size  = array_length(equip_list);
			var page_start = global.equip_scroll_page * 5;
			var has_next   = (page_start + 5) < list_size;
			var is_last_page = !has_next && page_start > 0;
			var show_next = has_next || is_last_page;
			
			//line 1 - shows NEXT if there are more pages
			if (list_size == 0) {
				//nothing to equip, show message
				draw_set_halign(fa_center);
				draw_text(top_right.x + global.card_w / 2, top_right.y + lh * 2, "Nothing");
				draw_text(top_right.x + global.card_w / 2, top_right.y + lh * 3, "To");
				draw_text(top_right.x + global.card_w / 2, top_right.y + lh * 4, "Equip");
				draw_set_halign(fa_left);
			} else {
				if (show_next) {
					var next_label = is_last_page ? "*FIRST*" : "*NEXT*";
					var next_col = (global.equip_cursor == 0) ? c_yellow : c_white;
					draw_text_color(top_right.x + lpad + 12, top_right.y + lh * 1, next_label, next_col, next_col, next_col, next_col, 1);
				}
			
				//lines 2-6 items 
				for (var i_ep = 0; i_ep < 5; i_ep++) {
					var slot_idx = page_start + i_ep;
					if (slot_idx >= list_size) break;
					var entry = equip_list[slot_idx];
					var item = entry.item;
					var is_eqp = member.is_equipped(item.name);
					var line_y = top_right.y + lh * (2 + i_ep);
					var cursor_i = show_next ? i_ep + 1 : i_ep;
					var is_sel = (global.equip_cursor == cursor_i);
				
					var r = is_eqp ? 100 : (is_sel ? 255 : 255);
					var g = is_eqp ? 100 : (is_sel ? 255 : 255);
					var b = is_eqp ? 255 : (is_sel ?   0 : 255);
					var item_col = make_color_rgb(r, g, b);
					draw_text_color(top_right.x + lpad + 12, line_y, item.name, item_col, item_col, item_col, item_col, 1);
				}
			
				//blinking cursor topright
				var cur_line  = show_next ? global.equip_cursor + 1 : global.equip_cursor + 2;
				var cur_y      = top_right.y + lh * cur_line;
				var _blink_on  = (blink_timer mod 40) < 20;
				draw_sprite((_blink_on ? sCursor : sBlink), 0, top_right.x + lpad, cur_y);
			}
		}
	}
}

//============================SAVEGAME SUBMENU DRAWING============================
if (global.menu_page == MENU_PAGE.SAVE) {
	var top_left = global.card_positions[0];
	var top_mid = global.card_positions[1];
	var top_right = global.card_positions[2];
	var bot_left = global.card_positions[3];
	var bot_mid = global.card_positions[4];
	var bot_right = global.card_positions[5];
	var lh = 14;
	var lpad = 6;
	var rpad = global.card_w - 6;
	
	var leader = global.party[0];
	var num_party = array_length(global.party);
	
	//topleft - playtime/money/leader
	draw_set_halign(fa_left);
	draw_text(top_left.x + lpad, top_left.y + lh * 1, "Playtime");
	draw_set_halign(fa_right);
	draw_text(top_left.x + rpad, top_left.y + lh * 2, format_playtime(global.playtime));
	draw_set_halign(fa_left);
	draw_text(top_left.x + lpad, top_left.y + lh * 3, "Money");
	draw_set_halign(fa_right);
	draw_text(top_left.x + rpad, top_left.y + lh * 4, string(global.money));
	draw_set_halign(fa_left);
	draw_text(top_left.x + lpad, top_left.y + lh * 5, leader.name);
	draw_set_halign(fa_right);
	draw_text(top_left.x + rpad, top_left.y + lh * 6, "Lv " + string(leader.level));
	draw_set_halign(fa_left);
	
	//topmid - save game? warning saved
	draw_set_halign(fa_center);
	var mid_cx = top_mid.x + global.card_w / 2;

	if (global.save_just_saved) {
		draw_text(mid_cx, top_mid.y + lh * 1, "SAVE");
		draw_text(mid_cx, top_mid.y + lh * 2, "GAME?");
		draw_set_color(c_lime);
		draw_text(mid_cx, top_mid.y + lh * 4, "SAVED!");
		draw_set_color(c_white);
	} else if (global.save_state == SAVE_STATE.CONFIRM_OVERWRITE) {
		draw_set_color(c_red);
		draw_text(mid_cx, top_mid.y + lh * 1, "WARNING!");
		draw_set_color(c_white);
		draw_text(mid_cx, top_mid.y + lh * 2, "Over-");
		draw_text(mid_cx, top_mid.y + lh * 3, "Write");
		draw_text(mid_cx, top_mid.y + lh * 4, "Save?");
		draw_set_color(c_red);
		draw_text(mid_cx, top_mid.y + lh * 6, "PERMANENT");
		draw_set_color(c_white);
	} else {
		draw_text(mid_cx, top_mid.y + lh * 1, "SAVE");
		draw_text(mid_cx, top_mid.y + lh * 2, "GAME?");
	}
	draw_set_halign(fa_left);
	
	//botleft - party members 2/3/4
	for (var p_bl = 1; p_bl < 4; p_bl++) {
		var line_start = (p_bl - 1) * 2 + 1;
		if (p_bl < num_party) {
			var pm = global.party[p_bl];
			draw_set_halign(fa_left);
			draw_text(bot_left.x + lpad, bot_left.y + lh * line_start, pm.name);
			draw_set_halign(fa_right);
			draw_text(bot_left.x + rpad, bot_left.y + lh * (line_start + 1), "Lv " + string(pm.level));
			draw_set_halign(fa_left);
		}
	}
	
	//topright and botright - slot info across two cards
	var slot_cards = [
		{ card: top_right, start_line: 1 },
		{ card: top_right, start_line: 5 },
		{ card: bot_right, start_line: 3 }
	];
	var slot_overflow = [
		{ card: top_right, lv_line: 3, money_line: 4 },
		{ card: bot_right, lv_line: 1, money_line: 2 },
		{ card: bot_right, lv_line: 4, money_line: 5 }
	];

	for (var sl = 0; sl < 3; sl++) {
		var sc    = slot_cards[sl];
		var so    = slot_overflow[sl];
		var sd    = global.save_slot_cache[sl];
		var is_sel = (global.save_cursor == sl);
		var is_ow  = (global.save_state == SAVE_STATE.CONFIRM_OVERWRITE && is_sel);
		var label_col = is_ow ? c_red : c_white;

		draw_set_halign(fa_left);
		draw_set_color(label_col);
		draw_text(sc.card.x + lpad, sc.card.y + lh * sc.start_line, "Slot " + string(sl + 1));
		draw_set_color(c_white);

		if (sd != undefined) {
			var sd_leader = sd.party[0];
			var name_col  = is_ow ? c_red : c_white;
			draw_set_halign(fa_right);
			draw_set_color(name_col);
			draw_text(sc.card.x + rpad, sc.card.y + lh * (sc.start_line + 1), sd_leader.name);
			draw_text(so.card.x + rpad, so.card.y + lh * so.lv_line, "Lv " + string(sd_leader.level));
			draw_text(so.card.x + rpad, so.card.y + lh * so.money_line, string(sd.money));
			draw_set_color(c_white);
			draw_set_halign(fa_left);
		} else {
			draw_set_halign(fa_right);
			draw_set_color(c_dkgray);
			draw_text(sc.card.x + rpad, sc.card.y + lh * (sc.start_line + 1), "Empty");
			draw_set_color(c_white);
			draw_set_halign(fa_left);
		}
	}

	//botmid - slot selection or overwrite yes/no
	if (global.save_state == SAVE_STATE.CONFIRM_OVERWRITE) {
		var ow_opts = ["No", "Yes"];
		for (var i_ow = 0; i_ow < 2; i_ow++) {
			var col = (global.save_confirm_cursor == i_ow) ? c_yellow : c_white;
			draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i_ow * 20), ow_opts[i_ow], col, col, col, col, 1);
		}
		var cursor_y = bot_mid.y + 20 + (global.save_confirm_cursor * 20);
		var cursor_x = bot_mid.x + 12;
		var _blink_on = (blink_timer mod 40) < 20;
		draw_sprite((_blink_on ? sCursor : sBlink), 0, cursor_x, cursor_y);
	} else {
		for (var i_sl = 0; i_sl < 3; i_sl++) {
			var col = (global.save_cursor == i_sl) ? c_yellow : c_white;
			draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i_sl * 20), "Slot " + string(i_sl + 1), col, col, col, col, 1);
		}
		var cursor_y = bot_mid.y + 20 + (global.save_cursor * 20);
		var cursor_x = bot_mid.x + 12;
		var _blink_on = (blink_timer mod 40) < 20;
		draw_sprite((_blink_on ? sCursor : sBlink), 0, cursor_x, cursor_y);
	}
}
//================================SKILL SUBMENU DRAWING================================
if (global.menu_page == MENU_PAGE.SKILLS) {
	var top_left = global.card_positions[0];
	var top_mid = global.card_positions[1];
	var top_right = global.card_positions[2];
	var bot_left = global.card_positions[3];
	var bot_mid = global.card_positions[4];
	var bot_right = global.card_positions[5];
	var lh = 14;
	var lpad = 6;
	var rpad = global.card_w - 6;
	var cards = [0, 3, 2, 5];
	
	//topmid - skill header
	draw_set_halign(fa_center);
	draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 1, "SKILL");
	draw_set_halign(fa_left);
	
	//select who
	if (global.skill_state == SKILL_STATE.SELECT_WHO) {
		draw_set_halign(fa_center);
		draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, "Who?");
		draw_set_halign(fa_left);
		
		for (var i_sk = 0; i_sk < array_length(global.partyOrder); i_sk++) {
			var col = (global.skill_char == i_sk) ? c_yellow : c_white;
			draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i_sk * 20), get_party_display_name(global.partyOrder[i_sk]), col, col, col, col, 1);
		}
		var cursor_y = bot_mid.y + 20 + (global.skill_char * 20);
		var cursor_x = bot_mid.x + 12;
		var _blink_on = (blink_timer mod 40) < 20;
		draw_sprite((_blink_on ? sCursor : sBlink), 0, cursor_x, cursor_y);
		
		if (global.skill_death_msg_timer > 0) {
			global.skill_death_msg_timer--;
			draw_set_halign(fa_center);
			draw_set_color(c_red);
			draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 4, "Verge");
			draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 5, "Of");
			draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 6, "Death!");
			draw_set_color(c_white);
			draw_set_halign(fa_left);
		}
	}
	
	//select what
	if (global.skill_state == SKILL_STATE.SELECT_WHAT) {
		var member    = global.party[global.skill_char];
		var list      = scrSkillBuildList(global.skill_char);
		var list_size = array_length(list);
		var items_per_card = 5;

		// Top mid: character name
		draw_set_halign(fa_center);
		draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, member.name);

		// Top mid: CANNOT or What?
		if (global.skill_cannot_timer > 0) {
			draw_set_color(c_yellow);
			draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 3, "CANNOT");
			draw_set_color(c_white);
		} else {
			draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 3, "What?");
		}
		draw_set_halign(fa_left);
		
		//ability list across 4 cards
		for (var card_idx = 0; card_idx < 4; card_idx++) {
			var c = global.card_positions[cards[card_idx]];
			for (var i_sl = 0; i_sl < items_per_card; i_sl++) {
				var global_slot = (card_idx * items_per_card) + i_sl;
				if (global_slot >= list_size) continue;
				var entry  = list[global_slot];
				var line_y = c.y + 12 + (i_sl * 20);

				if (entry.kind == "separator") {
					draw_set_color(c_dkgray);
					draw_text(c.x + 8, line_y, entry.label);
					draw_set_color(c_white);
				} else {
					var is_sel = (global.skill_cursor == global_slot);
					var cannot = false;
					if (entry.kind == "spell" && member.current_mana < entry.data.mp_cost) cannot = true;
					if (entry.kind == "skill" && entry.data.uses_left <= 0) cannot = true;
					var r = is_sel ? 255 : (cannot ? 128 : 255);
					var g = is_sel ? 255 : (cannot ?   0 : 255);
					var b = is_sel ?   0 : (cannot ?   0 : 255);
					var col = make_color_rgb(r, g, b);
					draw_text_color(c.x + 12, line_y, entry.label, col, col, col, col, 1);
				}
			}
		}
		
		// Blinking cursor
		if (list_size > 0) {
			var cur_card  = floor(global.skill_cursor / items_per_card);
			var cur_line  = global.skill_cursor mod items_per_card;
			var cur_c     = global.card_positions[cards[cur_card]];
			var cur_y     = cur_c.y + 12 + (cur_line * 20);
			var _blink_on = (blink_timer mod 40) < 20;
			draw_sprite((_blink_on ? sCursor : sBlink), 0, cur_c.x, cur_y);
		}
		
		//botmid 
		var s_stats = member.get_effective_stats();
		if (list_size > 0 && scrSkillCursorSelectable(list, global.skill_cursor)) {
			var entry = list[global.skill_cursor];
			draw_set_halign(fa_left);
			draw_text(bot_mid.x + lpad, bot_mid.y + lh * 1, entry.label);
			if (entry.kind == "spell") {
				draw_text(bot_mid.x + lpad, bot_mid.y + lh * 2, "MP: " + string(entry.data.mp_cost));
			} else {
				draw_text(bot_mid.x + lpad, bot_mid.y + lh * 2, string(entry.data.uses_left) + "/" + string(entry.data.uses_max) + " uses");
			}
			var effect_label = "";
			switch (entry.data.effect_type) {
				case "heal_hp":     effect_label = (entry.data.target_type == "all_allies" || entry.data.target_type == "all_party") ? "Heal All" : "Heals 1"; break;
				case "heal_mp":     effect_label = (entry.data.target_type == "all_allies" || entry.data.target_type == "all_party") ? "Mana All" : "+Mana 1"; break;
				case "damage":      effect_label = (entry.data.target_type == "all_enemies") ? "Dmg All" : "Dmg 1"; break;
				case "cure_status": effect_label = "RmStatus"; break;
				case "buff_stat":   effect_label = "StatBuff"; break;
				case "functional":  effect_label = "Function"; break;
				default:            effect_label = entry.data.effect_type; break;
			}
			draw_text(bot_mid.x + lpad, bot_mid.y + lh * 3, effect_label);
		}
		draw_set_halign(fa_left);
		draw_text(bot_mid.x + lpad, bot_mid.y + lh * 5 - 6, "H");
		draw_set_halign(fa_right);
		draw_text(bot_mid.x + global.card_w - lpad, bot_mid.y + lh * 5 - 6, string(member.current_hp) + "/" + string(s_stats.maxhp));
		draw_set_halign(fa_left);
		draw_text(bot_mid.x + lpad, bot_mid.y + lh * 6 - 6, "M");
		draw_set_halign(fa_right);
		draw_text(bot_mid.x + global.card_w - lpad, bot_mid.y + lh * 6 - 6, string(member.current_mana) + "/" + string(s_stats.max_mana));
		draw_set_halign(fa_left);
		draw_text(bot_mid.x + lpad, bot_mid.y + lh * 7 - 6, member.name);
		draw_set_halign(fa_right);
		draw_text(bot_mid.x + global.card_w - lpad, bot_mid.y + lh * 7 - 6, "Lv" + string(member.level));
		draw_set_halign(fa_left);
	}
	
	//Select target
	if (global.skill_state == SKILL_STATE.SELECT_TARGET) {
		var member = global.party[global.skill_char];

		//topmid
		draw_set_halign(fa_center);
		draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 2, member.name);
		draw_text(top_mid.x + global.card_w / 2, top_mid.y + lh * 3, "On Whom?");
		draw_set_halign(fa_left);
		
		//party list in bot mid
		for (var i_tgt = 0; i_tgt < array_length(global.partyOrder); i_tgt++) {
			var col = (global.skill_target_cursor == i_tgt) ? c_yellow : c_white;
			draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i_tgt * 20), get_party_display_name(global.partyOrder[i_tgt]), col, col, col, col, 1);
		}
		var cursor_y  = bot_mid.y + 20 + (global.skill_target_cursor * 20);
		var _blink_on = (blink_timer mod 40) < 20;
		draw_sprite((_blink_on ? sCursor : sBlink), 0, bot_mid.x + 12, cursor_y);
	}
}