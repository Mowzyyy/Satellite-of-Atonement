//Draw sprite at a rounded (floored) position
//This prevents the blurring while the character is moving via lerp
if (sprite_index != -1 && sprite_index != noone) {
	draw_sprite_ext(
		sprite_index, 
        image_index, 
        x - global.cam_frac_x, 
        y - global.cam_frac_y, 
        image_xscale, 
        image_yscale, 
        image_angle, 
        image_blend, 
        image_alpha
);

}

