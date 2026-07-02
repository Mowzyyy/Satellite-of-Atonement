/*
THIS IS THE SAVELOAD SCRIPT
GOD HAVE MERCY ON MY SOUL

I AM TERRIFIED OF WHAT I WILL HAVE TO UPDATE HERE LATER ON

Functionality: 3 save slots - soa_save0/1/2.json

All saved to GML's default working_directory

SAVE - call save game slot where _slot is 0,1,2
LOAD - call load game slot
CHECK - call if save slot exists returns true/false
DELETE - call detele save slot
*/

//=========================================HELPERS=========================================
#macro SAVE_VERSION 1.2
function save_filepath(_slot) {
	return working_directory + "soa_save_" + string(_slot) + ".json";
}

function save_slot_exists(_slot) {
	return file_exists(save_filepath(_slot));
}

function delete_save(_slot) {
	var path = save_filepath(_slot);
	if (file_exists(path)) file_delete(path);
}

//=========================================SERIALIZERS=========================================

//converts one equipment struct into a plain JSON-safe struct
function serialize_equipment(_equip) {
	return {
		name					: _equip.name,
		slot_type				: _equip.slot_type,
		atk_bonus			: _equip.atk_bonus,
		def_bonus			: _equip.def_bonus,
		spd_bonus			: _equip.spd_bonus,
		mental_bonus	: _equip.mental_bonus,
		mAtk_bonus		: _equip.mAtk_bonus,
		mDef_bonus		: _equip.mDef_bonus
		//special_effects omitted for now - add when accessory effects are designed
	};
}

//converts one item struct
function serialize_item(_item) {
	if (!variable_struct_exists(_item, "type")) {
		return serialize_equipment(_item);
	}
	return {
		name					: _item.name,
		type						: _item.type,
		description			: _item.description,
		value						: _item.value,
		effect_type			: _item.effect_type,
		effect_amount	: _item.effect_amount,
		effect_stat			: _item.effect_stat
	};
}

//converts one spell - saved by name only, re-resolved on load from global spell catalogue so spell data stays moddable
function serialize_spell(_spell) {
	return { name: _spell.name };
}
function serialize_skill(_skill) {
	return { name: _skill.name, uses_left: _skill.uses_left };
}

//converts one full party member struct
function serialize_party_member(_m) {
	//serialize inventory
	var inv = [];
	for ( var i = 0; i < array_length(_m.inventory); i++) {
		array_push(inv, serialize_item(_m.inventory[i]));
	}
	
	//serialize spells (name only)
	var sp = [];
	for (var i = 0; i < array_length(_m.spells); i++) {
		array_push(sp, serialize_spell(_m.spells[i]));
	}
	
	//serialize spells (name + uses remaining)
	var sk = [];
	for (var i = 0; i < array_length(_m.skills); i++) {
		array_push(sk, serialize_skill(_m.skills[i]));
	}
	
	return {
		name								: _m.name,
		bio										: _m.bio,
		age										: _m.age,
		species								: _m.species,
		can_use_magic				: _m.can_use_magic,
		level									: _m.level,
		experience						: _m.experience,
		exp_to_lvup					: _m.exp_to_lvup,
		
		//growth rates
		hp_growth						: _m.hp_growth,
		mp_growth						: _m.mp_growth,
		atk_growth						: _m.atk_growth,
		def_growth						: _m.def_growth,
		spd_growth					: _m.spd_growth,
		mental_growth				: _m.mental_growth,
		
		//archetype mods
		base_mAtk_mod			: _m.base_mAtk_mod,
		base_mDef_mod			: _m.base_mDef_mod,
		
		//current stats
		base_max_hp				: _m.base_max_hp,
		current_hp						: _m.current_hp,
		base_max_mana			: _m.base_max_mana,
		current_mana				: _m.current_mana,
		base_atk							: _m.base_atk,
		base_def							: _m.base_def,
		base_spd							: _m.base_spd,
		base_mental					: _m.base_mental,
		
		//Equipment (each slot serialized)
		head									: serialize_equipment(_m.head),
		r_Hand								: serialize_equipment(_m.r_Hand),
		l_Hand								: serialize_equipment(_m.l_Hand),
		body									: serialize_equipment(_m.body),
		feet									: serialize_equipment(_m.feet),
		accessory						: serialize_equipment(_m.accessory),
		
		//status
		status_effects : _m.status_effects,
		
		inventory : inv,
		spells			: sp,
		skills			: sk
		//battle_buffs ommitted, always reset fresh on load
	};
}

//Converts global.storyFlags into a serializeable struct
function serialize_flags() {
	//shallow copy assumes all flag values are primitives
	var out = {};
	var keys = variable_struct_get_names(global.storyFlags);
	for (var i = 0; i < array_length(keys); i++) {
		var k = keys[i];
		variable_struct_set(out, k, variable_struct_get(global.storyFlags, k));
	}
	return out;
}

function serialize_macros() {
	var out = [];
	for (var i = 0; i < 8; i++) {
		if (global.macros[i] == undefined) {
			array_push(out, { name: "", entries: [] });
		} else {
			array_push(out, global.macros[i]);//already plain structs/strings
		}
	}
	return out;
}

//========================================DESERIALIZERS========================================

function deserialize_equipment(_data) {
	return new cstrEquipment(
		_data.name,
		_data.slot_type,
		_data.atk_bonus,
		_data.def_bonus,
		_data.spd_bonus,
		_data.mental_bonus,
		_data.mAtk_bonus,
		_data.mDef_bonus
		);
}

function deserialize_item(_data) {
	if (!variable_struct_exists(_data, "type")) {
		return deserialize_equipment(_data);
	}
	var item = new cstrItem(_data.name, _data.type, _data.description, _data.value);
	item.effect_type   = _data.effect_type;
	item.effect_amount = _data.effect_amount;
	item.effect_stat   = _data.effect_stat;
	return item;
}

function deserialize_spell(_data) {
	var spell_name = _data.name;
	//add new spells as the catalogue grows
	switch (spell_name) {
		case "MgMissl": return global.sp_mgmissl;
		case "Heal": return global.sp_heal;
		default:
			show_debug_message("WARNING: deserialize_spell — unknown spell '" + spell_name + "'");
			return undefined;
	}
}

function deserialize_skill(_data) {
	var skill_name = _data.name;
	var sk = undefined;
	switch (skill_name) {
		case "Teleport":				sk = global.sk_teleport;				break;
		case "TrpThrt":					sk = global.sk_triplethrust;		break;
		case "Essentia":				sk = global.sk_essentia;				break;
		
		default:
			show_debug_message("WARNING: deserialize_skill — unknown skill '" + skill_name + "'");
			return undefined;
	}
	var skill_copy = new cstrSkill(sk.name, sk.uses_max, sk.target_type, sk.effect_type, sk.description);
	skill_copy.uses_left = _data.uses_left;
	return skill_copy;
}

function deserialize_party_member(_data) {
	//reconstruct via cstrPartyMember using saved values directly
	//bypasses factory functions so stats are loaded exactly as saved
	
	var m = new cstrPartyMember(
		_data.name,
		_data.bio,
		_data.age,
		_data.species,
		_data.can_use_magic,
		_data.level,
		// Lv1 bases - pass current saved values for base stats and set growth rates so level_up() stays correct
		_data.base_max_hp			- round(_data.hp_growth			* (_data.level - 1)),
		_data.base_max_mana		- round(_data.mp_growth			* (_data.level - 1)),
		_data.base_atk						- round(_data.atk_growth			* (_data.level - 1)),
		_data.base_def						- round(_data.def_growth			* (_data.level - 1)),
		_data.base_spd						- round(_data.spd_growth		* (_data.level - 1)),
		_data.base_mental				- round(_data.mental_growth	* (_data.level - 1)),
		_data.hp_growth,
		_data.mp_growth,
		_data.atk_growth,
		_data.def_growth,
		_data.spd_growth,
		_data.mental_growth,
		_data.base_mAtk_mod,
		_data.base_mDef_mod
		);
		
		//restore XP stats
		m.experience = _data.experience;
		m.exp_to_lvup = _data.exp_to_lvup;
		
		//restore current HP/mana - may differ from max if damaged when saved
		m.current_hp = _data.current_hp;
		m.current_mana = _data.current_mana;
		
		//restore equipment
		m.head				= deserialize_equipment(_data.head);
		m.r_Hand		= deserialize_equipment(_data.r_Hand);
		m.l_Hand			= deserialize_equipment(_data.l_Hand);
		m.body			= deserialize_equipment(_data.body);
		m.feet				= deserialize_equipment(_data.feet);
		m.accessory	= deserialize_equipment(_data.accessory);
		
		//restore status effects
		m.status_effects = _data.status_effects;
		
		//restore inventory
		m.inventory = [];
		for (var i = 0; i < array_length(_data.inventory); i++) {
			array_push(m.inventory, deserialize_item(_data.inventory[i]));
		}
		
		//restore spells
		m.spells = [];
		for (var i = 0; i < array_length(_data.spells); i++) {
			var sp = deserialize_spell(_data.spells[i]);
			if (sp != undefined) array_push(m.spells, sp);
		}
		
		//restore skills
		m.skills = [];
		for (var i = 0; i < array_length(_data.skills); i++) {
			var sk = deserialize_skill(_data.skills[i]);
			if (sk != undefined) array_push(m.skills, sk);
		}
		
		return m;
}

function deserialize_flags(_data) {
	var keys = variable_struct_get_names(_data);
	for (var i = 0; i < array_length(keys); i++) {
		var k = keys[i];
		variable_struct_set(global.storyFlags, k, variable_struct_get(_data, k));
	}
}


//========================================SAVE GAME========================================

function save_game(_slot) {
	//capture leader position at save time
	var _leader = instance_find(global.partyOrder[0], 0)
	if (_leader != noone && instance_exists(_leader)) {
		global.player_map_x = _leader.x_pos;
		global.player_map_y = _leader.y_pos;
	}
	
	//capture follower positions at save time
	var follower_data = [];
	for (var i_fdata = 0; i_fdata < array_length(global.partyOrder); i_fdata++) {
		var _inst = instance_find(global.partyOrder[i_fdata], 0);
		show_debug_message("save follower " + string(i_fdata) + " | found: " + string(_inst != noone) + " | x_pos: " + string(_inst != noone ? _inst.x_pos : -1));
		if (_inst != noone && instance_exists(_inst)) {
			array_push(follower_data, {
			x_pos			: _inst.x_pos,
			y_pos			: _inst.y_pos,
			last_dir			: _inst.last_dir
			});
		} else {
			array_push(follower_data, {
				x_pos			: global.player_map_x,
				y_pos			: global.player_map_y,
				last_dir			: directions.down
			});
		}
	}
	
	//build the full save struct
	var party_data = [];
	for (var i = 0; i < array_length(global.party); i++) {
		array_push(party_data, serialize_party_member(global.party[i]));
	}
	
	var party_order_names = [];
	for (var i = 0; i < array_length(global.partyOrder); i++) {
		array_push(party_order_names, get_party_display_name(global.partyOrder[i]));
	}
	
	var save_data = {
		slot						: _slot,
		version					: 1.2,//increment if save format changes
		timestamp			: string(current_year)				+ "-"
										+ string(current_month)		+ "-"
										+ string(current_day)				+ "-"
										+ string(current_hour)			+ "-"
										+ string(current_minute),
		playtime			: global.playtime,
		money				: global.money,
		map_id				: global.current_map_id,
		map_x				: global.player_map_x,
		map_y				: global.player_map_y,
		follower_data	: follower_data,
		party					: party_data,
		party_order	: party_order_names,
		flags					: serialize_flags(),
		macros				: serialize_macros()
	};
	
	//serialize to JSON and write to buffer
	var json_string = json_stringify(save_data);
	var buf = buffer_create(string_byte_length(json_string) + 1, buffer_fixed, 1);
	buffer_write(buf, buffer_string, json_string);
	buffer_save(buf, save_filepath(_slot));
	buffer_delete(buf);
	
	show_debug_message("Game saved to slot " + string(_slot));
}

//========================================LOAD GAME========================================
function load_game(_slot) {
	var path = save_filepath(_slot);
	if (!file_exists(path)) {
		show_debug_message("ERROR: No save file found at slot " + string(_slot));
		return "nosave";
	}
	
	//read buffer and parse JSON
	var buf = buffer_load(path);
	var json_string = buffer_read(buf, buffer_string);
	buffer_delete(buf);
	
	var data = json_parse(json_string);
	
	if (!variable_struct_exists(data, "version") || data.version != SAVE_VERSION) return "mismatch";
	
	//restore globals
	global.playtime					= data.playtime;
	global.money						= data.money;
	global.current_map_id	= data.map_id;
	global.player_map_x		= data.map_x;
	global.player_map_y		= data.map_y;
	
	//rebuild party
	global.party = [];
	for (var i = 0; i < array_length(data.party); i++) {
		array_push(global.party, deserialize_party_member(data.party[i]));
	}
	
	global.partyOrder = [];
	for (var i = 0; i < array_length(data.party_order); i++) {
		switch (data.party_order[i]) {
			case "LEON": array_push(global.partyOrder, oLeon); break;
			case "COAT": array_push(global.partyOrder, oCoat); break;
			case "OSEI": array_push(global.partyOrder, oOsei); break;
			case "ANNA": array_push(global.partyOrder, oAnna); break;
			case "DATA": array_push(global.partyOrder, oData); break;
		}
	}
	
	global.party_initialized = true;
	
	global.load_follower_data = data.follower_data;
	
	//restore flags
	deserialize_flags(data.flags);
	
	//restore macros
	scrInitMacros();
	if (variable_struct_exists(data, "macros")) {
		for (var i = 0; i < min(8, array_length(data.macros)); i++) {
			if (data.macros[i].name != "") global.macros[i] = data.macros[i];
		}
	}
	
	show_debug_message("Game loaded from slot " + string(_slot));
	show_debug_message("Loaded party[0]: " + global.party[0].name + " Lv" + string(global.party[0].level) + " HP:" + string(global.party[0].current_hp));
	return "ok";
}