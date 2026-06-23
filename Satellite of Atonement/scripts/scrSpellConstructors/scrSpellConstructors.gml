//Spell Constructor
//contains the spell constructor and all spell instances
//initialize spell globals before constructing party members
//damage formula - damage = spell.power + caster.mAtk - target.mDef
	
//==========================================Spell Constructor==========================================
// target_type:
//   "single_enemy" - one enemy, player-selected
//   "all_enemies" - every enemy in the encounter
//   "single_ally" - one party member, player-selected
//   "all_allies" - every party member
//   "any"  - player selects any valid combatant
//
// element:
//   "none", "fire", "ice", "lightning", "earth", "light", "dark"
//   "none" = untyped, no resistances apply

function cstrSpell ( 
	_name,
	_mp_cost,
	_mpower,
	_target_type,
	_effect_type = "damage",
	_element = "none",
	_description = ""
	) constructor {
		name				= _name;
		mp_cost			= _mp_cost;
		mpower			= _mpower;
		target_type		= _target_type;
		effect_type		= _effect_type;
		element			= _element;
		description		= _description;
	}
//==========================================Skill Constructor==========================================
// target_type: "single_enemy", "all_enemies", "single_ally", "all_allies", "any", "functional"
// effect_type: "heal_hp", "heal_mp", "damage", "cure_status", "buff_stat", "functional"
function cstrSkill(_name, _uses_max, _target_type, _effect_type, _description = "") constructor {
	name					= _name;
	uses_max			= _uses_max;
	uses_left				= _uses_max;
	target_type			= _target_type;
	effect_type			= _effect_type;
	description			= _description;
}
	
//===========================================Spell Instances===========================================
//one global per spell, prefix sp_
//assign to characters in their factory functions or learn_spells_at_level() during level_up()
	
function scrInitSpellGlobals() {
	
	global.sp_mgmissl = new cstrSpell ( 
	/* name */ "MgMissl",
	/*mp_cost*/ 3,
	/* power */ 12,
	/* target_type */ "single_enemy",
	/* effect type */ "damage",
	/*element*/ "none",
	/*desc*/ "A missile of raw magical force."
	);
	
	global.sp_heal = new cstrSpell ( 
	"Heal",
	8,
	120,
	"single_ally",
	"heal_hp",
	"none",
	"Restores HP to one ally"
	);
}


//===========================================Skill Instances===========================================
function scrInitSkillGlobals() {
	global.sk_teleport = new cstrSkill ( 
	"Teleport",
	3,
	"functional",
	"functional",
	"Warps the party - no effect yet"
	);
	
	global.sk_triplethrust = new cstrSkill (
	"TrpThrt", 
	5,
	"single_enemy", 
	"damage",
	"Thrusts the spear three times"
	);
	
	global.sk_essentia = new cstrSkill ( 
	"Essentia",
	2,
	"single_ally",
	"restore_mp",
	"Restores a moderate amount of MP"
	);
}
//==========================================Spell Learn Table==========================================
//called automatically from level)up(), add new cases here as spells are designed

function learn_spells_at_level(_name, _level) {
	var member = undefined;
	for (var i = 0; i < array_length(global.party); i++) {
		if (global.party[i].name == _name) {
			member = global.party[i];
			break;
		}
	}
	if (member == undefined) exit;
	
	switch (_name) {
		
		case "Leon":
			//switch
		break;
		
		case "Coat":
			switch (_level) {
				case 10: array_push(member.spells, global.sp_heal); break;
			}
		break;
		
		case "Osei":
			switch (_level) {
					case 5: array_push(member.spells, global.sp_mgmissl); break;
			}
		break;
		
		case "Anna":
			//switch
		break;
		
		case "Data":
			//switch
		break;
		
	}
}
//==========================================Skill Learn Table==========================================
function learn_skills_at_level(_name, _level) {
	var member = undefined;
	for (var i = 0; i < array_length(global.party); i++) {
		if (global.party[i].name == _name) {
			member = global.party[i];
			break;
		}
	}
	if (member == undefined) exit;
	
	switch (_name) {
		
		case "Leon":
			//switch
		break;
		
		case "Coat":
			switch (_level) {
				case 10: array_push(member.skills, global.sk_teleport); break;
			}
		break;
		
		case "Osei":
			//switch
		break;
		
		case "Anna":
			//switch
		break;
		
		case "Data":
			//switch
		break;
		
	}
}
