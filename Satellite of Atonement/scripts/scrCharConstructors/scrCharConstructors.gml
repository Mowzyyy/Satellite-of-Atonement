//Party Character Constructor
	
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
	
	
	//fluent setter allows chaining configuration after construction
	//eg var potion = new cstrIOtem("Potion", "consumable").set_effect("heal_hp", 50);
	static set_effect = function(_type, _amount, _stat = "") {
		effect_type			= _type;
		effect_amount	= _amount;
		effect_stat			=  _stat;
		return self;
	}
}

//====================================Main Party Constructor====================================

function cstrPartyMember(_name, 
	_bio = "???", _age = 0, _species = "???", _can_use_magic = true, _level = 1,
	_base_hp = 80, _base_mp = 30, _base_atk = 12, _base_def = 8, _base_spd = 10, _base_mental = 10,
	_hp_growth = 12.0, _mp_growth = 8.0, _atk_growth = 3.0, _def_growth = 2.0, _spd_growth = 2.0, _mental_growth = 2.5,
	_mAtk_mod = 0, _mDef_mod = 0
	) constructor {
	//Basic Info
	name = _name;
	bio = _bio;
	age = _age;
	species = _species;
	can_use_magic = _can_use_magic;
	level = _level;
	experience = 0;
	exp_to_lvup = 100;
	
	hp_growth = _hp_growth;
	mp_growth = _mp_growth;
	atk_growth = _atk_growth;
	def_growth = _def_growth;
	spd_growth = _spd_growth;
	mental_growth = _mental_growth;
	
	//archetype mods - set once and never change
	base_mAtk_mod = _mAtk_mod;
	base_mDef_mod = _mDef_mod;
	
	///Core Stats - base values, equipment will modify these numbers
	base_max_hp		= _base_hp				+ round(_hp_growth			* (_level - 1));
	base_max_mana	= _base_mp			+ round (_mp_growth			* (_level - 1));
	base_atk					=	_base_atk			+ round (_atk_growth			* (_level - 1));
	base_def					= _base_def				+ round (_def_growth			* (_level - 1));
	base_spd					= _base_spd			+ round (_spd_growth		* (_level - 1));
	base_mental			= _base_mental		+ round (_mental_growth	* (_level -1));
	
	current_hp = base_max_hp;
	current_mana = base_max_mana;

	//Equip	Slots
	head = new cstrEquipment();//starts empty
	r_Hand = new cstrEquipment();
	l_Hand = new cstrEquipment();
	body = new cstrEquipment();
	feet = new cstrEquipment();
	accessory = new cstrEquipment();
	
	//Non-Mana Combat Skills
	skills = [];//Array of skill structs or strings - can push new ones as they level up
	
	//example 
	//skills = [ { name: "Power Slash", power: 25, cooldown: 0, learned: true } ];
	
	//Inventory - up to 20 items not counting equipped gear
	inventory = array_create(0);//array of cstrItem instances
	
	//status effects - array of strings like poison or stun
	status_effects = [];
	
	//temporary battle buffs - reset at end of battle
	battle_buffs = {
		atk:				0,
		def:				0,
		spd:				0,
		mental:			0,
		mAtk:			0,
		mDef:			0
	};
	
	//Helper Methods - call these from objects
	
	static get_effective_stats = function() {
		var stats = {};
		
		stats.maxhp			= base_max_hp;
		stats.max_mana	= base_max_mana;
		stats.atk					= base_atk + head.atk_bonus + r_Hand.atk_bonus + l_Hand.atk_bonus + body.atk_bonus + feet.atk_bonus + battle_buffs.atk + accessory.atk_bonus;
		stats.def					= base_def + head.def_bonus + r_Hand.def_bonus + l_Hand.def_bonus + body.def_bonus + feet.def_bonus + battle_buffs.def + accessory.def_bonus;
		stats.spd					= base_spd + head.spd_bonus + r_Hand.spd_bonus + l_Hand.spd_bonus + body.spd_bonus + feet.spd_bonus + battle_buffs.spd + accessory.spd_bonus;
		stats.mental			= base_mental + head.mental_bonus + r_Hand.mental_bonus + l_Hand.mental_bonus + body.mental_bonus + feet.mental_bonus + battle_buffs.mental + accessory.mental_bonus;
		
		stats.mAtk				= floor(stats.mental * 0.6 + stats.atk * 0.4) + floor(base_max_mana / 4) + base_mAtk_mod + head.mAtk_bonus + r_Hand.mAtk_bonus + l_Hand.mAtk_bonus + body.mAtk_bonus + feet.mAtk_bonus + battle_buffs.mAtk + accessory.mAtk_bonus;
		stats.mDef				= floor(stats.mental * 0.6 + stats.def * 0.4) + floor(stats.spd / 4) + base_mDef_mod + head.mDef_bonus + r_Hand.mDef_bonus + l_Hand.mDef_bonus + body.mDef_bonus + feet.mDef_bonus + battle_buffs.mDef + accessory.mDef_bonus;
		
		//apply multiplier effects from accessories
		for (var i_acc = 0; i_acc < array_length(accessory.special_effects); i_acc++) {
			var fx = accessory.special_effects[i_acc];
			if (fx.type == "multiplier") {
				stats[$ fx.stat] = floor(stats[$ fx.stat] * fx.value);
			}
		}

		return stats;
	}
	
	//Equip an item to a slot - automatically unequips old item if any
	static equip = function(_slot, _item) {
		//validate slot type
		if (_item.slot_type != _slot 
		&& _item.slot_type != "none" 
		&& _item.slot_type != "weapon" 
		&& _item.slot_type != "armor"
		&& _item.slot_type != "r_hand"
		&& _item.slot_type != "l_hand") {
			show_debug_message("WARNING: " + _item.name + " is not for " + _slot + " slot!")
			return;
		}
		
		switch (_slot) {
			case "head":					head				=_item; break;
			case "r_Hand":				r_Hand			=_item; break;
			case "l_Hand":				l_Hand			=_item; break;
			case "body":					body				=_item; break;
			case "feet":						feet				=_item; break;
			case "accessory":			accessory	=_item; break;
			default: show_debug_message("Invalid slot: " + _slot);
		}
	}
	
	static unequip = function (_slot) {
		equip(_slot, new cstrEquipment());
	}
	
	//returns true if the item is currently equipped in any slot
	static is_equipped = function(_item_name) {
		if (head.name				== _item_name) return true;
		if (r_Hand.name			== _item_name) return true;
		if (l_Hand.name			== _item_name) return true;
		if (body.name				== _item_name) return true;
		if (feet.name					== _item_name) return true;
		if (accessory.name		== _item_name) return true;
		return false;
	}
	
	//returns which slot an item is equipped in, or "" if none
	static equipped_in_slot = function(_item_name) {
		if (head.name				== _item_name) return "head";
		if (r_Hand.name			== _item_name) return "r_Hand";
		if (l_Hand.name			== _item_name) return "l_Hand";
		if (body.name				== _item_name) return "body";
		if (feet.name					== _item_name) return "feet";
		if (accessory.name		== _item_name) return "accessory";
		return "";
	}
	
	//Simple levelup - can expand with specific growth tables later
	static level_up = function() {
		level++;
		
		//Phantasy Star-style growth
		base_max_hp			+= floor(hp_growth)				+ irandom(4);
		base_max_mana		+= floor(mp_growth) 				+ irandom(3);
		base_atk						+= floor(atk_growth) 				+ irandom(2);
		base_def						+= floor(def_growth)				+ irandom(2);
		base_spd						+= floor(spd_growth)				+ irandom(2);
		base_mental				+= floor(mental_growth)		+ irandom(2);
		
		//refill HP and mana on levelup
		current_hp = base_max_hp;
		current_mana = base_max_mana;
		
		exp_to_lvup = level * 120; //simple curve, tweak as needed
		
		show_debug_message(name + " reached level " + string(level) + "!");
		
		//TODO - check for new skills here
		//eg: if level >= 5 && _bio "Yux" tthen learn skill etc
		
	}
	
	//add an item to inventory - returns true if successful, false if full
	static add_item = function(_item) {
		if (array_length(inventory) >= 20) return false;
		array_push(inventory, _item);
		return true;
	}
	
	//Remove item at index - returns the item or undefined if invalid
	static remove_item = function(_index) {
		if (_index < 0 || _index >= array_length(inventory)) return undefined;
		var item = inventory[_index];
		array_delete(inventory, _index, 1);
		return item;
	}
	
	//Use an item at index on a target party member struct, returns true if the item was consumed, false if no effect
	static use_item = function(_index, _target) {
		if (_index < 0 || _index >= array_length(inventory)) return false;
		var item = inventory[_index];
		if (!variable_struct_exists(item, "type")) return false;
		if (item.type != "consumable") return false;
		
		var used = false;
		
		switch (item.effect_type) {
			case "heal_hp":
				if (_target.current_hp < _target.base_max_hp) {
					_target.current_hp = min(_target.current_hp + item.effect_amount, _target.base_max_hp);
					used = true;
				}
			break;
			
			case "heal_mp":
				if (_target.current_mana < _target.base_max_mana) {
					_target.current_mana = min(_target.current_mana + item.effect_amount, _target.base_max_mana);
					used = true;
				}
			break;
			
			case "cure_status":
				if (array_length(_target.status_effects) > 0) {
					_target.status_effects = [];	
					used = true;
				}
			break;
				
			case "damage":
				//direct damage, typically used outside battle for story items
				_target.current_hp = max(_target.current_hp - item.effect_amount, 0);
				used = true;
			break;
		
		case "buff_stat":
			if (item.effect_stat != "") {
				_target.battle_buffs[$ item.effect_stat] += item.effect_amount;
				used = true;
			}
		break;
		}
		
		if (used) array_delete(inventory, _index, 1);
		return used;
	}
	
	//adds multiple items
	static add_items = function() {
		for (var i_add = 0; i_add < argument_count; i_add++) {
			add_item(argument[i_add]);
		}
		return self;
	}
	
	//reset battle buffs - call at the end of the battle
	static reset_battle_buffs = function() {
		battle_buffs = { atk: 0, def: 0, spd: 0, mental: 0, mAtk: 0, mDef: 0 };
	}
	
	//check if a status is present
	static has_status = function(_status) {
		for (var i_status = 0; i_status < array_length(status_effects); i_status++) {
			if (status_effects[i_status] == _status) return true;
		}
		return false;
	}
	
	//Add a status effect if not already present
	static add_status = function (_status) {
		if (!has_status(_status)) array_push(status_effects, _status);
	}
	
	static remove_status = function(_status) {
		for (var i_rem = array_length(status_effects) - 1; i_rem >= 0; i_rem--) {
			if (status_effects[i_rem] == _status) array_delete(status_effects, i_rem, 1);
		}
	}
	
	//debug print
	static print_stats = function() {
		var s = get_effective_stats();
		show_debug_message("=== " + name + "(Lv." + string(level) + ") ===");
		show_debug_message("HP: " + string(current_hp) + "/" + string(s.maxhp) + " | Mana: " + string(current_mana) + "/" + string(s.max_mana));
		show_debug_message("Atk: " + string(s.atk) + " Def:" + string(s.def) + " Spd:" + string(s.spd));
		show_debug_message("Mental: " + string(s.mental) + "mAtk: " +string(s.mAtk) + "mDef:" + string(s.mDef));
		show_debug_message("Equipment: " + head.name + " | " + r_Hand.name + " | " + l_Hand.name + " | " + body.name + " | " + feet.name);
	}
}

function cstrLeon() {						//Initialize Leon creation
	return new cstrPartyMember("Leon", "Spearman", 20, "Human", true, 1, 
	18, 10, 21, 8, 13, 10,						//lv 1 bases - hp, mp, atk, def, spd, mental
	7.5, 3.86, 2.43, 1.64, 2.64, 2.5,		//growth rate
	-4, 3);													//mAtk and mDef mods
}

function cstrCoat() {
	return new cstrPartyMember("Coat", "Scout", 45, "Yux", true, 1,
	30, 14, 12, 12, 28, 20,
	5.68, 4.68, 2.91, 1.09, 2.54, 1.8,
	13, 13);
}

function cstrOsei() {
	return new cstrPartyMember("Osei", "Wizard", 54, "Human", true, 21,
	8, 26, 10, 14, 20, 25,
	5.5, 6.23, 1.96, 1.18, 1.59, 2.8,
	5, 5);
}

function cstrAnna() {
	return new cstrPartyMember("Anna", "General", 30, "Human", true, 1,
	20, 4, 20, 20, 14, 8,
	4.32, 2.64, 2.5, 1.82, 1.5, 2.0,
	-1, -1);
}

function cstrData() {
	return new cstrPartyMember("Data", "Android", 4, "Android", false, 1,
	9, 0, 25, 6, 25, 12,
	7.02, 0.0, 2.16, 1.68, 1.98, 2.2,
	3, 5);
}

//====================
//HOW TO USE
//====================
//Example: Create a main party in oGameController

//create party members
//array_push(global.party new cstrPartyMember("Leon", 1, "Spearman"));
//array_push(global.party new cstrPartyMember("Coat", 1, "Yux"));
//array_push(global.party, new, cstrPartyMember("Osei", 1, "Wizard"));

//Equip some starting gear
//var sword = new cstrEquipment("Iron Sword", "r_Hand", 15, 0, 3, 0, 0);
//global.party[0].equip("r_Hand", sword);
//
//var shield = new cstrEquipment("Wooden Shield", "l_Hand, 0, 8, 0, 0, 5);
//global.party[0].equip("l_Hand", shield);

//Learn a skill later
//global.party[0].learn_skill("Power Slash", 25, 2);

//In the battle/step code
//var stats = global.party[0].get_effective_stats();
//damage = stats.atk + ... etc

//level someone up:
//global.party[0].level_up();
//global.partyy[0].print_stats();