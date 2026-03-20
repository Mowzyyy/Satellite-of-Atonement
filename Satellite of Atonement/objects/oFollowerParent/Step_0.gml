turn_cooldown = 0;

//If not the leader (rank = 0), follow the person in front
if (myRank == 0 && state == states.idle) {
	// LEADER LOGIC
	
	//Gets the input of the keys the user is pressing
	keyUp = keyboard_check(vk_up) || keyboard_check(ord("W"));
	keyDown = keyboard_check(vk_down) || keyboard_check(ord("S"))
	keyLeft = keyboard_check(vk_left) || keyboard_check(ord("A"))
	keyRight = keyboard_check(vk_right) || keyboard_check(ord("D"))
	keyC = keyboard_check_pressed(ord("E")) || keyboard_check_pressed(ord("C")); //defines the Activate key as this button on the keyboard
	keyB = keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("X"));
	keyA = keyboard_check_pressed(vk_tab) || keyboard_check_pressed(ord("Z"));
	
	//Detect a new press to change facing immediately, psiv style
	var pressed_dir = -1;
	
//A switch to define which direction the character is going to move before they move on screen, making it a switch means it checks in order and breaks
//Inspired directly by how Phantasy Star IV movement

	//placing the switch inside an if states idle check smoothens the effect of movement and feels less laggy/sluggish from input buffering
	switch(keyboard_key){ 
		case vk_left:
		case ord("A"):
			if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
				pressed_dir = directions.left;
			}
				break;
	
		case vk_right:
		case ord("D"):
			if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
				pressed_dir = directions.right;
			}
				break;

		case vk_up:
		case ord("W"):
			if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
				pressed_dir = directions.up;
			}
				break;
	
		case vk_down:
		case ord("S"):
			if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
				pressed_dir = directions.down;
			}
				break;
	}
	//If there was a new press then always update facing/sprite even if not moving
	if (pressed_dir != -1) {
		last_dir = pressed_dir;
		sprite_index = sprite[pressed_dir];
	}
	
	turn_cooldown = 5;
	show_debug_message(turn_cooldown);

	//if a valid move direction was found, commit to stepping
		if (turn_cooldown > 0) {
		turn_cooldown--;
	}
	
	//commit to movement only if holding and already facing that way
	var move_dir = -1;
	
	if (keyLeft && last_dir == directions.left) move_dir = directions.left;
	if (keyRight && last_dir == directions.right) move_dir = directions.right;
	if (keyUp && last_dir == directions.up) move_dir = directions.up;
	if (keyDown && last_dir == directions.down) move_dir = directions.down;
	
	
	if (move_dir != -1) {
		Move(move_dir);
	}

}

//movement script, identical to script from oPlayer Step Event
if (state == states.walking){
	//only the leader progresses the clock
	if (myRank == 0) {
		walk_anim_time += delta_time / 1000000;
	}
	
	var _t = clamp(walk_anim_time / walk_anim_length, 0 ,1);
	
	//only the leader resets the state
	//followers will be reset in the end step
	if (myRank == 0 && walk_anim_time >= walk_anim_length) {
		walk_anim_time = 0;
		state = states.idle;
		x_pos = x_to;
		y_pos = y_to;
	}
	
	x = lerp(x_from, x_to, _t) * TILE_WIDTH;
	y = lerp(y_from, y_to, _t) * TILE_HEIGHT;
	
	if (is_array(frames) && array_length(frames) > 0) {
		image_index = frames[floor((array_length(frames) - 1) * _t)];
	}
}