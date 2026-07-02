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
			
			//Equip logic for menu C
			if (global.menu_page == MENU_PAGE.EQUIP) {
				global.equip_state = EQUIP_STATE.SELECT_WHO;
				global.equip_char = 0;
				global.equip_scroll_page = 0;
				global.equip_cursor = 0;
				global.equip_pending_item = -1;
				global.equip_hand_cursor = 0;
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				while (ds_stack_size(global.submenu_history) > 0) ds_stack_pop(global.submenu_history);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MAIN);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.EQUIP_SELECT_WHO);
				show_debug_message("Entered EQUIP from MAIN");
			}
			
			//Save logic for menu C
			if (global.menu_page == MENU_PAGE.SAVE) {
				global.save_state = SAVE_STATE.SELECT_SLOT;
				global.save_cursor = 0;
				global.save_confirm_cursor = 0;
				global.save_just_saved = false;
				menu_cursor = 0;
				scrSaveRefreshCache();
				io_clear();
				global.keyC = false;
				while (ds_stack_size(global.submenu_history) > 0) ds_stack_pop(global.submenu_history);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MAIN);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.SAVE_SELECT_SLOT);
				show_debug_message("Entered SAVE from MAIN");
			}
			
			//Skill logic for menu C
			if (global.menu_page == MENU_PAGE.SKILLS) {
				global.skill_state = SKILL_STATE.SELECT_WHO;
				global.skill_char = 0;
				global.skill_cursor = 0;
				global.skill_selected = -1;
				global.skill_cannot_timer = 0;
				global.skill_target_cursor = 0;
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				while (ds_stack_size(global.submenu_history) > 0) ds_stack_pop(global.submenu_history);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MAIN);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.SKILL_SELECT_WHO);
				show_debug_message("Entered SKILL from MAIN");
			}
			
			if (global.menu_page == MENU_PAGE.MACRO) {
				global.macro_state = MACRO_STATE.SELECT_SLOT;
				global.macro_slot = -1;
				global.macro_new = [];
				global.macro_pending_member = -1;
				global.macro_confirm_cursor = 0;
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				while (ds_stack_size(global.submenu_history) > 0) ds_stack_pop(global.submenu_history);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MAIN);
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MACRO_SELECT_SLOT);
				show_debug_message("Entered MACRO from MAIN");
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
	//=========================== EQUIP SUBMENU ===========================
	if (global.menu_page == MENU_PAGE.EQUIP) {
		scrEquipLogic();
	}
	//=========================== SAVE SUBMENU ===========================
	if (global.menu_page == MENU_PAGE.SAVE) {
		scrSaveLogic();
	}
	//=========================== SKILL SUBMENU ===========================
	if (global.menu_page == MENU_PAGE.SKILLS) {
		scrSkillLogic();
	}
	//=========================== MACRO SUBMENU ===========================
	if (global.menu_page == MENU_PAGE.MACRO) {
		scrMacroMenuLogic();
	}
}

function drawPortraitController(_member, _portrait_spr, _x, _y) {
	if (_member.is_dead) {
		//grayscale
		draw_sprite_ext(_portrait_spr, 0, _x, _y, 1, 1, 0, c_gray, 0.7);
	} else {
		draw_sprite(_portrait_spr, 0, _x, _y);
	}
}

function scrSyncDeathFlags() {
	for (var i = 0; i < array_length(global.party); i++) {
		var _pm = global.party[i];
		if (_pm.current_hp <= 0 && !_pm.is_dead) {
			_pm.current_hp = 0;
			_pm.is_dead = true;
			_pm.status_effects = [];
		} else if (_pm.current_hp > 0 && _pm.is_dead) {
			_pm.is_dead = false;
		}
	}
}
//=============================Inventory Submenu=============================
function scrInventoryLogic() {
	var num_party = array_length(global.partyOrder);
	
	//waiting for item use rollup to finish before autobacking
	if (global.item_use_wait) {
		//block input during the wait
		io_clear();
		
		//check if the rollup for this key is still active
		var _still_rolling = false;
		for (var _r = 0; _r < array_length(global.stat_rollups); _r++) {
			if (global.stat_rollups[_r].key == global.item_use_wait_key) {
				_still_rolling = true;
				break;
			}
		}
		if (_still_rolling) {
			return;//rollup still animating, keep waiting
		}
		//rollup done, wait for hold timer
		global.item_use_wait_timer--;
		if (global.item_use_wait_timer > 0) return;
		
		//hold time over, perform autoback
		global.item_use_wait = false;
		global.item_use_wait_key = "";
		
		while (ds_stack_top(global.submenu_history) != SUBMENU_HISTORY.INVENTORY_SELECT_ITEM && ds_stack_size(global.submenu_history) > 1) {
			ds_stack_pop(global.submenu_history);
		}
		global.inventory_state = INVENTORY_STATE.SELECT_ITEM;
		var new_size = array_length(global.party[global.selected_party].inventory);
		menu_cursor = clamp(global.selected_item, 0, max(0, new_size - 1));
		global.selected_item = menu_cursor;
		show_debug_message("Autoback to SELECT_ITEM after item use wait");
		return;
	}
	
	switch (global.inventory_state) {
		
		case INVENTORY_STATE.SELECT_WHO:
			//navigate the party list
			if (global.keyUpPressed) menu_cursor = (menu_cursor - 1 + num_party) mod num_party;
			if (global.keyDownPressed) menu_cursor = (menu_cursor + 1) mod num_party;
			
			if (global.keyC) {
				global.selected_party = menu_cursor;
				global.selected_item = 0;
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
			var items_per_card = 5;
			
			//card order - topleft = 0, botleft = 1, topright = 2, bort-right = 3
			//slot ranges - card 0 = slots 0-4, 1 = slots 5-9, 2 = 10-14, 3 = 15-19
			var cur_card = floor(menu_cursor / items_per_card);//0-3
			var cur_line = menu_cursor mod items_per_card;//0-4 within card

			if (global.keyUpPressed) {
				if (cur_line > 0) {
					//move up within card only if slot above has an item
					var target_slot = (cur_card * items_per_card) + (cur_line - 1);
					if (target_slot < inv_size) menu_cursor = target_slot;
				} else {
					//at top of card find last item scanning backwards from end
					var prev_card = cur_card - 1;
					if (prev_card < 0) prev_card = 3;
					//scan backwards through cards until one with items is found
					var found = false;
					for (var try_card = 0; try_card < 4; try_card++) {
						var check_card = (prev_card - try_card + 4) mod 4;
						var check_start = check_card * items_per_card;
						for (var s = items_per_card - 1; s >= 0; s--) {
							if (check_start + s < inv_size) {
								menu_cursor = check_start + s;
								found = true;
								break;
							}
						}
						if (found) break;
					}
				}
				io_clear();
			}
			
			if (global.keyDownPressed) {
				var next_slot = (cur_card * items_per_card)  + (cur_line + 1);
				if (cur_line < items_per_card - 1 && next_slot < inv_size) {
					// move down within card
					menu_cursor = next_slot;
				} else {
					//at bottom of card or end of items find first item on next non empty card
					var next_card = cur_card + 1;
					if (next_card > 3) next_card = 0;
					var found = false;
					for (var try_card = 0; try_card < 4; try_card++) {
						var check_card = (next_card + try_card) mod 4;
						var check_start = check_card * items_per_card;
						if (check_start < inv_size) {
							menu_cursor = check_start;
							found = true;
							break;
						}
					}
				}
				io_clear();
			}
			
			//left - move from right card to left card on the same line
			if (global.keyLeftPressed) {
				//2 and 3 are right cards, 0 and 1 are left
				if (cur_card == 2) {
					var target_slot = (0 * items_per_card) + cur_line;//top-left same line
					if (target_slot < inv_size) { menu_cursor = target_slot; io_clear(); }
				} else if (cur_card == 3) {
					var target_slot = (1 * items_per_card) + cur_line;//bot-left same line
					if (target_slot < inv_size) { menu_cursor = target_slot; io_clear(); }
				}
			}
			//right - move from left card to right card on the same line
			if (global.keyRightPressed) {
				if (cur_card == 0) {
					var target_slot = (2 * items_per_card) + cur_line;//top right same line
					if (target_slot < inv_size) { menu_cursor = target_slot; io_clear(); }
				} else if (cur_card == 1) {
					var target_slot = (3 * items_per_card) + cur_line;//bot-right same line
					if (target_slot < inv_size) { menu_cursor = target_slot; io_clear(); }
				}
			}
			
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
					global.selected_item = menu_cursor;
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
				var _hp_before = target.current_hp;
				var used = user.use_item(global.selected_item, target);
				scrSyncDeathFlags();
				
				scrCheckGameOver();
				if (global.state == GAME_STATE.GAME_OVER) exit;
				
				var _key = "hp_" + string(menu_cursor);
				scrStartRollup("hp_" + string(menu_cursor), _hp_before, target.current_hp);
				
				show_debug_message("Used item on " + target.name + " | success: " + string(used));
				
				//begin waiting for the rollup to finish before returning
				global.item_use_wait = true;
				global.item_use_wait_key = _key;
				global.item_use_wait_timer = 30;
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
			var give_item = giver.inventory[global.selected_item];
			
			//cannot give an equipped item
			if (giver.is_equipped(give_item.name)) {
				global.inventory_full_msg = true;//reuse flag but says "EQUIPD!"
				io_clear();
				global.keyC = false;
				show_debug_message("Give failed - " + give_item.name + " is equipped");
				break;
			}
			
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
				global.selected_item = menu_cursor;
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
			global.save_state = SAVE_STATE.SELECT_SLOT;
			global.save_confirm_cursor = 0;
			menu_cursor = 0;
			break;
			
		case SUBMENU_HISTORY.INVENTORY_SELECT_WHO:
			global.inventory_state = INVENTORY_STATE.SELECT_WHO;
			//global.selected_party = 0;
			global.selected_item = 0;
			menu_cursor = global.selected_party;
			break;
			
		case SUBMENU_HISTORY.INVENTORY_SELECT_ITEM:
			global.inventory_state = INVENTORY_STATE.SELECT_ITEM;
			var _inv_sz = array_length(global.party[global.selected_party].inventory);
			menu_cursor = clamp(global.selected_item, 0, max(0, _inv_sz - 1));
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
			
		case SUBMENU_HISTORY.EQUIP_SELECT_WHO:
			global.equip_state = EQUIP_STATE.SELECT_WHO;
			global.equip_char = 0;
			menu_cursor = 0;
			break;
		
		case SUBMENU_HISTORY.EQUIP_SELECT_SLOT:
			global.equip_state = EQUIP_STATE.SELECT_WHO;
			global.equip_scroll_page = 0;
			global.equip_cursor = 0;
			menu_cursor = global.equip_char;
			break;
			
		case SUBMENU_HISTORY.EQUIP_SELECT_HAND:
			global.equip_state = EQUIP_STATE.SELECT_SLOT;
			global.equip_pending_item = -1;
			global.equip_hand_cursor = 0;
			menu_cursor = 0;
			break;
			
		case SUBMENU_HISTORY.SAVE_SELECT_SLOT:
			global.save_state = SAVE_STATE.SELECT_SLOT;
			global.save_cursor = 0;
			menu_cursor = 0;
			break;
			
		case SUBMENU_HISTORY.SAVE_CONFIRM_OVERWRITE:
			global.save_state = SAVE_STATE.SELECT_SLOT;
			global.save_cursor = 0;
			menu_cursor = 0;
			break;
			
		case SUBMENU_HISTORY.SKILL_SELECT_WHO:
			global.skill_state = SKILL_STATE.SELECT_WHO;
			global.skill_char = 0;
			menu_cursor = 0;
			show_debug_message("Used BACK from SKILL_SELECT_WHO");
			break;
		
		case SUBMENU_HISTORY.SKILL_SELECT_WHAT:
			global.skill_state = SKILL_STATE.SELECT_WHO;
			global.skill_char = 0;
			menu_cursor = global.skill_char;
			show_debug_message("Used BACK from SKILL_SELECT_WHAT");
			break;
			
		case SUBMENU_HISTORY.SKILL_SELECT_TARGET:
			global.skill_state = SKILL_STATE.SELECT_WHAT;
			global.skill_target_cursor = 0;
			menu_cursor = global.skill_target_cursor;
			show_debug_message("Used BACK from SKILL_SELECT_TARGET");
			break;
		
		case SUBMENU_HISTORY.MACRO_SELECT_SLOT:
			global.macro_state =	MACRO_STATE.SELECT_SLOT;
			global.macro_new = [];
			menu_cursor = max(0, global.macro_slot);
			break;
			
		case SUBMENU_HISTORY.MACRO_SELECT_MEMBER:
			global.macro_state = MACRO_STATE.SELECT_MEMBER;
			menu_cursor = 0;
			break;
			
		case SUBMENU_HISTORY.MACRO_SELECT_ACTION:
			global.macro_state = MACRO_STATE.SELECT_ACTION;
			menu_cursor = 0;
			break;
		
		case SUBMENU_HISTORY.MACRO_CONFIRM:
			global.macro_state = MACRO_STATE.SELECT_MEMBER;
			menu_cursor = 0;
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
			global.party_initialized = false;
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


//==================================Save Menu Logic==================================
function scrSaveLogic() {
	//count down SAVED! display timer
	if (global.save_just_saved) {
		global.save_saved_timer--;
		if (global.save_saved_timer <= 0) {
			global.save_just_saved = false;
		}
	}
	
	switch (global.save_state) {
		
		case SAVE_STATE.SELECT_SLOT:
			if (global.keyUpPressed) {
				global.save_cursor = (global.save_cursor - 1 + 3) mod 3;
				global.save_just_saved = false;
				io_clear();
			}
			if (global.keyDownPressed) {
				global.save_cursor = (global.save_cursor + 1) mod 3;
				global.save_just_saved = false;
				io_clear();
			}
			
			if (global.keyC) {
				if (global.save_slot_cache[global.save_cursor] != undefined) {
					//slot has data - go to overwrite confirm
					global.save_state = SAVE_STATE.CONFIRM_OVERWRITE;
					global.save_confirm_cursor = 0;
					ds_stack_push(global.submenu_history, SUBMENU_HISTORY.SAVE_CONFIRM_OVERWRITE);
					io_clear();
					global.keyC = false;
					break;
				} else {
					//empty slot - save immediately
					save_game(global.save_cursor);
					scrSaveRefreshCache();
					global.save_just_saved = true;
					global.save_saved_timer = 180;
					io_clear();
					global.keyC = false;
					show_debug_message("SAVE: saved to slot " + string(global.save_cursor));
					break;
				}
			}
		break;
			
		case SAVE_STATE.CONFIRM_OVERWRITE:
			if (global.keyUpPressed || global.keyDownPressed) {
				global.save_confirm_cursor = 1 - global.save_confirm_cursor;
				io_clear();
			}
			
			if (global.keyC) {
				if (global.save_confirm_cursor == 1) {
					//yes - overwrite
					save_game(global.save_cursor);
					scrSaveRefreshCache();
					global.save_just_saved = true;
					global.save_saved_timer = 180;
					ds_stack_pop(global.submenu_history);
					show_debug_message("SAVE: overwritten slot " + string(global.save_cursor));
				} else {
					//no - back to slot select
					global.save_state = SAVE_STATE.SELECT_SLOT;
					ds_stack_pop(global.submenu_history);
				}
				io_clear();
				global.keyC = false;
			}
			break;
	}
}

function format_playtime(_seconds) {
	var s = floor(_seconds);
	var h = floor( s / 36000);
	var m = floor((s mod 3600) / 60);
	var sec = s mod 60;
	return string(h) + ":" + (m < 10 ? "0" : "") + string(m) + ":" + (sec < 10 ? "0" : "") + string(sec);
}

function scrSaveRefreshCache() {
	global.save_slot_cache = [];
	for (var i = 0; i < 3; i++) {
		if (save_slot_exists(i)) {
			var buf = buffer_load(save_filepath(i));
			var raw = buffer_read(buf, buffer_string);
			buffer_delete(buf);
			global.save_slot_cache[i] = json_parse(raw);
		} else {
			global.save_slot_cache[i] = undefined;
		}
	}
}
//==================================Skill Menu Logic==================================
function scrSkillLogic() {
	var num_party = array_length(global.partyOrder);
	var member = global.party[global.skill_char];
	
	//CANNOT timer - block input while showing message
	if (global.skill_cannot_timer > 0) {
		global.skill_cannot_timer--;
		return;
	}
	
	switch (global.skill_state) {
		
		case SKILL_STATE.SELECT_WHO:
			if (global.keyUpPressed) {
				var tries = 0;
				repeat (array_length(global.partyOrder)) {
					global.skill_char = (global.skill_char - 1 + num_party) mod num_party;
					if (!global.party[global.skill_char].is_dead) break;
				}
				menu_cursor = global.skill_char;
				io_clear();
			}
			if (global.keyDownPressed) {
				repeat (array_length(global.partyOrder)) {
					global.skill_char = (global.skill_char + 1) mod num_party;
					if (!global.party[global.skill_char].is_dead) break;
				}
				menu_cursor = global.skill_char;
				io_clear();
			}
			if (global.keyC) {
				var chosen = global.party[global.skill_char];
				if (chosen.is_dead) {
					global.skill_death_msg_timer = 120;//2 seconds
					io_clear();
					global.keyC = false;
					break;
				}
				var list = scrSkillBuildList(global.skill_char);
				global.skill_state  = SKILL_STATE.SELECT_WHAT;
				global.skill_cursor = 0;
				if (array_length(list) > 0 && list[0].kind == "separator") {
				    global.skill_cursor = scrSkillCursorNext(list, 0, 1);
				}
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.SKILL_SELECT_TARGET);
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				show_debug_message("SKILL: selected " + member.name);
			}
		break;
		
		case SKILL_STATE.SELECT_WHAT:
			var list      = scrSkillBuildList(global.skill_char);
			var list_size = array_length(list);

			if (list_size == 0) {
				if (global.keyC) { submenu_back(); io_clear(); global.keyC = false; }
				break;
			}
			
			if (global.keyUpPressed) {
				global.skill_cursor = scrSkillCursorNext(list, global.skill_cursor, -1);
				io_clear();
			}
			
			if (global.keyDownPressed) {
				global.skill_cursor = scrSkillCursorNext(list, global.skill_cursor, 1);
				io_clear();
			}
			
			if (global.keyC) {
				var entry = list[global.skill_cursor];
				global.skill_selected = global.skill_cursor;

				//check cannot
				var cannot = false;
				if (entry.kind == "spell" && member.current_mana < entry.data.mp_cost) cannot = true;
				if (entry.kind == "skill" && entry.data.uses_left <= 0) cannot = true;

				if (cannot) {
					global.skill_cannot_timer = 90;
					io_clear();
					global.keyC = false;
					break;
				}
				
				//functional - apply immediately
				if (entry.data.effect_type == "functional") {
					if (entry.kind == "skill") member.use_skill(entry.index, []);
					show_debug_message("SKILL: used functional " + entry.label);
					io_clear();
					global.keyC = false;
					break;
				}
				
				//all party - apply immediately
				if (entry.data.target_type == "all_allies" || entry.data.target_type == "all_party") {
					if (entry.kind == "spell") {
						member.cast_spell(entry.index, global.party);
					} else {
						member.use_skill(entry.index, global.party);
					}
					show_debug_message("SKILL: used " + entry.label + " on all party");
					io_clear();
					global.keyC = false;
					break;
				}
				
				//single ally target
				if (entry.data.target_type == "single_ally" || entry.data.target_type == "single_party") {
					global.skill_state = SKILL_STATE.SELECT_TARGET;
					global.skill_target_cursor = 0;
					ds_stack_push(global.submenu_history, SUBMENU_HISTORY.SKILL_SELECT_TARGET);
					io_clear();
					global.keyC = false;
					show_debug_message("SKILL: selecting target for " + entry.label);
					break;
				}
				
				io_clear();
				global.keyC = false;
			}
		break;
		
		case SKILL_STATE.SELECT_TARGET:
			if (global.keyUpPressed) {
				global.skill_target_cursor = (global.skill_target_cursor - 1 + num_party) mod num_party;
				menu_cursor = global.skill_target_cursor;
				io_clear();
			}
			if (global.keyDownPressed) {
				global.skill_target_cursor = (global.skill_target_cursor + 1) mod num_party;
				menu_cursor = global.skill_target_cursor;
				io_clear();
			}
			
			if (global.keyC) {
				list  = scrSkillBuildList(global.skill_char);
				var entry = list[global.skill_selected];
				var target = global.party[global.skill_target_cursor];

				if (entry.kind == "spell") {
					member.cast_spell(entry.index, [target]);
				} else {
					member.use_skill(entry.index, [target]);
				}
				
				show_debug_message("SKILL: used " + entry.label + " on " + target.name);
				
				while (ds_stack_top(global.submenu_history) != SUBMENU_HISTORY.SKILL_SELECT_WHAT && ds_stack_size(global.submenu_history) > 1) {
					ds_stack_pop(global.submenu_history);
				}
				
				global.skill_state = SKILL_STATE.SELECT_WHAT;
				menu_cursor = global.skill_selected;
				io_clear();
				global.keyC = false;
			}
			break;
	}
}

function scrSkillBuildList(_char_idx) {
	var member = global.party[_char_idx];
	var result = [];

	if (array_length(member.spells) > 0) {
		array_push(result, { kind: "separator", label: "*SPELLS*", index: -1, data: undefined });
		for (var i = 0; i < array_length(member.spells); i++) {
			array_push(result, { kind: "spell", label: member.spells[i].name, index: i, data: member.spells[i] });
		}
	}
	
	if (array_length(member.skills) > 0) {
		array_push(result, { kind: "separator", label: "*SKILLS*", index: -1, data: undefined });
		for (var i = 0; i < array_length(member.skills); i++) {
			array_push(result, { kind: "skill", label: member.skills[i].name, index: i, data: member.skills[i] });
		}
	}
	
	return result;
}

function scrSkillCursorSelectable(_list, _cursor) {
	if (_cursor < 0 || _cursor >= array_length(_list)) return false;
	return _list[_cursor].kind != "separator";
}

function scrSkillCursorNext(_list, _cursor, _dir) {
	var size = array_length(_list);
	if (size == 0) return 0;
	var next  = (_cursor + _dir + size) mod size;
	var tries = 0;
	while (_list[next].kind == "separator" && tries < size) {
		next = (next + _dir + size) mod size;
		tries++;
	}
	return next;
}
//=====================================Stat Rollups=====================================
function scrStartRollup(_key, _from, _to) {
	if (_from == _to) {
		scrClearRollup(_key);
		return;
	}
	//replace any existing rollup for this key
	for (var i = 0; i < array_length(global.stat_rollups); i++) {
		if (global.stat_rollups[i].key == _key) {
			global.stat_rollups[i].from = global.stat_rollups[i].current;
			global.stat_rollups[i].to = _to;
			global.stat_rollups[i].elapsed = 0;
			return;
		}
	}
	array_push(global.stat_rollups, {
		key				: _key,
		from			: _from,
		to				: _to,
		current		: _from,
		elapsed	: 0,
		duration : 30
	});
}

function scrClearRollup(_key) {
	for (var i = array_length(global.stat_rollups) - 1; i >= 0; i--) {
		if (global.stat_rollups[i].key == _key) array_delete(global.stat_rollups, i, 1);
	}
}

//advance all rollups - call once per frame from oGameController Step
function scrUpdateRollups() {
	for (var i = array_length(global.stat_rollups) - 1; i >= 0; i--) {
		var r = global.stat_rollups[i];
		r.elapsed++;
		var t = clamp(r.elapsed / r.duration, 0, 1);
		r.current = round(lerp(r.from, r.to, t));
		if (t >= 1) {
			r.current = r.to;
			array_delete(global.stat_rollups, i, 1);//falls back to real value
		}
	}
}

//returns the value and color for drawing a stat
function scrGetStatDisplay(_key, _real_value) {
	for (var i = 0; i < array_length(global.stat_rollups); i++) {
		var r = global.stat_rollups[i];
		if (r.key == _key) {
			var col = (r.to > r.from) ? c_lime : c_orange;
			return { value: r.current, color: col };
		}
	}
	return { value: _real_value, color: c_white };
}

//draws a right-aligned stat value at (_x, _y) animating and coloring iof a rollup is active
function draw_stat_value(_key, _real_value, _x, _y) {
	var d = scrGetStatDisplay(_key, _real_value);
	var prev_halign = draw_get_halign();
	draw_set_halign(fa_right);
	draw_text_color(_x, _y, string(d.value), d.color, d.color, d.color, d.color, 1);
	draw_set_halign(prev_halign);
}

function draw_hp_value(_key, _current, _max, _x, _y, _dead) {
	var d = scrGetStatDisplay(_key, _current);
	var base_col = _dead ? c_red : c_white;
	var cur_col = (d.value != _current) ? d.color : base_col;
	var prev = draw_get_halign();
	draw_set_halign(fa_right);
	draw_text_color(_x, _y, string(d.value) + "/" + string(_max), cur_col, cur_col, cur_col, cur_col, 1);
	draw_set_halign(prev);
}

function scrFireEquipRollup (_before, _char) {
var _after = global.party[_char].get_effective_stats();
	scrStartRollup("atk_" + string(_char), _before.atk, _after.atk);
	scrStartRollup("def_" + string(_char), _before.def, _after.def);
	scrStartRollup("spd_" + string(_char), _before.spd, _after.spd);
	scrStartRollup("mental_" + string(_char), _before.mental, _after.mental);
	scrStartRollup("matk_" + string(_char), _before.mAtk, _after.mAtk);
	scrStartRollup("mdef_" + string(_char), _before.mDef, _after.mDef);
}