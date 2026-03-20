//Below section is the global party manager

global.partyStatus = {
	coat: false,
	osei: false,
	anna: false,
	data: false,
}
//party order index
global.partyOrder = [oLeon, oCoat, oOsei, oAnna, oData];


//Below section manages the entirety of the main story linear variables enumerated in the StoryVariables script
global.storyStep = PLOT.CHAPTER_ONE

global.storyFlags = {
	able_death: false,
}

//This section upscales the game
var _scale =3; //this will make the window 960x720
window_set_size(320 * _scale, 240 * _scale);

//application surface is the canvas the game draws on
surface_resize(application_surface, 320, 240);

//GUI should match the game resolution
display_set_gui_size(320, 240);

//center the window on the desktop
alarm[0] = 1;

//Disable linear interpolation
gpu_set_texfilter(false);

//==================================Controls==================================
//Gets the input of the keys the user is pressing
keyUp = keyboard_check(vk_up) || keyboard_check(ord("W"));
keyDown = keyboard_check(vk_down) || keyboard_check(ord("S"))
keyLeft = keyboard_check(vk_left) || keyboard_check(ord("A"))
keyRight = keyboard_check(vk_right) || keyboard_check(ord("D"))
keyC = keyboard_check_pressed(ord("E")) || keyboard_check_pressed(ord("C")); //defines the Activate key as this button on the keyboard
keyB = keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("X"));
keyA = keyboard_check_pressed(vk_tab) || keyboard_check_pressed(ord("Z"));

//==================================State Machine==================================
//This machine controls all of the menus and the headaches that they will cause me

global.state = GAME_STATE.MAIN_MENU;
global.menu_page = MENU_PAGE.MAIN;
global.selected_char = 0;//0-3 for the 4 portraits
menu_cursor = 0;//Which menu option is highlighted