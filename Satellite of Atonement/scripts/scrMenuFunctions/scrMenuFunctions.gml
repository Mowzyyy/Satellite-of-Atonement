function scrMenuMainLogic() {

}

function scrMenuPauseLogic() {
	//simplified logic for psiii-style transitions
	if (global.menu_page == MENU_PAGE.MAIN) {
		//navigate the central panel
		if (global.keyUp) menu_cursor = max(0, menu_cursor -1);
		if (global.keyDown) menu_cursor = min( 5, menu_cursor + 1);
		
		//select card with C
		if (global.keyC) {
			switch (menu_cursor) {
				case 0: global.menu_page = MENU_PAGE.INVENTORY; break;
				case 1: global.menu_page = MENU_PAGE.SKILLS; break;
				case 2: global.menu_page = MENU_PAGE.EQUIP; break;
				case 3: global.menu_page = MENU_PAGE.STATS; break;
				case 4: global.menu_page = MENU_PAGE.ORDER; break;
				case 5: global.menu_page = MENU_PAGE.SETTINGS; break;
			}
			menu_cursor = 0;
		}
	} else {
		//If in a sub-menu like stats, pressing back returns to main
		if (global.keyB) {
			global.menu_page = MENU_PAGE.MAIN;
			menu_cursor = 0;
		}
	}
}

function scrBattleLogic(){
	
}