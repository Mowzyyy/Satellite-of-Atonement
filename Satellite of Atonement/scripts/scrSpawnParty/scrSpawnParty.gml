function scrSpawnParty(){
	//dont spawn on main menu or if transitioning
	if (global.state == GAME_STATE.MAIN_MENU) return;
	if (global.state == GAME_STATE.TRANSITIONING && !global.pending_arrival) return;
if (array_length(global.party) > 0) {
	show_debug_message("scrSpawnParty party[0]: " + global.party[0].name + " Lv" + string(global.party[0].level) + " HP:" + string(global.party[0].current_hp));
}
	//destroy any existing partyy isntances to avoid duplicates
	for (var i = 0; i < array_length(global.partyOrder); i++) {
		var existing = instance_find(global.partyOrder[i], 0);
		if (existing != noone && instance_exists(existing)) {
			instance_destroy(existing);
		}
	}

//spawn each party member from partyOrder
for (var i = 0; i <array_length(global.partyOrder); i++) {
	instance_create_depth(0, 0, 0, global.partyOrder[i]);
	}
	show_debug_message("scrSpawnParty fired | party count: " + string(array_length(global.partyOrder)));

//apply saved follower positions if loading a game
if (array_length(global.load_follower_data) > 0) {
	for (var i = 0; i < array_length(global.partyOrder); i++) {
		var inst = instance_find(global.partyOrder[i], 0);
		if (inst == noone || !instance_exists(inst)) continue;
		if (i >= array_length(global.load_follower_data)) continue;
		
		var fd = global.load_follower_data[i];
		show_debug_message("follower " + string(i) + " | x: " + string(fd.x_pos) + " y: " + string(fd.y_pos) + " dir: " + string(fd.last_dir));
		
		inst.x_pos							= fd.x_pos;
		inst.y_pos							= fd.y_pos;
		inst.x_from							= fd.x_pos;
		inst.y_from							= fd.y_pos;
		inst.x_to								= fd.x_pos;
		inst.y_to								= fd.y_pos;
		inst.x										= fd.x_pos * TILE_WIDTH;
		inst.y										= fd.y_pos * TILE_HEIGHT;
		inst.last_dir							= fd.last_dir;
		inst.sprite_index				= inst.sprite_standing;
		inst.image_index				= fd.last_dir;
		inst.state								= states.idle;
		inst.walk_anim_time		= 0;
		ds_list_clear(inst.pos_x);
		ds_list_clear(inst.pos_y);
		ds_list_clear(inst.pos_dir);
	}
	global.load_follower_data = [];//clear after applying
	
	//follower data handled positioning
	global.pending_arrival = false;
	global.transition_phase = 2;
	global.transition_active = false;
	global.state = GAME_STATE.OVERWORLD;
	show_debug_message("scrSpawnParty load complete");
	return;//exit here
}

//if arrival was waiting for instances to exist handle it now
if (!global.pending_arrival) return;
global.pending_arrival = false;

var is_overworld = (global.transition_target_map == MAP.DUNES);
var offset_x = 0;
var offset_y = 0;
switch (global.transition_target_dir) {
	case directions.up: offset_y = 1; break;
	case directions.down: offset_y = -1; break;
	case directions.left: offset_x = 1; break;
	case directions.right: offset_x = -1; break;
}

for (var i = 0; i < array_length(global.partyOrder); i++) {
	var inst = instance_find(global.partyOrder[i], 0);
	if (inst == noone || !instance_exists(inst)) continue;
	
	var tile_x = global.transition_target_x + (is_overworld ? 0 : offset_x * i);
	var tile_y = global.transition_target_y + (is_overworld ? 0 : offset_y * i);
	
	inst.x_pos = tile_x;
	inst.y_pos = tile_y;
	inst.x_from = tile_x;
	inst.y_from = tile_y;
	inst.x_to = tile_x;
	inst.y_to = tile_y;
	inst.x = tile_x * TILE_WIDTH;
	inst.y = tile_y * TILE_HEIGHT;
	inst.last_dir = global.transition_target_dir;
	inst.sprite_index = inst.sprite_standing;
	inst.image_index = global.transition_target_dir;
	inst.state = states.idle;
	inst.walk_anim_time = 0;
	ds_list_clear(inst.pos_x);
	ds_list_clear(inst.pos_y);
	ds_list_clear(inst.pos_dir);
}

global.transition_phase = 2;
global.transition_active = false;
global.state = GAME_STATE.OVERWORLD;

show_debug_message("scrSpawnParty arrival complete | leader at: " + string(global.transition_target_x) + "," + string(global.transition_target_y));
}
