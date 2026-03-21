//============================Global Menu GUI============================
if (global.state == GAME_STATE.IN_GAME_MENU) {
	//draw the 6 cards
	for (var i = 0; i < 6; i++) {
		var cx = global.card_positions[i].x;
		var cy = global.card_positions[i].y;
		
		//draw 9-slice card bg
		draw_sprite_stretched(sBasicGUI, 0, cx, cy, global.card_w, global.card_h);
		
		//draw the content inside each card
		//example placeholder text
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(c_white);
		
		var label;
		switch (i) {
			case 0: label = "Inventory"; break;
			case 1: label = "Skills"; break;
			case 2: label = "Equip"; break;
			case 3: label = "Stats"; break;
			case 4: label = "Order"; break;
			case 5: label = "Settings"; break;
		}
		
		draw_text(cx + global.card_w/2, cy + global.card_h/2, label);
	}
	
	//Blinking cursor
	if (global.menu_page == MENU_PAGE.MAIN) {
		var sel_x = global.card_positions[menu_cursor].x;
		var sel_y = global.card_positions[menu_cursor].y;
		
		var _blink_on = (blink_timer mod 40) < 20;
		var _cursor_spr = _blink_on ? sCursor : sBlink;
		
		//place cursor left of card
		draw_sprite(_cursor_spr, 0, sel_x - 12, sel_y + global.card_h/2);
	}
	
	//reset draw states
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
}