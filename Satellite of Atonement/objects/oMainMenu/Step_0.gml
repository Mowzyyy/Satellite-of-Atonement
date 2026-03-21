//splash and title logic
if (stage != TITLE_STAGE.MENU_ACTIVE) {
	stage_timer++;
	
	var advance = false;
	
	//timed auto-advance: only triggers once when timer first hits hold time
	if (stage_timer >= hold_time) {
		advance = true;
		stage_timer = 0;//reset immediately
	}
	
	show_debug_message("Stage: " + string(stage) + " | Timer: " + string(stage_timer) + " | Advance this frame: " + string(advance));
	
	//input skip: also only once per press
	if (global.keyC) {
		advance = true;
		stage_timer = 0;
	}
	
	if (advance) {
		if (stage == TITLE_STAGE.SPLASH_1) {
			stage = TITLE_STAGE.SPLASH_2;
		} else if (stage == TITLE_STAGE.SPLASH_2) {
			stage = TITLE_STAGE.TITLE_IDLE;
		} else if (stage == TITLE_STAGE.TITLE_IDLE) {
			stage = TITLE_STAGE.MENU_ACTIVE;
		}
	}
	
	//show press E or C after delay on title idle
	if (stage == TITLE_STAGE.TITLE_IDLE && stage_timer > 60) {
		show_press_start = true;
	}
}

//menu navigation logic
else {
	var _move = global.keyDown - global.keyUp;
	cursor_index = clamp(cursor_index + _move, 0, array_length(menu_options) - 1);
	
	if (global.keyC) {
		var _choice = menu_options[cursor_index];
		switch(_choice) {
			case "New Game":
				room_goto(Test);
				break;
			case "Continue":
				//scr_load_game(0);
				break;
			case "Misc":
				//misc();
				break;
		}
	}
}

//Blinking cursor timer
blink_timer++;
		