// Inherit the parent event
event_inherited();

event_inherited();

sprite[directions.right] = sOseiRight;
sprite[directions.left] = sOseiLeft;
sprite[directions.up] = sOseiUp;
sprite[directions.down] = sOseiDown;
sprite_standing = sOseiStanding;
sprite_index = sprite_standing;
image_index = directions.down;
last_dir = directions.down;

sprite_combat = sOseiCombat;

depth = -myRank * 10;