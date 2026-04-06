if (save_slot_exists(0) || save_slot_exists(1) || save_slot_exists(2)) {
	if (variant != MENU_VARIANT.RETURNING) {
		variant = MENU_VARIANT.RETURNING;
		menu_options = ["Continue", "New Game", "Misc"];
		cursor_index = 0;
	}
} else {
	if (variant != MENU_VARIANT.NEW_PLAYER) {
		variant = MENU_VARIANT.NEW_PLAYER;
		menu_options = ["New Game", "Misc"];
		cursor_index = 0;
	}
}

//splash and title logic
if (stage != TITLE_STAGE.MENU_ACTIVE) {
	stage_timer++;
	
	var advance = false;
	
	//timed auto-advance: only triggers once when timer first hits hold time
	if (stage_timer >= hold_time) {
		advance = true;
		stage_timer = 0;//reset immediately
	}
	
	//input skip: also only once per press
	if (global.keyC && stage != TITLE_STAGE.TITLE_IDLE) {
		advance = true;
		stage_timer = 0;
	}
	
	if (advance) {
		if (stage == TITLE_STAGE.SPLASH_1) {
			stage = TITLE_STAGE.SPLASH_2;
		} else if (stage == TITLE_STAGE.SPLASH_2) {
			stage = TITLE_STAGE.TITLE_IDLE;
		}
	}
	
	//show blinking prompt
	if (stage == TITLE_STAGE.TITLE_IDLE && stage_timer > 60 && !show_press_start) {
		show_press_start = true;
		prompt_start_time = current_time;
	}

	
	//press E or C to hide prompt and go to menu
	if (stage == TITLE_STAGE.TITLE_IDLE && show_press_start) {
		if (global.keyC) {
			show_press_start = false;
			stage = TITLE_STAGE.MENU_ACTIVE;
			stage_timer = 0;
		}
	}
}

//menu navigation logic
else {
	if (slot_selecting) {
		//count exisiting slots for clamping
		var num_exists = 0;
		walk_frame_timer++;
		
		if (walk_frame_timer >= walk_frame_speed) {
			walk_frame_timer = 0;
			walk_frame = (walk_frame + 1) mod 3;
		}
		
		for (var s = 0; s < 3; s++) {
			if (slot_data[s] != undefined) num_exists++;
		}
		
		if (slot_confirming) {
			slot_confirm_timer++;
			if (slot_confirm_timer >= slot_confirm_delay) {
				//waiting for c to dismiss game loaded and actually load
				if (global.keyC) {
					load_game(slot_confirmed);
					global.state = GAME_STATE.OVERWORLD;
					instance_destroy();
					room_goto(rmTest);
					slot_confirm_timer = 0;
				}
				if (global.keyB) {
					//cancel load - back to slot select
					slot_confirming = false;
					slot_confirmed = -1;
					slot_confirm_timer = 0;
				}
			}
			exit;
		}
		
		var _mov = global.keyRightPressed - global.keyLeftPressed;
		slot_cursor = clamp(slot_cursor + _mov, 0, max(0, num_exists - 1));
		
		//confirm - only load if slot has data
		if (global.keyC) {
			if (slot_data[slot_cursor] != undefined) {
				slot_confirming = true;
				slot_confirmed  = slot_cursor;
			}
		}
		
		//cancel - go back to menu
		if (global.keyA || global.keyB) {
			slot_selecting = false;
			slot_confirming = false;
			slot_confirmed  = -1;
		}
		
		exit;//skip normal menu nav while slot screen is open
	}
	
	var _move = global.keyDownPressed - global.keyUpPressed;
	cursor_index = clamp(cursor_index + _move, 0, array_length(menu_options) - 1);
	
	if (global.keyC) {
		var _choice = menu_options[cursor_index];
		switch(_choice) {
			case "New Game":
				global.state = GAME_STATE.OVERWORLD;
				instance_destroy();
				room_goto(rmTest);
				break;
			case "Continue":
				slot_selecting = true;
				slot_cursor = 0;
				break;
			case "Misc":
				//misc();
				break;
		}
	}
}

//Blinking cursor timer
blink_timer++;
