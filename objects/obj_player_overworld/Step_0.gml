/// @description Player movement

switch (obj_game.state){
	case GAME_STATE.BATTLE_START_ANIMATION:{
		player_anim_stop() //Player stops moving when a battle is about to happen.
	break}
	case GAME_STATE.ROOM_CHANGE:{
		if (obj_game.anim_timer == 1){
			player_anim_stop()
		}
	break}
	case GAME_STATE.PLAYER_CONTROL:{
		//Add more enums in the scr_constants and manage their logic here for more functionality of the player, like specific movement behavior or animations.
		switch (state){
			case PLAYER_STATE.NONE:{
				//This is so other entities can manipulate it without interference, there's nothing here, in case you want something to happen when this state is on, declare the function that is being called here and put it inside it.
				//You could place all instance dependencies here, so the player can store some info and give feedback to the other instances that may be manipulating it, if not, it is recomendable to remove this case.
				if (!is_undefined(state_none_function)){
					state_none_function()
				}
			break}
			case PLAYER_STATE.STILL:{ //Player is unable to move but the animation is being reset, it's different from the NONE state for that reason, make sure whatever put the player in the STILL state has a way to make it go back to MOVEMENT or you'll softlock yourself here.
				player_anim_stop()
			break}
			case PLAYER_STATE.MOVEMENT:{
				player_movement_update()
			break}
		}
	break}
}