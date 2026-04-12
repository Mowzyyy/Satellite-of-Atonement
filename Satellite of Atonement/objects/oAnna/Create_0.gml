event_inherited();

sprite[directions.right] = sAnnaRight;
sprite[directions.left] = sAnnaLeft;
sprite[directions.up] = sAnnaUp;
sprite[directions.down] = sAnnaDown;
sprite_standing = sAnnaStanding;
sprite_index = sprite_standing;
image_index = directions.down;
last_dir = directions.down;

sprite_combat = sAnnaCombat;

depth = -myRank * 10;