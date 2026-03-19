//Track where a specific follower is in the party line
myRank = array_get_index(global.partyOrder, object_index);

//If not the leader (rank = 0), follow the person in front
if (myRank > 0) {
	var leader = global.partyOrder[myRank - 1]
	
	//Check if the person in front has started moving
	if (leader.state == states.walking && leader.walk_anim_t == 0) {
		ds_list_insert(pos_x, 0, leader.x_from);
		ds_list_insert(pos_y, 0, leader.y_from);
		ds_list_insert(pos_dir, 0, leader.last_dir);
	}
	
	//If I have a destination and am idle, start moving
	if (state == states.idle && ds_list_size(pos_x) > 0) {
		x_from = x_pos;
		y_from = y_pos;
		
		var _idx = ds_list_size(pos_x) -1;
		x_to = ds_list_find_value(pos_x, _idx);
        y_to = ds_list_find_value(pos_y, _idx);
        last_dir = ds_list_find_value(pos_dir, _idx);
		
		//update the sprite to match the direction
		sprite_index = sprite[last_dir];
		
		//remove the oldest recorded position after taking it
		ds_list_delete(pos_x, _idx);
		ds_list_delete(pos_y, _idx);
		ds_list_delete(pos_dir, _idx);
		
		state = states.walking;
		x_pos = x_to;
		y_pos = y_to;
	}
}

//movement script, identical to script from oPlayer Step Event
if (state == states.walking) {
	walk_anim_time += delta_time / 1000000;
	var t = walk_anim_time / walk_anim_length;
	
	if (t >= 1) {
		walk_anim_time = 0;
		t = 1;
		state = states.idle;
	}
	
	var _x = lerp(x_from, x_to, t);
	var _y = lerp(y_from, y_to, t);
	
	x = _x * TILE_WIDTH;
	y = _y * TILE_HEIGHT;
	
	image_index = frames[floor((walk_anim_frames - 1) * t)];
}