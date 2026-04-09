//call script to begin a room transition
//_room - room to go to
//_map_id - map Enum value
// _world_x - tile x on arrival
//_world_y  - tile y on arrival
// _dir - directions enum facing on arrival
// _music - sound asset, -1 for no change

function scrBeginTransition(_room, _map_id, _world_x, _world_y, _dir, _music = -1) {
	if (global.transition_active) return;
	
	global.transition_active = true;
	global.pending_arrival = true;
	global.transition_target_room = _room;
	global.transition_target_x = _world_x;
	global.transition_target_y = _world_y;
	global.transition_target_dir = _dir;
	global.transition_target_map = _map_id;
	global.transition_music = _music;
	global.state = GAME_STATE.TRANSITIONING;
	global.transition_alpha = 0;//starts transparent
	global.transition_phase = 0;//0 = fading out, 1 = changing room, 2 = fading in
}

//call this in the Create event of every overworld room to handle arrival
function scrHandleArrival() {
	if (!global.transition_active) return;
	global.pending_arrival = true;
	show_debug_message("scrHandleArrival firing | target: " + string(global.transition_target_x) + "," + string(global.transition_target_y));
}