function scrCheckGameOver(){
	var all_dead = true;
	for (var i = 0; i < array_length(global.party); i++) {
		if (!global.party[i].is_dead) { all_dead = false; break; }
	}
	if (all_dead) {
		if (instance_exists(oBattleManager)) instance_destroy(oBattleManager);
		global.state = GAME_STATE.GAME_OVER;
		audio_stop_all();
		/*Uncomment when real gameover audio exists
		if (audio_exists(sndGameOver)) audio_play_sound(sndGameOver, 10, false);
		*/
		if (audio_exists(sndStaySharp)) audio_play_sound(sndStaySharp, 10, false);
		global.game_over_timer = 0;
	}
}

function scrGameOverLogic() {
	global.game_over_timer++;
	if (global.game_over_timer > 90 && (global.keyC || global.keyB || global.keyA)) {
		global.state = GAME_STATE.MAIN_MENU;
		room_goto(rmTitle);
	}
}