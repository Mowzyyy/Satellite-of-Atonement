function scrMenuMainLogic() {

}

function scrMenuPauseLogic() {
	///simplified logic for psiii-style transitions
	if (global.menu_page == MENU_PAGE.MAIN) {
		//navigate the central panel
		if (keyUp) menu_cursor--;
		if (keyDown) menu_curse++;
		
		if (keyC) {
			//example: choosing stats
			if (menu_cursor == 3) {
				global.menu_page = MENU_PAGE.STATS;
				//In the Draw Event, this will trigger the portrait to vanish
			}
		}
	} else {
		//If in a sub-menu like stats, pressing back returns to main
		if (keyB) {
			global.menu_page = MENU_PAGE.MAIN;
		}
	}
}

function scrBattleLogic(){
	
}