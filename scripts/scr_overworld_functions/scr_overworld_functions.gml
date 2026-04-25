function handle_interaction_action(_direction, _movement_speed){
	var _x_offset = _movement_speed*dsin(_direction) //Calculate the offset of all obj_interaction instances.
	var _y_offset = _movement_speed*dcos(_direction)
	
	if (can_interact and !is_undefined(interaction) and place_meeting(x - _x_offset, y - _y_offset, obj_player_overworld)){
		var _is_interacting
		
		//Check for the key to interact being pressed.
		switch (interaction_key){
			case "confirm":
				_is_interacting = get_confirm_button(false)
			break
			case "cancel":
				_is_interacting = get_cancel_button(false)
			break
			case "menu":
				_is_interacting = get_menu_button(false)
			break
			default: //Checks the key you have.
				_is_interacting = keyboard_check_pressed(ord(interaction_key))
			break
		}
		
		if (_is_interacting){
			obj_player_overworld.player_anim_stop() //This resets the player animation automatically, but since it's ran before the interaction function, users can change that.
			interaction(_direction) //Trigger the interaction if the played pressed the right key to interact with.
		}
		
		return _is_interacting
	}
	
	return false
}

//DO NOT MODIFY - unless you know what you're doing
function set_battle_scene(_animation, _background, _init_function, _end_function, _heart_x, _heart_y){
	obj_game.battle_start_animation_player_heart_x = _heart_x
	obj_game.battle_start_animation_player_heart_y = _heart_y
	
	battle_init_function = _init_function
	battle_end_function = _end_function
	battle_start_animation_type = _animation
	
	battle_black_alpha = 1
	battle_background_name = _background
	
	update_border_alpha = is_border_dynamic()
	
	if (_animation == BATTLE_START_ANIMATION.NORMAL or _animation == BATTLE_START_ANIMATION.FAST){
		obj_game.anim_timer = -36
		
		audio_play_sound(snd_warning, 100, false) //Plays the warning sound
	}else{
		obj_game.anim_timer = 0
		
		audio_play_sound(snd_switch_flip, 100, false) //Plays here since it doesn't play in the main time
	}
}
