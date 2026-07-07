//====================================Equipment Constructor====================================
function cstrEquipment(_name = "No Item", _slot_type = "none", _atk = 0, _def = 0, _spd = 0, _mental =  0, _mAtk = 0, _mDef = 0) constructor {
		name = _name;
		slot_type = _slot_type;//head, body, feet, r_hand, l_hand, accessory, weapon, misc, none
		atk_bonus = _atk;
		def_bonus = _def;
		spd_bonus = _spd;
		mental_bonus = _mental;
		mAtk_bonus = _mAtk;
		mDef_bonus = _mDef;
		//accessory special effects - array of effect structs
		//effects: { type: "flat_stat|multiplier|teach_skill|teach_spell|auto_effect|stats }
		special_effects = [];
		
		//fluent setter for chaining special effects onto accessories
		static add_effect = function(_effect) {
			array_push(special_effects, _effect);
			return self;
		}
		
		//example : new cstrEquipment("Iron Sword", "right_hand", 15, 0, 2, 0, 0);
}

//=======================================Item Constructor=======================================
//types - consumable, weapon, armor, key, misc
//effect types - heal_hp, heal_mp, cure_status, damage, buff_stat
function cstrItem(_name, _type, _description = "", _value = 0) constructor {
	name					= _name;
	type						= _type;//consumable, weapon, armor, key, misc
	description			= _description;
	value						= _value;//sell/buy price, 0 - unsellable
	
	//effect fields for consumables
	effect_type			="none";		//heal_hp, heal_mp, cure_status, damage, buff_stat
	effect_amount	= 0;					//amount healed, damaged, buffed
	effect_stat			="";					//for buff_stat - atk, def, spd, mental etc
	target_type			= "single_ally";//for battle targeting
	
	
	//fluent setter allows chaining configuration after construction
	//eg var potion = new cstrIOtem("Potion", "consumable").set_effect("heal_hp", 50);
	static set_effect = function(_type, _amount, _stat = "") {
		effect_type			= _type;
		effect_amount	= _amount;
		effect_stat			=  _stat;
		return self;
	}
}

function scrInitItemGlobals(){
	//consumables
	global.it_potion					= new cstrItem("Potion",			"consumable", "Restores 20 HP", 10).set_effect("heal_hp",			20);
	global.it_stimpak				=	new cstrItem("Stimpak",		"consumable", "Restores 80 HP", 50).set_effect("heal_hp",			80);
	global.it_antitox				= new cstrItem("Antitox",			"consumable","Cures all status", 75).set_effect("cure_status",		0);
	global.it_antidote				= new cstrItem("Antidte",			"consumable","Cures poison", 40).set_effect("cure_status",			0, "poison");
	global.it_cyanide				= new cstrItem("Cyanide",		"consumable", "Damages you", 25).set_effect("damage",				45);
	global.it_revive					= new cstrItem("Revive",			"consumable", "Revives with 15HP", 100).set_effect("revive",		15);
	global.it_phoenix				= new cstrItem("Phoenix",		"consumable", "Fully Revives", 500).set_effect("revive",					0);
	
	//equipment
	global.it_sword					= new cstrEquipment("Sword",			"r_hand",				15, 0, 2, 0, 0, 0);
	global.it_dagger				= new cstrEquipment("Dagger",			"weapon",			8, 0, 5, 0, 0, 0);
	global.it_staff						= new cstrEquipment("Staff",				"two_hand",		5, 0, 0, 0, 8, 4);
	global.it_wand					= new cstrEquipment("Wand",			"r_hand",				3, 2, 3, 7, 1, 0);
	global.it_spear					= new cstrEquipment("Spear",			"two_hand",		20, 2, 0, 0, 0, 0);
	global.it_shield					= new cstrEquipment("Shield",			"l_hand",				0, 8, 0, 0, 0, 5);
	global.it_hat						= new cstrEquipment("Hat",				"head",					0, 4, 0, 0, 0, 2);
	global.it_helm					= new cstrEquipment("Helm",			"head",					0, 8, 0, 0, 0, 3);
	global.it_vest						= new cstrEquipment("Vest",				"body",					0, 6, 0, 0, 0, 3);
	global.it_plate					= new cstrEquipment("Plate",				"body",					0,13, 0, 0, 0, 6);
	global.it_boots					= new cstrEquipment("Boots",			"feet",					0, 3, 3, 0, 0, 0);
	global.it_greaves				= new cstrEquipment("Greaves",		"feet",					0, 5, 1, 0, 2, 2);
	global.it_mgcring				= new cstrEquipment("MgcRing",		"accessory",		0, 0, 0, 5, 5, 5);
	global.it_spdchrm			= new cstrEquipment("SpdChrm",	"accessory",		0, 0, 8, 0, 0, 0);
}

function scrRestorePartyAtInn() {
	for  (var i = 0; i < array_length(global.party); i++) {
		var member = global.party[i];
		if (member.has_status("poison")) continue;
		member.current_hp    = member.base_max_hp;
		member.current_mana  = member.base_max_mana;
	}
}
//==================================Equip Menu Logic==================================
function scrEquipLogic() {
	var num_party = array_length(global.partyOrder);
	var member = global.party[global.equip_char];
	
	switch global.equip_state {
		case EQUIP_STATE.SELECT_WHO:
			if (global.keyUpPressed) global.equip_char = (global.equip_char - 1 + num_party) mod num_party;
			if (global.keyDownPressed) global.equip_char = (global.equip_char + 1) mod num_party;
			if (global.keyUpPressed|| global.keyDownPressed) {
				menu_cursor = global.equip_char;
				io_clear();
			}
			
			if (global.keyC) {
				global.equip_state = EQUIP_STATE.SELECT_SLOT;
				global.equip_scroll_page = 0;
				global.equip_cursor = 0;
				ds_stack_push(global.submenu_history, SUBMENU_HISTORY.EQUIP_SELECT_SLOT);
				menu_cursor = 0;
				io_clear();
				global.keyC = false;
				show_debug_message("EQUIP: selected " + member.name);
			}
		break;
		
		case EQUIP_STATE.SELECT_SLOT:
			//build equippable list for this page
			var equip_list = scrEquipBuildList(global.equip_char);
			var list_size = array_length(equip_list);
			var page_start = global.equip_scroll_page * 5;
			var page_items = min(5, list_size - page_start);
			var has_next = (page_start + 5) < list_size;
			var is_last_page = !has_next && page_start > 0;
			var show_next = has_next || is_last_page;
			
			//if there is nothing equippable, C goes back
			if (list_size == 0) {
				if (global.keyC) {
					submenu_back();
					io_clear();
					global.keyC = false;
				}
				break;
			}
			
			if (global.keyUpPressed) {
				if (global.equip_cursor <= 0) {
				var max_cursor = show_next ? page_items : page_items - 1;
				global.equip_cursor = max_cursor;
				} else {
				global.equip_cursor--;
				}
				io_clear();
			}
			if (global.keyDownPressed) {
				var max_cursor = show_next ? page_items : page_items - 1;
				if (global.equip_cursor >= max_cursor) {
				global.equip_cursor = 0;
				} else {
				global.equip_cursor++;
				}
				io_clear();
			}
			if (global.keyC) {
				//check if cursor is on NEXT
				if (show_next && global.equip_cursor == 0) {
					if (is_last_page) {
						//FIRST - wrap to first page
						global.equip_scroll_page = 0;
					} else {
						//NEXT -advance page
						var total_pages = ceil(list_size / 5);
						global.equip_scroll_page = (global.equip_scroll_page + 1) mod total_pages;
					}
					global.equip_cursor = 0;
					io_clear();
					global.keyC = false;
					break;
				}
				
				//resolve actual item index 
				var item_cursor = show_next ? global.equip_cursor - 1 : global.equip_cursor;
				var actual_idx = page_start + item_cursor;
				if (actual_idx < 0 || actual_idx >= list_size) {io_clear(); global.keyC = false; break; }
				
				var inv_idx = equip_list[actual_idx].inv_idx;
				var item = member.inventory[inv_idx];
				var _s_before = member.get_effective_stats();
				
				//if already equipped, unequip item first
				if (member.is_equipped(item.name)) {
					var slot = member.equipped_in_slot(item.name);
					//if 2H, clear both hands
					if (item.slot_type == "two_hand") {
						member.unequip("r_Hand");
						member.unequip("l_Hand");
						show_debug_message("EQUIP: unequipped two-hander " + item.name + " from both hands");
					} else {
						member.unequip(slot);
						show_debug_message("EQUIP: unequipped " + item.name + " from " + slot);
					}
					scrFireEquipRollup(_s_before, global.equip_char);
					io_clear();
					global.keyC = false;
					break;
				}
				
				//2H
				if (item.slot_type == "two_hand") {
					member.unequip("r_Hand");
					member.unequip("l_Hand");
					member.equip("r_Hand", item);
					member.equip("l_Hand", item);
					show_debug_message("EQUIP: equipped two-hander " + item.name);
					scrFireEquipRollup(_s_before, global.equip_char);
					 io_clear();
					 global.keyC = false;
					break;
				}
				
				//offhand
				if (item.slot_type == "l_Hand") {
					//if rH holds a 2H, unequip from both slots first
					if (member.r_Hand.slot_type == "two_hand") {
						var two_h = member.r_Hand;
						member.unequip("r_Hand");
						member.unequip("l_Hand");
						show_debug_message("EQUIP: cleared two-hander " + two_h.name + " to equip offhand");
					}
					member.equip("l_Hand", item);
					show_debug_message("EQUIP: equipped offhand " + item.name + " to l_Hand");
					scrFireEquipRollup(_s_before, global.equip_char);
					io_clear();
					global.keyC = false;
					break;
				}
				
				//ambidextrous weapon
				if (item.slot_type == "weapon") {
					//if rH holds a 2H, unequip both slots first
					if (member.r_Hand.slot_type == "two_hand") {
						member.unequip("r_Hand");
						member.unequip("l_Hand");
						show_debug_message("EQUIP: cleared two-hander before equipping weapon");
					}
					global.equip_stats_before = member.get_effective_stats();
					//only go to hand selection if neither hand already holds this item
					global.equip_pending_item = inv_idx;
					global.equip_hand_cursor = 0;

					global.equip_state = EQUIP_STATE.SELECT_HAND;
					ds_stack_push(global.submenu_history, SUBMENU_HISTORY.EQUIP_SELECT_HAND);
					io_clear();
					global.keyC = false;
					show_debug_message("EQUIP: ambidextrous - select hand");
					break;
				}
				
				//all other slots
				var auto_slot = scrEquipAutoSlot(item.slot_type);
				if (auto_slot != "") {
					member.equip(auto_slot, item);
					show_debug_message("EQUIP: equipped " + item.name + " to " + auto_slot);
				}
				scrFireEquipRollup(_s_before, global.equip_char);
				io_clear();
				global.keyC = false;
			}
		break;
		
		case EQUIP_STATE.SELECT_HAND:
			if (global.keyUpPressed || global.keyDownPressed) {
			global.equip_hand_cursor = 1 - global.equip_hand_cursor;
			io_clear();
			}
			if (global.keyC) {
				var item = member.inventory[global.equip_pending_item];
				var slot = (global.equip_hand_cursor == 0) ? "r_Hand" : "l_Hand";
				member.equip(slot, item);
				show_debug_message("EQUIP: equipped " + item.name + " to " + slot);
				scrFireEquipRollup(global.equip_stats_before, global.equip_char);
				global.equip_state        = EQUIP_STATE.SELECT_SLOT;
				ds_stack_pop(global.submenu_history);
				global.equip_pending_item = -1;
				global.equip_hand_cursor  = 0;
				io_clear();
				global.keyC = false;
			}
		break;
	}
}

//returns array of { inv_idx, item } for equippable items
function scrEquipBuildList(_char_idx) {
	var member = global.party[_char_idx];
	var result = [];
	for (var i_idx = 0; i_idx < array_length(member.inventory); i_idx++) {
		var item = member.inventory[i_idx];
		var item_type = variable_struct_exists(item, "type") ? item.type : "";
		if (item_type == "consumable" || item_type == "key") continue;
		array_push(result, { inv_idx: i_idx, item: item });
	}
	return result;
}

//maps item type to default equipment slot
function scrEquipAutoSlot(_type) {
	switch(_type) {
		case "head":				return "head";
		case "body":				return "body";
		case "feet":					return "feet";
		case "armor":			return "body";//fallback for generic armor
		case "accessory":		return "accessory";
		case "weapon":			return "r_Hand";//default overriden by hand selection
		case "l_Hand":			return "l_Hand";
		case "l_hand":			return "l_Hand";
		case "r_Hand":			return "r_Hand";
		case "r_hand":			return "r_Hand";
		case "two_hand":		return "r_Hand";//placeholder, handled specially
		case "misc":				return "";//misc has no autoslot
		default:						return "";
	}
}


function scrProjectStatsOnEquip(_char_idx, _item) {
	var member = global.party[_char_idx];
	var before = member.get_effective_stats();
	
	//find which slot the item goes in
	var slot = scrEquipAutoSlot(_item.slot_type);
	if (slot == "") return before; // can't equip, return unchanged
	
	//2h - unequip both hands temporarily
	var old_r = undefined, old_l = undefined;
	if (_item.slot_type == "two_hand") {
		old_r = member.r_Hand;
		old_l = member.l_Hand;
		member.r_Hand = new cstrEquipment();
		member.l_Hand = new cstrEquipment();
	} else if (slot == "r_Hand" && member.l_Hand.slot_type == "two_hand") {
		old_r = member.r_Hand;
		old_l = member.l_Hand;
		member.r_Hand = new cstrEquipment();
		member.l_Hand = new cstrEquipment();
	} else {
		//save old item in slot
		old_r = member[$ slot];
		member[$ slot] = _item;
	}
	
	var after = member.get_effective_stats();
	
	//restore
	if (_item.slot_type == "two_hand" || (slot == "r_Hand" && old_l != undefined)) {
		member.r_Hand = old_r;
		member.l_Hand = old_l;
	} else {
		member[$ slot] = old_r;
	}
	
	return { before: before, after: after };
}
