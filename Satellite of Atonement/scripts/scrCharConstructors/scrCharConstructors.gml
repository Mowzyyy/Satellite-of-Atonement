//Party Character Constructor
	
//====================================Equipment Constructor====================================
function cstrEquipment(_name = "No Item", _slot_type = "none", _atk = 0, _def = 0, _spd = 0, _mental =  0, _mAtk = 0, _mDef = 0) constructor {
		name = _name;
		slot_type = _slot_type;//head, right hand, left hand, body, feet
		atk_bonus = _atk;
		def_bonus = _def;
		spd_bonus = _spd;
		mental_bonus = _mental;
		mAtk_bonus = _mAtk;
		mDef_bonus = _mDef;
		
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
	effect_state			="";					//for buff_stat - atk, def, spd, mental etc
	
	//fluent setter allows chaining configuration after construction
	//eg var potion = new cstrIOtem("Potion", "consumable").set_effect("heal_hp", 50);
	static set_effect = function(_type, _amount, _stat = "") {
		effect_type			= _type;
		effect_amount	= _amount;
		effect_state			=  _stat;
		return self;
	}
}

//====================================Main Party Constructor====================================

function cstrPartyMember(_name, _level = 1, _bio = "???", _age = 0, _species = "???", _can_use_magic = true) constructor {
	//Basic Info
	name = _name;
	bio = _bio;
	age = _age;
	species = _species;
	can_use_magic = _can_use_magic;
	level = _level;
	experience = 0;
	exp_to_lvup = 100;
	
	///Core Stats - base values, equipment will modify these numbers
	// HP / Mana use max + current so you can damage/heal without losing max values
	base_max_hp = 80 + (level * 12);//Phantasy star growth default
	current_hp = base_max_hp;
	
	base_max_mana = 30 + (level * 8);
	current_mana = base_max_mana;
	
	base_atk = 12 + (level * 3);
	base_def = 8 + (level * 2)
	base_spd = 10 + (level * 2);
	base_mental = 10 + (level * 3);

	//Equip	Slots
	head = new cstrEquipment();//starts empty
	r_Hand = new cstrEquipment();
	l_Hand = new cstrEquipment();
	body = new cstrEquipment();
	feet = new cstrEquipment();
	
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
		stats.atk					= base_atk + head.atk_bonus + r_Hand.atk_bonus + l_Hand.atk_bonus + body.atk_bonus + feet.atk_bonus + battle_buffs.atk;
		stats.def					= base_def + head.def_bonus + r_Hand.def_bonus + l_Hand.def_bonus + body.def_bonus + feet.def_bonus + battle_buffs.def;
		stats.spd					= base_spd + head.spd_bonus + r_Hand.spd_bonus + l_Hand.spd_bonus + body.spd_bonus + feet.spd_bonus + battle_buffs.spd;
		stats.mental			= base_mental + head.mental_bonus + r_Hand.mental_bonus + l_Hand.mental_bonus + body.mental_bonus + battle_buffs.mental;
		
		stats.mAtk				= floor(stats.mental * 0.6 + stats.atk * 0.4) + floor(base_max_mana / 4) + head.mAtk_bonus + r_Hand.mAtk_bonus + l_Hand.mAtk_bonus + body.mAtk_bonus + feet.mAtk_bonus + battle_buffs.mAtk;
		stats.mDef				= floor(stats.mental * 0.6 + stats.def * 0.4) + floor(stats.spd / 4) + head.mDef_bonus + r_Hand.mDef_bonus + l_Hand.mDef_bonus + body.mDef_bonus + feet.mDef_bonus + battle_buffs.mDef;

		return stats;
	}
	
	//Equip an item to a slot - automatically unequips old item if any
	static equip = function(_slot, _item) {
		//validate slot type
		if (_item.slot_type != _slot && _item.slot_type != "none") {
			show_debug_message("WARNING: " + _item.name + " is not for " + _slot + " slot!")
			return;
		}
		
		switch (_slot) {
			case "head":					head				=_item; break;
			case "r_Hand":				r_Hand			=_item; break;
			case "l_Hand":				l_Hand			=_item; break;
			case "body":					body				=_item; break;
			case "feet":						feet				=_item; break;
			default: show_debug_message("Invalid slot: " + _slot);
		}
	}
	
	//Simple levelup - can expand with specific growth tables later
	static level_up = function() {
		level++;
		
		//Phantasy Star-style growth
		base_max_hp += 12 + irandom(4);
		base_max_mana += 8 + irandom(3);
		base_atk += 3 + irandom(2);
		base_def += 2 + irandom(2);
		base_spd += 2 + irandom(2);
		base_mental += 3 + irandom(2);
		
		//refill HP and mana on levelup
		current_hp = base_max_hp;
		current_mana = base_max_mana;
		
		exp_to_next = level * 120; //simple curve, tweak as needed
		
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
		battle_buffs = { atk: 0, def: 0, spd: 0, mental: 0 };
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
		show_debug_message("Mental: " + string(stats.mental) + "mAtk: " +string(s.mAtk) + "mDef:" + string(s.mDef));
		show_debug_message("Equipment: " + head.name + " | " + r_Hand.name + " | " + l_Hand.name + " | " + body.name + " | " + feet.name);
	}
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