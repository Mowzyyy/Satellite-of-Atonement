if (myRank > 0) {
	var _target_obj = global.partyOrder[myRank - 1];
	var _target_inst = instance_find(_target_obj, 0);
	
	if (_target_inst != noone && instance_exists(_target_inst)) {
		// --- The Trigger ---
		//Person in front just started walking, follow their old tile
		if (_target_inst.state == states.walking && state == states.idle) {
			state = states.walking;
			
			x_from = x_pos;
			y_from = y_pos;
			x_to = _target_inst.x_from;
			y_to = _target_inst.y_from;
			
			//Logical position updates immediately
			x_pos = x_to;
			y_pos = y_to;
			
			//Calculate our movement direction for correct facing
			var dx = x_to - x_from;
			var dy = y_to - y_from;
			var move_dir = last_dir; // fallback
			if (dx > 0) move_dir = directions.right;
			else if (dx < 0) move_dir = directions.left;
			else if (dy >0) move_dir = directions.down;
			else if (dy <0) move_dir = directions.up;
			
			last_dir = move_dir;
			sprite_index = sprite[move_dir];
		}
		// --- The Master Sync ---
		if (state == states.walking) {
			//copy timing from the person in front so everyone animates in perfect sync
			walk_anim_time = _target_inst.walk_anim_time;
			
			//when person in front finishes their step, finish step
			if (_target_inst.state == states.idle) {
				x_pos = x_to;
				y_pos = y_to;
				state = states.idle;
				walk_anim_time = 0;
				sprite_index = sprite_standing;
				image_index = last_dir;
			}
		}
	}
}

//Contextual occlusion
for (var mRaCheck = 1; mRaCheck < array_length(global.partyOrder); mRaCheck++) {
		var _follower = instance_find(global.partyOrder[mRaCheck], 0);
		var _ahead = instance_find(global.partyOrder[mRaCheck-1], 0);
		
		if (_follower == noone || _ahead == noone) continue;
		if (_ahead.last_dir == directions.down) {
			//person ahead facing down, follower draws behind - no standing on head
			_follower.depth = _ahead.depth+10;
		}
		else if (_ahead.last_dir == directions.up) {
			//person ahead facing up, follower draws in front
			_follower.depth = _ahead.depth - 10;
		}
		else {
			//left/right = neutral, slightly ahead as to not overlap
			_follower.depth = _ahead.depth + 2;
		}
}

var _leader = instance_find(global.partyOrder[0], 0);
if (_leader != noone) _leader.depth = 0;