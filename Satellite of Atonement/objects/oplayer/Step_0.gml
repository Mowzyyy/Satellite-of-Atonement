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
		moveInputReceived = false;
}//A switch to define which direction the character is going to move before they move on screen, making it a switch means it checks in order and breaks

//Gets the input of the keys the user is pressing
keyUp = keyboard_check(vk_up) || keyboard_check(ord("W"));
keyDown = keyboard_check(vk_down) || keyboard_check(ord("S"))
keyLeft = keyboard_check(vk_left) || keyboard_check(ord("A"))
keyRight = keyboard_check(vk_right) || keyboard_check(ord("D"))
keyC = keyboard_check_pressed(ord("E")) || keyboard_check_pressed(ord("C")); //defines the Activate key as this button on the keyboard
keyB = keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("X"));
keyA = keyboard_check_pressed(vk_tab) || keyboard_check_pressed(ord("Z"));
