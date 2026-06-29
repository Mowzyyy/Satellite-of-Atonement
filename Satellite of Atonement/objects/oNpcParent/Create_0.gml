if (sprite_prefix == "") sprite_prefix = "sDunesGuard1";

sprite[directions.right] = asset_get_index(sprite_prefix + "Right");
sprite[directions.left] = asset_get_index(sprite_prefix + "Left");
sprite[directions.up] = asset_get_index(sprite_prefix + "Up");
sprite[directions.down] = asset_get_index(sprite_prefix + "Down");
sprite_standing = asset_get_index(sprite_prefix + "Standing");

sprite_index = sprite_standing;
image_speed = 0;
image_index = directions.down;
last_dir = directions.down;

//tile grid
x_pos = x div TILE_WIDTH;
y_pos = y div TILE_HEIGHT;
x_from = x_pos; y_from = y_pos;
x_to = x_pos; y_to = y_pos;
x = x_pos * TILE_WIDTH;
y = y_pos * TILE_HEIGHT;

state = states.idle;

//wandering config - set per instance

move_type = 0;
//0 = stationary, 1= wandering

walk_interval = 180;
//frames between walk decisions

walk_chance = 40;
//percentage

walk_duration = 30;
//frames per step

walk_pause = 60;
//frames to pause after walking

walk_progress = 0;

walk_timer = 0;

interacting = false;
interact_cooldown = 0;


depth = -y;