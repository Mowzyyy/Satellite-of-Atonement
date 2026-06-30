if (instance_number(oGameController) > 1) {
	instance_destroy();
	exit
}
persistent = true;

//==================================Party Data==================================
//global xp init
scrInitExpTables();
scrInitItemGlobals();
scrInitSpellGlobals();
scrInitSkillGlobals();

//initialize party
if (!variable_global_exists("party_initialized")) {
	global.party_initialized = false;
}
if (!global.party_initialized) {
	scrInitPartyFresh();
}


//==================================SaveLoad==================================
global.save_state = SAVE_STATE.SELECT_SLOT;
global.save_cursor = 0;
global.save_confirm_cursor = 0;
global.save_slot_cache = [];
global.save_just_saved = false;
global.save_saved_timer = 0;
global.money = 0;
global.playtime = 0;
global.current_map_id = 0;
global.player_map_x = 0;
global.player_map_y = 0;
global.load_follower_data = [];

//==================================MAP Data==================================
global.transition_active = false;
global.transition_fade_in = false;
global.transition_target_room = -1;
global.transition_target_x = 0;
global.transition_target_y = 0;
global.transition_target_dir = directions.down;
global.transition_target_map = MAP.DUNES;
global.transition_music = -1;
global.transition_alpha = 0;
global.transition_phase = 0;
global.pending_arrival = false;

global.slide_queued = false;
global.slide_follow_dir = -1;
global.slide_history = [];
global.slide_followup = false;

global.current_music = -1;
//==================================Story Var==================================
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

global.skill_death_msg_timer = 0;

global.menu_page = MENU_PAGE.MAIN;
global.selected_char = 0;//0-3 for the 4 portraits
global.stats_state = STATS_STATE.SELECT_WHO;
global.selected_stat_char = 0;
global.order_state = ORDER_STATE.SELECT;
global.order_new = [];//builds the new order for partyOrder
global.order_new_party = [];//builds the new order for party structs
global.order_confirm_cursor = 0;
global.skill_state = SKILL_STATE.SELECT_WHO;
global.skill_char = 0;
global.skill_cursor = 0;
global.skill_selected = -1;
global.skill_cannot_timer = 0;
global.skill_target_cursor = 0;
global.stat_rollups = [];//active animations: { key, from, to, current, elapsed, duration }
global.item_use_wait = false;
global.item_use_wait_timer = 0;
global.item_use_wait_key = "";
global.dlg_active = false;
global.dlg_pages = [];//pre-wraps page strings joined with \n
global.dlg_page =0;
global.dlg_words_shown =0;//words fully revealed on the current page
global.dlg_word_timer = 0;
global.dlg_word_speed = 4;//frames between word reveals
global.dlg_word_fade = 0;//0..1 fade of the newest word
global.dlg_portrait = -1;//chat portrait sprite, -1 = none
global.dlg_return_state = GAME_STATE.OVERWORLD;
menu_cursor = 0;//Which menu option is highlighted
blink_timer = 0;

//Restart game guard flag
global.is_restarting = false;
//====================================Battle State====================================
global.current_zone_tile = 0;//current tsZoneMap tile the leader is on
global.battle_background = -1;//sprite drawn behind combat


global.battle_enemies					= [];
global.battle_phase							= BATTLE_PHASE.SELECT_COMMAND;
global.battle_turn_order				= [];
global.battle_actions						= [];
global.battle_cmd_index				= 0;
global.battle_cmd_cursor				= 0;
global.battle_icon_cursor				= 0;
global.battle_sub_cursor				= 0;
global.battle_sub_page					= 0;
global.battle_target_cursor			= 0;
global.battle_selecting_target		= false;
global.battle_sub_open					= false;
global.battle_damage_display		= [];
global.battle_action_display			= "";
global.battle_action_timer			= 0;
global.battle_flee_result					= -1;
global.encounter_steps					= 0;
global.battle_target_list					= [];
global.battle_target_cursor			= 0;
global.battle_action_delay			= 0;
global.battle_sub_list						= [];
global.battle_sub_mode				= "";
global.battle_pending_entry		= undefined;
global.battle_attack_target			= -1;
global.battle_attack_target_side	= "";
global.battle_attacker						= -1;
global.battle_attacker_side			= "";
global.battle_intro_timer				= 0;
global.battle_all_target_side			= "";

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
"ITEM", "SKILL", "EQUIP", "STATS", "ORDER", 
"TALK", "MACRO", "CONFIG", "SAVE", "QUIT"
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
MENU_PAGE.SAVE,
MENU_PAGE.QUIT
];

//Inventory submenu state
global.inventory_state = INVENTORY_STATE.SELECT_WHO;
global.selected_party = 0;//0-3 for which party member
global.selected_item = 0;//index in their inventory
global.inventory_full_msg = false;//trigger shows full in topmid card

//equip menu state
global.equip_state = EQUIP_STATE.SELECT_WHO;
global.equip_char = 0;//which party member is being equipped
global.equip_scroll_page = 0;//current page in topright card scroll
global.equip_cursor = 0;//cursor position in scroll list 0-4
global.equip_pending_item = -1;//inventory index of it em being equipped
global.equip_hand_cursor = 0;//0 = rhand 1 = lhand for ambidextrous weapons
//==================================Global Menu Var==================================
global.submenu_history = ds_stack_create();
ds_stack_push(global.submenu_history, SUBMENU_HISTORY.MAIN);//start at top level



//pre-read slot metadata
scrSaveRefreshCache();
