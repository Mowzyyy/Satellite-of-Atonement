//Draw sprite at a rounded (floored) position
//This prevents the blurring while the character is moving via lerp
if (sprite_index != -1) {
	var _draw_x = floor(x);
	var _draw_y = floor(y);

	draw_sprite_ext(
		sprite_index, 
        image_index, 
        floor(x), // This 'x' was already multiplied by TILE_WIDTH in the Step Event
        floor(y), 
        image_xscale, 
        image_yscale, 
        image_angle, 
        image_blend, 
        image_alpha
);

}

