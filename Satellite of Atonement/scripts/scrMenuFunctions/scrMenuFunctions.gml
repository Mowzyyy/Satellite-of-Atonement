function scrMenuMainLogic() {

}

function scrMenuPauseLogic() {
	if (global.keyA || global.keyB) {
		global.state = GAME_STATE.OVERWORLD;
		global.menu_page = MENU_PAGE.MAIN;
		menu_cursor = 0;
		//audio_play_sound(sndEample, 10, false);
		io_clear();
		return;
	}
	//====================== MAIN MENU ======================
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
	} 
	//====================== INVENTORY SUBMENU ======================
	else if (global.menu_page == MENU_PAGE.INVENTORY) {
		scrInventoryLogic();
	}
	//====================== OTHER SUBMENUS (add later) ======================
	else {
		//If in a sub-menu like stats, pressing back returns to main
		if (global.keyB) {
			global.menu_page = MENU_PAGE.MAIN;
			//menu_cursor = 0;
		}
	}
}

function scrInventoryLogic() {
	var num_party = array_length(global.partyOrder);
	
	switch (global.inventory_state) {
		
		case INVENTORY_STATE.SELECT_WHO:
			//navigate the party list
			if (global.keyUpPressed) menu_cursor = (menu_cursor - 1 + num_party) mod num_party;
			if (global.keyDownPressed) menu_cursor = (menu_cursor + 1) mod num_party;
			
			if (global.keyC) {
				global.selected_party = menu_cursor;
				global.inventory_state = INVENTORY_STATE.SELECT_ITEM;
				menu_cursor = 0;
			}
			break;
		
		case INVENTORY_STATE.SELECT_ITEM:
		//TODO later when we have real inventory arrays
		//for now just simulate 4 items
		if (global.keyUpPressed) menu_cursor = max(0, menu_cursor - 1);
		if (global.keyDownPressed) menu_cursor = min(7, menu_cursor + 1);
		
		if (global.keyC) {
			global.selected_item = menu_cursor;
			global.inventory_state = INVENTORY_STATE.SELECT_ACTION;
			menu_cursor = 0;
		}
		break;
	
	case INVENTORY_STATE.SELECT_ACTION:
	if (global.keyUpPressed) menu_cursor = max(0, menu_cursor - 1);
	if (global.keyDownPressed) menu_cursor = min(2, menu_cursor + 1);
	
	if (global.keyC) {
		switch (menu_cursor) {
			case 0://Use
			global.inventory_state = INVENTORY_STATE.SELECT_TARGET;
			menu_cursor = 0;
			break;
			case 1://Give
			//TODO later
			break;
			case 2://Toss
			//TODO later
			break;
		}
	}
	break;
	
	case INVENTORY_STATE.SELECT_TARGET:
	//Reuse the same party selection logic as SELECT_WHO
	if (global.keyUpPressed) menu_cursor = (menu_cursor - 1 + num_party) mod num_party;
	if (global.keyDownPressed) menu_cursor = (menu_cursor + 1) mod num_party;
	
	if (global.keyC) {
		//Item used on target!
		show_debug_message("Used item on party member " + string(menu_cursor));
		//TODO: apply item effect
		global.inventory_state = INVENTORY_STATE.SELECT_WHO;
		MENU_CURSOR = 0;
	}
	break;
	}
}

function scrBattleLogic(){
	
}

function get_party_display_name(_party_obj) {
		//get a display name
		if (_party_obj == oLeon) display_name = "LEON";
		if (_party_obj == oCoat) display_name = "COAT";
		if (_party_obj == oOsei) display_name = "OSEI";
		if (_party_obj == oAnna) display_name = "ANNA";
		if (_party_obj == oData) display_name = "DATA";
		return "????";//fallback if unknown
}