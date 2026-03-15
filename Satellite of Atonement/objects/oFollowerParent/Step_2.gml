if (myRank > 0) {
	var _target_inst = global.partyOrder[myRank - 1];
	
	if (instance_exists(_target_inst)) {
		// -- The Trigger -- 
		//if the person in front of my is walking, follow their shadow
		if (_target_inst.state == states.walking && state == states.idle) {
			state = states.walking
				
				//destination is always the previous tile of the person in front
				x_from = x_pos;
				y_from = y_pos;
				x_to = _target_inst.x_from;
				y_to = _target_inst.y_from;
				
				//update logical grid position
				x_pos = x_to;
				y_pos = y_to;
				
				//mirror direction
				sprite_index = sprite[last_dir];
		}
		
			
		// -- The Master Sync --
		//force my clock to match the person in front
		if (state == states.walking) {
			walk_anim_time = _target_inst.walk_anim_time;
			
			//hand-off
			if (walk_anim_time >= walk_anim_length || _target_inst.state ==states.idle) {
				//if we are at the end of the step
				if (walk_anim_time >= walk_anim_length) {
					
					x_pos = x_to;
					y_pos = y_to;
					
					last_dir = _target.last_dir;
					sprite_index = sprite[last_dir];
					
					state = states.idle;
					walk_anim_time = 0;
				}
			}
		}
	}
}