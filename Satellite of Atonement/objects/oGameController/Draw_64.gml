draw_set_font(ftDefault);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(c_white);

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
		if(global.menu_page == MENU_PAGE.STATS && global.stats_state == STATS_STATE.SELECT_WHO) _show_side_cards = true;
		
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
			draw_sprite(portrait_spr, 0, c.x + lpad * 3 + 4, c.y + lpad * 1);
			
			//HP and MP beneath protrait
			draw_text(c.x + lpad, c.y + lh * 5 - 6, "HP " + string(member.current_hp) + "/" + string(stats.maxhp));
			draw_text(c.x +lpad, c.y + lh * 6 - 6, "MP " + string(member.current_mana) + "/" + string(stats.max_mana));
			
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
		var selected_name = get_party_display_name(selected_obj)
		
	
		switch (global.inventory_state) {
		
			case INVENTORY_STATE.SELECT_WHO:
				//top card: "ITEM" and "WHOSE?"
				draw_text(top_mid.x + 24, top_mid.y + 28, "ITEM");
				draw_text(top_mid.x + 24, top_mid.y + 52, "Whose?");
		
				//bottom card: party member list
				for (var i = 0; i < array_length(global.partyOrder); i++) {
					var party_obj = global.partyOrder[i];
					var name = get_party_display_name(party_obj)
					var col = (menu_cursor == i) ? c_yellow : c_white;
					draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i*20), name, col, col, col, col, 1);
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
				draw_text(top_mid.x + 24, top_mid.y + 28, "ITEM");
				draw_text(top_mid.x + 24, top_mid.y + 52, selected_name);
				draw_text(top_mid.x + 24, top_mid.y + 76, "What?");

				// 4 cards in fixed order: top-left, bottom-left, top-right, bottom-right
				var cards = [0, 3, 2, 5];
				var items_per_card = 5;
				var max_items = 20;

				// Draw static 5 items on each card
				for (var card_idx = 0; card_idx < 4; card_idx++) {
				    var c = global.card_positions[cards[card_idx]];
				    for (var local_i = 0; local_i < items_per_card; local_i++) {
				        var global_slot = (card_idx * items_per_card) + local_i;
				        if (global_slot >= max_items) break;

				        var col = (menu_cursor == global_slot) ? c_yellow : c_white;
				        var item_y = c.y + 12 + (local_i * 20);

				        draw_text_color(c.x + 20, item_y, "Potion " + string(global_slot+1), col, col, col, col, 1);
				    }
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
				draw_text(top_mid.x + 24, top_mid.y + 28, "ITEM");
				draw_text(top_mid.x + 24, top_mid.y + 52, selected_name);
				draw_text(top_mid.x + 24, top_mid.y + 76, "What?");
				
				//find which card the selected item was on
				var selected_slot = global.selected_item;
				var items_per_card = 5;
				var card_index = floor(selected_slot / items_per_card);
				var cards = [0, 3, 2, 5];
				var selected_card = global.card_positions[cards[card_index]];
				var local_i = selected_slot mod items_per_card;
				var item_y = selected_card.y + 12 + (local_i * 20);
				
				//Draw only the selected item in its original position
				draw_text_color(selected_card.x + 20, item_y, "Potion", c_yellow, c_yellow, c_yellow, c_yellow, 1);
					
				var actions = ["Use", "Give", "Toss"];
				for (var i = 0; i < 3; i++) {
					var col = (menu_cursor == i) ? c_yellow : c_white;
					var action_y = bot_mid.y + 20 + (i * 20);
					draw_text_color(bot_mid.x + 24, action_y, actions[i], col, col, col, col, 1);
				}
				
				//blinking cursor
				var cursor_y = bot_mid.y + 20 + (menu_cursor * 20);
				var cursor_x = bot_mid.x + 24 -12;//12 pixels left of text
				var _blink_on = (blink_timer mod 40) < 20;
				var _cursor_spr = _blink_on ? sCursor : sBlink;
				draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
			break;
				
			case INVENTORY_STATE.SELECT_TARGET:
				draw_text(top_mid.x + 24, top_mid.y + 28, "ITEM");
				draw_text(top_mid.x + 24, top_mid.y + 52, selected_name);
				draw_text(top_mid.x + 8, top_mid.y + 76, "On Whom?");
					
				for (var i = 0; i < array_length(global.partyOrder); i++) {
					var party_obj = global.partyOrder[i];
					var name = get_party_display_name(party_obj);
					var col = (menu_cursor == i) ? c_yellow : c_white;
					var name_y = bot_mid.y + 20 + (i * 20);
					draw_text_color(bot_mid.x + 24, name_y, name, col, col, col, col, 1);
				}
				
				//blinking cursor
				var cursor_y = bot_mid.y + 20 + (menu_cursor * 20);
				var cursor_x = bot_mid.x + 24 -12;//12 pixels left of text
				var _blink_on = (blink_timer mod 40) < 20;
				var _cursor_spr = _blink_on ? sCursor : sBlink;
				draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
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
			draw_sprite(portrait_spr, 0, portrait_cx, bot_mid.y + lpad * 1);
			
			//hp and mp beneath portrait
			draw_set_halign(fa_left);
			draw_text(bot_mid.x + lpad, bot_mid.y + lh * 6 - 6, "HP " + string(member.current_hp) + "/" + string(stats.maxhp));
			draw_text(bot_mid.x +lpad, bot_mid.y + lh * 7 - 6, "MP " + string(member.current_mana) + "/" + string(stats.max_mana));
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