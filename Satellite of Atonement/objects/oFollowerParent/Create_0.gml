//Find leader's position in the line
myRank = 0;
for (var slot = 0; slot < array_length(global.partyOrder); slot++) {
	if (global.partyOrder[slot] == object_index) {
		myRank = slot;
		break;
	}
}

//Grid Position management
state = states.idle;
x_pos = x div TILE_WIDTH;
y_pos = y div TILE_HEIGHT;

x_from = x_pos;
y_from = y_pos;
x_to = x_pos;
y_to = y_pos;

//Animation and States
state = states.idle;
walk_anim_length = 0.5;//seconds to cross one tile
walk_anim_time = 0;//current progress in seconds
image_speed = 0;//frames are handled manually
frames = [0, 1, 0, 2, 0];
walk_anim_frames = 5;


//Every follower will be given its own history queue
pos_x = ds_list_create();
pos_y = ds_list_create();
pos_dir = ds_list_create();
last_dir = directions.down;//default face down

//sprite directions initialization
sprite[directions.right] = noone;
sprite[directions.left] = noone;
sprite[directions.up] = noone;
sprite[directions.down] = noone;

//Track where a specific follower is in the party line
myRank = -1;
for (var slot = 0; slot < array_length(global.partyOrder); slot++) {
	if (global.partyOrder[slot] == object_index){
		myRank = slot;
		break;
	}
}
