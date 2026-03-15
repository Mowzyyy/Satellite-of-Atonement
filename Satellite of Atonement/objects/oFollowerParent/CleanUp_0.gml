//Check if the list exists before destroying them

if  (ds_exists(pos_x, ds_type_list)) {
	ds_list_destroy(pos_x);
}

if (ds_exists(pos_y, ds_type_list)) {
	ds_list_destroy(pos_y);
}

if (ds_exists(pos_dir, ds_type_list)) {
	ds_list_destroy(pos_dir);
}
