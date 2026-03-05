/// @description Manage of sprite state

image_index = 2*button_type + selected

switch (get_battle_state()){
	case BATTLE_STATE.PLAYER_BUTTONS: case BATTLE_STATE.PLAYER_DIALOG_RESULT: case BATTLE_STATE.ENEMY_DIALOG: case BATTLE_STATE.ENEMY_ATTACK:
		selected = false
	break
}