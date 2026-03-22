//==================================Controls==================================
global.keyUp = keyboard_check(vk_up) || keyboard_check(ord("W"));
global.keyDown = keyboard_check(vk_down) || keyboard_check(ord("S"));
global.keyLeft = keyboard_check(vk_left) || keyboard_check(ord("A"));
global.keyRight = keyboard_check(vk_right) || keyboard_check(ord("D"));

global.keyUpPressed = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
global.keyDownPressed = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
global.keyLeftPressed = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
global.keyRightPressed = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));

global.keyC = keyboard_check_pressed (ord("E")) || keyboard_check_pressed(ord("C"));
global.keyB = keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("X"));
global.keyA = keyboard_check_pressed(vk_tab) || keyboard_check_pressed(ord("Z"));

//===================================Menus===================================
switch (global.state) {
	case GAME_STATE.MAIN_MENU:
		scrMenuMainLogic();
		break;
	
	case GAME_STATE.OVERWORLD:
		if (global.keyA) {
			show_debug_message("Opening Menu!");
			global.state = GAME_STATE.IN_GAME_MENU;
			global.menu_page = MENU_PAGE.MAIN;
			menu_cursor = 0;
			
			io_clear();
			show_debug_message("Game state changes!");
			//audio_play_sound(sndExample, 10, false);
		}
			break;
		
		case GAME_STATE.IN_GAME_MENU:
			//Navigation and selection, expand later
			blink_timer++;
			scrMenuPauseLogic();
			break;
			
			case GAME_STATE.BATTLE:
				scrBattleLogic();
				break;
}