function scrInitItemGlobals(){
	//consumables
	global.it_potion					= new cstrItem("Potion",			"consumable", "Restores 20 HP", 10).set_effect("heal_hp",			20);
	global.it_stimpak				=	new cstrItem("Stimpak",		"consumable", "Restores 80 HP", 50).set_effect("heal_hp",			80);
	global.it_antitox				= new cstrItem("Antitox",			"consumable","Cures all status", 75).set_effect("cure_status",		0);
	global.it_antidote				= new cstrItem("Antidote",		"consumable","Cures poison", 40).set_effect("cure_status",			0, "poison");
	global.it_cyanide				= new cstrItem("Cyanide",		"consumable", "Damages you", 25).set_effect("damage",				45);
	
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