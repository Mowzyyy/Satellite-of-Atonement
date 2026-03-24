//Party Character Constructor
	
//====================================Equipment Constructor====================================
function cstrEquipment(_name = "No Item", _slot_type = "none", _atk = 0, _def = 0, _spd = 0, _mAtk = 0, _mDef = 0) constructor {
		name = _name;
		slot_type = _slot_type;//head, right hand, left hand, body, feet
		atk_bonus = _atk;
		def_bonus = _def;
		spd_bonus = _spd;
		mAtk_bonus = _mAtk;
		mDef_bonus = _mDef;
		
		//example : new cstrEquipment("Iron Sword", "right_hand", 15, 0, 2, 0, 0);
}

//====================================Main Party Constructor====================================

function cstrPartyMember(_name, _level = 1, _bio = "Yux") constructor {
	//Basic Info
	name = _name;
	bio = _bio;
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
	base_mAtk = 6 + (level * 3);
	base_mDef = 6 + (LEVEL * 2);

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
	
	//Helper Methods - call these from objects
	
	static get_effective_stats = function() {
		var stats = {};
		
		stats.maxhp			= base_max_hp;
		stats.max_mana	= base_max_mana;
		stats.atk					= base_atk + head.atk_bonus + r_Hand.atk_bonus + l_Hand.atk_bonus + body.atk_bonus + feet.atk_bonus;
		stats.def					= base_def + head.def_bonus + r_Hand.def_bonus + l_Hand.def_bonus + body.def_bonus + feet.def_bonus;
		stats.spd					= base_spd + head.spd_bonus + r_Hand.spd_bonus + l_Hand.spd_bonus + body.spd_bonus + feet.spd_bonus;
		stats.mAtk				= base_mAtk + head.mAtk_bonus + r_Hand.mAtk_bonus + l_Hand.mAtk_bonus + body.mAtk_bonus + feet.mAtk_bonus;
		stats.mDef				= base_mDef + head.mDef_bonus + r_Hand.mDef_bonus + l_Hand.mDef_bonus + body.mDef_bonus + feet.mDef_bonus;

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
		base_mAtk += 3 + irandom(2);
		base_mDef += 2 + irandom(2);
		
		//refill HP and mana on levelup
		current_hp = base_max_hp;
		current_mana = base_max_mana;
		
		exp_to_next = level * 120; //simple curve, tweak as needed
		
		show_debug_message(name + " reached level " + string(level) + "!");
		
		//TODO - check for new skills here
		//eg: if level >= 5 && _bio "Yux" tthen learn skill etc
		
	}
	
	//debug print
	static print_stats = function() {
		var s = get_effective_stats();
		show_debug_message("=== " + name + "(Lv." + string(level) + ") ===");
		show_debug_message("HP: " + string(current_hp) + "/" + string(s.maxhp) + " | Mana: " + string(current_mana) + "/" + string(s.max_mana));
		show_debug_message("Atk: " + string(s.atk) + " Def:" + string(s.def) + " Spd:" + string(s.spd));
		show_debug_message("mAtk:" +string(s.mAtk) + "mDef:" + string(s.mDef));
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