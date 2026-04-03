event_inherited();

sprite[directions.right] = sCoatRight;
sprite[directions.left] = sCoatLeft;
sprite[directions.up] = sCoatUp;
sprite[directions.down] = sCoatDown;
sprite_standing = sCoatStanding;
sprite_index = sprite_standing;
image_index = directions.down;
last_dir = directions.down;


depth = -myRank * 10;