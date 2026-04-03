//==================================Launch Menu==================================
function scrMenuMainLogic() {

}
//==================================In Game Menu==================================
function scrMenuPauseLogic() {
	if (global.is_restarting) return;
	
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
			
			//Quit logic for menu C
			if (global.menu_page == MENU_PAGE.QUIT) {
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				while (ds_stack_size(global.submenu_history) > 0) ds_stack_pop(global.submenu_history);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MAIN);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.QUIT_CONFIRM);
				show_debug_message("Entered QUIT CONFIRM from MAIN");
			}
			
			//Order logic for menu C
			if (global.menu_page == MENU_PAGE.ORDER) {
				global.order_state = ORDER_STATE.SELECT;
				global.order_new = [];
				global.order_new_party = [];
				global.order_confirm_cursor = 0;
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				while (ds_stack_size(global.submenu_history) > 0) ds_stack_pop(global.submenu_history);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MAIN);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.ORDER_SELECT);
				show_debug_message("Entered ORDER from MAIN");
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
	//========================= QUIT SUBMENU =========================
	if (global.menu_page == MENU_PAGE.QUIT){
		scrQuitLogic();
	}
	//========================= ORDER SUBMENU =========================
	if (global.menu_page == MENU_PAGE.ORDER) {
		scrOrderLogic();
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
			var inv = global.party[global.selected_party].inventory;
			var inv_size = array_length(inv);

			if (global.keyUpPressed) menu_cursor = max(0, menu_cursor - 1);
			if (global.keyDownPressed) menu_cursor = min(max(0, inv_size - 1), menu_cursor + 1);
			
			if (global.keyC && inv_size > 0) {
				global.selected_item = menu_cursor;
				global.inventory_state = INVENTORY_STATE.SELECT_ACTION;
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.INVENTORY_SELECT_ACTION);
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				show_debug_message("Entered SELECT_ACTION - item: " + inv[global.selected_item].name);
			}
		break;
	
		case INVENTORY_STATE.SELECT_ACTION:
		if (global.keyUpPressed) menu_cursor = max(0, menu_cursor - 1);
		if (global.keyDownPressed) menu_cursor = min(2, menu_cursor + 1);
	
		if (global.keyC) {
			var selected_inv = global.party[global.selected_party].inventory;
			switch (menu_cursor) {
				case 0://use
					global.inventory_state=	INVENTORY_STATE.SELECT_TARGET;
					ds_stack_push(global.submenu_history, SUBMENU_HISTORY.INVENTORY_SELECT_TARGET);
					menu_cursor = 0;
					io_clear();
					global.keyC = false;
					show_debug_message("Entered SELECT_TARGET for Use");
					break;
				case 1://Give
					global.inventory_state = INVENTORY_STATE.SELECT_GIVE_TARGET;
					ds_stack_push(global.submenu_history, SUBMENU_HISTORY.INVENTORY_SELECT_GIVE_TARGET);
					menu_cursor = 0;
					global.inventory_full_msg = false;
					io_clear()
					global.keyC = false;
					show_debug_message("Entered SELECT_GIVE_TARGET");
					break;
				case 2://Toss
					global.party[global.selected_party].remove_item(global.selected_item);
					show_debug_message("Tossed item");
					//back to select_item
					while (ds_stack_top(global.submenu_history) != SUBMENU_HISTORY.INVENTORY_SELECT_ITEM && ds_stack_size(global.submenu_history) > 1) {
						ds_stack_pop(global.submenu_history);
					}
					global.inventory_state = INVENTORY_STATE.SELECT_ITEM;
					var new_size = array_length(global.party[global.selected_party].inventory);
					menu_cursor = clamp(global.selected_item, 0, max(0, new_size - 1));
					io_clear();
					global.keyC = false;
					break;
			}		
		}
		break;
	
		case INVENTORY_STATE.SELECT_TARGET:
			if (global.keyUpPressed) menu_cursor = (menu_cursor - 1 + num_party) mod num_party;
			if (global.keyDownPressed) menu_cursor = (menu_cursor + 1) mod num_party;
	
			if (global.keyC) {
				var user = global.party[global.selected_party];
				var target = global.party[menu_cursor];
				var used = user.use_item(global.selected_item, target);
				show_debug_message("Used item on " + target.name + " | success: " + string(used));
			
				io_clear()
				global.keyC = false;
			
				//autoback to select item
				while (ds_stack_top(global.submenu_history) != SUBMENU_HISTORY.INVENTORY_SELECT_ITEM && ds_stack_size(global.submenu_history) > 1) {
					ds_stack_pop(global.submenu_history);
				}
				global.inventory_state = INVENTORY_STATE.SELECT_ITEM;
				var new_size = array_length(global.party[global.selected_party].inventory);
				menu_cursor = clamp(global.selected_item, 0, max(0, new_size - 1));
				show_debug_message("Auto-back to SELECT_ITEM after use");
			}
		break;
		
		case INVENTORY_STATE.SELECT_GIVE_TARGET:
			if (global.keyUpPressed) menu_cursor = (menu_cursor - 1 + num_party) mod num_party;
			if (global.keyDownPressed) menu_cursor = (menu_cursor + 1) mod num_party;
		
			if (global.keyUpPressed || global.keyDownPressed) {
				global.inventory_full_msg = false;//clear message on navigation
			}
		
			if (global.keyC) {
				//cannot give to self
				if (menu_cursor == global.selected_party) {
					io_clear();
					global.keyC = false;
					break;
				}
			
			var giver = global.party[global.selected_party];
			var receiver = global.party[menu_cursor];
			
			if (array_length(receiver.inventory) >= 20) {
				//target full - show message stay on screen
				global.inventory_full_msg = true;
				io_clear();
				global.keyC = false;
				show_debug_message("Give failed - " + receiver.name + " inventory full");
			} else {
				//move item
				var item = giver.remove_item(global.selected_item);
				receiver.add_item(item);
				global.inventory_full_msg = false;
				show_debug_message("Gave " + item.name + " to " + receiver.name);
				
				io_clear();
				global.keyC	= false;
				
				//back to select item
				while (ds_stack_top(global.submenu_history) != SUBMENU_HISTORY.INVENTORY_SELECT_ITEM && ds_stack_size(global.submenu_history) > 1) {
					ds_stack_pop(global.submenu_history);
				}
				global.inventory_state = INVENTORY_STATE.SELECT_ITEM;
				var new_size = array_length(global.party[global.selected_party].inventory);
				menu_cursor = clamp(global.selected_item, 0, max(0, new_size - 1));
			}
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
		
		case SUBMENU_HISTORY.QUIT_CONFIRM:
			global.menu_page = MENU_PAGE.MAIN;
			menu_cursor = 9;
			break;
		
		case SUBMENU_HISTORY.ORDER_SELECT:
			global.order_state = ORDER_STATE.SELECT;
			global.order_new = [];
			global.order_new_party = [];
			global.order_confirm_cursor = 0;
			menu_cursor = 0;
			break;
		
		case SUBMENU_HISTORY.ORDER_CONFIRM:
			global.order_state = ORDER_STATE.SELECT;
			global.order_new = [];
			global.order_new_party = [];
			global.order_confirm_cursor = 0;
			menu_cursor = 0;
			break;
			
		case SUBMENU_HISTORY.INVENTORY_SELECT_GIVE_TARGET:
			global.inventory_state = INVENTORY_STATE.SELECT_ACTION;
			global.inventory_full_msg = false;
			menu_cursor = 1;
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

//==================================Quit Menu Logic==================================
function scrQuitLogic() {
	var num_opts = 2;//yes,no
	
	if (global.keyUpPressed) menu_cursor = (menu_cursor - 1 + num_opts) mod num_opts;
	if (global.keyDownPressed) menu_cursor = (menu_cursor + 1) mod num_opts;
	
	if (global.keyC) {
		if (menu_cursor == 0) {
			//No - back to main pause menu
			submenu_back();
			io_clear();
			global.keyC = false;
			show_debug_message("Quit cancelled, returning to pause menu");
		} else {
			//yes - full nuke reset
			global.is_restarting = true;
			global.state = GAME_STATE.MAIN_MENU;
			ds_stack_clear(global.submenu_history);
			menu_cursor = 0;
			show_debug_message("Quit confirmed, restarting game");
			instance_destroy(oGameController);
			instance_create_depth(0, 0, 0, oGameController);
			game_restart();
		}
	}
}
//==================================Order Menu Logic==================================
function scrOrderLogic() {
	var num_available = 0;
	//count how many are still in the list
	for (var q = 0; q < array_length(global.partyOrder); q++) {
		var already_placed = false;
		for (var j = 0; j < array_length(global.order_new); j++) {
			if (global.order_new[j] == global.partyOrder[q]) {
				already_placed = true;
				break;
			}
		}
		if (!already_placed) num_available++;
	}
	
	switch (global.order_state) {
		
		case ORDER_STATE.SELECT:
		//build the available list dynamically
			var available = [];
			var available_party = [];
			for (var q = 0; q < array_length(global.partyOrder); q++) {
				var already_placed = false;
				for (var j = 0; j < array_length(global.order_new); j++) {
					if (global.order_new[j] == global.partyOrder[q]) {
						already_placed = true;
						break;
						}
					}
			if (!already_placed) {
				array_push(available, global.partyOrder[q]);
				array_push(available_party, global.party[q]);
				}
			}
			
			var num_avail = array_length(available);
			
			//auto-place the last member
			if(num_avail == 1) {
				array_push(global.order_new, available[0]);
				array_push(global.order_new_party, available_party[0]);
				global.order_state = ORDER_STATE.CONFIRM;
				menu_cursor = 0;
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.ORDER_CONFIRM);
				io_clear();
				break;
			}
			
			if (global.keyUpPressed) menu_cursor = (menu_cursor - 1 + num_avail) mod num_avail;
			if (global.keyDownPressed) menu_cursor = (menu_cursor + 1) mod num_avail;
			
			if (global.keyC) {
				//place selected char into new order
				array_push(global.order_new, available[menu_cursor]);
				array_push(global.order_new_party, available_party[menu_cursor]);
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				show_debug_message("ORDER: placed " + get_party_display_name(available[menu_cursor]));
			}
			break;
			
		case ORDER_STATE.CONFIRM:
			if (global.keyUpPressed) { global.order_confirm_cursor = (global.order_confirm_cursor - 1 + 2) mod 2; menu_cursor = global.order_confirm_cursor; io_clear(); }
			if (global.keyDownPressed) { global.order_confirm_cursor = (global.order_confirm_cursor + 1) mod 2; menu_cursor = global.order_confirm_cursor; io_clear();}
			
			if (global.keyC) {
				if (global.order_confirm_cursor == 1) {
					//yes - apply new order to both arrays in sync
					global.partyOrder = array_create(array_length(global.order_new));
					global.party = array_create(array_length(global.order_new_party));
					for (var i = 0; i < array_length(global.order_new); i++) {
						global.partyOrder[i] = global.order_new[i];
						global.party[i] = global.order_new_party[i];
					}
					scrRefreshPartyRanks();
					show_debug_message("ORDER: new order applied");
				} else {
					show_debug_message("ORDER: cancelled, no changes")
				}
				//reset order state either way
				global.order_new = [];
				global.order_new_party = [];
				global.order_state = ORDER_STATE.SELECT;
				global.order_confirm_cursor = 0;
				submenu_back();
				io_clear();
				global.keyC = false;
			}
		break;
	}
}
function scrRefreshPartyRanks() {
	for (var i_rnk = 0; i_rnk < array_length(global.partyOrder); i_rnk++) {
		var inst = instance_find(global.partyOrder[i_rnk], 0);
		if (inst != noone && instance_exists(inst)) {
			inst.myRank = i_rnk;
		}
	}
}