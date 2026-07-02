if (global.state != GAME_STATE.BATTLE) {
	instance_destroy();
	exit;
}

blink_timer++;

//battle intro timer - shows the field before command box appears
if (global.battle_intro_timer > 0) {
	global.battle_intro_timer--;
	return;
}

for (var di = array_length(global.battle_damage_display) - 1; di >= 0; di--) {
	global.battle_damage_display[di].timer--;
	if (global.battle_damage_display[di].timer <= 0) {
		array_delete(global.battle_damage_display, di, 1);
	}
}

switch (global.battle_phase) {
	
	case BATTLE_PHASE.SELECT_COMMAND:
		scrBattleCommandPhase();
		break;
		
	case BATTLE_PHASE.EXECUTE_TURN:
		scrBattleExecutePhase();
		break;
		
	case BATTLE_PHASE.WIN_LOSS:
		scrBattleWinLoss();
		break;
		
	case BATTLE_PHASE.RESULTS:
		scrBattleResultsPhase();
		break;
}