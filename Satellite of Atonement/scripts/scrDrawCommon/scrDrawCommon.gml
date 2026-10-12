//============================ Shared Draw Primitives ============================
//every screen resets to this baseline before drawing, so sections are order-independent
function scrDrawResetState() {
	draw_set_font(ftDefault);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

//the six PSIII style cards + line metrics
function scrDrawCardLayout() {
	var _cw = global.card_w;
	return {
		tl: global.card_positions[0], tm: global.card_positions[1], tr: global.card_positions[2],
		bl: global.card_positions[3], bm: global.card_positions[4], br: global.card_positions[5],
		lh: 14, lpad: 6, rpad: _cw -6
	};
}

//battle card row + enemy row geometry, shared by field, cards, and command UI
function scrDrawBattleLayout() {
	var _card_w = 80;
	var _card_h = 48;
	var _card_gap = 0;
	var _total = (4 * _card_w) + (3 * _card_gap);
	var _num_e = array_length(global.battle_enemies);
	var _espace = 64;
	return {
		card_w: _card_w, card_h: _card_h, card_gap: _card_gap,
		card_start_x: floor((320 - _total) / 2),
		card_y: 240 - _card_h,
		enemy_spacing: _espace,
		enemy_start_x: 160 - (_num_e - 1) * _espace / 2,
		enemy_y: 120,
		card_order: [2, 1, 0, 3]
	};
}

//blink cursor
function scrDrawBlinkCursor(_x, _y) {
	draw_sprite(((blink_timer mod 40) < 20) ? sCursor : sBlink, 0, _x, _y);
}

//chat/full portrait lookup
function scrGetPortraitFor(_party_obj, _full = false) {
	if (_full) {
		if (_party_obj == oLeon) return sPortraitLeon;
		if (_party_obj == oCoat) return sPortraitCoat;
		if (_party_obj == oOsei) return sPortraitOsei;
		if (_party_obj == oAnna) return sPortraitAnna;
		if (_party_obj == oData) return sPortraitData;
		return sPortraitDefault;
		
	}
		if (_party_obj == oLeon) return sChatPortLeon;
		if (_party_obj == oCoat) return sChatPortCoat;
		if (_party_obj == oOsei) return sChatPortOsei;
		if (_party_obj == oAnna) return sChatPortAnna;
		if (_party_obj == oData) return sChatPortData;
		return sChatPortDefault;
}

//9-slice list panel used by every popup
function scrDrawListPanel(_x, _y, _w, _h) {
	draw_sprite_stretched(sBasicGUI, 0, _x, _y, _w, _h);
}