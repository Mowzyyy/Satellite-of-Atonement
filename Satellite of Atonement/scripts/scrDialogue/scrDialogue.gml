//being a dialogue. _text is the full string; _portrait is a sprite index or -1/undefined
function scrStartDialogue(_text, _portrait) {
	draw_set_font(ftDefault);
	global.dlg_portrait				=	(_portrait == undefined) ? -1 : _portrait;
	global.dlg_pages					=	scrWrapDialogue(_text, 30, 2);
	global.dlg_page						=	0;
	global.dlg_words_shown	=	0;
	global.dlg_word_timer		=	0;
	global.dlg_active					=	true;
	global.dlg_return_state		=	global.state;
	global.state								=	GAME_STATE.DIALOGUE;
}
//word-wraps text into pages of _rows lines, each at most _cols chars
function scrWrapDialogue(_text, _cols, _rows) {
	var words = string_split(_text, " ");
	var pages = [];
	var cur_lines = [];
	var cur_line = "";
	
	var _safe_cols = _cols - 2;
	
	for (var i = 0; i < array_length(words); i++) {
		var w = words[i];
		var test = (cur_line == "") ? w : cur_line + " " + w;
		
		if (string_length(test) <= _safe_cols) {
			cur_line = test;
		} else {
			array_push(cur_lines, cur_line);
			cur_line = w;
			if (array_length(cur_lines) >= _rows) {
				array_push(pages, scrJoinLines(cur_lines));
				cur_lines = [];
			}
		}
	}
	if (cur_line != "") array_push(cur_lines, cur_line);
	if (array_length(cur_lines) > 0) array_push(pages, scrJoinLines(cur_lines));
	return pages;
}

function scrJoinLines(_lines) {
	var s = "";
	for (var i = 0; i < array_length(_lines); i++) {
		s += (i == 0) ? _lines[i] : "\n" + _lines[i];
	}
	return s;
}

//per-frame dialogue logic - called from oGameController Step in DIALOGUE
function scrDialogueLogic() {
	if (!global.dlg_active) return;
	
	var page_txt = global.dlg_pages[global.dlg_page];
	var total_words = array_length(string_split(string_replace_all(page_txt, "\n", " "), " "));
	if (global.dlg_words_shown < total_words) {
		global.dlg_word_timer++;
		global.dlg_word_fade = clamp(global.dlg_word_timer / global.dlg_word_speed, 0, 1);
		if (global.dlg_word_timer >= global.dlg_word_speed) {
			global.dlg_words_shown++;
			global.dlg_word_timer = 0;
			global.dlg_word_fade = 0;
		}
	}
	
	if (global.keyC) {
		if (global.dlg_words_shown < total_words) {
			global.dlg_words_shown = total_words;//snap full page visible
			global.dlg_word_fade = 1;
		} else if (global.dlg_page < array_length(global.dlg_pages) - 1) {
			global.dlg_page++;//next page
			global.dlg_words_shown = 0;
			global.dlg_word_timer = 0;
			global.dlg_word_fade = 0;
		} else {
			global.dlg_active = false//end
			global.state = global.dlg_return_state;
		}
		io_clear();
		global.keyC = false;
	}
}

function scrGetPortraitForObject(_obj) {
	if (_obj == oLeon) return sChatPortLeon;
	if (_obj == oCoat) return sChatPortCoat;
	if (_obj == oOsei) return sChatPortOsei;
	if (_obj == oAnna) return sChatPortAnna;
	if (_obj == oData) return sChatPortData;
	return sChatPortDefault;
}