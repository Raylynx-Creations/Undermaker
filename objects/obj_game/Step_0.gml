///@description Control of game flow, many systems update and more

if (starting_up){
	if (!is_audio_loaded()){
		return
	}else{
		starting_up = false
		
		if (!is_undefined(game_ready)){
			game_ready()
		}
	}
}

//Keyboard controls handler, if you don't understand it, I recommend not to touch it, don't even look at it... well ok you can in an attempt to understand, my bad, sorry...
input_system.step()

//Little system that sets the equipped atk, equipped def and invulnerability frames.
if (global.player.prev_weapon != global.player.weapon or global.player.prev_armor != global.player.armor){
	//If they are different, reassign them to save their state in the previous state variables
	global.player.prev_weapon = global.player.weapon
	global.player.prev_armor = global.player.armor
	
	//Reset the data on the player as if it had no armor
	global.player.equipped_atk = 0
	global.player.equipped_def = 0
	global.player.invulnerability_frames = PLAYER_BASE_INVULNERABILITY_FRAMES
	
	//Update stats accordingly to what piece of armor and weapon has
	if (!is_undefined(global.player.weapon) and global.player.weapon >= 0){
		var _weapon = global.item_pool[global.player.weapon]

		global.player.equipped_atk += ((is_undefined(_weapon[$"atk"])) ? 0 : _weapon[$"atk"])
		global.player.equipped_def += ((is_undefined(_weapon[$"def"])) ? 0 : _weapon[$"def"])
		global.player.invulnerability_frames += ((is_undefined(_weapon[$"inv_frames"])) ? 0 : _weapon[$"inv_frames"])
	}
	
	if (!is_undefined(global.player.armor) and global.player.armor >= 0){
		var _armor = global.item_pool[global.player.armor]
	
		global.player.equipped_atk += ((is_undefined(_armor[$"atk"])) ? 0 : _armor[$"atk"])
		global.player.equipped_def += ((is_undefined(_armor[$"def"])) ? 0 : _armor[$"def"])
		global.player.invulnerability_frames += ((is_undefined(_armor[$"inv_frames"])) ? 0 : _armor[$"inv_frames"])
	}
}

//In general if the player drops to 0 HP, we trigger the Game Over, no matter when, if it reaches 0 HP, it will Game Over (except if on game menu of course)
if (global.player.hp <= 0 and state != GAME_STATE.GAME_OVER and state != GAME_STATE.MENU_CONTROL){
	trigger_game_over()
}

//Step the player menu system, even if it's not open, it must update
player_menu_system.step() //SHould not work in the menu_control state

//Depending on the state of the game, different updates happen, they can be from the system or made here only in the obj_game.
switch (state){
	case GAME_STATE.MENU_CONTROL: { //Your own menu logic, in this example I'm using a constructor to handle my menu.
		game_menu_system.step()
	break}
	case GAME_STATE.GAME_OVER: { //Game over system update
		game_over_system.step()
	break}
	case GAME_STATE.BATTLE: { //Battle system update, you're already in the battle room when in this state, most variables depend on that being true, if not then errors may happen.
		battle_system.step()
	break}
	case GAME_STATE.BATTLE_START_ANIMATION:{ //Animation of the battle starting
		if (anim_timer == 0){
			//If the border is set to be dynamic, set it to no alpha for visual effects in the transition.
			if (is_border_dynamic()){
				border_alpha = 0
			}
			
			if (battle_pause_music){
				overworld_music_system.pause_music() //If it has to pause the music, pause it.
			}
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
				audio_play_sound(snd_switch_flip, 100, false) //Sound of the player's heart flickering
			break}
			case 24:{
				audio_play_sound(snd_battle_start, 100, false) //Player's heart moving in position
			break}
			case 48:{ //Change to battle room and state
				state = GAME_STATE.BATTLE
				obj_player_overworld.image_alpha = 0
				
				if (room != rm_battle){
					player_prev_room = room //Save the room where it comes from
				}
				
				room_persistent = true
				
				border_prev_id = border_id
				
				room_goto(rm_battle)
			break}
		}
	break}
	case GAME_STATE.PLAYER_CONTROL:{ //Random encounter system update, encounters happen only when the player has control and they are set (Has no break)
		random_encounter_system.step()
	} //No break
	case GAME_STATE.PLAYER_MENU_CONTROL:{ //Nothing is here, but in case you need stuff to happen on the player menu system and player control, here you can place it, the update for the menu is already being done above.
		//Nothing
	break}
	case GAME_STATE.ROOM_CHANGE:{ //Room change system update
		room_transition_system.step()
	break}
	case GAME_STATE.BATTLE_END:{ //Transition from the battle room back to the overworld (Conditional break)
		anim_timer++ //Uses animation timer too
		
		//This is in case an event is happening after the battle is over, you trigger the events usually on the end function of the battle.
		var _is_undefined = is_undefined(event_end_condition)
		if (anim_timer == 20){
			//If there's no event happening, give control back to the player, otherwise keep the event going
			if (_is_undefined){
				state = GAME_STATE.PLAYER_CONTROL
				obj_player_overworld.state = PLAYER_STATE.MOVEMENT
				
				break
			}else{
				state = GAME_STATE.EVENT
			}
		}
		
		//If borders are dynamic, set the alpha same.
		if (is_border_dynamic()){
			border_alpha = anim_timer/20
		}
		
		//If there's an event happening, there has to be an end event condition, for like cutscenes when exiting battles, then the case doesn't stop here, it propagates to the GAME_STATE.EVENT
		if (_is_undefined){
			break
		}
	}//No break
	case GAME_STATE.EVENT:{ //System that controls events happening and returns control to the player when events are over, useful for cutscenes and other stuff you want
		if (!is_undefined(event_update)){
			event_update()
		}
		
		if (event_end_condition()){
			if (state == GAME_STATE.EVENT){
				state = GAME_STATE.PLAYER_CONTROL
				obj_player_overworld.state = PLAYER_STATE.MOVEMENT
			}
			
			event_update = undefined
			event_end_condition = undefined
		}
	break}
	case GAME_STATE.DIALOG_PLUS_CHOICE:{ //For handling the choice options, this is for the ones that are laid out like a cross, use start_plus_choice() and create_plus_choice_option() to enter these states.
		var _prev_selection = selection
		
		//There's an event update here too, in case you wanted to do like a timer for these choices and something else to happen if they didn't pick in time
		if (!is_undefined(event_update)){
			event_update()
		}
		
		for (var _i = 0; _i < 4; _i++){
			if (!is_undefined(plus_options[_i])){
				plus_options[_i][4].step() //Each of these is a dialog system, must be updated
			}
		}
		
		//Selection and confirm actions
		if (get_confirm_button(false) and selection >= 0){
			//Unless the function passed in the option variables set it otherwise, upon finishing a selection, the player regains control, a little fail safe in case you forget to place the event.
			state = GAME_STATE.PLAYER_CONTROL
			obj_player_overworld.state = PLAYER_STATE.MOVEMENT
			
			plus_options[selection][3]() //Execute the function of the selected one
			
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
		
		//Update of the color of the options selected
		if (_prev_selection != selection and (_prev_selection < 0 or !is_undefined(plus_options[_prev_selection])) and !is_undefined(plus_options[selection])){
			audio_play_sound(snd_menu_selecting, 0, false)
			
			if (_prev_selection >= 0){
				plus_options[_prev_selection][4].set_dialogues("[skip:false][progress_mode:none][asterisk:false]" + plus_options[_prev_selection][2])
			}
			
			plus_options[selection][4].set_dialogues("[skip:false][progress_mode:none][asterisk:false][color_rgb:255,255,0]" + plus_options[selection][2])
		}
	break}
	case GAME_STATE.DIALOG_GRID_CHOICE:{ //This is for the ones that are laid out in a grid, use start_grid_choice() and create_grid_choice_option() to enter these states.
		var _prev_selection = selection
		
		if (!is_undefined(event_update)){
			event_update() //Event updating like in the Plus choice
		}
		
		var _length = array_length(grid_options)
		
		for (var _i = 0; _i < _length; _i++){
			grid_options[_i][4].step() //Step every dialog system
		}
		
		//Confirming and selection of the options
		if (get_confirm_button(false)){
			//Unless the function passed in the option variables set it otherwise, upon finishing a selection, the player regains control, a little fail safe in case you forget to place the event.
			state = GAME_STATE.PLAYER_CONTROL
			obj_player_overworld.state = PLAYER_STATE.MOVEMENT
			
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
		
		//Updating their color
		if (_prev_selection != selection and (_prev_selection < 0 or !is_undefined(grid_options[_prev_selection])) and !is_undefined(grid_options[selection])){
			if (_prev_selection >= 0){
				grid_options[_prev_selection][4].set_dialogues("[skip:false][progress_mode:none][asterisk:false]" + grid_options[_prev_selection][2])
			}
			
			grid_options[selection][4].set_dialogues("[skip:false][progress_mode:none][asterisk:false][color_rgb:255,255,0]" + grid_options[selection][2])
		}
	break}
}

var _status_effect = global.player.status_effect
switch (_status_effect.type){
	case PLAYER_STATUS_EFFECT.KARMIC_RETRIBUTION:{
		if (_status_effect.value > 0){
			_status_effect.timer++
			
			if ((_status_effect.value >= 40 and _status_effect.timer >= 2) or (_status_effect.value >= 30 and _status_effect.timer >= 4) or (_status_effect.value >= 20 and _status_effect.timer >= 10) or (_status_effect.value >= 10 and _status_effect.timer >= 30) or _status_effect.timer >= 60){
				global.player.hp--
				_status_effect.value--
				_status_effect.timer = 0
			}
		}else if (_status_effect.timer > 0){
			_status_effect.timer = 0
		}
	}
}

//Fullscreen toggle, always there like in Undertale
if (keyboard_check_pressed(vk_f4)){
	set_fullscreen(!window_get_fullscreen())
	save_game_settings()
}

//Step the dialog system of the overworld
dialog.step()

if (get_escape_button() and state != GAME_STATE.MENU_CONTROL){
	quit_timer++
	
	if (quit_timer == 180){
		go_to_game_menu()
	}
}else{
	quit_timer = 0
}
