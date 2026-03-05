//Keyboard controls handler, if you don't understand it, I recommend not to touch it, don't even look at it... well ok you can in an attempt to understand, my bad, sorry...
input_system.step()

//Little system that sets the equipped atk, equipped def and invulnerability frames.
if (global.player.prev_weapon != global.player.weapon or global.player.prev_armor != global.player.armor){
	global.player.prev_weapon = global.player.weapon
	global.player.prev_armor = global.player.armor
	
	global.player.equipped_atk = 0
	global.player.equipped_def = 0
	global.player.invulnerability_frames = PLAYER_BASE_INVULNERABILITY_FRAMES
	
	var _weapon = global.item_pool[global.player.weapon]

	global.player.equipped_atk += ((is_undefined(_weapon[$"atk"])) ? 0 : _weapon[$"atk"])
	global.player.equipped_def += ((is_undefined(_weapon[$"def"])) ? 0 : _weapon[$"def"])
	global.player.invulnerability_frames += ((is_undefined(_weapon[$"inv_frames"])) ? 0 : _weapon[$"inv_frames"])
	
	var _armor = global.item_pool[global.player.armor]
	
	global.player.equipped_atk += ((is_undefined(_armor[$"atk"])) ? 0 : _armor[$"atk"])
	global.player.equipped_def += ((is_undefined(_armor[$"def"])) ? 0 : _armor[$"def"])
	global.player.invulnerability_frames += ((is_undefined(_armor[$"inv_frames"])) ? 0 : _armor[$"inv_frames"])
}

if (global.player.hp <= 0 and state != GAME_STATE.GAME_OVER or keyboard_check_pressed(ord("K"))){
	trigger_game_over()
}

player_menu_system.step()

switch (state){
	case GAME_STATE.GAME_OVER: {
		game_over_system.step()
	break}
	case GAME_STATE.BATTLE: { //You're already in the battle room when in this state, if not then errors may happen.
		battle_system.step()
	break}
	case GAME_STATE.BATTLE_START_ANIMATION:{
		if (anim_timer == 0 and battle_pause_music){
			overworld_music_system.pause_music()
		}
		
		//Depending on the animation the animation timer may go faster or start early, either way, it stops counting at 100.
		switch (battle_start_animation_type){
			case BATTLE_START_ANIMATION.NORMAL: case BATTLE_START_ANIMATION.NO_WARNING:{
				anim_timer++
			break}
			default:{ //BATTLE_START_ANIMATION.FAST or BATTLE_START_ANIMATION.NO_WARNING_FAST.
				anim_timer += 2
			break}
		}
		
		switch (anim_timer){
			case 0: case 8: case 16:{
				audio_play_sound(snd_switch_flip, 100, false)
			break}
			case 24:{
				audio_play_sound(snd_battle_start, 100, false)
			break}
			case 48:{
				state = GAME_STATE.BATTLE
				obj_player_overworld.image_alpha = 0
				
				if (room != rm_battle){
					player_prev_room = room
				}
				
				room_persistent = true
				
				room_goto(rm_battle)
			break}
		}
	break}
	case GAME_STATE.PLAYER_CONTROL:{
		random_encounter_system.step()
	} //No break
	case GAME_STATE.PLAYER_MENU_CONTROL:{
		//Nothing
	break}
	case GAME_STATE.ROOM_CHANGE:{
		room_transition_system.step()
	break}
	case GAME_STATE.BATTLE_END:{
		anim_timer++
		
		var _is_undefined = is_undefined(event_end_condition)
		if (anim_timer == 20){
			if (_is_undefined){
				state = GAME_STATE.PLAYER_CONTROL
				
				break
			}else{
				state = GAME_STATE.EVENT
			}
		}
		
		if (_is_undefined){
			break
		}
	}
	case GAME_STATE.EVENT:{
		if (!is_undefined(event_update)){
			event_update()
		}
		
		if (event_end_condition()){
			if (state == GAME_STATE.EVENT){
				state = GAME_STATE.PLAYER_CONTROL
			}
			
			event_update = undefined
			event_end_condition = undefined
		}
	break}
	case GAME_STATE.DIALOG_PLUS_CHOICE:{
		var _prev_selection = selection
		
		if (!is_undefined(event_update)){
			event_update()
		}
		
		for (var _i = 0; _i < 4; _i++){
			if (!is_undefined(plus_options[_i])){
				plus_options[_i][4].step()
			}
		}
		
		if (get_confirm_button(false) and selection >= 0){
			//Unless the function passed in the option variables set it otherwise, upon finishing a selection, the player regains control, a little fail safe in case you forget to place the event.
			state = GAME_STATE.PLAYER_CONTROL
			
			plus_options[selection][3]()
			
			for (var _i = 0; _i < 4; _i++){
				if (_i >= 0 and !is_undefined(plus_options[_i])){
					plus_options[_i][3] = undefined
					delete plus_options[_i][4]
					
					plus_options[_i] = undefined
				}
			}
		}else if (get_left_button(false) and selection != 0 and !is_undefined(plus_options[0])){
			selection = 0
		}else if (get_down_button(false) and selection != 1 and !is_undefined(plus_options[1])){
			selection = 1
		}else if (get_right_button(false) and selection != 2 and !is_undefined(plus_options[2])){
			selection = 2
		}else if (get_up_button(false) and selection != 3 and !is_undefined(plus_options[3])){
			selection = 3
		}
		
		if (_prev_selection != selection and (_prev_selection < 0 or !is_undefined(plus_options[_prev_selection])) and !is_undefined(plus_options[selection])){
			audio_play_sound(snd_menu_selecting, 0, false)
			
			if (_prev_selection >= 0){
				plus_options[_prev_selection][4].set_dialogues("[skip:false][progress_mode:none][asterisk:false]" + plus_options[_prev_selection][2])
			}
			
			plus_options[selection][4].set_dialogues("[skip:false][progress_mode:none][asterisk:false][color_rgb:255,255,0]" + plus_options[selection][2])
		}
	break}
	case GAME_STATE.DIALOG_GRID_CHOICE:{
		var _prev_selection = selection
		
		if (!is_undefined(event_update)){
			event_update()
		}
		
		var _length = array_length(grid_options)
		
		for (var _i = 0; _i < _length; _i++){
			grid_options[_i][4].step()
		}
		
		if (get_confirm_button(false)){
			//Unless the function passed in the option variables set it otherwise, upon finishing a selection, the player regains control, a little fail safe in case you forget to place the event.
			state = GAME_STATE.PLAYER_CONTROL
			
			grid_options[selection][3]()
			
			if (_length > 0){
				array_delete(grid_options, 0, _length)
			}
		}else if (get_left_button(false) or get_right_button(false)){
			audio_play_sound(snd_menu_selecting, 0, false)
			
			if (selection%2 == 0 and selection + 1 < _length){
				selection++
			}else if (selection >= 1){
				selection--
			}
		}else if (get_down_button(false)){
			audio_play_sound(snd_menu_selecting, 0, false)
			
			selection += 2
			if (selection >= _length){
				selection %= 2
			}
		}else if (get_up_button(false)){
			audio_play_sound(snd_menu_selecting, 0, false)
			
			selection -= 2
			if (selection < 0){
				selection = _length - 1 + selection%2
			}
		}
		
		if (_prev_selection != selection and (_prev_selection < 0 or !is_undefined(grid_options[_prev_selection])) and !is_undefined(grid_options[selection])){
			if (_prev_selection >= 0){
				grid_options[_prev_selection][4].set_dialogues("[skip:false][progress_mode:none][asterisk:false]" + grid_options[_prev_selection][2])
			}
			
			grid_options[selection][4].set_dialogues("[skip:false][progress_mode:none][asterisk:false][color_rgb:255,255,0]" + grid_options[selection][2])
		}
	break}
}

//Fullscreen toggle
if (keyboard_check_pressed(vk_f4)){
	set_fullscreen(!window_get_fullscreen())
}

//Border toggle - TEMP
if (keyboard_check_pressed(ord("G"))){
	toggle_border(!global.game_settings.border_active)
}

dialog.step()