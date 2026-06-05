#macro EPSILON 0.0001
#macro MAX_LOOP_COUNT 50

global.__edge_uid = 0

function Node(_x, _y) constructor {
    x = _x
    y = _y

    uid = global.__edge_uid++;
    next = undefined
    prev = undefined

    intersect = false
    neighbor = undefined

    alpha = 0        // position on edge
    entry = false    // entry/exit flag
    visited = false
	
    crossing = false; // true only for real boundary crossings
    kind = 0;         // 0=cross, 1=overlap, 2=touch
}

function polygon_to_linked_node_list(_poly) {
    var _first = undefined;
    var _prev = undefined;

	var _length = array_length(_poly)
    for (var _i = 0; _i < _length; _i += 2) {
        var _node = new Node(_poly[_i], _poly[_i+1]);

        if (is_undefined(_first)){
			_first = _node
		}

        if (!is_undefined(_prev)) {
            _prev.next = _node;
            _node.prev = _prev;
        }

        _prev = _node;
    }

    // close loop
    _prev.next = _first;
    _first.prev = _prev;

    return _first;
}

function segment_intersection(_a, _b) {
    var _x1 = _a.x, _y1 = _a.y;
    var _x2 = _a.next.x, _y2 = _a.next.y;
    var _x3 = _b.x, _y3 = _b.y;
    var _x4 = _b.next.x, _y4 = _b.next.y;
	var _direction1 = point_direction(_x1, _y1, _x2, _y2)
	var _direction2 = point_direction(_x3, _y3, _x4, _y4)
	
	var _hit = []
	var _p = intersection_of_lines(_x1, _y1, _direction1, _x3, _y3, _direction2, 10)
	
	if (is_nan(_p[0]) and is_nan(_p[1])){ //Collinear case, line is overlapping the other line
		//show_debug_message("WAS NAN")
		//show_debug_message(string_concat(_x1, " | ", _y1, " | ", _x2, " | ", _y2, " | ", _x3, " | ", _y3, " | ", _x4, " | ", _y4))
		if (point_distance(_x1, 0, _x3, 0) < 10 and point_distance(_x3, 0, _x4, 0) < 10){
			if (_y1 <= _y3){
				if (_y3 <= _y4){
					_p = [_x3, _y3]
				}else if (_y1 <= _y4){
					_p = [_x4, _y4]
				}else{
					_p = [_x1, _y1]
				}
			}else{
				if (_y3 <= _y4){
					_p = [_x4, _y4]
				}else if (_y1 <= _y3){
					_p = [_x3, _y3]
				}else{
					_p = [_x1, _y1]
				}
			}
		}else if (_x1 <= _x3){
			if (_x3 <= _x4){
				_p = [_x3, _y3]
			}else if (_x1 <= _x4){
				_p = [_x4, _y4]
			}else{
				_p = [_x1, _y1]
			}
		}else{
			if (_x3 <= _x4){
				_p = [_x4, _y4]
			}else if (_x1 <= _x3){
				_p = [_x3, _y3]
			}else{
				_p = [_x1, _y1]
			}
		}
	}else if (is_infinity(_p[0]) or is_infinity(_p[1])){ //Parallel lines, they are not overlapping
		return _hit
	}
	
	//show_debug_message(string_concat(_a.uid, " | ", _b.uid, " | ", _p, " | ", _direction1, " | ", _direction2, " | ", angle_difference(_direction1, _direction2)))
	
	if (_p[0] >= min(_x1, _x2) - 10 and _p[0] <= max(_x1, _x2) + 10 and _p[0] >= min(_x3, _x4) - 10 and _p[0] <= max(_x3, _x4) + 10 and _p[1] >= min(_y1, _y2) - 10 and _p[1] <= max(_y1, _y2) + 10 and _p[1] >= min(_y3, _y4) - 10 and _p[1] <= max(_y3, _y4) + 10){
		var _tA = point_distance(_x1, _y1, _p[0], _p[1])/point_distance(_x1, _y1, _x2, _y2)
		var _tB = point_distance(_x3, _y3, _p[0], _p[1])/point_distance(_x3, _y3, _x4, _y4)
		
		//show_debug_message(string_concat(string_format(_tA, 1, 6), " | ", string_format(_tB, 1, 6)))
		
		if (_tA < EPSILON or _tA > 1 - EPSILON or _tB < EPSILON or _tB > 1 - EPSILON){
			var _directionA, _directionB
			
			if (_tA < EPSILON){
				_directionA = point_direction(_x1, _y1, _a.prev.x, _a.prev.y)
			}else{
				_directionA = (_direction1 + 180)%360
				if (_tA > 1 - EPSILON){
					_direction1 = point_direction(_x2, _y2, _a.next.next.x, _a.next.next.y)
				}
			}
			
			if (_tB < EPSILON){
				_directionB = point_direction(_x3, _y3, _b.prev.x, _b.prev.y)
			}else{
				_directionB = (_direction2 + 180)%360
				if (_tB > 1 - EPSILON){
					_direction2 = point_direction(_x4, _y4, _b.next.next.x, _b.next.next.y)
				}
			}
			
			var _angle_epsilon = 100*EPSILON
			var _angle_diff1 = (abs(angle_difference(_direction1, _direction2)) <= _angle_epsilon)
			var _angle_diff2 = (abs(angle_difference(_direction1, _directionB)) <= _angle_epsilon)
			var _angle_diff3 = (abs(angle_difference(_direction2, _directionA)) <= _angle_epsilon)
			var _angle_diff4 = (abs(angle_difference(_directionA, _directionB)) <= _angle_epsilon)
			if (abs(angle_difference(_direction1, _directionA)) <= _angle_epsilon or abs(angle_difference(_direction2, _directionB)) <= _angle_epsilon or (_angle_diff1 and _angle_diff4) or (_angle_diff2 and _angle_diff3)){
				//show_debug_message("FULLY COLLINEAR")
				return _hit
			}else if (_angle_diff1 or _angle_diff2 or _angle_diff3 or _angle_diff4){
				//show_debug_message("COLLINEAR")
				if (_angle_diff1 or _angle_diff2){
					array_push(_hit, _p[0], _p[1], _tA, _a, _b, 1)
				}else{
					var _angle_base, _angle_value
					
					if (_angle_diff3){
						_angle_base = angle_difference(_direction2, _directionB)
						_angle_value = angle_difference(_directionA, _direction1)
					}else{
						_angle_base = angle_difference(_direction2, _directionB)
						_angle_value = angle_difference(_direction1, _directionA)
					}
					
					if (_angle_base < 0){
						_angle_base += 360
					}
					if (_angle_value < 0){
						_angle_value += 360
					}
					
					array_push(_hit, _p[0], _p[1], _tA, _a, _b, 2 - (_angle_value < _angle_base))
				}
			}else{
				//show_debug_message("CORNER OR CROSSING")
				var _angle_base = angle_difference(_directionA, _direction1)
				_angle_diff1 = angle_difference(_direction2, _direction1)
				_angle_diff2 = angle_difference(_directionB, _direction1)
				
				if (_angle_base < 0){
					_angle_base += 360
				}
				if (_angle_diff1 < 0){
					_angle_diff1 += 360
				}
				if (_angle_diff2 < 0){
					_angle_diff2 += 360
				}
				
				if ((_angle_base < _angle_diff1 and _angle_base > _angle_diff2) or (_angle_base < _angle_diff2 and _angle_base > _angle_diff1)){
					array_push(_hit, _p[0], _p[1], _tA, _a, _b, 0)
				}
			}
		}else{
			array_push(_hit, _p[0], _p[1], _tA, _a, _b, 0)
		}
	}
	
	return _hit
}

function collect_intersections(_polyA, _polyB) {
    var raw_hits = [];
    
    // Collect all raw intersections
    var _a = _polyA;
    repeat (MAX_LOOP_COUNT) {
        var _b = _polyB;
        repeat (MAX_LOOP_COUNT) {
            var h = segment_intersection(_a, _b);
			if (array_length(h) > 0){
	            array_push(raw_hits, {
	                x: h[0], y: h[1],
	                alphaA: h[2],
	                edgeA: _a, edgeB: _b,
	                kind: h[5]
	            });
			}
            _b = _b.next;
            if (_b == _polyB) break;
        }
        _a = _a.next;
        if (_a == _polyA) break;
    }
    
    // Cluster by position (within EPSILON)
    var clusters = [];
    var used = array_create(array_length(raw_hits), false);
    for (var i = 0; i < array_length(raw_hits); i++) {
        if (used[i]) continue;
        var cluster = [raw_hits[i]];
        used[i] = true;
        for (var j = i+1; j < array_length(raw_hits); j++) {
            if (used[j]) continue;
            if (point_distance(raw_hits[i].x, raw_hits[i].y, raw_hits[j].x, raw_hits[j].y) <= EPSILON) {
                array_push(cluster, raw_hits[j]);
                used[j] = true;
            }
        }
        array_push(clusters, cluster);
    }
    
    // Build final intersection list with merged edge pairs
    var result = [];
    for (var c = 0; c < array_length(clusters); c++) {
        var cluster = clusters[c];
        // Average position (though they should be identical)
        var avgX = 0, avgY = 0;
        for (var i = 0; i < array_length(cluster); i++) {
            avgX += cluster[i].x;
            avgY += cluster[i].y;
        }
        avgX /= array_length(cluster);
        avgY /= array_length(cluster);
        
        // Collect unique edgeA and edgeB pairs
        var edgePairs = [];
        for (var i = 0; i < array_length(cluster); i++) {
            var hit = cluster[i];
            var found = false;
            for (var j = 0; j < array_length(edgePairs); j++) {
                if (edgePairs[j].edgeA == hit.edgeA && edgePairs[j].edgeB == hit.edgeB) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                array_push(edgePairs, { edgeA: hit.edgeA, edgeB: hit.edgeB, kind: hit.kind, alphaA: hit.alphaA });
            }
        }
        
        // For each unique edge pair, create an entry in the result
        for (var i = 0; i < array_length(edgePairs); i++) {
            var ep = edgePairs[i];
            array_push(result, [avgX, avgY, ep.alphaA, ep.edgeA, ep.edgeB, ep.kind]);
        }
    }
    
    // Sort result by edgeA.uid and alpha (optional, for debugging)
    array_sort(result, function(a, b) {
        if (a[3].uid != b[3].uid) return a[3].uid - b[3].uid;
        return a[2] - b[2];
    });
    
    // Debug output
	var _length = array_length(result)
    //show_debug_message("=== Clustered intersections: " + string(_length));
    for (var i = 0; i < _length; i++) {
        var p = result[i];
		
		for (var _j = i + 1; _j < _length; _j++){
			var _p2 = result[_j]
			if (point_distance(p[0], p[1], _p2[0], _p2[1]) < EPSILON){
				array_delete(result, _j, 1)
				_j--
				_length--
			}
		}
		
        //show_debug_message("  " + string(i) + ": (" + string_format(p[0],2,2) + "," + string_format(p[1],2,2) + ") alpha=" + string_format(p[2],2,4) + " kind=" + string(p[5]) + " edgeA.uid=" + string(p[3].uid) + " edgeB.uid=" + string(p[4].uid));
    }
    
    return result;
}

function apply_intersections(_intersections) {
    var edge_map = ds_map_create();

    for (var i = 0; i < array_length(_intersections); i++) {
        var p = _intersections[i];
        var edge = p[3].uid;

        if (!ds_map_exists(edge_map, edge)) {
            ds_map_add(edge_map, edge, []);
        }

        var list = edge_map[? edge];
        array_push(list, p);
        edge_map[? edge] = list;
    }

    var keys = ds_map_keys_to_array(edge_map);

    for (var k = 0; k < array_length(keys); k++) {
        var edge = keys[k];
        var list = edge_map[? edge];

        array_sort(list, function(a,b){ return a[2] - b[2]; });

        for (var i = 0; i < array_length(list); i++) {
            var p = list[i];

            var ax = p[3];
            var bx = p[4];

            var na = new Node(p[0], p[1]);
            var nb = new Node(p[0], p[1]);

            na.intersect = true;
            nb.intersect = true;

            na.neighbor = nb;
            nb.neighbor = na;

            na.alpha = clamp(p[2], 0, 1);

            var bx1 = bx.x;
            var by1 = bx.y;
			
			var _cur = bx.next
			while (_cur.intersect){
				_cur = _cur.next
			}
            
			var bx2 = _cur.x;
            var by2 = _cur.y;
			
            var lenB = point_distance(bx1,by1,bx2,by2);

            nb.alpha = ((lenB > EPSILON) ? point_distance(bx1,by1,p[0],p[1])/lenB : 0);

            na.kind = p[5];
            nb.kind = p[5];

            insert_node(ax, na);
            insert_node(bx, nb);
        }
    }

    ds_map_destroy(edge_map);
}

function insert_node(_start, _node) {
    var _cur = _start;
	
	var _loop_count = 0
    while (_cur.next.intersect and _cur.next.alpha < _node.alpha) {
		_loop_count++
		if (_loop_count > MAX_LOOP_COUNT){
			break;
		}
		
        _cur = _cur.next;
    }

    _node.next = _cur.next;
    _node.prev = _cur;
	
    _cur.next.prev = _node;
    _cur.next = _node;
}

function point_in_linked_node(_px, _py, _start) {
    var _inside = false;
    var _cur = _start;

    var _loop_count = 0
    do{
		_loop_count++
		if (_loop_count > MAX_LOOP_COUNT){
			break;
		}
		
        var _x1 = _cur.x;
        var _y1 = _cur.y;
        var _x2 = _cur.next.x;
        var _y2 = _cur.next.y;

        if ((_y1 > _py) != (_y2 > _py) and _px < (_x2 - _x1)*(_py - _y1)/(_y2 - _y1) + _x1) {
            _inside = !_inside;
        }

        _cur = _cur.next;
    }until (_cur == _start);

    return _inside;
}

function mark_entry_exit(_poly, _other, _is_main=false) {
    var _cur = _poly;
    var _start = undefined;
    repeat (MAX_LOOP_COUNT) {
        if (_cur.intersect) { _start = _cur; break; }
        _cur = _cur.next;
        if (_cur == _poly) break;
    }
    if (is_undefined(_start)) return;
    
    _cur = _start;
    repeat (MAX_LOOP_COUNT) {
        if (_cur.intersect) {
			if (_cur.kind >= 1){
				if (_is_main) {
	                _cur.entry = (_cur.kind == 1)
	            } else {
	                _cur.entry = (_cur.kind == 2)
	            }
				
				//show_debug_message("Node uid=" + string(_cur.uid) + " cross=NA entry=" + string(_cur.entry) + " is_subject=" + string(_is_main));
			}else{
	            // Get edge vectors at the intersection
	            var ax = _cur.next.x - _cur.x;
	            var ay = _cur.next.y - _cur.y;
	            var bx = _cur.neighbor.next.x - _cur.neighbor.x;
	            var by = _cur.neighbor.next.y - _cur.neighbor.y;
            
	            // 2D cross product (ax*by - ay*bx)
	            var cross = ax * by - ay * bx;
            
	            // For difference: on subject, entry if cross > 0; on hole, entry if cross < 0.
	            // (This assumes subject CCW, hole CW; adjust signs if your winding is reversed.)
	            _cur.entry = (cross < 0);
				
				//show_debug_message("Node uid=" + string(_cur.uid) + " cross=" + string_format(cross,2,4) + " entry=" + string(_cur.entry) + " is_subject=" + string(_is_main));
			}
            
            _cur.crossing = true;  // All clustered hits are proper crossings or touches that matter
        }
        _cur = _cur.next;
        if (_cur == _start) break;
    }
}

function build_resulting_polygon(_poly, _diff=false, _flip_disabled=false) {
    var _result = [];
    var _cur = _poly;

    repeat (MAX_LOOP_COUNT) {
        if (_cur.intersect and !_cur.visited and _cur.crossing and _cur.entry) {
			//show_debug_message("Starting new component at node uid=" + string(_cur.uid) + " pos=(" + string(_cur.x) + "," + string(_cur.y) + ")");
							   
            var _out = [];
            var _start = _cur;
			var _flip = _flip_disabled
			var _inside = false

            repeat (MAX_LOOP_COUNT) {
                if (_cur.visited) break;
				
				if (!_cur.intersect or _cur.crossing) {
                    array_push(_out, _cur.x, _cur.y);
					//show_debug_message("    Added point (" + string(_cur.x) + "," + string(_cur.y) + ")");
                }

                _cur.visited = true;

                if (_cur.intersect) {
					if (((!_cur.entry and _inside) or (_cur.entry and !_inside)) xor _inside){
						_inside = !_inside
						_cur = _cur.neighbor;
	                    _cur.visited = true;
						//show_debug_message("    Switched to neighbor uid=" + string(_cur.uid));
					
						if (_diff and !_flip_disabled){
							_flip = !_flip
						}
					}else{
						_cur.neighbor.visited = true
					}
				}

                _cur = (_flip ? _cur.prev : _cur.next);

                if (_cur == _start) break;
            }

            array_push(_result, _out);
        }

        _cur = _cur.next;
        if (_cur == _poly) break;
    }

    var _length = array_length(_result);
    for (var _i = 0; _i < _length; _i++) {
		var _cleaned_result = clean_polygon(_result[_i]);
		
		if (array_length(_cleaned_result) == 0){
			//show_debug_message("Deleted poly " + string(_i) + ":" + string(_cleaned_result))
			array_delete(_result, _i, 1)
			_i--
			_length--
		}else{
			_result[_i] = _cleaned_result
		}
	}
	
	for (var i = 0; i < array_length(_result); i++) {
        var poly = _result[i];
        var str = "Result poly " + string(i) + ": [";
        for (var j = 0; j < array_length(poly); j += 2) {
            str += "(" + string(poly[j]) + "," + string(poly[j+1]) + ")";
            if (j + 2 < array_length(poly)) str += ", ";
        }
        str += "]";
        //show_debug_message(str);
    }

    return _result;
}

//DEBUG
function log_linked_list(_start, _name) {
    var _cur = _start;
    var _count = 0;
    var _str = "Linked list for " + _name + ":\n";
    repeat (MAX_LOOP_COUNT) {
        _str += "  uid=" + string(_cur.uid) +
                " pos=(" + string_format(_cur.x, 2, 2) + "," + string_format(_cur.y, 2, 2) + ")" +
                " intersect=" + string(_cur.intersect) +
                " alpha=" + string_format(_cur.alpha, 2, 4) +
                " neighbor_uid=" + (is_undefined(_cur.neighbor) ? "none" : string(_cur.neighbor.uid)) +
                "\n";
        _cur = _cur.next;
        _count++;
        if (_cur == _start) break;
    }
    _str += "Total nodes: " + string(_count);
    //show_debug_message(_str);
}

function polygon_union_by_greiner_hormann(_polyA_arr, _polyB_arr, _mergeA, _mergeB) {
    // rule: only merge if at least one is mergeable
	//show_debug_message(string_concat(_polyA_arr, " | ", _polyB_arr, " | ", _mergeA, " | ", _mergeB))
	
    if (!(_mergeA or _mergeB) or array_length(_polyA_arr) < 6 or array_length(_polyB_arr) < 6) {
		return false;
    }

    var _A = polygon_to_linked_node_list(_polyA_arr);
    var _B = polygon_to_linked_node_list(_polyB_arr);

	var _ints = collect_intersections(_A, _B);
	var _result
	
	if (array_length(_ints) == 0) {
		if (point_in_linked_node(_B.x, _B.y, _A)) {
	        _result = [_polyA_arr];
		} else if (point_in_linked_node(_A.x, _A.y, _B)) {
			_result = [_polyB_arr]
	    } else {
	        _result = [_polyA_arr, _polyB_arr];
	    }
	}else{
		apply_intersections(_ints);
		//log_linked_list(_A, "Subject A");
		//log_linked_list(_B, "Subject B");

	    mark_entry_exit(_A, _B, true);
		mark_entry_exit(_B, _A);
	
		_result = array_concat(build_resulting_polygon(_B), build_resulting_polygon(_A))
	}
	
	return _result
}

function polygon_difference_by_greiner_hormann(_poly_arr, _hole_arr){
	if (array_length(_poly_arr) < 6 or array_length(_hole_arr) < 6) {
        return [_poly_arr];
    }
	
    var _A = polygon_to_linked_node_list(_poly_arr);
    var _H = polygon_to_linked_node_list(_hole_arr);

	var _ints = collect_intersections(_A, _H);
	var _result;
	
	if (array_length(_ints) == 0) { //If no intersections we must check if the polygons are inside each other, otherwise return the solid polygon only
	    if (point_in_linked_node(_H.x, _H.y, _A)) { //If the hole is inside the solid polygon then it cretes a polygon inside it for the hole-
	        // B is fully inside A → create hole.
	        _result = [true, [_poly_arr], [_hole_arr]];
		} else if (point_in_linked_node(_A.x, _A.y, _H)) { //If the solid is inside the hole, then the polygon is consumed, nothing remains
			_result = [false]
	    } else {
	        _result = [_poly_arr];
	    }
	}else{
		apply_intersections(_ints);
		//log_linked_list(_A, "Subject");
		//log_linked_list(_H, "Hole");

		mark_entry_exit(_A, _H, true);   // A is subject
		mark_entry_exit(_H, _A);   // H is clip
		
	    _result = build_resulting_polygon(_A, true);
	}
	
	return _result
}

function polygon_intersection_by_greiner_hormann(_poly_arr, _cut_arr){
	if (array_length(_poly_arr) < 6 or array_length(_cut_arr) < 6) {
        return [_poly_arr];
    }
	
    var _A = polygon_to_linked_node_list(_poly_arr);
    var _C = polygon_to_linked_node_list(_cut_arr);

	var _ints = collect_intersections(_A, _C);
	var _result;
	
	if (array_length(_ints) == 0) { //If no intersections we must check if the polygons are inside each other, otherwise return the solid polygon only
	    if (point_in_linked_node(_C.x, _C.y, _A)) {
	        _result = [_cut_arr]
		} else if (point_in_linked_node(_A.x, _A.y, _C)) {
			_result = [_poly_arr]
	    } else {
	        _result = []
	    }
	}else{
		apply_intersections(_ints);
		//log_linked_list(_A, "Subject");
		//log_linked_list(_C, "Cut");

		mark_entry_exit(_A, _C, true);   // A is subject
		mark_entry_exit(_C, _A);   // C is cut
		
	    _result = build_resulting_polygon(_A, true, true)
	}
	
	return _result
}

function polygon_signed_area(_poly) {
    var area = 0;
    var len = array_length(_poly);

    for (var i = 0; i < len; i += 2) {
        var j = (i + 2) mod len;

        area += (_poly[i] * _poly[j+1] - _poly[j] * _poly[i+1]);
    }

    return area * 0.5;
}

function polygon_is_clockwise(_poly) {
    return polygon_signed_area(_poly) < 0;
}

function reverse_polygon(_poly, _linked_nodes=false){
	if (_linked_nodes){
		var _cur = _poly
		do{
			var _next = _cur.next
			_cur.next = _cur.prev
			_cur.prev = _next
			_cur = _next
		}until (_poly == _cur)
	}else{
        var _len = array_length(_poly);
        var _rev = [];
        for (var i = _len - 2; i >= 0; i -= 2) {
            array_push(_rev, _poly[i], _poly[i+1]);
        }
        return _rev;
	}
}

function ensure_winding(_poly, _clockwise) {
    if (polygon_is_clockwise(_poly) != _clockwise) {
        return reverse_polygon(_poly);
    }
    return _poly;
}

function clean_polygon(_poly) {
    //show_debug_message(_poly)
	
	var _length = array_length(_poly)
    for (var _i = 0; _i < _length; _i += 2) {
        var _j = (_i + 2)%_length;
        var _k = (_i - 2 + _length)%_length;
		var _x1 = _poly[_i]
		var _y1 = _poly[_i + 1]
		var _x2 = _poly[_j]
		var _y2 = _poly[_j + 1]
		var _x_1 = _poly[_k]
		var _y_1 = _poly[_k + 1]

        if (point_distance(_x1, _y1, _x2, _y2) < 10 or abs(angle_difference(point_direction(_x1, _y1, _x2, _y2), point_direction(_x_1, _y_1, _x1, _y1))) < 100*EPSILON) {
            array_delete(_poly, _i, 2)
			_i -= 2
			_length -= 2
        }
    }
	
	//show_debug_message(_poly)

    return _poly;
}

function multi_polygon_union_by_greiner_hormann(_polys, _poly_merge_flags=undefined) {
	var _poly_specific_holes = []
	var _polys_copy = []
	
	var _length = array_length(_polys)
	for (var _i = 0; _i < _length; _i++){
		var _copy = []
		var _poly = _polys[_i]
		
		array_copy(_copy, 0, _poly, 0, array_length(_poly))
		array_push(_polys_copy, _copy)
	}
	
	//show_debug_message(string_concat("Number of polygons to merge: ", _length))
	
	for (var _i = 0; _i < _length; _i++) {
		var _did_merge = false
		
	    for (var _j = _i + 1; _j < _length; _j++) {
			var _merge_i, _merge_j
			if (is_undefined(_poly_merge_flags)){
				_merge_i = 1
				_merge_j = 1
			}else{
				_merge_i = _poly_merge_flags[_i]
				_merge_j = _poly_merge_flags[_j]
			}
			
	        var _merged = polygon_union_by_greiner_hormann(
	            ensure_winding(_polys[_i], false),
	            ensure_winding(_polys[_j], false),
	            _merge_i,
	            _merge_j
	        );
			
			var _merged_length = array_length(_merged)
			for (var _k = 0; _k < _merged_length; _k++){
				if (array_length(_merged[_k]) < 6){
					array_delete(_merged, _k, 1)
					_k--
					_merged_length--
				}
			}
			
	        if (_merged_length == 1 and _merged[0] != false) {
	            _polys[_i] = _merged[0];
	            array_delete(_polys, _j, 1);
				
	            if (!is_undefined(_poly_merge_flags)){
					_poly_merge_flags[_i] = 1;
				    array_delete(_poly_merge_flags, _j, 1);
				}
				
				_did_merge = true
	            _j--;
				_length--;
	        }else{
				var _merged_linked_list = []
				for (var _k = 0; _k < _merged_length; _k++){
					array_push(_merged_linked_list, polygon_to_linked_node_list(_merged[_k]))
				}
				
				var _solid = undefined
				var _hole_candidates = []
				for (var _k = 0; _k < _merged_length; _k++){
					_solid = _merged_linked_list[_k]
					for (var _l = 0; _l < _merged_length; _l++){
						if (_k == _l){
							continue
						}
						
						var _candidate = _merged_linked_list[_l]
						if (!point_in_linked_node(_candidate.x, _candidate.y, _solid)){
							var _hole_candidates_length = array_length(_hole_candidates)
							if (_hole_candidates_length > 0){
								array_delete(_hole_candidates, 0, _hole_candidates_length)
							}
							
							_solid = undefined
							break
						}else{
							array_push(_hole_candidates, _merged[_l])
						}
					}
					
					//show_debug_message(_solid)
					
					if (!is_undefined(_solid)){
						_polys[_i] = _merged[_k];
			            array_delete(_polys, _j, 1);
						
						if (!is_undefined(_poly_merge_flags)){
				            _poly_merge_flags[_i] = 1;
				            array_delete(_poly_merge_flags, _j, 1);
						}
						
						_poly_specific_holes = array_concat(_poly_specific_holes, _hole_candidates)
						
						_did_merge = true
			            _j--;
						_length--;
						
						break
					}
				}
			}
	    }
		
		if (_did_merge){
			_i--
		}
	}
	
	var _result = multi_polygon_difference_by_greiner_hormann(_poly_specific_holes, _polys_copy)
	_poly_specific_holes = _result[0]
	var _hole_specific_cuts = _result[1]
	
	return [_poly_specific_holes, _hole_specific_cuts]
}

function multi_polygon_difference_by_greiner_hormann(_polys, _holes, _poly_merge_flags=undefined){
	var _new_holes = []
	
	var _length = array_length(_holes)
	for (var h = 0; h < _length; h++) {
	    var hole = ensure_winding(_holes[h], false);
	    var new_polys = [];
		var _new_merge_flags = []
		
		var _poly_length = array_length(_polys)
	    for (var r = 0; r < _poly_length; r++) {
			var _poly = ensure_winding(_polys[r], false)
	        var clipped = polygon_difference_by_greiner_hormann(_poly, hole);
			
			var _clipped_length = array_length(clipped)
			if (_clipped_length == 0 or clipped[0] == false){
				continue
			}else if (clipped[0] == true){
				_new_holes = array_concat(_new_holes, clipped[2])
				clipped = clipped[1]
			}
			
	        _clipped_length = array_length(clipped)
	        for (var k = 0; k < _clipped_length; k++) {
	            array_push(new_polys, clipped[k]);
				
				if (!is_undefined(_poly_merge_flags)){
					array_push(_new_merge_flags, _poly_merge_flags[r])
				}
	        }
	    }

	    _polys = new_polys;
		
		if (!is_undefined(_poly_merge_flags)){
			_poly_merge_flags = _new_merge_flags
		}
	}
	
	return [_polys, _new_holes, _poly_merge_flags]
}

function multi_polygon_intersection_by_greiner_hormann(_polys, _cuts, _poly_merge_flags=undefined){
	var _result_polys = []
	var _result_merge_flags = []
	
	var _length = array_length(_cuts)
	for (var h = 0; h < _length; h++) {
	    var _cut = ensure_winding(_cuts[h], false);
	    var new_polys = [];
		var _new_merge_flags = []
		
		var _poly_length = array_length(_polys)
	    for (var r = 0; r < _poly_length; r++) {
			var _poly = ensure_winding(_polys[r], false)
	        var clipped = polygon_intersection_by_greiner_hormann(_poly, _cut);
			
	        var _clipped_length = array_length(clipped)
	        for (var k = 0; k < _clipped_length; k++) {
	            array_push(new_polys, clipped[k]);
				
				if (!is_undefined(_poly_merge_flags)){
					array_push(_new_merge_flags, _poly_merge_flags[r])
				}
	        }
	    }

	    _result_polys = new_polys;
		_result_merge_flags = _new_merge_flags
	}
	
	return [_result_polys, _result_merge_flags]
}

function multi_polygon_operations_by_greiner_hormann(_polys, _merge_flags) {
	global.__edge_uid = 0
	
	var _length = array_length(_polys)
	for (var _i = 0; _i < _length; _i++){ //Convert decimal part into integer to get around floating point precission
		var _poly = []
		array_copy(_poly, 0, _polys[_i], 0, array_length(_polys[_i]))
		
		var _points_length = array_length(_poly)
		for (var _j = 0; _j < _points_length; _j++){
			_poly[_j] *= 1000
			//_poly[_j] = round(_poly[_j]) //then delete any remaining decimal numbers and operate
		}
		
		_polys[_i] = _poly
	}
	
	var _solids = [];
	var _solid_merge_flags = [];
	var _holes = [];
	var _holes_flags = [];
	
	// Separate polygons
	for (var i = 0; i < _length; i++) {
		var _poly = []
		array_copy(_poly, 0, _polys[i], 0, array_length(_polys[i]))
		
	    if (_merge_flags[i] == 2) {
	        array_push(_holes, _poly);
	    } else {
	        array_push(_solids, _poly);
			array_push(_solid_merge_flags, _merge_flags[i])
	    }
	}
    
	var _result = multi_polygon_union_by_greiner_hormann(_holes)
	var _hole_specific_cuts = _result[0]
	var _cut_specific_holes = _result[1]
	
	var _solids_copy = []
	var _solid_copy_merge_flags = []
	_length = array_length(_solids)
	for (var _i = 0; _i < _length; _i++){
		var _copy = []
		var _solid = _solids[_i]
		
		array_copy(_copy, 0, _solid, 0, array_length(_solid))
		array_push(_solids_copy, _copy)
	}
	array_copy(_solid_copy_merge_flags, 0, _solid_merge_flags, 0, _length)
	
	_result = multi_polygon_difference_by_greiner_hormann(_solids, _holes, _solid_merge_flags)
	_solid_merge_flags = _result[2]
	_holes = _result[1]
	_solids = _result[0]
	
	_result = multi_polygon_intersection_by_greiner_hormann(_solids_copy, _hole_specific_cuts, _solid_copy_merge_flags)
	_solid_merge_flags = array_concat(_solid_merge_flags, _result[1])
	_solids = array_concat(_solids, _result[0])
	
	_result = multi_polygon_difference_by_greiner_hormann(_solids, _cut_specific_holes, _solid_merge_flags)
	_solid_merge_flags = _result[2]
	_holes = array_concat(_holes, _result[1])
	_solids = _result[0]
	
	//show_debug_message(string_concat(_solids, " | ", _solid_merge_flags))
	
	_result = multi_polygon_union_by_greiner_hormann(_solids, _solid_merge_flags)
	_holes = array_concat(_holes, _result[0])
	_solids = array_concat(_solids, _result[1])
	
	_length = array_length(_solids) //Undo increment on number and normalize it from previous operation.
	for (var _i = 0; _i < _length; _i++){
		var _points_length = array_length(_solids[_i])
		for (var _j = 0; _j < _points_length; _j++){
			_solids[_i][_j] /= 1000
		}
	}
	
	_length = array_length(_holes)
	for (var _i = 0; _i < _length; _i++){
		var _points_length = array_length(_holes[_i])
		for (var _j = 0; _j < _points_length; _j++){
			_holes[_i][_j] /= 1000
		}
	}
	
    return [_solids, _holes];
}