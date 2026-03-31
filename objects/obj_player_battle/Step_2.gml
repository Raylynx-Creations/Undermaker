/// @description Soul collision for box and platforms

//Calculate relative movement to where you want the player to move to in absolute coordinates
var _move_x = (is_undefined(move_to_x) ? 0 : move_to_x - x)
var _move_y = (is_undefined(move_to_y) ? 0 : move_to_y - y)

//Replace relative movement with absolute movement if it exists
if (_move_x != 0 or _move_y != 0){
	move_x = _move_x
	move_y = _move_y
}

//Red soul removes all conveyor push effect after it's applied
if (mode == SOUL_MODE.NORMAL){
	conveyor_push.x = 0
	conveyor_push.y = 0
}

//Movement only applies when dodging an attack, this is where the collision is checked by the movement
if (battle_get_state() == BATTLE_STATE.ENEMY_ATTACK or battle_get_state() == BATTLE_STATE.END_DODGE_ATTACK){
	//If there's a movement we have to check if the movement is valid and if it results in a collision, move it out of the collision by the conditions given by it
	if (move_x != 0 or move_y != 0){
		var _finish = false //Flag to finish early in case of loop in movement
		var _is_x_longer = (abs(move_x) >= abs(move_y)) //Determinate which movement is longer
		var _longer = abs(_is_x_longer ? move_x : move_y) //Save its raw value
		var _increment = (_is_x_longer ? move_y : move_x)/_longer //Determinate the increments of the other coordiante based on the longer coordinate movement
		
		//As long as there's distance to step, it will iterate
		while (_longer > 0){
			array_push(soul_previous_positions, [x, y]) //Save every position the player has been in to make sure it doesn't repeat the cycle
		
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
			soul_update_collision()
		
			//Check if the new position is repeated
			var _length = array_length(soul_previous_positions)
			for (var _j=0; _j<_length; _j++){
				var _pos = soul_previous_positions[_j]
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
		array_delete(soul_previous_positions, 0, array_length(soul_previous_positions))
	//If there's no movement being made, update the collision then, as the player can be colliding with a moving collision
	}else{
		soul_update_collision()
	}
}

//Reset movement variables
move_x = 0
move_y = 0
move_to_x = undefined
move_to_y = undefined
//x = round(x)
//y = round(y)