if (trigger_fired) exit;
if (global.transition_active) exit;
if (global.state != GAME_STATE.OVERWORLD) exit;

//find the leader
var leader = instance_find(global.partyOrder[0], 0);
if (leader == noone || !instance_exists(leader)) exit;

//only trigger when leader is idle and centered on this trigger's tile
if (leader.state != states.idle) exit;

var leader_tile_x = leader.x_pos;
var leader_tile_y = leader.y_pos;
var trigger_tile_x = x div TILE_WIDTH;
var trigger_tile_y = y div TILE_HEIGHT;


if (leader_tile_x == trigger_tile_x && leader_tile_y == trigger_tile_y) {
	trigger_fired = true;
	global.current_map_id = target_map;
	show_debug_message("ZoneTrigger firing | target room: " + string(target_room) + " | target tile: " + string(target_tile_x) + "," + string(target_tile_y) + " | map: " + string(target_map));
	scrBeginTransition(target_room, target_map, target_tile_x, target_tile_y, target_dir, target_music);
}