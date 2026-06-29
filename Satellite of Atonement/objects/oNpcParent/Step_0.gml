if (global.state != GAME_STATE.OVERWORLD) exit;

if (interact_cooldown > 0) {
	interact_cooldown--;
	if (interact_cooldown == 0) interacting = false;
	if (interacting) exit;
}

//walk animation lerp
if (state == states.walking) {
	walk_progress++;
	var t = walk_progress / walk_duration;
	x = x_from * TILE_WIDTH + (x_to - x_from) * TILE_WIDTH * t;
	y = y_from * TILE_HEIGHT + (y_to - y_from) * TILE_HEIGHT * t;
	
	//cycle walk frames across the step
	var _nFrames = sprite_get_number(sprite_index);
	if (_nFrames > 1) {
		image_index = floor((_nFrames) * t) mod _nFrames;
	}
	
	if (walk_progress >= walk_duration) {
		x = x_to * TILE_WIDTH;
		y = y_to * TILE_HEIGHT;
		x_pos = x_to; y_pos = y_to;
		state = states.idle;
		sprite_index = sprite_standing;
		image_index = last_dir;
		walk_progress = 0;
		walk_timer = walk_pause;
	}
	depth = -y;
	exit;
}

//wandering decision
if (move_type == 1 && walk_timer <= 0) {
	if (irandom(99) < walk_chance) {
		var try_dir = irandom(3);
		var dx = global.components[try_dir][0];
		var dy = global.components[try_dir][1];
		var dest_x = x_pos + dx;
		var dest_y = y_pos + dy;
		//check barriers, otehr Npcs, and party members
		var blocked = scrIsBarrierBlocked(dest_x, dest_y, try_dir) || scrIsTileOccupied(dest_x, dest_y);
		if (!blocked) {
			for (var pin = 0; pin < array_length(global.partyOrder); pin++) {
				var pinst = instance_find(global.partyOrder[pin], 0);
				if (pinst != noone && instance_exists(pinst) && pinst.x_pos == dest_x && pinst.y_pos == dest_y) {
					blocked = true;
					break;
				}
			}
		}
		
		if (!blocked) {
			x_from = x_pos;y_from = y_pos;
			x_to = dest_x; y_to = dest_y;
			x_pos = x_to; y_pos = y_to;
			last_dir = try_dir;
			state = states.walking;
			sprite_index = sprite[try_dir];
			image_index = 0;
			walk_progress = 0;
		}
	}
	walk_timer = walk_interval;
} else if (walk_timer > 0) {
	walk_timer--;
}

//interaction
if (global.keyC) {
	var leader = instance_find(global.partyOrder[0], 0);
	if (leader != noone && instance_exists(leader)) {
		var dx = abs(x_pos - leader.x_pos);
		var dy = abs(y_pos - leader.y_pos);
		if ((dx == 1 && dy == 0) || (dx == 0 && dy == 1)) {
			//face the player
			if (leader.x_pos > x_pos) last_dir = directions.right;
			else if (leader.x_pos < x_pos) last_dir = directions.left;
			else if (leader.y_pos < y_pos) last_dir = directions.up;
			else if (leader.y_pos > y_pos) last_dir = directions.down;
			sprite_index = sprite_standing;
			image_index = last_dir;
			state = states.idle;
			walk_progress = 0;
			interacting = true;
			interact_cooldown = 30;
			io_clear();
			global.keyC = false;
		}
	}
}

depth = -y;

//keep idle NPCs locked to their facing frame
if (state == states.idle) {
	image_speed = 0;
	image_index = last_dir;
}