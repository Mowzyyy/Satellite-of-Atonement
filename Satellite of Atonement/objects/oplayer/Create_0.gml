//This event sets up the main variables to animate the character
/*
Old Code

walkSpeed = 4.0; //sets the speed for walking speed

spriteWalk = sLeonWalking; //Sets the walking sprite
spriteIdle = sLeon; //Sets the idle sprite
localFrame = 0;
*/
enum states {
	idle,
	walking
} //creates the idle and walking states

state = states.idle; //sets the default state to idle

x_pos = x div TILE_WIDTH;
y_pos = y div TILE_HEIGHT;

x_from = x_pos;//defines what x position the player is moving from
y_from = y_pos;

x_to = x_pos;//defines what x position the player is moving to
y_to = y_pos;

walk_anim_length = 0.5; //time in seconds it takes to cross one tile
walk_anim_time = 0; //how far along the animation we are in seconds

image_speed = 0; //stops sprite from animating
frames = [0, 1, 0, 2, 0];
walk_anim_frames = 5;

sprite[directions.right] = sLeonRight;
sprite[directions.left] = sLeonLeft;
sprite[directions.up] = sLeonUp;
sprite[directions.down] = sLeonDown;

