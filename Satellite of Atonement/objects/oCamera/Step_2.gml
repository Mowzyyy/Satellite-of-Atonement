var _leader_type = global.partyOrder[0];
var _target = instance_find(_leader_type, 0);

if (_target != noone) {
	//target the center of the character's current tile
	var _dest_x = _target.x + (TILE_WIDTH / 2);
	var _dest_y =_target.y + (TILE_HEIGHT / 2);
	
	//smooth follow x acis
	var _new_x = lerp(x, _dest_x, 0.2);
	var _intended_vx = floor(_new_x - (base_width / 2));
	var _clamped_vx = clamp(_intended_vx, 0, room_width - base_width);
	
	if (_clamped_vx != _intended_vx) {
		_new_x = _clamped_vx + (base_width / 2);//lock x at the horizontal border
	}
	
	//y axis
	var _new_y = lerp(y, _dest_y, 0.2);
	var _intended_vy = floor(_new_y - (base_height / 2));
	var _clamped_vy = clamp(_intended_vy, 0, room_height - base_height);
	
	if (_clamped_vy != _intended_vy) {
		_new_y = _clamped_vy + (base_height / 2);//lock y at the vertical border	
	}
	
	//apply final camera center
	x = _new_x;
	y = _new_y;

	var _vx = floor(x - (base_width / 2));
	var _vy = floor(y - (base_height / 2));
	
	//clamp to room bounds so we don't show the black void
	_vx = clamp(_vx, 0, room_width - base_width);
	_vy = clamp(_vy, 0, room_height - base_height);
	
	
	camera_set_view_pos(view_camera[0], _vx, _vy);
	
	// --- Compensation ---
	global.cam_frac_x = x - (_vx + base_width / 2);
	global.cam_frac_y = y - (_vy + base_height / 2);
}
