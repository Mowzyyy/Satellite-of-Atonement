function scrMenuMainLogic() {

}

function scrMenuPauseLogic() {
	if (global.keyA || global.keyB) {
		show_debug_message("Closing menu");
		global.state = GAME_STATE.OVERWORLD;
		global.menu_pagee = MENU_PAGE.MAIN;
		menu_cursor = 0;
		//audio_play_sound(sndEample, 10, false);
		io_clear();
		return;
	}
	//simplified logic for psiii-style transitions
	if (global.menu_page == MENU_PAGE.MAIN) {
		//navigate the 9 option list
		var num_items = array_length(global.menu_list);
		
		if (global.keyUpPressed) {
			menu_cursor -= 1;
			if (menu_cursor <0) menu_cursor = num_items - 1;//wrap to SAVE
		}
		if (global.keyDownPressed) {
			menu_cursor+= 1;
			if (menu_cursor >= num_items) menu_cursor = 0;//wrap to ITEM
		}
		
		//clamp as safety
		menu_cursor = clamp(menu_cursor, 0, num_items - 1);
		
		//select option from list with C
		if (global.keyC) {
			global.menu_page = global.menu_page_map[menu_cursor];
			//optional: reset sub-menu cursor if you add one later
			//menu_cursor = 0;
		}
	} else {
		//If in a sub-menu like stats, pressing back returns to main
		if (global.keyB) {
			global.menu_page = MENU_PAGE.MAIN;
			//menu_cursor = 0;
		}
	}
}

function scrBattleLogic(){
	
}