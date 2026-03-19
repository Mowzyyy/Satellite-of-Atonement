//Find leader's position in the line
myRank = 0;
for (var slot = 0; slot < array_length(global.partyOrder); slot++) {
	if (global.party_order[slot] == object_index) {
		myRank = i;
		break;
	}
}

//Movement variables
state = states.idle;
x_from = x;
y_from = y;
x_to = x;
y_to = y;
walk_anim_t = 0;

//Mirroring script from oPlayer Create Event to set up walking for every follower to behave identically
state = states.idle;
x_pos = x div TILE_WIDTH;
y_pos = y div TILE_HEIGHT;

x_from = x_pos;
y_from = y_pos;
x_to = x_pos;
y_to = y_pos;

walk_anim_length = 0.5;
walk_anim_time = 0;

image_speed = 0;
frames = [0, 1, 0, 2, 0];
walk_anim_frames = 5;

//sprite directions

//Every follower will be given its own history queue
pos_x = ds_list_create();
pos_y = ds_list_create();
pos_dir = ds_list_create();
last_dir = directions.down;
