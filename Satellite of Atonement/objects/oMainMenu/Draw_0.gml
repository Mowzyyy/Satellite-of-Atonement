//Always draw the background
draw_sprite(sBackgroundMain, 0, 0, 0);

switch (stage) {
		case TITLE_STAGE.SPLASH_1:
			draw_sprite(sLogoStudio, 0, 0, 0);
			break;
			
		case TITLE_STAGE.SPLASH_2:
			draw_sprite(sLogoEngine, 0, 0, 0)
			break;
		case TITLE_STAGE.TITLE_IDLE:
				if (show_press_start) {
					if ((current_time mod 1000) < 500) {
						draw_set_halign(fa_center);
						draw_set_color(c_white);
						draw_set_alpha(1.0);
				
						var prompt_text = "Press E or C";
						var center_x = room_width / 2;
						var y_pos = room_height / 2;
				
						draw_text(center_x, y_pos, prompt_text);
				
						draw_set_halign(fa_left);
					}
				}
				break;

		
		case TITLE_STAGE.MENU_ACTIVE:
			// -- Auto-menu using sBasicGUI
			var num_opts = array_length(menu_options);
			
			//find the longest text width
			var max_text_w = 0;
			for (var i = 0; i < num_opts; i++) {
				var tw = string_width(menu_options[i]);
				if (tw > max_text_w) max_text_w = tw;
			}
			
			//width = space for blinking cursor + longest text + tiny padding
			var tile_size = 8;
			var cursor_space = 8;
			var inner_side_pad = 12;
			var panel_w = cursor_space + max_text_w + inner_side_pad * 2;
			
			//force width to multiple of tile_size
			panel_w = ceil(panel_w / tile_size) * tile_size;
			
			//height = rows + very small top/bottom padding
			var row_height = 16;
			var inner_vert_pad =8;
			var panel_h = (num_opts * row_height) + inner_vert_pad * 2;
			panel_h = ceil(panel_h / tile_size) * tile_size;
			
			//position so it dodges the bottom of the screen
			//panel grows upward from near the bottom
			var bottom_margin = 80; //how far from the very bottom
			var panel_y = room_height - bottom_margin - panel_h;
			var panel_x = room_width / 2 - panel_w / 2;//center the "box"
			
			//draw the 9 slice panel
			draw_sprite_stretched(sBasicGUI, 0, panel_x, panel_y, panel_w, panel_h);
			
			
			//content area insets
			var content_left = panel_x + tile_size + inner_side_pad;
			var content_top = panel_y + tile_size + inner_vert_pad;
			
			//draw menu options top to bottom inside the panel
			for (var i = 0; i < num_opts; i++) {
				var _color = (i == cursor_index) ? c_yellow : c_white;
				
				//start from content_top + row offset
				var _y = content_top + (i * row_height);
				draw_text_color(content_left, _y, menu_options[i], _color, _color, _color, _color, 1);
				
				//blinking cursor
				if (i == cursor_index) {
					var _blink_on = (blink_timer mod 40) < 20;
					var _cursor_spr = _blink_on ? sCursor : sBlink;
					//position: text_left_x - pixels
					var cursor_x = content_left - 12;
					var cursor_y = _y;//same y as text
					
					draw_sprite(_cursor_spr, 0, cursor_x, cursor_y);
				}
			}
			break;
				
}