//returns the barrier data for a given tile index
//blocked_from: array of directions that CANNOT enter this tile
//returns undefined if tile has no barrier data
function scrGetBarrierData(_tile_idx) {
	show_debug_message("scrGetBarrierData called with: " + string(_tile_idx));
	switch (_tile_idx) {
		//row 1
		case 2: return { blocked: [directions.right, directions.down] };
		case 3: return { blocked: [directions.right, directions.down, directions.left] };
		case 4: return { blocked: [directions.down, directions.left] };
		
		//row 2
		case 7: return { blocked: [directions.right] };
		case 8: return { blocked: [directions.left] };
		case 9: return { blocked: [directions.up, directions.down, directions.right] };
		case 10: return { blocked: [directions.up, directions.down, directions.right, directions.left] };
		case 11: return { blocked: [directions.up, directions.down, directions.left] };
		
		//row 3
		case 14: return { blocked: [directions.up] };
		case 15: return { blocked: [directions.down] };
		case 16: return { blocked: [directions.up, directions.right] };
		case 17: return { blocked: [directions.up, directions.left, directions.right] };
		case 18: return { blocked: [directions.up, directions.left] };
		
		default: return undefined;//no barrier
	}
}


//returns true if moving in _mov_dir onto tile at (_tx, _ty) is blocked
function scrIsBarrierBlocked(_tx, _ty, _mov_dir) {
	var _layer = layer_get_id("Barriers");
	if (_layer == -1) return false;
	var _tilemap = layer_tilemap_get_id(_layer);
	show_debug_message("tilemap x: " + string(tilemap_get_x(_tilemap)) + " tilemap y: " + string(tilemap_get_y(_tilemap)));
	if (_tilemap == -1) return false;
	
	var _tile_idx = tilemap_get(_tilemap, _tx, _ty);
	show_debug_message("raw tilemap value: " + string(_tile_idx));
	
	//strip flags
	_tile_idx = _tile_idx & tile_index_mask;
	show_debug_message("masked tile index: " + string(_tile_idx));
	
	var _data = scrGetBarrierData(_tile_idx);
	if (_data == undefined) return false;
	
	//check if move direction is in the blocked array
	for (var i = 0; i < array_length(_data.blocked); i++) {
		show_debug_message("comparing blocked[" + string(i) + "]: " + string(_data.blocked[i]) + " vs entry_dir: " + string(_mov_dir));
		if (_data.blocked[i] == _mov_dir) return true;
	}
	show_debug_message("barrier check | tile: " + string(_tx) + "," + string(_ty) + " | idx: " + string(_tile_idx) + " | entry_dir: " + string(_mov_dir));

	return false;
}

//returns the slide direction if a slide is possible, or -1 if not
//_tx, _ty is the destination tile that was blocked
//_move_dir is the original intended direction
function scrGetSlideDir(_tx, _ty, _from_x, _from_y, _move_dir) {
	//perpendicular directions based on intended movement
	var perp = [];
	if (_move_dir == directions.left || _move_dir == directions.right) {
		perp = [directions.left, directions.right, directions.up, directions.down];
		//remove the original direction from candidates
		perp = [directions.up, directions.down];//perpendicular to left/right ios up/down
	} else {
		perp = [directions.left, directions.right];//perpendicular to up/down is left/right
	}
	
	var priority = [directions.left, directions.right, directions.up, directions.down];
	var candidates = [];
	
	for (var i = 0; i < array_length(priority); i++) {
		var d = priority[i];
		var in_perp = false;
		for (var j = 0; j < array_length(perp); j++) {
			if (perp[j] == d) { in_perp = true; break; }
		}
		if (!in_perp) continue;
		
		//check the adjacent tile in this perpendicular direction
		var comp = global.components[d];
		var slide_tx = _from_x + comp[0];
		var slide_ty = _from_y + comp[1];
		
		//can we enter the adjacent tile from our original direction?
		if (scrIsBarrierBlocked(slide_tx, slide_ty, _move_dir)) continue;
		
		//can we enter the adjacent tile from the perpendicular direction?
		if (scrIsBarrierBlocked(slide_tx, slide_ty, d)) continue;
		
		//check that the tile beyond the slide in the original direction is also open
		var comp2 = global.components[_move_dir];
		var final_tx = slide_tx + comp2[0];
		var final_ty = slide_ty + comp2[1];
		if (scrIsBarrierBlocked(final_tx, final_ty, _move_dir)) continue;
		
		array_push(candidates, d);
		break;//take first valid by priority
	}
	
	if (array_length(candidates) == 0) return -1;
	return candidates[0];
}