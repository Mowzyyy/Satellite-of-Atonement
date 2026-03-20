//Draw background always
draw_sprite(sBackgroundMain, 0, 0, 0);

switch (stage) {
	case TITLE_STAGE.SPLASH_1:
		draw_sprite(sLogoStudio, 0, 0, 0);
		break;
	case TITLE_STAGE.SPLASH_2:
		draw_sprite(sLogoEngine, 0, 0,0);
		break;
	case TITLE_STAGE.TITLE_IDLE:
		if (show_press_start) {
			//blinking effect
			blink_timer++;
			if ((blink_timer mod 60) < 30) {
					draw_text(room_width/2, room_height - 100, "Press E or C");
			}
		}
		break;
	case TITLE_STAGE.MENU_ACTIVE:
	//dRAW THE mENU OPTIONS
	for (var i = 0; i < array_length(menu_options); i++) {
		var _color = (i == cursor_index) ? c_yellow : c_white;
		draw_text_color(room_width/2, 200 + (i * 32), menu_options[i], _color, _color, _color, _color, 1);
		
		//Draw blinking cursor
		if (i == cursor_index) {
			blink_timer++;
			if ((blink_timer mod 40) < 20) {
				draw_sprite(sCursor, 0, (room_width/2) - 80, 200 + (i * 32));
			}
		}
	}
	break;
}