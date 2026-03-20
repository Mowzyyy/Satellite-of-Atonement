enum GAME_STATE {
	MAIN_MENU,
	OVERWORLD,
	IN_GAME_MENU,//PSIII style menu
	BATTLE,//PSIV style combat
	CUTSCENE
}

enum MENU_PAGE {
	MAIN,//Central panel
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