//Party Character Constructor
	

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
	spells = [];
	
	//Inventory - up to 20 items not counting equipped gear
	inventory = [];
	
	//status effects - array of strings like poison or stun
	status_effects = [];
	is_dead = false;
	
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
		
		stats.max_hp			= base_max_hp;
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
		&& _item.slot_type != "two_hand"
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
		var _before = {
			level: level,
			max_hp: base_max_hp, max_mp: base_max_mana,
			atk: base_atk, def: base_def, spd: base_spd, mental: base_mental
		};
		
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
		
		//display only: xp remaining until next level
		exp_to_lvup = xp_threshold(name, level) - experience; 
		
		show_debug_message(name + " reached level " + string(level) + "!");
		
		//Check for spells and skills
		learn_spells_at_level(name, level);
		learn_skills_at_level(name, level);
		
		var _after = {
			level: level,
			max_hp: base_max_hp, max_mp: base_max_mana,
			atk: base_atk, def: base_def, spd: base_spd, mental: base_mental
		};
		return { before: _before, after: _after };
		
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
				if (_target.is_dead || _target.has_status("poison")) break;
				if (_target.current_hp < _target.base_max_hp) {
					_target.current_hp = min(_target.current_hp + item.effect_amount, _target.base_max_hp);
					used = true;
				}
			break;
			
			case "heal_mp":
				if (_target.is_dead || _target.has_status("poison")) break;
				if (_target.current_mana < _target.base_max_mana) {
					_target.current_mana = min(_target.current_mana + item.effect_amount, _target.base_max_mana);
					used = true;
				}
			break;
			
			case "revive":
				if (!_target.is_dead) break;
				_target.is_dead = false;
				_target.current_hp = item.effect_amount > 0 ? item.effect_amount : _target.base_max_hp;
				_target.check_death();
				used = true;
			break;
			
			case "cure_status":
				if (item.effect_stat != "") {
					if (_target.has_status(item.effect_stat)) {
						_target.remove_status(item.effect_stat);
						used = true;
					}
				} else if (array_length(_target.status_effects) > 0) {
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
	
	static cast_spell = function(_index, _targets) {
		if (_index < 0 || _index >= array_length(spells)) return false;
		var spell = spells[_index];
		if (current_mana < spell.mp_cost) return false;
		current_mana -= spell.mp_cost;
		
		var s = get_effective_stats();
		var mpower = floor(s.mAtk * (spell.mpower / 100));
		
		if (!is_array(_targets)) _targets = [_targets];
		for (var i = 0; i < array_length(_targets); i++) {
			var t = _targets[i];
			switch (spell.effect_type) {
				case "heal_hp":
					if (!t.has_status("poison")) {
						t.current_hp = min(t.current_hp + mpower, t.base_max_hp);
					}
					break;
				case "heal_mp":
					if (!t.has_status("poison")) {
						t.current_mana = min(t.current_mana + mpower, t.base_max_mana);
					}
					break;
				case "damage":
					t.current_hp = max(t.current_hp - mpower, 0);
					break;
				case "cure_status":
					t.status_effects = [];
					break;
				case "buff_stat":
					t.battle_buffs.mental += mpower;
					break;
				case "functional":
					break;
			}
		}
		return true;
	}
	
	static use_skill = function(_index, _targets) {
		if (_index < 0 || _index >= array_length(skills)) return false;
		var skill = skills[_index];
		if (skill.uses_left <= 0) return false;
		skill.uses_left--;
		
		if (!is_array(_targets)) _targets = [_targets];
		for (var i = 0; i < array_length(_targets); i++) {
			var t = _targets[i];
			switch (skill.effect_type) {
				case "heal_hp":
					t.current_hp = min(t.current_hp + skill.uses_max, t.base_max_hp);
					break;
				case "functiona;":
					break;
			}
		}
		return true;
	}
	
	//adds multiple items
	static add_items = function() {
		for (var i_add = 0; i_add < argument_count; i_add++) {
			add_item(argument[i_add]);
		}
		return true;
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
	
	//check if the character is dead
	static check_death = function() {
		if (current_hp <= 0 && !is_dead) {
			current_hp = 0;
			is_dead = true;
			show_debug_message(name + " is incapacitated");
		}
	}
	
	//debug print
	static print_stats = function() {
		var s = get_effective_stats();
		show_debug_message("=== " + name + "(Lv." + string(level) + ") ===");
		show_debug_message("HP: " + string(current_hp) + "/" + string(s.max_hp) + " | Mana: " + string(current_mana) + "/" + string(s.max_mana));
		show_debug_message("Atk: " + string(s.atk) + " Def:" + string(s.def) + " Spd:" + string(s.spd));
		show_debug_message("Mental: " + string(s.mental) + "mAtk: " +string(s.mAtk) + "mDef:" + string(s.mDef));
		show_debug_message("Equipment: " + head.name + " | " + r_Hand.name + " | " + l_Hand.name + " | " + body.name + " | " + feet.name);
	}
}

//==================================XP TABLES==================================

function scrInitExpTables(){
	global.xp_table_leon = [
// Lv1–9
         6,     18,     51,    100,    160,    252,    393,    573,    775,
// Lv10–18
       950,   1164,   1409,   1692,   2020,   2400,   2878,   3479,   4202,
// Lv19–27
      5075,   6000,   7378,   9233,  11356,  13503,  15000,  16933,  18948,
// Lv28–36
     20939,  22800,  24000,  25199,  26302,  27488,  28832,  30000,  31501,
// Lv37–45
     33173,  35016,  37033,  38000,  40513,  43125,  45849,  48000,  51000,
// Lv46–54
     54267,  57816,  61660,  64344,  68312,  72575,  77132,  81990,  87154,
// Lv55–63
     92627,  98793, 105315, 111881, 118822, 126159, 133905, 141984, 150406,
// Lv64–72
    159188, 168343, 177887, 187834, 198197, 208990, 220227, 231921, 244086,
// Lv73–81
    256736, 269884, 283543, 297728, 312452, 327729, 343573, 360000, 376984,
// Lv82–90
    394603, 412876, 431819, 451450, 471785, 492843, 514641, 537198, 560533,
// Lv91–98
    584665, 609613, 635396, 662034, 689547, 717954, 747275, 777530
	];
global.xp_table_coat = [
// Lv1–9
        15,     75,    208,    390,    600,    905,   1345,   1853,   2360,
// Lv10–18
      2800,   3146,   3446,   3742,   4079,   4500,   5054,   5751,   6570,
// Lv19–27
      7493,   8500,  10006,  12029,  14022,  15697,  16000,  17607,  19318,
// Lv28–36
     20926,  22225,  22000,  22604,  23487,  24651,  26000,  27013,  27613,
// Lv37–45
     27880,  27990,  28011,  27913,  27990,  28082,  28187,  28304,  28433,
// Lv46–54
     28573,  28718,  28867,  29017,  29166,  29313,  29458,  29599,  29737,
// Lv55–63
     29870,  29000,  29100,  29200,  29300,  29400,  29500,  29600,  29700,
// Lv64–72
     29800,  29900,  30000,  30080,  30160,  30240,  30320,  30400,  29667,
// Lv73–81
     29750,  29833,  29917,  30000,  30084,  30168,  30252,  30336,  30420,
// Lv82–90
     30504,  30588,  30672,  30756,  30840,  30924,  31000,  31075,  31150,
// Lv91–98
     31225,  31300,  31375,  31450,  31500,  31500,  31500,  31500
];

global.xp_table_osei = [
// Lv1–9
         9,     30,     88,    171,    290,    453,    709,   1031,   1396,
// Lv10–18
      1800,   2205,   2659,   3181,   3789,   4500,   5357,   6416,   7697,
// Lv19–27
      9217,  11000,  13519,  17009,  21031,  25162,  29000,  32565,  36199,
// Lv28–36
     39743,  43047,  46000,  48421,  50507,  52481,  54569,  57000,  59849,
// Lv37–45
     63029,  66482,  70152,  74000,  78064,  82447,  87104,  92000,  97504,
// Lv46–54
    103380, 109698, 116469, 123764, 131478, 139680, 148390, 157621, 167387,
// Lv55–63
    177702, 192560, 204993, 217663, 230591, 243796, 257291, 271091, 285207,
// Lv64–72
    299652, 314438, 329577, 345080, 360960, 377228, 393896, 410977, 428483,
// Lv73–81
    446424, 464814, 483663, 502983, 522785, 543081, 563882, 585200, 607047,
// Lv82–90
    629437, 652381, 675892, 699983, 724665, 749952, 775854, 802385, 829559,
// Lv91–98
    857387, 885884, 915060, 944929, 975501,1006791,1038810,1071570
];

global.xp_table_anna = [
// Lv1–9
         3,      6,     12,     23,     35,     55,     87,    129,    181,
// Lv10–18
       240,    313,    410,    537,    699,    900,   1220,   1736,   2452,
// Lv19–27
      3372,   4500,   7187,  11942,  17503,  22609,  26000,  28024,  29817,
// Lv28–36
     31298,  32386,  33000,  33296,  33508,  33672,  33824,  34000,  34208,
// Lv37–45
     34423,  34634,  34830,  35000,  35147,  35280,  35399,  35500,  35624,
// Lv46–54
     35765,  35921,  36090,  36312,  36516,  36729,  36951,  37182,  37421,
// Lv55–63
     37670,  37927,  38193,  38466,  38748,  39000,  39186,  39384,  39593,
// Lv64–72
     39814,  40046,  40290,  40546,  40813,  41000,  41133,  41277,  41431,
// Lv73–81
     41596,  41771,  41956,  42000,  42066,  42168,  42282,  42355,  42399,
// Lv82–90
     42420,  42422,  42408,  42380,  42399,  42419,  42439,  42459,  42479,
// Lv91–98
     42499,  42500,  42500,  42500,  42500,  42500,  42500,  42500
];

global.xp_table_data = [
// Lv1–9
         8,     26,     75,    146,    230,    357,    550,    793,   1065,
// Lv10–18
      1350,   1646,   1973,   2348,   2786,   3300,   3940,   4746,   5722,
// Lv19–27
      6873,   8200,  10079,  12648,  15558,  18458,  21000,  23193,  25284,
// Lv28–36
     27278,  29182,  31000,  32685,  34243,  35757,  37315,  39000,  40838,
// Lv37–45
     42781,  44805,  46886,  49000,  51157,  53381,  55664,  58000,  61026,
// Lv46–54
     64352,  67988,  71945,  74133,  78682,  83566,  88796,  94383, 100340,
// Lv55–63
    106677, 108919, 115924, 123359, 131229, 139541, 148300, 157513, 167186,
// Lv64–72
    177325, 187937, 199028, 210604, 222671, 235234, 248300, 261874, 275963,
// Lv73–81
    290573, 305709, 321378, 337586, 354338, 371641, 389500, 407923, 426914,
// Lv82–90
    446480, 466626, 487358, 508682, 530604, 553129, 576264, 600015, 624388,
// Lv91–98
    649389, 675025, 701302, 728226, 755804, 784042, 812948, 842527
];

}
//returns xp as needed to advance
function xp_threshold(_name, _level) {
	if (_level < 1 || _level > 98) return 0;
	var idx = _level - 1;
	switch (_name) {
		case "Leon": return global.xp_table_leon[idx];
		case "Coat": return global.xp_table_coat[idx];
		case "Osei": return global.xp_table_osei[idx];
		case "Anna": return global.xp_table_anna[idx];
		case "Data": return global.xp_table_data[idx];
		default:
			show_debug_message("WARNING: xp_threshold — unknown character '" + _name + "'");
			return global.xp_table_leon[idx];
	}
}
//===============================EXP AWARD HANDLING===============================
//Add to battle end/enemyt death handler
//called once per enemy death - awards xp to all lviing party members
function award_xp(_xp_value) {
	for (var i = 0; i < array_length(global.party); i++) {
		var member = global.party[i];
		if (member.current_hp <= 0) continue;
		
		member.experience += _xp_value;
		
		while (member.level < 99 && member.experience >= xp_threshold(member.name, member.level)) {
			var res = member.level_up();
			array_push(global.battle_msgs, {
				kind: "levelup",
				name: member.name,
				before: res.before,
				after: res.after
			});
		}
	}
}

//===================================PARTY GUARD===================================
function scrInitPartyFresh() {
global.partyStatus = {
		coat: false,
		osei: false,
		anna: false,
		data: false,
	}

	//party order index
	global.partyOrder = [oLeon, oCoat, oOsei, oAnna];

	global.party = [];
	
	//Party constuctor syntax: cstrPartyMember(name, level, bio, age, species, can_use_magic)
	array_push(global.party, cstrLeon());
	array_push(global.party, cstrCoat());
	array_push(global.party, cstrOsei());
	array_push(global.party, cstrAnna())
	

//testing items spawnin
global.party[0].add_item(global.it_potion);
global.party[0].add_item(global.it_stimpak);
global.party[0].add_items(global.it_antidote, global.it_revive, global.it_phoenix);

global.party[1].add_item(global.it_antitox);

global.party[2].add_items(global.it_cyanide, global.it_cyanide, global.it_cyanide, global.it_potion, global.it_potion, 
	global.it_stimpak, global.it_cyanide, global.it_antitox, global.it_antitox, global.it_cyanide, global.it_cyanide, 
	global.it_cyanide, global.it_cyanide, global.it_potion, global.it_potion, global.it_stimpak, global.it_cyanide, 
	global.it_antitox, global.it_antitox, global.it_cyanide);
	
global.party[3].add_items(global.it_sword, global.it_dagger, global.it_staff, global.it_spear, global.it_shield, 
	global.it_hat, global.it_helm, global.it_vest, global.it_plate, global.it_boots, global.it_greaves, global.it_mgcring, 
	global.it_spdchrm);
	
	
	//initialize party flag
	global.party_initialized = true;
}

//========================PREMADE CHARACTER CONSTRUCTIONS========================
function cstrLeon() {						//Initialize Leon creation
	var c = new cstrPartyMember("Leon", "Spearman", 20, "Human", true, 1, 
	18, 10, 21, 8, 13, 10,						//lv 1 bases - hp, mp, atk, def, spd, mental
	7.5, 3.86, 2.43, 1.64, 2.64, 2.5,		//growth rate
	-4, 3);													//mAtk and mDef mods
	c.exp_to_lvup = xp_threshold("Leon", 1);
	
	array_push(c.skills, global.sk_triplethrust);
	
	return c;
}

function cstrCoat() {
	var c = new cstrPartyMember("Coat", "Scout", 45, "Yux", true, 10,
	30, 14, 12, 12, 28, 20,
	5.68, 4.68, 2.91, 1.09, 2.54, 1.8,
	13, 13);
	c.exp_to_lvup = xp_threshold("Coat", 1);
	
	array_push(c.spells, global.sp_heal);
	
	array_push(c.skills, global.sk_teleport);
	
	return c;
}

function cstrOsei() {
	var c = new cstrPartyMember("Osei", "Wizard", 54, "Human", true, 21,
	8, 26, 10, 14, 20, 25,
	5.5, 6.23, 1.96, 1.18, 1.59, 2.8,
	5, 5);
	c.exp_to_lvup = xp_threshold("Osei", 21);
	
	//Osei joins at lv 21, MgMissl learned at Lv5 and already known
	array_push(c.spells, global.sp_mgmissl);
	
	return c;
}

function cstrAnna() {
	var c = new cstrPartyMember("Anna", "General", 30, "Human", true, 1,
	20, 4, 20, 20, 14, 8,
	4.32, 2.64, 2.5, 1.82, 1.5, 2.0,
	-1, -1);
	c.exp_to_lvup = xp_threshold("Anna", 1);
	
	array_push(c.skills, global.sk_essentia);
	
	return c;
}

function cstrData() {
	var c = new cstrPartyMember("Data", "Android", 4, "Android", false, 1,
	9, 0, 25, 6, 25, 12,
	7.02, 0.0, 2.16, 1.68, 1.98, 2.2,
	3, 5);
	c.exp_to_lvup = xp_threshold("Data", 1);
	return c;
}

