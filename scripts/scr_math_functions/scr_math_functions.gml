function calculate_cross_product(_ax, _ay, _bx, _by, _cx, _cy) {
    return (_bx - _ax)*(_cy - _ay) - (_by - _ay)*(_cx - _ax)
}

function is_triangle_convex(_ax, _ay, _bx, _by, _cx, _cy, _orientation) {
    var _cross_value = calculate_cross_product(_ax, _ay, _bx, _by, _cx, _cy)
    return ((_orientation == ROTATION_ORIENTATION.CLOCKWISE) ? _cross_value > 0 : _cross_value < 0)
}

function intersection_of_lines(_x1, _y1, _direction_1, _x2, _y2, _direction_2, _precission=EPSILON){
	var _angle_diff = abs(angle_difference(_direction_1, _direction_2))
	var _angle_epsilon = 100*EPSILON
	
	//show_debug_message(string_concat("diff: ", string_format(_angle_diff, 3, 10)))
	
	if (_angle_diff <= _angle_epsilon or _angle_diff >= 180 - _angle_epsilon){
		if (_angle_diff >= 180 - _angle_epsilon){
			_direction_2 += 180
		}
		_direction_1 += angle_difference(_direction_2, _direction_1)/2
		
		_angle_diff = abs(angle_difference(90, _direction_1))
		var _px, _py
		
		if (_angle_diff <= _angle_epsilon or _angle_diff >= 180 - _angle_epsilon){
			var _tan = dtan(_direction_1 - 90)
			_px = _x1 + _tan*(_y2 - _y1)
			_py = _y2
		}else{
			var _tan = -dtan(_direction_1)
			_px = _x2
			_py = _y1 + _tan*(_x2 - _x1)
		}
		
		//show_debug_message(string_concat(_px, " | ", _py, " | ", _x1, " | ", _y1, " | ", _x2, " | ", _y2, " | ", _direction_1, " | ", _direction_2, " | ", point_distance(_px, _py, _x2, _y2), " | ", _precission))
		
		if (point_distance(_px, _py, _x2, _y2) < _precission){
			return [NaN, NaN]
		}else{
			return [infinity, infinity]
		}
	}
	
	var _delta_x1 = lengthdir_x(1, _direction_1)
	var _delta_y1 = lengthdir_y(1, _direction_1)
	var _delta_x2 = lengthdir_x(1, _direction_2)
	var _delta_y2 = lengthdir_y(1, _direction_2)
	
	var _determinant = _delta_x1 * _delta_y2 - _delta_y1 * _delta_x2
	
	var _scalar_distance = ((_x2 - _x1) * _delta_y2 - (_y2 - _y1) * _delta_x2) / _determinant
	var _p_x = _x1 + _scalar_distance * _delta_x1
	var _p_y = _y1 + _scalar_distance * _delta_y1
	
	return [_p_x, _p_y]
}
