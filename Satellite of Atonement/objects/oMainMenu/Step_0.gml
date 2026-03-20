var _key_confirm = keyC;

//Splash and title logic
if (stage != TITLE_STAGE.MENU_ACTIVE) {
	stage_time++;
	
	//skip current splash or advance to Menu
	if (_key_confirm || stage_timer >= hold_time) {
		if (stage == TITLE_STAGE.SPLASH_1) {
			stage = TITLE_STAGE.SPLASH_2;
			stage_timer = 0;
		} else if (stage == TITLE_STAGE.SPLASH_2) {
			stage = TITLE_STAGE.TITLE_IDLE;
			stage_timer = 0;
		} else if (stage ==TITLE_STAGE.TITLE_IDLE) {
			stage =	TITLE_STAGE.MENU_ACTIVE;
		}
	}
	
	//show "press E or C" after a short delay on title screen
	if (stage == TITLE_STAGE.TITLE_IDLE&& stage_timer > 60) {
		show_press_start = true;
	}
}

//menu navigation logic
else {
	var _move = keyDown- keyUp;
	cursor_index = clamp(cursor_index + _move, 0, array_length(menu_options) - 1);
	
	if (_key_confirm) {
		var _choice = menu_options[cursor_index];
		
		switch(_choice) {
			case "New Game":
				room_goto(Test);//test room
				break;
			case "Continue":
				//scr_load_game(0);//load the latest save
				break;
			case "Misc":
				//misc();
				break;
			//ETC
		}
	}
}