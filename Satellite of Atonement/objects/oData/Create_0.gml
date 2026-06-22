event_inherited();

sprite[directions.right] = sDataRight;
sprite[directions.left] = sDataLeft;
sprite[directions.up] = sDataUp;
sprite[directions.down] = sDataDown;
sprite_standing = sDataStanding;
sprite_index = sprite_standing;
image_index = directions.down;
last_dir = directions.down;

sprite_combat = sLeonCombat;

depth = -myRank * 10;