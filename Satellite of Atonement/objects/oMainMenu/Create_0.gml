//The Main Menu/Title Screen
stage = TITLE_STAGE.SPLASH_1;
stage_timer = 0;
hold_time = 180;//3 seconds at 60fps

walk_frame_timer = 0;
walk_frame = 0;
walk_frame_speed = 9;

//Check for saves
if (file_exists("save0.dat")) {
	variant = MENU_VARIANT.RETURNING;
	menu_options = ["Continue", "New Game", "Misc"];
} else {
	variant = MENU_VARIANT.NEW_PLAYER;
	menu_options = ["New Game", "Misc"];
}

cursor_index = 0;

slot_selecting = false;//true when slot subscreen is open
slot_cursor = 0; //which slot is highlighted0;
slot_data = [];//cached save metadata for drawing

slot_confirming = false;//true after C is pressed
slot_confirmed = -1;

slot_confirm_timer = 0;
slot_confirm_delay = 20;


//pre-read all 3 slots once on create so the draw event never hits disk
for (var i = 0; i < 3; i++) {
	if (save_slot_exists(i)) {
		var buf = buffer_load(save_filepath(i));
		var raw = buffer_read(buf, buffer_string);
		buffer_delete(buf);
		slot_data[i] = json_parse(raw);
	} else {
		slot_data[i] = undefined;
	}
}

show_press_start = false;
blink_timer = 0;
prompt_start_time=0;

//play looping title music
audio_play_sound(sndTitle, 10, true);