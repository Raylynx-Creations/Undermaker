function soul_update_collision(){
	var _colliding_instances = []
	var _instance_directions = []
	var _collision_amount = 0
	var _current_x = x
	var _current_y = y
	var _has_checked = false
	var _a_valid_direction_found = false
	
	do{
		with (obj_battle_platform){
			var _direction = image_angle - other.image_angle
			var _horizontal_axis = ((dsin(_direction) >= 0) ? other.sprite_right_collision_offset : other.sprite_left_collision_offset)
			var _vertical_axis = ((dcos(_direction) >= 0) ? other.sprite_bottom_collision_offset : other.sprite_top_collision_offset)
			var _offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_direction), 2) + power(_horizontal_axis*dsin(_direction), 2))
			
			var _platform_p1_x = x - length/2*dcos(image_angle) - _offset*dsin(image_angle)
			var _platform_p1_y = y + length/2*dsin(image_angle) - _offset*dcos(image_angle)
			var _platform_p2_x = x + length/2*dcos(image_angle) - _offset*dsin(image_angle)
			var _platform_p2_y = y - length/2*dsin(image_angle) - _offset*dcos(image_angle)
			
			_collision_amount = general_line_collision_handler(other, [_platform_p1_x, _platform_p1_y, _platform_p2_x, _platform_p2_y], image_angle, 0, true, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
			
			var _p1_x = _platform_p1_x - dsin(image_angle)
			var _p1_y = _platform_p1_y - dcos(image_angle)
			var _p2_x = _platform_p2_x - dsin(image_angle)
			var _p2_y = _platform_p2_y - dcos(image_angle)
			
			_collision_amount = general_line_collision_handler(other, [_p1_x, _p1_y, _p2_x, _p2_y], image_angle, 1, true, _colliding_instances, _instance_directions, _collision_amount, effect_collision_function)
			
			if (type == PLATFORM_TYPE.STICKY and is_player_on){
				_direction += 180
				_horizontal_axis = ((dsin(_direction) >= 0) ? other.sprite_right_collision_offset : other.sprite_left_collision_offset)
				_vertical_axis = ((dcos(_direction) >= 0) ? other.sprite_bottom_collision_offset : other.sprite_top_collision_offset)
				_offset += _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_direction), 2) + power(_horizontal_axis*dsin(_direction), 2))
				
				var _push_direction = image_angle + 90
				var _tan_x = clamp((dcos(_push_direction) >= 0) ? abs(dtan(_push_direction + 90)) : -abs(dtan(_push_direction + 90)), -1, 1)
				var _tan_y = clamp((dsin(_push_direction) >= 0) ? -abs(dtan(_push_direction)) : abs(dtan(_push_direction)), -1, 1)
				_p1_x += (_offset + 1)*_tan_x
				_p1_y += (_offset + 1)*_tan_y
				_p2_x += (_offset + 1)*_tan_x
				_p2_y += (_offset + 1)*_tan_y
				
				_collision_amount = general_line_collision_handler(other, [_p1_x, _p1_y, _p2_x, _p2_y], image_angle + 180, 2, true, _colliding_instances, _instance_directions, _collision_amount, player_sticky_platform_collision_function)
				
				var _func = function(){
					is_player_on = false
					other.sticky_animation.timer = 0
					
					return [false, 0]
				}
				
				_direction -= 90
				_horizontal_axis = ((dsin(_direction) >= 0) ? other.sprite_right_collision_offset : other.sprite_left_collision_offset)
				_vertical_axis = ((dcos(_direction) >= 0) ? other.sprite_bottom_collision_offset : other.sprite_top_collision_offset)
				_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_direction), 2) + power(_horizontal_axis*dsin(_direction), 2))
				
				_direction += 180
				_horizontal_axis = ((dsin(_direction) >= 0) ? other.sprite_right_collision_offset : other.sprite_left_collision_offset)
				_vertical_axis = ((dcos(_direction) >= 0) ? other.sprite_bottom_collision_offset : other.sprite_top_collision_offset)
				_offset += _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_direction), 2) + power(_horizontal_axis*dsin(_direction), 2))
				
				_platform_p1_x -= _offset*dcos(image_angle)
				_platform_p1_y += _offset*dsin(image_angle)
				_p1_x -= _offset*dcos(image_angle)
				_p1_y += _offset*dsin(image_angle)
				
				_platform_p2_x += _offset*dcos(image_angle)
				_platform_p2_y -= _offset*dsin(image_angle)
				_p2_x += _offset*dcos(image_angle)
				_p2_y -= _offset*dsin(image_angle)
				
				_collision_amount = general_line_collision_handler(other, [_platform_p1_x, _platform_p1_y, _p1_x, _p1_y], image_angle - 90, 3, true, _colliding_instances, _instance_directions, _collision_amount, _func)
				_collision_amount = general_line_collision_handler(other, [_platform_p2_x, _platform_p2_y, _p2_x, _p2_y], image_angle + 90, 4, true, _colliding_instances, _instance_directions, _collision_amount, _func)
			}
		}
		
		with (obj_battle_box){
			var _inside_points = box_polygon_points.inside
			var _outside_points = box_polygon_points.outside
			var _direction_points = box_polygon_points.direction
			var _length = array_length(box_polygon_points.inside)
			
			for (var _i=0; _i<_length; _i+=2){
				var _start_id = 3*(_i div 2)
				var _id_x, _id_y
				
				if (_i + 2 >= _length){
					_id_x = 0
					_id_y = 1
				}else{
					_id_x = _i + 2
					_id_y = _i + 3
				}
				
				var _direction = _direction_points[_i div 2]
				
				var _normal_angle = _direction + 90
				var _horizontal_axis = ((dcos(_normal_angle) >= 0) ? other.sprite_left_collision_offset : other.sprite_right_collision_offset)
				var _vertical_axis = ((dsin(_normal_angle) >= 0) ? other.sprite_bottom_collision_offset : other.sprite_top_collision_offset)
				var _offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_normal_angle), 2) + power(_horizontal_axis*dsin(_normal_angle), 2))
				
				var _p1_i_x = _inside_points[_i] + _offset*dcos(_normal_angle)
				var _p1_i_y = _inside_points[_i+1] - _offset*dsin(_normal_angle)
				var _p2_i_x = _inside_points[_id_x] + _offset*dcos(_normal_angle)
				var _p2_i_y = _inside_points[_id_y] - _offset*dsin(_normal_angle)
				
				_normal_angle = _direction - 90
				_horizontal_axis = ((dcos(_normal_angle) >= 0) ? other.sprite_left_collision_offset : other.sprite_right_collision_offset)
				_vertical_axis = ((dsin(_normal_angle) >= 0) ? other.sprite_bottom_collision_offset : other.sprite_top_collision_offset)
				_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_normal_angle), 2) + power(_horizontal_axis*dsin(_normal_angle), 2))
				
				var _p1_o_x = _outside_points[_i] + _offset*dcos(_normal_angle)
				var _p1_o_y = _outside_points[_i+1] - _offset*dsin(_normal_angle)
				var _p2_o_x = _outside_points[_id_x] + _offset*dcos(_normal_angle)
				var _p2_o_y = _outside_points[_id_y] - _offset*dsin(_normal_angle)
				
				if (_length >= 6){
					var _next_direction = _direction_points[_id_x div 2]
				
					var _angle_difference = angle_difference(_next_direction, _direction)
					if (_angle_difference != 0 and abs(_angle_difference) < 180){
						if (_angle_difference < 0){
							_normal_angle = _next_direction + 90
							_offset = other.sprite_left_collision_offset*max(dcos(_normal_angle), 0) + other.sprite_bottom_collision_offset*max(dsin(_normal_angle), 0) - other.sprite_right_collision_offset*min(dcos(_normal_angle), 0) - other.sprite_top_collision_offset*min(dsin(_normal_angle), 0)
							
							var _p3_i_x = _inside_points[_id_x] + _offset*dcos(_normal_angle)
							var _p3_i_y = _inside_points[_id_y] - _offset*dsin(_normal_angle)
							
							_collision_amount = general_line_collision_handler(other, [_p2_i_x, _p2_i_y, _p3_i_x, _p3_i_y], point_direction(_p2_i_x, _p2_i_y, _p3_i_x, _p3_i_y), _start_id, true, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
						}else if (_angle_difference > 0){
							_normal_angle = _next_direction - 90
							_offset = other.sprite_left_collision_offset*max(dcos(_normal_angle), 0) + other.sprite_bottom_collision_offset*max(dsin(_normal_angle), 0) - other.sprite_right_collision_offset*min(dcos(_normal_angle), 0) - other.sprite_top_collision_offset*min(dsin(_normal_angle), 0)
							
							var _p3_o_x = _outside_points[_id_x] + _offset*dcos(_normal_angle)
							var _p3_o_y = _outside_points[_id_y] - _offset*dsin(_normal_angle)
							
							_collision_amount = general_line_collision_handler(other, [_p2_o_x, _p2_o_y, _p3_o_x, _p3_o_y], point_direction(_p2_o_x, _p2_o_y, _p3_o_x, _p3_o_y), _start_id, false, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
						}
					}
					
					_collision_amount = general_line_collision_handler(other, [_p1_i_x, _p1_i_y, _p2_i_x, _p2_i_y], _direction, _start_id + 1, true, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
					_collision_amount = general_line_collision_handler(other, [_p1_o_x, _p1_o_y, _p2_o_x, _p2_o_y], _direction, _start_id + 2, false, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
				}else{
					_normal_angle = _direction + 180
					_horizontal_axis = ((dcos(_normal_angle) >= 0) ? other.sprite_left_collision_offset : other.sprite_right_collision_offset)
					_vertical_axis = ((dsin(_normal_angle) >= 0) ? other.sprite_bottom_collision_offset : other.sprite_top_collision_offset)
					_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_normal_angle), 2) + power(_horizontal_axis*dsin(_normal_angle), 2))
					
					var _p3_i_x = _inside_points[_i] + _offset*dcos(_normal_angle)
					var _p3_i_y = _inside_points[_i+1] - _offset*dsin(_normal_angle)
					var _p3_o_x = _outside_points[_i] + _offset*dcos(_normal_angle)
					var _p3_o_y = _outside_points[_i+1] - _offset*dsin(_normal_angle)
					
					_horizontal_axis = ((dcos(_direction) >= 0) ? other.sprite_left_collision_offset : other.sprite_right_collision_offset)
					_vertical_axis = ((dsin(_direction) >= 0) ? other.sprite_bottom_collision_offset : other.sprite_top_collision_offset)
					_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_direction), 2) + power(_horizontal_axis*dsin(_direction), 2))
					
					var _p4_i_x = _inside_points[_id_x] + _offset*dcos(_direction)
					var _p4_i_y = _inside_points[_id_y] - _offset*dsin(_direction)
					var _p4_o_x = _outside_points[_id_x] + _offset*dcos(_direction)
					var _p4_o_y = _outside_points[_id_y] - _offset*dsin(_direction)
					
					_collision_amount = general_line_collision_handler(other, [_p3_i_x, _p3_i_y, _p1_i_x, _p1_i_y], point_direction(_p3_i_x, _p3_i_y, _p1_i_x, _p1_i_y), _start_id + 4, true, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
					_collision_amount = general_line_collision_handler(other, [_p3_o_x, _p3_o_y, _p1_o_x, _p1_o_y], point_direction(_p3_o_x, _p3_o_y, _p1_o_x, _p1_o_y), _start_id + 5, false, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
					_collision_amount = general_line_collision_handler(other, [_p2_i_x, _p2_i_y, _p4_i_x, _p4_i_y], point_direction(_p2_i_x, _p2_i_y, _p4_i_x, _p4_i_y), _start_id + 6, true, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
					_collision_amount = general_line_collision_handler(other, [_p2_o_x, _p2_o_y, _p4_o_x, _p4_o_y], point_direction(_p2_o_x, _p2_o_y, _p4_o_x, _p4_o_y), _start_id + 7, false, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
					
					_collision_amount = general_line_collision_handler(other, [_p1_i_x, _p1_i_y, _p2_i_x, _p2_i_y], _direction, _start_id + 1, true, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
					_collision_amount = general_line_collision_handler(other, [_p1_o_x, _p1_o_y, _p2_o_x, _p2_o_y], _direction, _start_id + 2, false, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
					
					_collision_amount = general_line_collision_handler(other, [_p3_i_x, _p3_i_y, _p3_o_x, _p3_o_y], _direction + 90, _start_id, false, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
					_collision_amount = general_line_collision_handler(other, [_p4_i_x, _p4_i_y, _p4_o_x, _p4_o_y], _direction + 90, _start_id + 3, true, _colliding_instances, _instance_directions, _collision_amount, player_collision_function)
					
					break
				}
			}
		}
		
		if (!_has_checked){
			_has_checked = true
		
			if (_collision_amount >= 2){
				for (var _i=0; _i < _collision_amount; _i++){
					var _valid_direction = true
					var _direction = _instance_directions[_i]
					var _offset_x = dcos(_direction)
					var _offset_y = -dsin(_direction)
					var _data
			
					do{
						for (var _j=0; _j < _collision_amount; _j++){
							if (_i == _j){
								continue
							}
					
							_data = _colliding_instances[_j]
							if ((typeof(_data) == "ref" and !place_meeting(_current_x + _offset_x, _current_y + _offset_y, _data)) or (typeof(_data) == "struct" and !collision_line(_data.points[0] - _offset_x, _data.points[1] - _offset_y, _data.points[2] - _offset_x, _data.points[3] - _offset_y, id, false, false))){
								_valid_direction = false
						
								break
							}
						}
				
						if (!_valid_direction){
							break
						}
				
						_offset_x += dcos(_direction)
						_offset_y -= dsin(_direction)
						
						_data = _colliding_instances[_i]
					}until ((typeof(_data) == "ref" and !place_meeting(_current_x + _offset_x, _current_y + _offset_y, _data)) or (typeof(_data) == "struct" and !collision_line(_data.points[0] - _offset_x, _data.points[1] - _offset_y, _data.points[2] - _offset_x, _data.points[3] - _offset_y, id, false, false)))
			
					if (_valid_direction){
						for (var _j=0; _j < _collision_amount; _j++){
							if (_i == _j){
								continue
							}
							
							_data = _colliding_instances[_j]
							if ((typeof(_data) == "ref" and place_meeting(_current_x + _offset_x, _current_y + _offset_y, _data)) or (typeof(_data) == "struct" and collision_line(_data.points[0] - _offset_x, _data.points[1] - _offset_y, _data.points[2] - _offset_x, _data.points[3] - _offset_y, id, false, false))){
								_valid_direction = false
						
								break
							}
						}
			
						if (_valid_direction){
							for (var _j=0; _j < _collision_amount; _j++){
								if (_i == _j){
									continue
								}
						
								_instance_directions[_j] = _direction
							}
					
							_a_valid_direction_found = true
							x = _current_x
							y = _current_y
					
							break
						}
					}
				}
			}
		}
	
		if (!_a_valid_direction_found){
			if (_current_x == x and _current_y == y){
				break
			}else{
				_current_x = x
				_current_y = y
			}
		}else{
			_a_valid_direction_found = false
		}
	}until (_collision_amount == 0)
}
