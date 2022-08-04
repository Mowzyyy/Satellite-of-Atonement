//Movement and Input


//moveInputReceived = false; //this bool tells if a movement key's input has been received

switch(keyboard_key){ 
	case vk_left:
	case ord("A"):
		Move(directions.left);
			break;
	
	case vk_right:
	case ord("D"):
		Move(directions.right);
			break;

	case vk_up:
	case ord("W"):
		Move(directions.up);
			break;
	
	case vk_down:
	case ord("S"):
		Move(directions.down);
			break;
	default:
		//moveInputReceived = false;
}//A switch to define which direction the character is going to move before they move on screen, making it a switch means it checks in order and breaks

//Gets the input of the keys the user is pressing
keyUp = keyboard_check(vk_up) || keyboard_check(ord("W"));
keyDown = keyboard_check(vk_down) || keyboard_check(ord("S"))
keyLeft = keyboard_check(vk_left) || keyboard_check(ord("A"))
keyRight = keyboard_check(vk_right) || keyboard_check(ord("D"))
keyC = keyboard_check_pressed(ord("E")) || keyboard_check_pressed(ord("C")); //defines the Activate key as this button on the keyboard
keyB = keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("X"));
keyA = keyboard_check_pressed(vk_tab) || keyboard_check_pressed(ord("Z"));

/*
imageIndex = round(image_index); //rounds the image index to an integer

//Update Sprite Index
var _oldSprite = sprite_index;
if (moveInputReceived == true) //checks if movement input is received
{
	sprite_index = sLeonWalking; //changes the sprite index to the walking animation
} else if ((imageIndex + 1)%2 == 0){ 
	sprite_index = sLeon;
	show_debug_message("successful")
	} //changes the sprite to the idle animation

//Try to find a way to make the animation follow through before stopping


if (_oldSprite != sprite_index) localFrame = 0;

//Update image index
PlayerAnimateSprite();
*/

if (state == states.walking) { //checks if player is in walking state
	walk_anim_time += delta_time / 1000000; //updates the animation time
	
	var t = walk_anim_time / walk_anim_length; //tells how far along the animation we are between 0 and 1
	
	if (t >= 1) { //checks if the end of the animation is reached when t = 1
		walk_anim_time = 0;
		t = 1;
		state = states.idle;
	}
	
	var _x = lerp(x_from, x_to, t) //the lerp function tells how far along a destination between 2 points and find the coordinates
	var _y = lerp(y_from, y_to, t)
	
	x = _x * TILE_WIDTH;
	y = _y * TILE_HEIGHT;
	
	image_index = frames[floor((walk_anim_frames - 1) * t)]
}