if (global.state != GAME_STATE.BATTLE) {
	instance_destroy();
	exit;
}

blink_timer++;

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
}

if (global.battle_action_delay > 0) return;//pause all battle logic during the delay