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
		for (var i = 0; i < 4; i++) {
			var col = (menu_cursor == i) ? c_yellow : c_white;
			var _y = top_middle.y + 20 + (i * 20);
			draw_text_color(top_middle.x + 8 + 12, _y, global.menu_list[i], col, col, col, col, 1);
		}
		
		//bottom middle card: remaining 5 options
		for (var i = 4; i < 9; i++) {
			var col = (menu_cursor == i) ? c_yellow : c_white;
			var _y = bot_middle.y + 12 + ((i-4) * 20);
			draw_text_color(bot_middle.x + 8 + 12, _y, global.menu_list[i], col, col, col, col, 1);
		}
		
		//blinking cursor on the active options
		var cursor_card = (menu_cursor < 4) ? global.card_positions[1] : global.card_positions[4];
		var line_in_card = (menu_cursor < 4) ? menu_cursor : menu_cursor - 4;
		var cursor_y = cursor_card.y + 20 + (line_in_card * 20);
		if (menu_cursor >= 4) {
			cursor_y -= 8;//move 8 pixels higher on bottom card only
		}
	
		//keep the cursor 4 pixels to the left of content
		var text_x = cursor_card.x + 12 + 12;//matches the text x position
		var cursor_x = text_x - 8 - 8; //4 px left of text with 8px offset
		
		var _blink_on = (blink_timer mod 40) < 20;
		var _cursor_spr = _blink_on ? sCursor : sBlink;
		draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
	}
		
	//side cards - party members
	if (global.menu_page != MENU_PAGE.INVENTORY || global.inventory_state == INVENTORY_STATE.SELECT_WHO) {
		for (var p = 0; p <  array_length(global.partyOrder); p++) {
			var party_obj = global.partyOrder[p];
			var name = get_party_display_name(party_obj);

			var card_idx = global.party_card_map[p];//[0, 2, 3, 5]
			var c = global.card_positions[card_idx];
		
			draw_set_halign(fa_center);
			draw_text(c.x + global.card_w/2, c.y + 30, name);
			draw_set_halign(fa_left);
			//later add HP and MP, protraits, etc
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
	//reset draw settings
	draw_set_halign(fa_left);
	draw_set_valign(fa_center);
	draw_set_color(c_white);
}