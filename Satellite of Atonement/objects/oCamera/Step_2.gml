var _leader_type = global.partyOrder[0];
var _target = instance_find(_leader_type, 0);

if (_target != noone) {
	//target the center of the character's current tile
	var _dest_x = floor(_target.x + (TILE_WIDTH / 2));
	var _dest_y =floor( _target.y + (TILE_HEIGHT / 2));
	
	//smoothly interpolate the camera object's position
	x = lerp(x, _dest_x, follow_speed);
	y = lerp(y, _dest_y, follow_speed);
	
	x = floor(x);
	y = floor (y);
	
	var _vx = x - (base_width / 2);
	var _vy = y - (base_height / 2);
	
	//clamp to room bounds so we don't show the black void
	_vx = clamp(floor(_vx), 0, room_width - base_width);
	_vy = clamp(floor(_vy), 0, room_height - base_height);
	
	camera_set_view_pos(view_camera[0], _vx, _vy);
}
