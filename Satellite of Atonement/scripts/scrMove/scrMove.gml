function scrMove(_dir){
    var components = global.components[_dir];
    var dx = components[0];
    var dy = components[1];
    
    if (state == states.idle) {
		var dest_x = x_pos + dx;
		var dest_y = y_pos + dy;

		//check for barrier on destination tile
		if (scrIsBarrierBlocked(dest_x, dest_y, _dir) || scrIsTileOccupied(dest_x, dest_y)) {
			show_debug_message("BLOCKED at " + string(dest_x) + "," + string(dest_y) + " from dir " + string(_dir));
			//try to slide
			var slide_dir = scrGetSlideDir(dest_x, dest_y, x_pos, y_pos, _dir);
			if (slide_dir != -1) {
				//queue a slide - step perpendicular then continue in original direction
				global.slide_queued = true;
				global.slide_follow_dir = _dir;
				
				//record intermediate tile for all followers to read
				global.slide_history = [];
				for (var sli = 0; sli < array_length(global.partyOrder); sli++) {
					var inst = instance_find(global.partyOrder[sli], 0);
					if (inst != noone && instance_exists(inst)) {
						array_push(global.slide_history, { x: inst.x_pos, y: inst.y_pos });
					} else {
						array_push(global.slide_history, { x: x_pos, y: y_pos });
					}
				}
				scrMove(slide_dir);//step perpendicular
			} else {
				//hard block - face the direction but don't move
				last_dir = _dir;
				sprite_index = sprite_standing;
				image_index = _dir;
			}
			return;
		}
		show_debug_message("ALLOWED move to " + string(dest_x) + "," + string(dest_y));
		
        x_from = x_pos;
        y_from = y_pos;
        
        x_to = x_pos + dx;
        y_to = y_pos + dy;
        
        x_pos = x_to;
        y_pos = y_to;
        
        last_dir = _dir;
        state = states.walking;
        sprite_index = sprite[_dir];
    }
}