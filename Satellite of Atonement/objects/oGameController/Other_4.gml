scrHandleArrival();
scrSpawnParty();
if (global.state != GAME_STATE.MAIN_MENU) {
	scrPlayMapMusic(global.current_map_id);
}