if (global.state == GAME_STATE.IN_GAME_MENU) exit;
if (global.state == GAME_STATE.BATTLE) exit;

//death state locks to standing sprite
var _party_idx = -1;
for (var dei = 0; dei < array_length(global.party); dei++) {
	if (global.partyOrder[dei] == object_index) {
		_party_idx = dei;
		break;
	}
}
var _i_am_dead = (_party_idx >= 0 && global.party[_party_idx].is_dead);

for (var ide = 0; ide < array_length(global.party); ide++) {
	var _pm = global.party[ide];
	if (_pm.current_hp <= 0 && !_pm.is_dead) {
		_pm.current_hp = 0;
		_pm.is_dead = true;
		_pm.status_effects = [];
		show_debug_message(_pm.name + " is in dying state");
	} else if (_pm.current_hp > 0 && _pm.is_dead) {
		_pm.is_dead = false;
		show_debug_message(_pm.name + " has been revived");
	}
}

//If not the leader (rank = 0), follow the person in front
if (myRank == 0) {
	// LEADER LOGIC
	
	//A switch to define which direction the character is going to move before they move on screen, making it a switch means it checks in order and breaks
	//Inspired directly by how Phantasy Star IV movement
	if (state == states.idle) {
		
		//queued slide takes place before reading new input
	if (global.slide_followup) {
		global.slide_followup = false;
		scrMove(global.slide_follow_dir);
	}
		
		var input_dir = -1;
		
		if (global.keyLeft) input_dir = directions.left;
		else if (global.keyRight) input_dir = directions.right;
		else if (global.keyUp) input_dir = directions.up;
		else if (global.keyDown) input_dir = directions.down;
		
		//placing the switch inside an if states idle check smoothens the effect of movement and feels less laggy/sluggish from input buffering
		switch(input_dir){ 
			case directions.left:
				scrMove(directions.left);
					break;
	
			case directions.right:
				scrMove(directions.right);
					break;

			case directions.up:
				scrMove(directions.up);
					break;
	
			case directions.down:
				scrMove(directions.down);
					break;
			default:
				//no movement input
				//moveInputReceived = false; //uncomment if flag is in use
				break;
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
		sprite_index = sprite_standing;
		image_index = last_dir;
		x = x_pos * TILE_WIDTH;
		y = y_pos * TILE_HEIGHT;
	
		//fire queued slide followup step
		if (global.slide_queued) {
			global.slide_queued = false;
			global.slide_history = [];
			global.slide_followup = true;
		}
		
		//count this completed step for random encounters
		if (global.state == GAME_STATE.OVERWORLD) {
			scrStepEncounter(global.current_map_id);
		}
		
		exit;
	}
	
	x = lerp(x_from, x_to, _t) * TILE_WIDTH;
	y = lerp(y_from, y_to, _t) * TILE_HEIGHT;
	
	if (_i_am_dead) {
		//slide without animating
		sprite_index = sprite_standing;
		image_index = last_dir;
		image_alpha = 0.4;
	} else if (is_array(frames) && array_length(frames) > 0) {
		image_alpha = 1;
		image_index = frames[floor((array_length(frames) - 1) * _t)];
	}
}