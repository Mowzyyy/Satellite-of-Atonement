switch (global.state) {
	case GAME_STATE.MAIN_MENU:
		scrMenuMainLogic();
		break;
	
	case GAME_STATE.OVERWORLD:
		if (keyA) {
			global.state = GAME_STATE.IN_GAME_MENU;
			global.menu_page = MENU_PAGE.MAIN;
			instance_deactivate_all(true);//pause the world
		}
			break;
		
		case GAME_STATE.IN_GAME_MENU:
			scrMenuPauseLogic();
			break;
			
			case GAME_STATE.BATTLE:
				scrBattleLogic();
				break;
}