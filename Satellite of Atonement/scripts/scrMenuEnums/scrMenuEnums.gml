enum GAME_STATE {
	MAIN_MENU,
	OVERWORLD,
	IN_GAME_MENU,//PSIII style menu
	BATTLE,//PSIV style combat
	CUTSCENE
}

enum MENU_PAGE {
	MAIN,
	INVENTORY,
	SKILLS,
	EQUIP,
	STATS,
	ORDER,
	TALK,
	MACRO,
	SETTINGS,
	SAVE
}

enum BATTLE_PHASE {
	SELECT_COMMAND,
	SELECT_TARGET,
	RUN_MACRO,
	EXECUTE_TURN,
	WIN_LOSS
}

enum TITLE_STAGE {
	SPLASH_1,
	SPLASH_2,
	TITLE_IDLE,//Background showing, waiting for "Press Start"
	MENU_ACTIVE//The actual selectable options appear
}

enum MENU_VARIANT {
		NEW_PLAYER,//only new game and misc 
		RETURNING//allows to load game
}

enum INVENTORY_STATE {
	SELECT_WHO,//"Whose" + party list
	SELECT_ITEM,//"What?" + inventory list
	SELECT_ACTION,//"Use / Give / Toss"
	SELECT_TARGET//"On Whom?" + party list again
}

enum SUBMENU_HISTORY {
	NONE,
	MAIN,
	INVENTORY_SELECT_WHO,
	INVENTORY_SELECT_ITEM,
	INVENTORY_SELECT_ACTION,
	INVENTORY_SELECT_TARGET//add more later for other sub-menus
}