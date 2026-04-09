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
} else { 
x = room_width /2;
y = room_height / 2;
}

/*
//store smooth subpixel center
x = _target.x + (TILE_WIDTH /2);//initial
y = _target.y + (TILE_HEIGHT / 2);
*/

//global frac variables
global.cam_frac_x = 0;
global.cam_frac_y = 0;