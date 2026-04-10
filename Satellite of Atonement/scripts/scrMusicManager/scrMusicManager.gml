//==================================Music Manager==================================
//maps each MAP enum value to a music asset
//add new entries here as maps and tracks are created

function scrGetMapMusic(_map_id) {
	switch (_map_id) {
		case MAP.DUNES: return sndLustwind;
		case MAP.TEST: return sndTitle;
		//add new as maps and tracks are added
		default: return -1;
	}
}

//play music for the given map - hard cut, always restarts, skips if the requested track is already playing
function scrPlayMapMusic(_map_id) {
	var _track = scrGetMapMusic(_map_id) {
		if (_track == -1) {
			audio_stop_all();
			global.current_music = -1;
			return;
		}
		
		//if already playing this track do nothing
		if (global.current_music == _track && audio_is_playing(_track)) return;
		
		audio_stop_all();
		audio_play_sound(_track, 10, true);
		global.current_music = _track;
		show_debug_message("Music: playing " + audio_get_name(_track) + " for map " + string(_map_id));
	}
}
	
//play a specific track directly regardless of map
//used in cutscenes, battle music, etc
function scrPlayMusic(_track) {
	if (_track == -1) {
		audio_stop_all();
		global.current_music = -1;
		return;
	}
	if (global.current_music == _track && audio_is_playing(_track)) return;
	audio_stop_all();
	audio_play_sound(_track, 10, true);
	global.current_music = _track;
}
	
function scrStopMusic() {
	audio_stop_all();
	global.current_music = -1;
}
