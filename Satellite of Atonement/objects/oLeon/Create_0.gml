event_inherited();

sprite[directions.right] = sLeonRight;
sprite[directions.left] = sLeonLeft;
sprite[directions.up] = sLeonUp;
sprite[directions.down] = sLeonDown;
sprite_standing = sLeonStanding;
sprite_index = sprite_standing;
image_index = directions.down;
last_dir = directions.down;

sprite_combat = sLeonCombat;

depth = -myRank * 10;