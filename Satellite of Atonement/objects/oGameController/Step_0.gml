//==================================Controls==================================
global.keyUp = keyboard_check(vk_up) || keyboard_check(ord("W"));
global.keyDown = keyboard_check(vk_down) || keyboard_check(ord("S"));
global.keyLeft = keyboard_check(vk_left) || keyboard_check(ord("A"));
global.keyRight = keyboard_check(vk_right) || keyboard_check(ord("D"));

global.keyC = keyboard_check_pressed (ord("E")) || keyboard_check_pressed(ord("C"));
global.keyB = keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("X"));
global.keyA = keyboard_check_pressed(vk_tab) || keyboard_check_pressed(ord("Z"));

//===================================Menus===================================
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