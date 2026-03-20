//The Main Menu/Title Screen
stage = TITLE_STAGE.SPLASH_1;
stage_timer = 0;
hold_time = 180;//3 seconds at 60fps

//Check for saves
if (file_exists("save0.dat")) {
	variant = MENU_VARIANT.RETURNING;
	menu_options = ["Continue", "New Game", "Misc"];
} else {
	variant = MENU_VARIANT.NEW_PLAYER;
	menu_options = ["New Game", "Misc"];
}

cursor_index = 0;
show_press_start = false;
blink_timer = 0;