var _my_idx = -1;
for (var _di = 0; _di < array_length(global.party); _di++) {
	if (global.partyOrder[_di] == object_index) { _my_idx = _di; break; }
}

var _i_am_dead = (_my_idx >= 0 && global.party[_my_idx].is_dead);

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
			
			//if target just completed a slide step follow the intermediate tile
			if (global.slide_queued && myRank < array_length(global.slide_history)) {
				var sh = global.slide_history[myRank - 1];
				x_to = sh.x;
				y_to = sh.y;
			} else {
				x_to = _target_inst.x_from;
				y_to = _target_inst.y_from;
			}
			
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
			if (_i_am_dead) {
				sprite_index = sprite_standing;
				image_index = last_dir;
			} else {
				sprite_index = sprite[move_dir];
			}
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

// Contextual occlusion
for (var mRaCheck = 0; mRaCheck < array_length(global.partyOrder); mRaCheck++) {
    var _inst = instance_find(global.partyOrder[mRaCheck], 0);
    if (_inst == noone || !instance_exists(_inst)) continue;
    // Lower on screen (higher y) = drawn on top = lower depth
    _inst.depth = -_inst.y;
}