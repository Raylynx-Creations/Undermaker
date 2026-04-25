/// @description Collision, interaction and layer handling

//Calculate relative movement to where you want the player to move to in absolute co
var _move_x = (is_undefined(move_to_x) ? 0 : move_to_x - x)
var _move_y = (is_undefined(move_to_y) ? 0 : move_to_y - y)

//Replace relative movement with absolute movement if it exists
if (_move_x != 0 or _move_y != 0){
	move_x = _move_x
	move_y = _move_y
}

//Update of the previous positions of the player before updating the actual position
x_previous = x
y_previous = y

//Apply movement when the player is moving
if (move_x != 0 or move_y != 0){
	var _finish = false //Flag to finish early in case of loop in movement
	var _is_x_longer = (abs(move_x) >= abs(move_y)) //Determinate which movement is longer
	var _longer = abs(_is_x_longer ? move_x : move_y) //Save its raw value
	var _increment = (_is_x_longer ? move_y : move_x)/_longer //Determinate the increments of the other coordiante based on the longer coordinate movement
	
	//As long as there's distance to step, it will iterate
	while (_longer > 0){
		array_push(player_previous_positions, [x, y]) //Save every position the player has been in to make sure it doesn't repeat the cycle
		
		var _step = min(1, _longer) //Step the movement by units
		_longer -= min(_step, _longer) //Reduce it by the step
		
		//Perform the step on the actual coordiantes
		if (_is_x_longer){
			x += sign(move_x)*_step
			y += _increment*_step
		}else{
			x += _increment*_step
			y += sign(move_y)*_step
		}
		
		//Check for collisions and move the player accordingly if it collides with anything
		player_update_collision()
		
		//Check if the new position is repeated
		var _length = array_length(player_previous_positions)
		for (var _j=0; _j<_length; _j++){
			var _pos = player_previous_positions[_j]
			if (_pos[0] == x and _pos[1] == y){
				_finish = true //If it is, finish the movement
				break
			}
		}
		
		//Finish early if it finished the movement early due to repetition
		if (_finish){
			break //No more stepping
		}
	}
	
	//Clear the array for other frames
	array_delete(player_previous_positions, 0, array_length(player_previous_positions))
//If not just update the collision once in case there's a moving collision
}else{
	player_update_collision()
}

//Reset movement variables
move_x = 0
move_y = 0
move_to_x = undefined
move_to_y = undefined
//x = round(x)
//y = round(y)

//If the player has control of movement, we check for any interaction validations, this is to avoid opening the menu while an interaction is happening like dialog
if (obj_game.state == GAME_STATE.PLAYER_CONTROL and state == PLAYER_STATE.MOVEMENT){
	//This is the part where the interaction check is being executed.
	var _direction = 90*(image_index div 4) //It calculates the direction the player is looking, where 0 is down, 90 is right, 180 is up and 270 is left.
	var _is_interacting = false
	
	//This executes the interaction of all obj_interaction, and if one is found, then we execute that interaction, and only that one.
	//Even if other valid interactions are in range, we don't want multiple at the same time, so we avoid more interactions.
	with (obj_interaction){
		_is_interacting = handle_interaction_action(_direction, other.movement_speed)
		
		if (_is_interacting){
			break //An interaction happened, exit early
		}
	}
	
	//If no interactions are being done with the obj_interaction objects, check with the obj_entity
	if (!_is_interacting){
		with (obj_entity){
			_is_interacting = handle_interaction_action(_direction, other.movement_speed)
		
			if (_is_interacting){
				break //Exit early if interaction
			}
		}
	}
	
	//No interactions at all and the player can open the menu and there's no dialog currently playing in the overworld? then you can open the menu
	if (!_is_interacting and can_open_menu and get_menu_button(false) and obj_game.dialog.is_finished()){
		if (obj_game.player_menu_system.open_menu()){ //If the meny opened successfully then stop the animation and play a sound
			player_anim_stop()
		
			audio_play_sound(snd_menu_selecting, 0, false)
		}
	}
}

//Player is always depth ordered by it's Y coordinate
depth = -y