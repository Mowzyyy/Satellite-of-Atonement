//========================ENEMY MOVE CONSTRUCTOR========================
//type - "attack", "magic", "skill", "heal", "status"
//target - "single_enemy", "all_enemies", "single_ally", "all_allies"
function cstrEnemyMove(_name, _type, _power, _mp_cost, _target, _weight = 1) constructor {
	name				= _name;
	type					= _type;
	enPower			= _power;
	mp_cost			= _mp_cost;
	target				= _target;
	weight				= _weight;//higher weight, more likely to be chosen
}

//===========================ENEMY CONSTRUCTOR===========================
function cstrEnemy(_name, _hp, _mp, _atk, _def, _spd, _mental, _exp, _money) constructor {
	name				= _name;
	max_hp			= _hp;
	current_hp		= _hp;
	max_mp			= _mp;
	current_mp	= _mp;
	atk						= _atk;
	def						= _def;
	spd					= _spd;
	mental				= _mental;
	mAtk					= floor(_mental * 0.6 + _atk * 0.4) + floor(_mp / 4);
	mDef					= floor(_mental * 0.6 + _def * 0.4) + floor(_spd / 4);
	xp						= _exp;
	money				= _money;
	
	moves				= [];//array of cstrEnemyMove
	weaknesses	= [];//array of element strings ie "fire"
	resistances		= [];//array of element strings
	flags					= {};//boss flags ie { requires_item: "superwand", stage: 1 }
	
	//combat sprite - set per enemy instance
	sprite_combat = 1;
	sprite_portrait = -1;
	
	//status
	status_effects = [];
	is_dead				= false;
	
	static add_move = function(_move) {
		array_push(moves, _move);
		return self;
	}
	
	static add_weakness = function(_element) {
		array_push(weaknesses, _element);
		return self;
	}
		
	static add_resistance = function(_element) {
		array_push(resistances, _element);
	}
	
	static set_flag = function(_key, _value) {
		flag[$ _key] = _value;
		return self;
	}
	
	//weighted random move selection
	static choose_move = function() {
		if (array_length(moves) == 0) return undefined;
		var total_weight = 0;
		for (var i = 0; i < array_length(moves); i++) {
			total_weight += moves[i].weight;
		}
		var roll = random(total_weight);
		var cumulative = 0;
		for (var i = 0; i < array_length(moves); i++) {
			cumulative += moves[i].weight;
			if (roll < cumulative) return moves[i];
		}
		return moves[array_length(moves) - 1];//fallback
	}
	
	static is_weak_to = function(_element) {
		for (var i = 0; i < array_length(weaknesses); i++) {
			if (weaknesses[i] == _element) return true;
		}
		return false;
	}
	
	static is_resistant_to = function(_element) {
		for (var i = 0; i < array_length(reesistances); i++) {
			if (resistances[i] == _element) return true;
		}
		return false;
	}
}

//===========================TEST ENEMY===========================
function cstrTestSlime() {
	var e = new cstrEnemy("Slime", 30, 0, 8, 4, 6, 2, 10, 5);
	e.sprite_combat = sTestSlime;//placeholder - add sprite when ready
	e.add_move(new cstrEnemyMove("Tackle", "attack", 10, 0, "single_enemy", 4));
	e.add_move(new cstrEnemyMove("Ooze", "status", 0, 0, "single_enemy", 1));
	return e;
}
