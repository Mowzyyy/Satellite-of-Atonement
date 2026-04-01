//==================================Launch Menu==================================
function scrMenuMainLogic() {

}
//==================================In Game Menu==================================
function scrMenuPauseLogic() {
	if (global.keyB) {
		var closed = submenu_back();
		if (closed) {
			show_debug_message("Closed entire menu (from B at MAIN)");
		} else {
			show_debug_message("Went back one level (from B)");
		//audio_play_sound(sndEample, 10, false);
		}
		io_clear();
		return;
	}
	if (global.keyA) {
		show_debug_message("Immediate exit to overworld (from A)");
		global.state = GAME_STATE.OVERWORLD;
		global.menu_page = MENU_PAGE.MAIN;
		global.inventory_state = INVENTORY_STATE.SELECT_WHO;
		menu_cursor = 0;
		ds_stack_clear(global.submenu_history);
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
		
		//select option from list with C
		if (global.keyC) {
			global.menu_page = global.menu_page_map[menu_cursor];
			
			//Inventory logic for menu C
			if (global.menu_page == MENU_PAGE.INVENTORY) {
				//reset inventory state when entering ITEM

				global.inventory_state = INVENTORY_STATE.SELECT_WHO;
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				//clear history and push fresh
				while (ds_stack_size(global.submenu_history) > 0) ds_stack_pop(global.submenu_history);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MAIN);//push current menu level
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.INVENTORY_SELECT_WHO);
				show_debug_message("Entered SELECT_WHO from MAIN")
			}
			
			//Stats logic for menu C
			if (global.menu_page == MENU_PAGE.STATS) {
				global.stats_state = STATS_STATE.SELECT_WHO;
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				while (ds_stack_size(global.submenu_history) > 0) ds_stack_pop(global.submenu_history);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MAIN);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.STATS_SELECT_WHO);
				show_debug_message("Entered STATS SELECT_WHO from MAIN");
			}
			//add similar reset/push for other submenus later
		}
	} 
	//====================== INVENTORY SUBMENU ======================
	if (global.menu_page == MENU_PAGE.INVENTORY) {
		scrInventoryLogic();
	}
	//========================= STATS SUBMENU =========================
	if (global.menu_page == MENU_PAGE.STATS){
		scrStatsLogic();
	}
	//====================== OTHER SUBMENUS (add later) ======================
}
//=============================Inventory Submenu=============================
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
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.INVENTORY_SELECT_ITEM);
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				show_debug_message("Entered SELECT_ITEM");
			}
			break;
		
		case INVENTORY_STATE.SELECT_ITEM:
		//TODO later when we have real inventory arrays
		//for now just simulate 4 items
			if (global.keyUpPressed) menu_cursor = max(0, menu_cursor - 1);
			if (global.keyDownPressed) menu_cursor = min(19, menu_cursor + 1);
		
			if (global.keyC) {
				global.selected_item = menu_cursor;
				global.inventory_state = INVENTORY_STATE.SELECT_ACTION;
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.INVENTORY_SELECT_ACTION);
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				show_debug_message("Entered SELECT_ACTION - selected item: " + string(global.selected_item));
			}
			break;
	
	case INVENTORY_STATE.SELECT_ACTION:
		if (global.keyUpPressed) menu_cursor = max(0, menu_cursor - 1);
		if (global.keyDownPressed) menu_cursor = min(2, menu_cursor + 1);
	
		if (global.keyC) {
			if (menu_cursor == 0) {//use
				global.inventory_state = INVENTORY_STATE.SELECT_TARGET;
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.INVENTORY_SELECT_TARGET);
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				show_debug_message("Entered SELECT_TARGET");
			}
		}
		break;
	
	case INVENTORY_STATE.SELECT_TARGET:
		//Reuse the same party selection logic as SELECT_WHO
		if (global.keyUpPressed) menu_cursor = (menu_cursor - 1 + num_party) mod num_party;
		if (global.keyDownPressed) menu_cursor = (menu_cursor + 1) mod num_party;
	
		if (global.keyC) {
			var target_member = global.partyOrder[menu_cursor];
			show_debug_message("Used item " + string(global.selected_item) + " on party member" +string(menu_cursor));
			
			//TODO - apply actual item effect here
			//example heal damage status etc
			//for now just consume the item
			//var inv_list = ds_map_find_value(global.party_inventory, global.partyOrder[global.selected_party]);
			//ds_list_delete(inv_list, global.selected_item;
			
			io_clear();
			global.keyC = false;
			
			//autoback to select item "What?" after use
			while (ds_stack_top(global.submenu_history) != SUBMENU_HISTORY.INVENTORY_SELECT_ITEM && ds_stack_size(global.submenu_history) > 1) {
				ds_stack_pop(global.submenu_history);
		}
		global.inventory_state= INVENTORY_STATE.SELECT_ITEM;
		menu_cursor = global.selected_item;
		show_debug_message("Auto-back to SELECT_ITEM after use");
		}
	break;
	}
}
//==================================Combat Menu==================================
function scrBattleLogic(){
	
}

//==================================Display Name==================================
function get_party_display_name(_party_obj) {
		//get a display name
		if (_party_obj == oLeon) return "LEON";
		if (_party_obj == oCoat) return "COAT";
		if (_party_obj == oOsei) return "OSEI";
		if (_party_obj == oAnna) return "ANNA";
		if (_party_obj == oData) return "DATA";
		return "????";//fallback if unknown
}
//====================================Submenus====================================
function submenu_back() {
	if (ds_stack_size(global.submenu_history) <= 1) {
		//at top level - close menu
		global.state = GAME_STATE.OVERWORLD;
		global.menu_page = MENU_PAGE.MAIN
		global.inventory_state = INVENTORY_STATE.SELECT_WHO;
		menu_cursor = 0;
		ds_stack_clear(global.submenu_history);
		show_debug_message("Closed entire menu")
		return true;
	}
	
	//pop the current state and go back one level
	ds_stack_pop(global.submenu_history);
	var previous = ds_stack_top(global.submenu_history);
	show_debug_message("Back to: " + string(previous) + " | inventory_state now: " + string(global.inventory_state));
	
	switch (previous) {
		case	SUBMENU_HISTORY.MAIN:
			global.menu_page = MENU_PAGE.MAIN;
			menu_cursor = 0;
			break;
			
		case SUBMENU_HISTORY.INVENTORY_SELECT_WHO:
			global.inventory_state = INVENTORY_STATE.SELECT_WHO;
			show_debug_message("Set to SELECT_WHO - cursor: " + string(menu_cursor) + " | history size: " + string(ds_stack_size(global.submenu_history)));
			menu_cursor = global.selected_party;//restore previous selection
			break;
			
		case SUBMENU_HISTORY.INVENTORY_SELECT_ITEM:
			global.inventory_state = INVENTORY_STATE.SELECT_ITEM;
			menu_cursor = global.selected_item;//restore item cursor
			break;
		
		case SUBMENU_HISTORY.INVENTORY_SELECT_ACTION:
			global.inventory_state = INVENTORY_STATE.SELECT_ACTION;
			menu_cursor = 0;
			break;
		
		case SUBMENU_HISTORY.INVENTORY_SELECT_TARGET:
			global.inventory_state = INVENTORY_STATE.SELECT_ACTION;//back to action after target
			menu_cursor = 0;
			break;
			
		case SUBMENU_HISTORY.STATS_SELECT_WHO:
			global.stats_state = STATS_STATE.SELECT_WHO;
			menu_cursor = global.selected_stat_char;
			break;
			
		case SUBMENU_HISTORY.STATS_VIEW:
			global.stats_state = STATS_STATE.SELECT_WHO;
			menu_cursor = global.selected_stat_char;
			break;
	}
	return false;//did not close entire menu
}
//==================================Stats Menu Logic==================================
function scrStatsLogic() {
	var num_party = array_length(global.partyOrder);
	
	switch (global.stats_state) {
		case STATS_STATE.SELECT_WHO:
			if(global.keyUpPressed) {
				global.selected_stat_char = (global.selected_stat_char - 1 + num_party) mod num_party;
				menu_cursor = global.selected_stat_char;
				io_clear();
			}
			if (global.keyDownPressed) {
				global.selected_stat_char = (global.selected_stat_char + 1) mod num_party;
				menu_cursor = global.selected_stat_char;
				io_clear();
				show_debug_message("selected_stat_char: " + string(global.selected_stat_char) + " | num_party " + string(num_party));
			}
			
			if(global.keyC) {
				global.stats_state = STATS_STATE.VIEW_STATS;
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.STATS_VIEW);
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				show_debug_message("Stats: viewing " + get_party_display_name(global.partyOrder[global.selected_stat_char]));
			}
		break;
		
		case STATS_STATE.VIEW_STATS:
			//No navigation needed - B to go back is handled by submenu_back()
		break;
	}
}