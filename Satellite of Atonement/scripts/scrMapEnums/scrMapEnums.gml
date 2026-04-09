enum MAP{
	DUNES,
	TEST
}

function scrMapIdToRoom(_map_id) {
	switch (_map_id) {
		case MAP.DUNES: return rmDunes;
		case MAP.TEST: return rmTest;
		//add more as needed
		default:
			show_debug_message("WARNING: scrMapIdToRoom — unknown map id " + string(_map_id));
			return rmTest;
	}
}