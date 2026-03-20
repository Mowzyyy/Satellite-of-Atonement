//If not the leader (rank = 0), follow the person in front
if (myRank == 0) {
	// LEADER LOGIC
	
	//Gets the input of the keys the user is pressing
	keyUp = keyboard_check(vk_up) || keyboard_check(ord("W"));
	keyDown = keyboard_check(vk_down) || keyboard_check(ord("S"))
	keyLeft = keyboard_check(vk_left) || keyboard_check(ord("A"))
	keyRight = keyboard_check(vk_right) || keyboard_check(ord("D"))
	keyC = keyboard_check_pressed(ord("E")) || keyboard_check_pressed(ord("C")); //defines the Activate key as this button on the keyboard
	keyB = keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("X"));
	keyA = keyboard_check_pressed(vk_tab) || keyboard_check_pressed(ord("Z"));
	
	//A switch to define which direction the character is going to move before they move on screen, making it a switch means it checks in order and breaks
	//Inspired directly by how Phantasy Star IV movement
	if (state == states.idle) {
		//placing the switch inside an if states idle check smoothens the effect of movement and feels less laggy/sluggish from input buffering
		switch(keyboard_key){ 
			case vk_left:
			case ord("A"):
				Move(directions.left);
					break;
	
			case vk_right:
			case ord("D"):
				Move(directions.right);
					break;

			case vk_up:
			case ord("W"):
				Move(directions.up);
					break;
	
			case vk_down:
			case ord("S"):
				Move(directions.down);
					break;
			default:
				//moveInputReceived = false;
		}
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