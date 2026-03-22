//============================Global Menu GUI============================
if (global.state == GAME_STATE.IN_GAME_MENU) {
	//draw the 6 cards
	for (var i = 0; i < 6; i++) {
		var cx = global.card_positions[i].x;
		var cy = global.card_positions[i].y;
		
		//draw 9-slice card bg
		draw_sprite_stretched(sBasicGUI, 0, cx, cy, global.card_w, global.card_h);
	}
		
	//middle cards: menu list split vertically
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
		
	//side cards - party members
	for (var p = 0; p <  array_length(global.partyOrder); p++) {
		var party_obj = global.partyOrder[p];
		var name = get_party_display_name(party_obj);

		var card_idx = global.party_card_map[p];//[0, 2, 3, 5]
		var c = global.card_positions[card_idx];
		
		draw_set_halign(fa_center);
		draw_text(c.x + global.card_w/2, c.y + 30, display_name);
		draw_set_halign(fa_left);
		//later add HP and MP, protraits, etc
	}
		
	//reset draw settings
	draw_set_halign(fa_left);
	draw_set_valign(fa_center);
	draw_set_color(c_white);
}
//============================INVENTORY SUBMENU DRAWING============================
if (global.menu_page == MENU_PAGE.INVENTORY) {
	var top_mid = global.card_positions[1];
	var bot_mid = global.card_positions[4];
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
		break;
			
		case INVENTORY_STATE.SELECT_ITEM:
			draw_text(top_mid.x + 24, top_mid.y + 28, "ITEM");
			draw_text(top_mid.x + 24, top_mid.y + 52, selected_name);
			draw_text(top_mid.x + 24, top_mid.y + 76, "What?");
				
			//bottom card: fake inventory list to be replaced with real later
			for (var i = 0; i < 8; i++) {
				var col = (menu_cursor == i) ? c_yellow : c_white;
				draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i*20), "Potion " + string(i+1), col, col, col, col, 1);
			}
		break;
				
		case INVENTORY_STATE.SELECT_ACTION:
			draw_text(top_mid.x + 24, top_mid.y + 28, "ITEM");
			draw_text(top_mid.x + 24, top_mid.y + 52, selected_name);
			draw_text(top_mid.x + 24, top_mid.y + 76, "What?");
					
			var actions = ["Use", "Give", "Toss"];
			for (var i = 0; i < 3; i++) {
				var col = (menu_cursor == i) ? c_yellow : c_white;
				draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i*20), "Potion " + string(i+1), col, col, col, col, 1);
			}
		break;
				
		case INVENTORY_STATE.SELECT_TARGET:
			draw_text(top_mid.x + 24, top_mid.y + 28, "ITEM");
			draw_text(top_mid.x + 24, top_mid.y + 52, selected_name);
			draw_text(top_mid.x + 24, top_mid.y + 76, "On Whom?");
					
			for (var i = 0; i < array_length(global.partyOrder); i++) {
				var party_obj = global.partyOrder[i];
				var name = get_party_display_name(party_obj);
				var col = (menu_cursor == i) ? c_yellow : c_white;
				draw_text_color(bot_mid.x + 24, bot_mid.y + 20 + (i*20), name, col, col, col, col, 1);
			}
		break;
	}
}