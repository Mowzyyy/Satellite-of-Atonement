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
			if (slot_selecting) {
			var box_w    = 96;
			var box_h    = 64;
			var box_gap  = 8;
			var num_slots = 3;

			//count how many slots actually exist
			var existing_slots = [];
			for (var s = 0; s < num_slots; s++) {
				 if (slot_data[s] != undefined) array_push(existing_slots, s);
			}
			var num_existing = array_length(existing_slots);

			//stack grows upward from bottom-middle of screen
			var total_w = (num_existing * box_w) + ((num_existing - 1) * box_gap);
			var row_x = room_width / 2 - total_w / 2;
			var row_y = room_height - box_h - 24;

			for (var s_idx = 0; s_idx < num_existing; s_idx++) {
				var s      = existing_slots[s_idx];
				var box_x  = row_x + s_idx * (box_w + box_gap);
				var is_sel = (slot_cursor == s_idx);

				//box background
				draw_sprite_stretched(sBasicGUI, 0, box_x, row_y, box_w, box_h);

				 //highlight selected box
				if (is_sel) {
					draw_set_alpha(0.15);
					draw_set_color(c_yellow);
					draw_rectangle(box_x, row_y, box_x + box_w, row_y + box_h, false);
					draw_set_alpha(1.0);
					draw_set_color(c_white);
				}

				//slot number at top
				draw_set_halign(fa_center);
				draw_set_color(is_sel ? c_yellow : c_white);
				draw_text(box_x + box_w / 2, row_y + 6, string(s + 1));

				var sd = slot_data[s];
				if (sd != undefined) {
					// party sprites facing left normally, forward when selected
					var spr_frame
					if (slot_confirming && s_idx == slot_cursor) {
						spr_frame = directions.down;
					} else if (is_sel && !slot_confirming) {
						spr_frame = walk_frame;
					} else {
						spr_frame = directions.left
					}
					
					var spr_start_x = box_x + 4;
					var spr_y       = row_y + 16;
					var num_members = array_length(sd.party);

					for (var p = 0; p < num_members; p++) {
						var spr_name;
						if (slot_confirming && s_idx == slot_cursor) {
							spr_name = "s" + sd.party[p].name + "Standing";
						} else if (is_sel) {
							spr_name = "s" + sd.party[p].name + "Left";
						} else {
							spr_name = "s" + sd.party[p].name + "Standing";
						}
						var spr_idx = asset_get_index(spr_name);
						
						var slot_w     = (box_w - 8) / num_members;
						var spr_draw_x = box_x - 4 + (p * slot_w) + (slot_w / 2);
						var spr_draw_y = spr_y + 8;
						if (spr_idx >= 0) {
							draw_sprite(spr_idx, spr_frame, spr_draw_x, spr_draw_y);
						} else {
							draw_set_color(c_dkgray);
							draw_rectangle(spr_draw_x, spr_y, spr_draw_x + 10, spr_y + 16, false);
							draw_set_color(c_white);
						}
					}
					
					if (slot_confirming && slot_confirm_timer >= slot_confirm_delay) {
						//dim overlay
						draw_set_alpha(0.5);
						draw_set_color(c_black);
						draw_rectangle(0, 0, room_width, room_height, false);
						draw_set_alpha(1.0);
						draw_set_color(c_white);
						
						//centered dialogue box
						var dlg_w = 120;
						var dlg_h = 32;
						var dlg_x = room_width / 2 - dlg_w / 2;
						var dlg_y = room_height / 2 - dlg_h / 2;
						draw_sprite_stretched(sBasicGUI, 0, dlg_x, dlg_y, dlg_w, dlg_h);
						
						draw_set_halign(fa_center);
						draw_text(room_width / 2, dlg_y + 10, "Game Loaded!");
						draw_text(room_width / 2, dlg_y + 22, "Press E or C");
						draw_set_halign(fa_left);
					}

					//leader name and level
					var lead     = sd.party[0];
					var name_str = lead.name + " Lv" + string(lead.level);
					draw_set_halign(fa_center);
					draw_set_color(c_white);
					draw_text(box_x + box_w / 2, row_y + box_h - 18, name_str);

					//money
					draw_text(box_x + box_w / 2, row_y + box_h - 8, "$" + string(sd.money));
				} else {
					draw_set_halign(fa_center);
					draw_set_color(c_dkgray);
					draw_text(box_x + box_w / 2, row_y + box_h / 2, "EMPTY");
					draw_set_color(c_white);
				}
			}

			draw_set_halign(fa_left);
			exit;
		}
		
			//auto-menu using sBasicGUI
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