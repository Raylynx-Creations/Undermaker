#macro EPSILON 0.0001
#macro MAX_LOOP_COUNT 50

function float_equality(_a, _b) {
    return abs(_a - _b) < EPSILON;
}

function point_equality(_x1,_y1,_x2,_y2) {
    return (float_equality(_x1,_x2) and float_equality(_y1,_y2));
}

function triangle_orientation(_ax,_ay,_bx,_by,_cx,_cy) {
    var _v = (_bx - _ax)*(_cy - _ay) - (_by - _ay)*(_cx - _ax);
    if (abs(_v) < EPSILON){
		return 0; // collinear
	}
	
    return sign(_v);
}

function point_on_segment(_px,_py,_ax,_ay,_bx,_by) {
    return (triangle_orientation(_ax,_ay,_bx,_by,_px,_py) == 0 and _px >= min(_ax,_bx) - EPSILON and _px <= max(_ax,_bx) + EPSILON and _py >= min(_ay,_by) - EPSILON and _py <= max(_ay,_by) + EPSILON);
}

function offset_point(_x1,_y1,_x2,_y2) {
    var _dx = _y2 - _y1;
    var _dy = -(_x2 - _x1);

    var _len = sqrt(_dx*_dx + _dy*_dy);
    if (_len < EPSILON){
		return [_x1,_y1];
	}

    _dx /= _len;
    _dy /= _len;

    return [_x1 + _dx*EPSILON*10, _y1 + _dy*EPSILON*10];
}

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

function add_unique_hit(_hits, _x, _y, _t, _edgeA, _edgeB, _kind) {
    _t = clamp(_t, 0, 1);
	
	if (_t < EPSILON or _t > 1 - EPSILON){
		_kind = 1
	}

    for (var i = 0; i < array_length(_hits); i++) {
        if (point_distance(_x, _y, _hits[i][0], _hits[i][1]) <= EPSILON) {
            // Keep the best kind if the same point is seen again
            if (_kind < _hits[i][5]) _hits[i][5] = _kind;
            return;
        }
    }

    array_push(_hits, [_x, _y, _t, _edgeA, _edgeB, _kind]);
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
	
	var _dir1 = point_direction(_a.prev.x, _a.prev.y, _x1, _y1) + 90
	var _dir2 = point_direction(_x1, _y1, _x2, _y2) + 90
	var _dir3 = point_direction(_x2, _y2, _a.next.next.x, _a.next.next.y) + 90
	var _dir4 = point_direction(_b.prev.x, _b.prev.y, _x3, _y3) + 90
	var _dir5 = point_direction(_x3, _y3, _x4, _y4) + 90
	var _dir6 = point_direction(_x4, _y4, _b.next.next.x, _b.next.next.y) + 90
		
	var _diff1 = angle_difference(_dir2, _dir1)/2
	var _diff2 = angle_difference(_dir3, _dir2)/2
	var _diff3 = angle_difference(_dir5, _dir4)/2
	var _diff4 = angle_difference(_dir6, _dir5)/2
		
	_dir1 += _diff1
	_dir2 += _diff2
	_dir4 += _diff3
	_dir5 += _diff4
	
	_x1 += 10*dcos(_dir1)
	_y1 -= 10*dsin(_dir1)
	_x2 += 10*dcos(_dir2)
	_y2 -= 10*dsin(_dir2)
	_x3 += 10*dcos(_dir4)
	_y3 -= 10*dsin(_dir4)
	_x4 += 10*dcos(_dir5)
	_y4 -= 10*dsin(_dir5)

    var _dxA = _x2 - _x1;
    var _dyA = _y2 - _y1;
    var _dxB = _x4 - _x3;
    var _dyB = _y4 - _y3;

    var _o1 = triangle_orientation(_x1,_y1,_x2,_y2,_x3,_y3);
    var _o2 = triangle_orientation(_x1,_y1,_x2,_y2,_x4,_y4);
    var _o3 = triangle_orientation(_x3,_y3,_x4,_y4,_x1,_y1);
    var _o4 = triangle_orientation(_x3,_y3,_x4,_y4,_x2,_y2);

    var _hits = [];

    // Proper crossing
    if (_o1 != _o2 and _o3 != _o4) {
        var _den = (_x1 - _x2) * (_y3 - _y4) - (_y1 - _y2) * (_x3 - _x4);
        if (abs(_den) < EPSILON) return _hits;

        var _tA = ((_x1 - _x3) * (_y3 - _y4) - (_y1 - _y3) * (_x3 - _x4)) / _den;
        var _px = _x1 + _tA * (_x2 - _x1);
        var _py = _y1 + _tA * (_y2 - _y1);

        var _lenB = point_distance(_x3,_y3,_x4,_y4);
        var _tB = (_lenB > EPSILON) ? point_distance(_x3,_y3,_px,_py) / _lenB : 0;

        add_unique_hit(_hits, _px, _py, _tA, _a, _b, 0);
        return _hits;
    }

    // Collinear case
    if (_o1 == 0 and _o2 == 0 and _o3 == 0 and _o4 == 0) {
        var _lenA2 = _dxA*_dxA + _dyA*_dyA;
        var _lenB2 = _dxB*_dxB + _dyB*_dyB;
        if (_lenA2 < EPSILON or _lenB2 < EPSILON) return _hits;

        var tA0 = ((_x3 - _x1) * _dxA + (_y3 - _y1) * _dyA) / _lenA2;
        var tA1 = ((_x4 - _x1) * _dxA + (_y4 - _y1) * _dyA) / _lenA2;

        var t0 = max(0, min(tA0, tA1));
        var t1 = min(1, max(tA0, tA1));

        if (t1 < t0 - EPSILON) return _hits;

        var _px0 = _x1 + _dxA * t0;
        var _py0 = _y1 + _dyA * t0;
        var _px1 = _x1 + _dxA * t1;
        var _py1 = _y1 + _dyA * t1;

        var _lenB = sqrt(_lenB2);
        var _tB0 = point_distance(_x3,_y3,_px0,_py0) / _lenB;
        var _tB1 = point_distance(_x3,_y3,_px1,_py1) / _lenB;

        if (point_distance(_px0,_py0,_px1,_py1) <= EPSILON) {
            add_unique_hit(_hits, _px0, _py0, t0, _a, _b, 2);
        } else {
            add_unique_hit(_hits, _px0, _py0, t0, _a, _b, 1);
            add_unique_hit(_hits, _px1, _py1, t1, _a, _b, 1);
        }

        return _hits;
    }

    // Endpoint touch / T-junction
    if (_o1 == 0 and point_on_segment(_x3,_y3,_x1,_y1,_x2,_y2)) {
        add_unique_hit(_hits, _x3, _y3,
            point_distance(_x1,_y1,_x3,_y3) / max(EPSILON, point_distance(_x1,_y1,_x2,_y2)),
            _a, _b, 2);
    }
    if (_o2 == 0 and point_on_segment(_x4,_y4,_x1,_y1,_x2,_y2)) {
        add_unique_hit(_hits, _x4, _y4,
            point_distance(_x1,_y1,_x4,_y4) / max(EPSILON, point_distance(_x1,_y1,_x2,_y2)),
            _a, _b, 2);
    }

    return _hits;
}

function collect_intersections(_polyA, _polyB, _diff=false) {
    var raw_hits = [];
    
    // Collect all raw intersections
    var _a = _polyA;
    repeat (MAX_LOOP_COUNT) {
        var _b = _polyB;
        repeat (MAX_LOOP_COUNT) {
            var hits = segment_intersection(_a, _b);
            for (var i = 0; i < array_length(hits); i++) {
                var h = hits[i];
                // For difference, skip collinear overlaps (kind=1)
                if (_diff && h[5] == 1) continue;
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

function apply_intersections(_intersections, _diff = false) {
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
            insert_node(bx, nb, _diff);
        }
    }

    ds_map_destroy(edge_map);
}

function insert_node(_start, _node, _diff = false) {
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

function sample_on_edge(_node, _forward, _dist) {
    var _x1 = _forward ? _node.x : _node.prev.x;
    var _y1 = _forward ? _node.y : _node.prev.y;
    var _x2 = _forward ? _node.next.x : _node.x;
    var _y2 = _forward ? _node.next.y : _node.y;

    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _len = sqrt(_dx*_dx + _dy*_dy);
    if (_len < _dist/10) return [_node.x, _node.y];

    _dx /= _len;
    _dy /= _len;

    var _s = _forward ? _dist : -_dist;
    return [_node.x + _dx * _s, _node.y + _dy * _s];
}

function mark_entry_exit(_poly, _other, _is_subject, _diff = false) {
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
            // Get edge vectors at the intersection
            var ax = _cur.next.x - _cur.x;
            var ay = _cur.next.y - _cur.y;
            var bx = _cur.neighbor.next.x - _cur.neighbor.x;
            var by = _cur.neighbor.next.y - _cur.neighbor.y;
            
            // 2D cross product (ax*by - ay*bx)
            var cross = ax * by - ay * bx;
            
            // For difference: on subject, entry if cross > 0; on hole, entry if cross < 0.
            // (This assumes subject CCW, hole CW; adjust signs if your winding is reversed.)
            if (_diff) {
                if (_is_subject) {
                    _cur.entry = (cross > -EPSILON);
                } else {
                    _cur.entry = (cross < EPSILON);
                }
            } else {
                // Union: entry if cross > 0
                _cur.entry = (cross > EPSILON);
            }
            
            _cur.crossing = true;  // All clustered hits are proper crossings or touches that matter
            
            //show_debug_message("Node uid=" + string(_cur.uid) + " cross=" + string_format(cross,2,4) + " entry=" + string(_cur.entry) + " is_subject=" + string(_is_subject));
        }
        _cur = _cur.next;
        if (_cur == _start) break;
    }
}

function build_resulting_polygon(_poly, _diff=false, _flip_enabled=false) {
    var _result = [];
    var _cur = _poly;

    repeat (MAX_LOOP_COUNT) {
        if (_cur.intersect and !_cur.visited and _cur.crossing and _cur.entry and _cur.kind != 1) {
			//show_debug_message("Starting new component at node uid=" + string(_cur.uid) + " pos=(" + string(_cur.x) + "," + string(_cur.y) + ")");
							   
            var _out = [];
            var _start = _cur;
			var _flip = _diff

            repeat (MAX_LOOP_COUNT) {
                if (_cur.visited) break;
				
				if (!_cur.intersect or _cur.crossing) {
                    array_push(_out, _cur.x, _cur.y);
					//show_debug_message("    Added point (" + string(_cur.x) + "," + string(_cur.y) + ")");
                }

                _cur.visited = true;

                if (_cur.intersect and _cur.kind != 1) {
					_cur = _cur.neighbor;
                    _cur.visited = true;
					//show_debug_message("    Switched to neighbor uid=" + string(_cur.uid));
					
					if (_flip_enabled){
						_flip = !_flip
					}
				}

                _cur = (!_flip ? _cur.prev : _cur.next);

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
		log_linked_list(_A, "Subject A");
		log_linked_list(_B, "Subject B");

	    mark_entry_exit(_A, _B, true);
		mark_entry_exit(_B, _A, true);
	
		_result = array_concat(build_resulting_polygon(_A), build_resulting_polygon(_B))
	}
	
	return _result
}

function polygon_difference_by_greiner_hormann(_poly_arr, _hole_arr){
	if (array_length(_poly_arr) < 6 or array_length(_hole_arr) < 6) {
        return [_poly_arr];
    }
	
    var _A = polygon_to_linked_node_list(_poly_arr);
    var _H = polygon_to_linked_node_list(_hole_arr);

	var _ints = collect_intersections(_A, _H, true);
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
		apply_intersections(_ints, true);
		log_linked_list(_A, "Subject");
		log_linked_list(_H, "Hole");

		mark_entry_exit(_A, _H, true,  true);   // A is subject
		mark_entry_exit(_H, _A, false, true);   // H is clip
		
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

	var _ints = collect_intersections(_A, _C, true);
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
		apply_intersections(_ints, true);
		log_linked_list(_A, "Subject");
		log_linked_list(_C, "Cut");

		mark_entry_exit(_A, _C, true,  true);   // A is subject
		mark_entry_exit(_C, _A, false, true);   // C is cut
		
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
    var _result = [];
	
	var _length = array_length(_poly)
    for (var _i = 0; _i < _length; _i += 2) {
        var _j = (_i + 2)%_length;

        if (point_distance(_poly[_i],_poly[_i + 1],_poly[_j],_poly[_j + 1]) > EPSILON) {
            array_push(_result, _poly[_i], _poly[_i + 1]);
        }
    }

    return _result;
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
	
	for (var _i = 0; _i < _length; _i++) {
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
						
			            _j--;
						_length--;
						
						break
					}
				}
			}
	    }
	}
	var _result = multi_polygon_difference_by_greiner_hormann(_poly_specific_holes, _polys_copy) //TODO: Make it so difference doesn't consider collinear edges as intersection
	_poly_specific_holes = _result[0]
	var _hole_specific_cuts = _result[1]
	
	return [_poly_specific_holes, _hole_specific_cuts]
}

function multi_polygon_difference_by_greiner_hormann(_polys, _holes, _poly_merge_flags=undefined){
	var _new_holes = []
	
	var _length = array_length(_holes)
	for (var h = 0; h < _length; h++) {
	    var hole = ensure_winding(_holes[h], true);
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
	    var _cut = ensure_winding(_cuts[h], true);
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
			//_poly[_j] = floor(_poly[_j]) //then delete any remaining decimal numbers and operate
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
	
	_result = multi_polygon_difference_by_greiner_hormann(_solids, _holes, _solid_merge_flags) //TODO: Make it like intersection so we can array_concat results always
	_solid_merge_flags = _result[2]
	_holes = _result[1]
	_solids = _result[0]
	
	_result = multi_polygon_intersection_by_greiner_hormann(_solids, _hole_specific_cuts, _solid_merge_flags)
	_solid_merge_flags = array_concat(_solid_merge_flags, _result[1])
	_solids = array_concat(_solids, _result[0])
	
	_result = multi_polygon_difference_by_greiner_hormann(_solids, _cut_specific_holes, _solid_merge_flags)
	_solid_merge_flags = _result[2]
	_holes = array_concat(_holes, _result[1])
	_solids = _result[0]
	
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
