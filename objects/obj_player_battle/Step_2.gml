/// @description Soul collision for box and platforms

var _move_x = (is_undefined(move_to_x) ? 0 : move_to_x - x)
var _move_y = (is_undefined(move_to_y) ? 0 : move_to_y - y)

if (_move_x != 0 or _move_y != 0){
	move_x = _move_x
	move_y = _move_y
}

if (mode == SOUL_MODE.NORMAL){
	conveyor_push.x = 0
	conveyor_push.y = 0
}

if (get_battle_state() == BATTLE_STATE.ENEMY_ATTACK or get_battle_state() == BATTLE_STATE.END_DODGE_ATTACK){
	if (move_x != 0 or move_y != 0){
		var _finish = false
		var _is_x_longer = (abs(move_x) >= abs(move_y))
		var _longer = abs(_is_x_longer ? move_x : move_y)
		var _increment = (_is_x_longer ? move_y : move_x)/_longer
		
		while (_longer > 0){
			array_push(soul_previous_positions, [x, y])
		
			var _step = min(1, _longer)
			_longer -= min(_step, _longer)
			
			if (_is_x_longer){
				x += sign(move_x)*_step
				y += _increment*_step
			}else{
				x += _increment*_step
				y += sign(move_y)*_step
			}
		
			soul_update_collision()
		
			var _length = array_length(soul_previous_positions)
			for (var _j=0; _j<_length; _j++){
				var _pos = soul_previous_positions[_j]
				if (_pos[0] == x and _pos[1] == y){
					_finish = true
					break
				}
			}
		
			if (_finish){
				break
			}
		}
	
		array_delete(soul_previous_positions, 0, array_length(soul_previous_positions))
	}else{
		soul_update_collision()
	}
}

move_x = 0
move_y = 0
move_to_x = undefined
move_to_y = undefined
//x = round(x)
//y = round(y)