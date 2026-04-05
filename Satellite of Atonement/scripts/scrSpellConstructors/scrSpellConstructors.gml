//Spell Constructor
//contains the spell constructor and all spell instances
//initialize spell globals before constructing party members
//damage formula - damage = spell.power + caster.mAtk - target.mDef
	
//=========================================Spell Constructor=========================================
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
	_element = "none",
	_description = ""
	) constructor {
		name				= _name;
		mp_cost			= _mp_cost;
		mpower			= _mpower;
		target_type		= _target_type;
		element			= _element;
		description		= _description;
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
	/*element*/ "none",
	/*desc*/ "A missile of raw magical force."
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
			//switch
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

