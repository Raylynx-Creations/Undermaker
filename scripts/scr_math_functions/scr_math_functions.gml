function calculate_cross_product(_ax, _ay, _bx, _by, _cx, _cy) {
    return (_bx - _ax)*(_cy - _ay) - (_by - _ay)*(_cx - _ax)
}

function is_triangle_convex(_ax, _ay, _bx, _by, _cx, _cy, _orientation) {
    var _cross_value = calculate_cross_product(_ax, _ay, _bx, _by, _cx, _cy)
    return ((_orientation > 0) ? _cross_value > 0 : _cross_value < 0)
}

function intersection_of_lines(_x1, _y1, _direction_1, _x2, _y2, _direction_2){
	var _delta_x1 = lengthdir_x(1, _prev_direction)
	var _delta_y1 = lengthdir_y(1, _prev_direction)
	var _delta_x2 = lengthdir_x(1, _direction)
	var _delta_y2 = lengthdir_y(1, _direction)
	
	var _determinant = _delta_x1 * _delta_y2 - _delta_y1 * _delta_x2
	
	var _scalar_distance = ((_p2_x - _p_1_x) * _delta_y2 - (_p2_y - _p_1_y) * _delta_x2) / _determinant
	var _pintersection_x = _p_1_x + _scalar_distance * _delta_x1
	var _pintersection_y = _p_1_y + _scalar_distance * _delta_y1
}
