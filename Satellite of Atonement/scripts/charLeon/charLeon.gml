// ====================================================
// charLeon
//Full Constructor for Leon
// =====================================================
function charLeon(){
	// ===================BASIC IDENTITY===================
	name						= "LEON";
	level							= 1;
	levelpoints				=0;
	race							="Man";//for flavor or future racial bonuses
	
	// ======================CORE STATS=====================
	//Starting values tuned to keep Leon as the benchmark character
	//Endgame scaling: level 40-50 is "paeak party power"
	hp							= 32;			hp_max			= 32;				//Lv45 target: ~980
	mana					= 10;			mana_max		= 10;				//Lv45 target: ~180
	atk							= 14;																//Lv45 target: ~185
	defense				= 11;																//Lv45 target: ~140
	agi							= 13;																//Lv45 target: ~165 (turn order king)
	mst						= 10;																//Lv45 target: ~140 (magic defense)
	
	// =====================GROWTH RATES=====================
	//Called every level-up
	hp_growth_min		= 18;		hp_growth_max		= 26;	//Leon gets solid HP
	mana_growth_min	= 3;			mana_growth_max  = 7;		//Balanced magic pool
	stat_gain_pool = [1, 2, 3];															//Possible + per stat per level
	
	// ========================EXPERIENCE========================
	get_xp_needed = function() {
		//Medium progression: levels feel rewarding but not grindy
		//At Lv45 you want roughly the amount of exp that feels like a full campaign
		return floor(80 * power(level, 1.3));
	};
	
	// =========================EQUIPMENT=========================
	equipment = {
		left_hand:		{item: noone, type: ""},					//Spear(2H),  Shield, Pistol
		right_hand:		{item: noone, type:""},					//Dagger, Pistol (locked if 2H)
		body:				{item: noone, type: "Medium"},	//Light/Medium/Heavy
		head:					{item: noone, type: ""},
		feet:					{item: noone, type:""}
	};
	
	//Quick equip helper (call after changing equipment)
	calculate_equipment_bonuses = function() {
		var bonus_atk = 0, bonus_def = 0, bonus_agi = 0, bonus_mst = 0;
		
		//Example: add weapon bonuses (expand with real item data later)
		if (equipment.left_hand.item != noone) {
			bonus_atk += equipment.left_hand.item.atk_bonus ?? 0;
			bonus_def += equipment.left_hand.item.def_bonus ?? 0;
			if (equipment.left_hand.type == "@H") {
				//Lock right hand and give big atk bonus
				equipment.right_hand.item = noone;
				bonus_atk += 8;
			}
		}
		if (equipment.body.item != noone) {
			bonus_def += equipment.body.item.def_bonus ?? 0;
			if (equipment.body.type == "Heavy") bonus_agi -= 2;
		}
		
		//Apply to displayed stats (temporary, real stats stay base)
		//In battle object, do: effective_atk = atk + bonus)atk etc.
		return {atk: bonus_atk, def: bonus_def, agi: bonus_agi, mst: bonus_mst};
	};
	
	// ============================SKILLS===========================
	//Skills have independent charges. Magic skills also cost MP
	skills = [
		{ name:		"Spear Thrust",			max_uses: 4, current_uses: 4, skillpower: 1.4, skilltype: "Martial Arts",		cost_mana: 0 },
		{ name:		"Pistol Barrage",		max_uses: 3, current_uses: 3, skillpower: 1.2, skilltype: "Technology",		cost_mana: 0 },
		{ name:		"Tech Pulse",				max_uses: 2, current_uses: 2, skillpower: 1.0, skilltype: "Technology",		cost_mana: 6 },//stuns or accuracy boost
		{ name:		"Elemental Strike",	max_uses: 3, current_uses: 3, skillpower: 1.6, skilltype: "Magic",					cost_mana: 8 },//Fire/Water etc
		{ name:		"Motivate",					max_uses: 2, current_uses: 2, skillpower: 1.0, skilltype: "Specialized",		cost_mana: 0 }//party buff
	];
		
}