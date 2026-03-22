//Below section is the global party manager

global.partyStatus = {
	coat: false,
	osei: false,
	anna: false,
	data: false,
}
//party order index
global.partyOrder = [oLeon, oCoat, oOsei, oAnna];


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


//==================================State Machine==================================
//This machine controls all of the menus and the headaches that they will cause me

//only set default state the very first time the game runs
if (!variable_global_exists("state_initialized")) {
	global.state = GAME_STATE.MAIN_MENU;
	global.state_initialized = true;
}
global.menu_page = MENU_PAGE.MAIN;
global.selected_char = 0;//0-3 for the 4 portraits
menu_cursor = 0;//Which menu option is highlighted
blink_timer = 0;

//============================Global Menu Drawing Settings============================
//This makes every context menu in the game use the default font automatically
draw_set_font(ftDefault);
draw_set_halign(fa_left);//centers the text alignment horizontally
draw_set_valign(fa_middle);
draw_set_color(c_white);

//==================================GUI Card Settings==================================
var total_width = (3 * global.card_w) + (2 * global.card_gap);
var start_x = (320 - total_width) / 2;//center horizontally - 320 = base_width

global.card_positions = array_create(6);

global.card_positions[0] = {x: start_x, y: 240 - global.card_bottom_margin - global.card_h * 2 - global.card_gap};
global.card_positions[1] = {x: start_x + global.card_w + global.card_gap, y: global.card_positions[0].y};
global.card_positions[2] = {x: start_x + (global.card_w + global.card_gap) * 2, y: global.card_positions[0].y};

global.card_positions[3] = {x: start_x, y: global.card_positions[0].y + global.card_h + global.card_gap};
global.card_positions[4] = {x: global.card_positions[1].x, y: global.card_positions[3].y};
global.card_positions[5] = {x: global.card_positions[2].x, y: global.card_positions[3].y};

global.party_card_map = [0, 2, 3, 5];

//psiii style menu list
global.menu_list = [
"ITEM", "SKILL", "EQUIP",
"STATS", "ORDER", "TALK",
"MACRO", "CONFIG", "SAVE"
];

global.menu_page_map = [
MENU_PAGE.INVENTORY,
MENU_PAGE.SKILLS,
MENU_PAGE.EQUIP,
MENU_PAGE.STATS,
MENU_PAGE.ORDER,
MENU_PAGE.TALK,
MENU_PAGE.MACRO,
MENU_PAGE.SETTINGS,
MENU_PAGE.SAVE
];
