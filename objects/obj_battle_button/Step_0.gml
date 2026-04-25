/// @description Manage of sprite state

if (!is_undefined(step)){
	step()
}

image_index = 2*button_type + selected

//States in which the button deselects (may not be completed tho)
switch (battle_get_state()){
	case BATTLE_STATE.PLAYER_BUTTONS:
	case BATTLE_STATE.PLAYER_DIALOG_RESULT:
	case BATTLE_STATE.ENEMY_DIALOG:
	case BATTLE_STATE.ENEMY_ATTACK:
	case BATTLE_STATE.TURN_END:
		selected = false
	break
}