//Update Sprite
function scrPlayerAnimateSprite(){
	var _cardinalDirection = round(direction/90); //gets the cardinal direction as an integer 0-3
	var _totalFrames = sprite_get_number(sprite_index) / 4; //chops up the total frames by the number of directions
	image_index = localFrame + (_cardinalDirection * _totalFrames); //to get image index, take the local frame plut the direction multiplied by total frames in the animation
	localFrame += sprite_get_speed(sprite_index) / FRAME_RATE; //animating by local frame to figure out what the image index should be divided by the frame rate

//If animation would loop on next game step
	if (localFrame >= _totalFrames)
	{
		animationEnd = true;
		localFrame -= _totalFrames
	}else animationEnd = false;
}