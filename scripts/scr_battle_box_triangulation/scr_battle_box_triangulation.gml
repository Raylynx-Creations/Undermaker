function get_polygon_orientation(_points) {
    var _sum = 0
    var _length = array_length(_points)
	
    for (var _i = 0; _i < _length; _i += 2) {
        var _p1_x = _points[_i]
        var _p1_y = _points[_i+1]
        var _p2_x = _points[(_i + 2)%_length]
        var _p2_y = _points[(_i + 3)%_length]
        _sum += (_p2_x - _p1_x)*(_p2_y + _p1_y)
    }
	
    return ((_sum > 0) ? ROTATION_ORIENTATION.COUNTER_CLOCKWISE : ROTATION_ORIENTATION.CLOCKWISE)
}

function triangulate_polygon(_points) {
    var _triangles = []
	var _vertices = []
	var _length = array_length(_points)
	
	array_copy(_vertices, 0, _points, 0, _length)
    var _orientation = get_polygon_orientation(_vertices)
	
    while (_length > 6) {
        var _ear_found = false
		
        for (var _i = 0; _i < _length; _i += 2) {
            var _prev_x = _vertices[(_i - 2 + _length)%_length]
            var _prev_y = _vertices[(_i - 1 + _length)%_length]
            var _curr_x = _vertices[_i]
            var _curr_y = _vertices[_i+1]
            var _next_x = _vertices[(_i + 2)%_length]
            var _next_y = _vertices[(_i + 3)%_length]
			
            if (!is_triangle_convex(_prev_x, _prev_y, _curr_x, _curr_y, _next_x, _next_y, _orientation)) {
                continue
            }
			
            var _contains_point = false
			
            for (var _j = 0; _j < _length; _j += 2) {
                if (_j == _i or _j == (_i - 2 + _length)%_length or _j == (_i + 2)%_length){
					continue
				}
				
                var _px = _vertices[_j]
                var _py = _vertices[_j+1]
				
                if (point_in_triangle(_px, _py, _prev_x, _prev_y, _curr_x, _curr_y, _next_x, _next_y)) {
                    _contains_point = true
					
                    break
                }
            }
			
            if (!_contains_point) {
                array_push(_triangles, [_prev_x, _prev_y, _curr_x, _curr_y, _next_x, _next_y])
                array_delete(_vertices, _i, 2)
				
				_length -= 2
                _ear_found = true
                
				break
            }
        }
		
        if (!_ear_found) {
			show_message("Triangulation failed, the polygon given is not valid for triangulation, make sure the lines don't intersect with each other.")
			
            break
        }
    }
	
    if (_length == 6) {
        array_push(_triangles, [_vertices[0], _vertices[1], _vertices[2], _vertices[3], _vertices[4], _vertices[5]]);
    }
	
    return _triangles
}
