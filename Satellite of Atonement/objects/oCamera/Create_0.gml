//Create the viewing pane
base_width = 320;
base_height = 240;

//enable the camera
view_enabled = true;
view_visible[0] = true;

//follow speed: 1 is instant, 0.1 is smooth glide
follow_speed = 1

//Initial position setup
var _leader_type = global.partyOrder[0];
var _target = instance_find(_leader_type, 0);
if (_target != noone) {
	x = _target.x;
	y = _target.y;
}