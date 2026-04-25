function soul_update_collision(){
	var _colliding_instances = []
	var _instance_directions = []
	var _collision_amount = 0
	var _current_x = x
	var _current_y = y
	var _has_checked = false
	var _a_valid_direction_found = false
	
	var _loop_count = 0
	do{
		_loop_count++
		
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
		
		var _lines = obj_game.battle_system.battle_box_line_collisions
		var _length = array_length(_lines)
		if (_length > 0){
			for (var _i = 0; _i < _length; _i++){
				var _line = _lines[_i]
				_collision_amount = general_line_collision_handler(id, _line[0], _line[1], _line[2], _line[3], _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
			}
		}else{
			var _data = [[], [], [], []]
			
			with (obj_battle_box){
				if (depth != other.box_depth){
					continue
				}
				
				var _type = ((type == BATTLE_BOX_TYPE.MERGE) ? 1 : ((type == BATTLE_BOX_TYPE.HOLE) ? 2 : 0))
				if (_type == 2){
					array_push(_data[0], box_polygon_points.outside)
					array_push(_data[1], box_polygon_points.inside)
				}else{
					array_push(_data[0], box_polygon_points.inside)
					array_push(_data[1], box_polygon_points.outside)
				}
				array_push(_data[2], _type)
				array_push(_data[3], _type)
			}
			
			//show_debug_message("INPUT")
			//show_debug_message(_data[0])
			var _temp_result_inside = multi_polygon_operations_by_greiner_hormann(_data[0], _data[2])
			var _temp_result_outside = multi_polygon_operations_by_greiner_hormann(_data[1], _data[3])
			
			var _result_inside = array_concat(_temp_result_inside[0], _temp_result_outside[1]) //_temp_result_outside[1])
			var _result_outside = array_concat(_temp_result_outside[0], _temp_result_inside[1])
			//var _result_outside = []
			
			obj_game.battle_system.result_inside = _result_inside
			obj_game.battle_system.result_outside = _result_outside
			
			//show_debug_message("OUTPUT")
			//show_debug_message(_result_inside)
			//show_debug_message("------------")
			
			var _line_id = 0
			_length = array_length(_result_inside)
			for (var _i = 0; _i < _length; _i++){
				var _polygon = _result_inside[_i]
				var _points_length = array_length(_polygon)
				
				if (_points_length >= 6){
					_polygon = ensure_winding(_polygon, true)
				}
				
				for (var _j = 0; _j < _points_length; _j += 2){
					var _p1_x = _polygon[_j]
					var _p1_y = _polygon[_j + 1]
					var _p2_x = _polygon[(_j + 2)%_points_length]
					var _p2_y = _polygon[(_j + 3)%_points_length]
				
					var _direction = point_direction(_p1_x, _p1_y, _p2_x, _p2_y)
				
					var _normal_angle = _direction + 90
					var _horizontal_axis = ((dcos(_normal_angle) >= 0) ? sprite_left_collision_offset : sprite_right_collision_offset)
					var _vertical_axis = ((dsin(_normal_angle) >= 0) ? sprite_bottom_collision_offset : sprite_top_collision_offset)
					var _offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_normal_angle), 2) + power(_horizontal_axis*dsin(_normal_angle), 2))
				
					var _p1_i_x = _p1_x + _offset*dcos(_normal_angle)
					var _p1_i_y = _p1_y - _offset*dsin(_normal_angle)
					var _p2_i_x = _p2_x + _offset*dcos(_normal_angle)
					var _p2_i_y = _p2_y - _offset*dsin(_normal_angle)
				
					if (_points_length >= 6){
						var _next_direction = point_direction(_p2_x, _p2_y, _polygon[(_j + 4)%_points_length], _polygon[(_j + 5)%_points_length])
				
						var _angle_difference = angle_difference(_next_direction, _direction)
						if (_angle_difference != 0 and abs(_angle_difference) < 180){
							if (_angle_difference < 0){
								_normal_angle = _next_direction + 90
								_offset = sprite_left_collision_offset*max(dcos(_normal_angle), 0) + sprite_bottom_collision_offset*max(dsin(_normal_angle), 0) - sprite_right_collision_offset*min(dcos(_normal_angle), 0) - sprite_top_collision_offset*min(dsin(_normal_angle), 0)
							
								var _p3_i_x = _p2_x + _offset*dcos(_normal_angle)
								var _p3_i_y = _p2_y - _offset*dsin(_normal_angle)
								
								var _line = [_p2_i_x, _p2_i_y, _p3_i_x, _p3_i_y]
								var _dir = point_direction(_p2_i_x, _p2_i_y, _p3_i_x, _p3_i_y)
								
								_collision_amount = general_line_collision_handler(id, _line, _dir, _line_id, true, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
								array_push(_lines, [_line, _dir, _line_id, true])
							}
						}
						
						var _line = [_p1_i_x, _p1_i_y, _p2_i_x, _p2_i_y]
						_collision_amount = general_line_collision_handler(id, _line, _direction, _line_id + 1, true, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
						array_push(_lines, [_line, _direction, _line_id + 1, true])
						
						_line_id += 2
					}else{
						var _p1_o_x = _result_outside[_i][_j]
						var _p1_o_y = _result_outside[_i][_j + 1]
						var _p2_o_x, _p2_o_y
				
						if (_j + 2 >= _points_length){
							_p2_o_x = _result_outside[_i][0]
							_p2_o_y = _result_outside[_i][1]
						}else{
							_p2_o_x = _result_outside[_i][_j + 2]
							_p2_o_y = _result_outside[_i][_j + 3]
						}
					
						_normal_angle = _direction - 90
						_horizontal_axis = ((dcos(_normal_angle) >= 0) ? other.sprite_left_collision_offset : other.sprite_right_collision_offset)
						_vertical_axis = ((dsin(_normal_angle) >= 0) ? other.sprite_bottom_collision_offset : other.sprite_top_collision_offset)
						_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_normal_angle), 2) + power(_horizontal_axis*dsin(_normal_angle), 2))
				
						_p1_o_x += _offset*dcos(_normal_angle)
						_p1_o_y -= _offset*dsin(_normal_angle)
						_p2_o_x += _offset*dcos(_normal_angle)
						_p2_o_y -= _offset*dsin(_normal_angle)
					
						_normal_angle = _direction + 180
						_horizontal_axis = ((dcos(_normal_angle) >= 0) ? sprite_left_collision_offset : sprite_right_collision_offset)
						_vertical_axis = ((dsin(_normal_angle) >= 0) ? sprite_bottom_collision_offset : sprite_top_collision_offset)
						_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_normal_angle), 2) + power(_horizontal_axis*dsin(_normal_angle), 2))
					
						var _p3_i_x = _p1_x + _offset*dcos(_normal_angle)
						var _p3_i_y = _p1_x - _offset*dsin(_normal_angle)
						var _p3_o_x = _result_outside[_i][_j] + _offset*dcos(_normal_angle)
						var _p3_o_y = _result_outside[_i][_j + 1] - _offset*dsin(_normal_angle)
					
						_horizontal_axis = ((dcos(_direction) >= 0) ? sprite_left_collision_offset : sprite_right_collision_offset)
						_vertical_axis = ((dsin(_direction) >= 0) ? sprite_bottom_collision_offset : sprite_top_collision_offset)
						_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_direction), 2) + power(_horizontal_axis*dsin(_direction), 2))
					
						var _p4_i_x = _p2_x + _offset*dcos(_direction)
						var _p4_i_y = _p2_y - _offset*dsin(_direction)
						var _p4_o_x = _result_outside[_i][(_j + 2)%_points_length] + _offset*dcos(_direction)
						var _p4_o_y = _result_outside[_i][(_j + 3)%_points_length] - _offset*dsin(_direction)
						
						var _line = [_p3_i_x, _p3_i_y, _p1_i_x, _p1_i_y]
						var _dir = point_direction(_p3_i_x, _p3_i_y, _p1_i_x, _p1_i_y)
						_collision_amount = general_line_collision_handler(id, _line, _dir, _line_id + 4, true, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
						array_push(_lines, [_line, _dir, true])
						
						_line = [_p3_o_x, _p3_o_y, _p1_o_x, _p1_o_y]
						_dir = point_direction(_p3_o_x, _p3_o_y, _p1_o_x, _p1_o_y)
						_collision_amount = general_line_collision_handler(id, _line, _dir, _line_id + 5, false, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
						array_push(_lines, [_line, _dir, false])
						
						_line = [_p2_i_x, _p2_i_y, _p4_i_x, _p4_i_y]
						_dir = point_direction(_p2_i_x, _p2_i_y, _p4_i_x, _p4_i_y)
						_collision_amount = general_line_collision_handler(id, _line, _dir, _line_id + 6, true, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
						array_push(_lines, [_line, _dir, true])
						
						_line = [_p2_o_x, _p2_o_y, _p4_o_x, _p4_o_y]
						_dir = point_direction(_p2_o_x, _p2_o_y, _p4_o_x, _p4_o_y)
						_collision_amount = general_line_collision_handler(id, _line, _dir, _line_id + 7, false, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
						array_push(_lines, [_line, _dir, false])
						
						_line = [_p1_i_x, _p1_i_y, _p2_i_x, _p2_i_y]
						_collision_amount = general_line_collision_handler(id, _line, _direction, _line_id + 1, true, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
						array_push(_lines, [_line, _direction, true])
						
						_line = [_p1_o_x, _p1_o_y, _p2_o_x, _p2_o_y]
						_collision_amount = general_line_collision_handler(id, _line, _direction, _line_id + 2, false, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
						array_push(_lines, [_line, _direction, false])
						
						_line = [_p3_i_x, _p3_i_y, _p3_o_x, _p3_o_y]
						_dir = _direction + 90
						_collision_amount = general_line_collision_handler(id, _line, _dir, _line_id, false, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
						array_push(_lines, [_line, _dir, false])
						
						_line = [_p4_i_x, _p4_i_y, _p4_o_x, _p4_o_y]
						_dir = _direction + 90
						_collision_amount = general_line_collision_handler(id, _line, _dir, _line_id + 3, true, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
						array_push(_lines, [_line, _dir, true])
						
						_line_id += 8
						break
					}
				}
			}
		
			_length = array_length(_result_outside)
			for (var _i = 0; _i < _length; _i++){
				var _polygon = _result_outside[_i]
				var _points_length = array_length(_polygon)
				
				if (_points_length >= 6){
					_polygon = ensure_winding(_polygon, true)
				}
				
				for (var _j = 0; _j < _points_length; _j += 2){
					var _p1_x = _polygon[_j]
					var _p1_y = _polygon[_j + 1]
					var _p2_x, _p2_y
				
					if (_j + 2 >= _points_length){
						_p2_x = _polygon[0]
						_p2_y = _polygon[1]
					}else{
						_p2_x = _polygon[_j + 2]
						_p2_y = _polygon[_j + 3]
					}
				
					var _direction = point_direction(_p1_x, _p1_y, _p2_x, _p2_y)
				
					var _normal_angle = _direction - 90
					var _horizontal_axis = ((dcos(_normal_angle) >= 0) ? other.sprite_left_collision_offset : other.sprite_right_collision_offset)
					var _vertical_axis = ((dsin(_normal_angle) >= 0) ? other.sprite_bottom_collision_offset : other.sprite_top_collision_offset)
					var _offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_normal_angle), 2) + power(_horizontal_axis*dsin(_normal_angle), 2))
				
					var _p1_o_x = _p1_x + _offset*dcos(_normal_angle)
					var _p1_o_y = _p1_y - _offset*dsin(_normal_angle)
					var _p2_o_x = _p2_x + _offset*dcos(_normal_angle)
					var _p2_o_y = _p2_y - _offset*dsin(_normal_angle)
				
					if (_points_length >= 6){
						var _next_direction = point_direction(_p2_x, _p2_y, _polygon[(_j + 4)%_points_length], _polygon[(_j + 5)%_points_length])
				
						var _angle_difference = angle_difference(_next_direction, _direction)
						if (_angle_difference != 0 and abs(_angle_difference) < 180){
							if (_angle_difference > 0){
								_normal_angle = _next_direction - 90
								_offset = sprite_left_collision_offset*max(dcos(_normal_angle), 0) + sprite_bottom_collision_offset*max(dsin(_normal_angle), 0) - sprite_right_collision_offset*min(dcos(_normal_angle), 0) - sprite_top_collision_offset*min(dsin(_normal_angle), 0)
							
								var _p3_o_x = _p2_x + _offset*dcos(_normal_angle)
								var _p3_o_y = _p2_y - _offset*dsin(_normal_angle)
								
								var _line = [_p2_o_x, _p2_o_y, _p3_o_x, _p3_o_y]
								var _dir = point_direction(_p2_o_x, _p2_o_y, _p3_o_x, _p3_o_y)
						
								_collision_amount = general_line_collision_handler(id, _line, _dir, _line_id, false, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
								array_push(_lines, [_line, _dir, _line_id, false])
							}
						}
						
						var _line = [_p1_o_x, _p1_o_y, _p2_o_x, _p2_o_y]
						_collision_amount = general_line_collision_handler(id, _line, _direction, _line_id + 1, false, _colliding_instances, _instance_directions, _collision_amount, obj_battle_box.player_collision_function)
						array_push(_lines, [_line, _direction, _line_id + 1, false])
						
						_line_id += 2
					}
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
					
					var _loop_count_2 = 0
					do{
						_loop_count_2++
						
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
				
						_offset_x += dcos(_direction)/4
						_offset_y -= dsin(_direction)/4
						
						_data = _colliding_instances[_i]
						
						if (_loop_count_2 >= 50){
							break
						}
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
		
		if (_loop_count >= 50){
			break
		}
	}until (_collision_amount == 0)
}
