function general_line_collision_handler(_id, _line_points, _line_direction, _line_id, _counter_clockwise_push, _colliding_instances, _instance_directions, _collision_amount, _before_push_function=undefined){
	var _id_index = -1
	
	for (var _i=0; _i < _collision_amount; _i++){
		var _data = _colliding_instances[_i]
		if (typeof(_data) == "struct" and _data.object_id == id and _data.line_id == _line_id){
			_id_index = _i
			
			break
		}
	}
	
	if (collision_line(_line_points[0], _line_points[1], _line_points[2], _line_points[3], _id, false, false)){
		var _collide = true
		if (_id_index >= 0){
			var _direction = _instance_directions[_id_index]
			
			if (!is_undefined(_before_push_function)){
				var _data = _before_push_function(_id, _direction, _counter_clockwise_push)
				_collide = _data[0]
				_direction = _data[1]
			}
			
			if (_collide){
				_id.x += dcos(_direction)
				_id.y -= dsin(_direction)
			}else{
				array_delete(_colliding_instances, _id_index, 1)
				array_delete(_instance_directions, _id_index, 1)
				_collision_amount--
			}
			
			return _collision_amount
		}
		
		var _direction = _line_direction - 90 + 180*_counter_clockwise_push
		
		if (!is_undefined(_before_push_function)){
			var _data = _before_push_function(_id, _direction, _counter_clockwise_push)
			_collide = _data[0]
			_direction = _data[1]
		}
		
		if (_collide){
			_id.x += dcos(_direction)
			_id.y -= dsin(_direction)
		
			if (collision_line(_line_points[0], _line_points[1], _line_points[2], _line_points[3], _id, false, false)){
				array_push(_colliding_instances, {object_id: id, line_id: _line_id, points: [_line_points[0], _line_points[1], _line_points[2], _line_points[3]]})
				array_push(_instance_directions, _direction)
				_collision_amount++
			}
		}
	}else if (_id_index >= 0){
		array_delete(_colliding_instances, _id_index, 1)
		array_delete(_instance_directions, _id_index, 1)
		_collision_amount--
	}
	
	return _collision_amount
}

function general_object_collision_handler(_id, _colliding_instances, _instance_directions, _collision_amount, _handle_collision_function){
	var _id_index = -1
	
	for (var _i=0; _i < _collision_amount; _i++){
		var _instance_id = _colliding_instances[_i]
		if (typeof(_instance_id) == "ref" and _instance_id == id){
			_id_index = _i
			
			break
		}
	}
	
	if (place_meeting(x, y, _id)){
		if (_id_index >= 0){
			var _direction = _instance_directions[_id_index]
			
			_id.x += dcos(_direction)
			_id.y -= dsin(_direction)
			
			return _collision_amount
		}
		
		var _direction = _handle_collision_function(_id)
		
		if (place_meeting(x, y, _id)){
			array_push(_colliding_instances, id)
			array_push(_instance_directions, _direction)
			_collision_amount++
		}
	}else if (_id_index >= 0){
		array_delete(_colliding_instances, _id_index, 1)
		array_delete(_instance_directions, _id_index, 1)
		_collision_amount--
	}
	
	return _collision_amount
}

function general_entity_update(_pusher=undefined){
	var _colliding_instances = []
	var _instance_directions = []
	var _collision_amount = 0
	var _length_ids = array_length(collision_ids)
	var _id = id
	var _current_x = x
	var _current_y = y
	
	do{
		with (obj_collision){
			var _can_collide = false
			
			for (var _i=0; _i < _length_ids; _i++){
				if (_id.collision_ids[_i] == collision_id){
					_can_collide = true
			
					break
				}
			}
			
			if (_can_collide){
				_collision_amount = general_object_collision_handler(_id, _colliding_instances, _instance_directions, _collision_amount, handle_collision_object_and_interaction_collision)
			}
		}
		
		with (obj_interaction){
			if (can_entities_collide){
				_collision_amount = general_object_collision_handler(_id, _colliding_instances, _instance_directions, _collision_amount, handle_collision_object_and_interaction_collision)
			}
		}
		
		if (!can_overlap){
			with (obj_entity){
				if (id != _id and id != _pusher and (!can_entities_push or !_id.can_push_entities) and !can_overlap){
					_collision_amount = general_object_collision_handler(_id, _colliding_instances, _instance_directions, _collision_amount, handle_entity_collision)
				}
			}
		}
		
		if (_current_x == x and _current_y == y){
			break
		}else{
			_current_x = x
			_current_y = y
		}
	}until (_collision_amount == 0)
	
	if (can_push_entities){
		_colliding_instances = []
		_instance_directions = []
		_collision_amount = 0
		
		with (obj_entity){
			if (id != _id and id != _pusher and can_entities_push and !can_overlap and place_meeting(x, y, _id)){
				push_entity(_id)
				
				if (!_id.can_overlap and place_meeting(x, y, _id)){
					do{
						_collision_amount = general_object_collision_handler(_id, _colliding_instances, _instance_directions, _collision_amount, handle_entity_collision)
					}until (_collision_amount == 0)
				}
			}
		}
	}
}

function push_entity(_pusher){
	//Some information needed for the obj_entitys.
	var _pusher_collision_center_x = _pusher.x + ((sprite_get_bbox_right(_pusher.sprite_index) + 1 + sprite_get_bbox_left(_pusher.sprite_index))/2 - sprite_get_xoffset(_pusher.sprite_index))*_pusher.image_xscale
	var _pusher_collision_center_y = _pusher.y + ((sprite_get_bbox_bottom(_pusher.sprite_index) + 1 + sprite_get_bbox_top(_pusher.sprite_index))/2 - sprite_get_yoffset(_pusher.sprite_index))*_pusher.image_yscale
	var _pusher_collision_width = (sprite_get_bbox_right(_pusher.sprite_index) + 1 - sprite_get_bbox_left(_pusher.sprite_index))*abs(_pusher.image_xscale)
	var _pusher_collision_height = (sprite_get_bbox_bottom(_pusher.sprite_index) + 1 - sprite_get_bbox_top(_pusher.sprite_index))*abs(_pusher.image_yscale)
	
	//Get information about the collision of the obj_entity.
	var _collision_center_x = x + ((sprite_get_bbox_right(sprite_index) + 1 + sprite_get_bbox_left(sprite_index))/2 - sprite_get_xoffset(sprite_index))*image_xscale
	var _collision_center_y = y + ((sprite_get_bbox_bottom(sprite_index) + 1 + sprite_get_bbox_top(sprite_index))/2 - sprite_get_yoffset(sprite_index))*image_yscale
	var _collision_width = (sprite_get_bbox_right(sprite_index) + 1 - sprite_get_bbox_left(sprite_index))*abs(image_xscale)
	var _collision_height = (sprite_get_bbox_bottom(sprite_index) + 1 - sprite_get_bbox_top(sprite_index))*abs(image_yscale)
	
	if (round_collision_behavior){
		var _direction = point_direction(_pusher_collision_center_x, _pusher_collision_center_y, _collision_center_x, _collision_center_y)
		
		while (place_meeting(x, y, _pusher)){
			x += dcos(_direction)
			y -= dsin(_direction)
		}
	}else{
		var _pusher_moved_dist = max(abs(_pusher.xprevious - _pusher.x), abs(_pusher.yprevious - _pusher.y))
		var _pusher_left_collision = _pusher_collision_center_x - _pusher_collision_width/2
		var _pusher_top_collision = _pusher_collision_center_y - _pusher_collision_height/2
		
		if (_pusher.round_collision_behavior){
			if (_collision_center_x >= _pusher_left_collision and _collision_center_x <= _pusher_left_collision + _pusher_collision_width){
				if (!place_meeting(x, y + _pusher_moved_dist, _pusher)){ //Down pushing
					y += _pusher_collision_center_y + _pusher_collision_height/2 - _collision_center_y + _collision_height/2
				}else{ //Up pushing
					y -= _collision_center_y + _collision_height/2 - _pusher_collision_center_y + _pusher_collision_height/2
				}
			}else if(_collision_center_y >= _pusher_top_collision and _collision_center_y <= _pusher_top_collision + _pusher_collision_height){
				if (!place_meeting(x + _pusher_moved_dist, y, _pusher)){ //Right pushing
					x += _pusher_collision_center_x + _pusher_collision_width/2 - _collision_center_x + _collision_width/2
				}else{ //Left pushing
					x -= _collision_center_x + _collision_width/2 - _pusher_collision_center_x + _pusher_collision_width/2
				}
			}else{
				var _direction = point_direction(_pusher_collision_center_x, _pusher_collision_center_y, _collision_center_x, _collision_center_y)
				
				while (place_meeting(x, y, _pusher)){
					x += dcos(_direction)
					y -= dsin(_direction)
				}
			}
		}else{
			//These here are for determinating to which cardinal direction it should move.
			if (!place_meeting(x + _pusher_moved_dist, y, _pusher)){ //Right pushing
				x += _pusher_collision_center_x + _pusher_collision_width/2 - _collision_center_x + _collision_width/2
			}else if (!place_meeting(x - _pusher_moved_dist, y, _pusher)){ //Left pushing
				x -= _collision_center_x + _collision_width/2 - _pusher_collision_center_x + _pusher_collision_width/2
			}else if (!place_meeting(x, y + _pusher_moved_dist, _pusher)){ //Down pushing
				y += _pusher_collision_center_y + _pusher_collision_height/2 - _collision_center_y + _collision_height/2
			}else{ //Up pushing
				y -= _collision_center_y + _collision_height/2 - _pusher_collision_center_y + _pusher_collision_height/2
			}
		}
	}
	
	general_entity_update(_pusher) //Update the entity so it checks for collision in general of the entity, pass the _pusher id so it avoids taking into account the one that pushed it, as that one will do its own thing after this is done.
}

function handle_collision_object_and_interaction_collision(_id){
	var _angle = image_angle
	
	if (_angle < 0){
		_angle = 359 - (abs(_angle) - 1)%360
	}
	
	var _id_center_x = _id.xprevious + ((sprite_get_bbox_right(_id.sprite_index) + 1 + sprite_get_bbox_left(_id.sprite_index))/2 - sprite_get_xoffset(_id.sprite_index))*_id.image_xscale
	var _id_center_y = _id.yprevious + ((sprite_get_bbox_bottom(_id.sprite_index) + 1 + sprite_get_bbox_top(_id.sprite_index))/2 - sprite_get_yoffset(_id.sprite_index))*_id.image_yscale
	
	var _center_x = x + 10*image_xscale*dcos(_angle) + 10*image_yscale*dsin(_angle)
	var _center_y = y + 10*image_yscale*dcos(_angle) - 10*image_xscale*dsin(_angle)
	var _direction = 0
	
	if (_angle%90 == 0){
		var _id_width = (sprite_get_bbox_right(_id.sprite_index) + 1 - sprite_get_bbox_left(_id.sprite_index))*abs(_id.image_xscale)
		var _id_height = (sprite_get_bbox_bottom(_id.sprite_index) + 1 - sprite_get_bbox_top(_id.sprite_index))*abs(_id.image_yscale)
		var _collision_width = abs(20*image_xscale*dcos(_angle) + 20*image_yscale*dsin(_angle))
		var _collision_height = abs(20*image_yscale*dcos(_angle) + 20*image_xscale*dsin(_angle))
		
		//Checking the closest direction to push out.
		//In theory, when 2 rectangles collide, the distance will yield always negative values, just in case goes positive the absolute is used.
		var _left_distance = abs(_id_center_x - _id_width/2 - _center_x - _collision_width/2)
		var _right_distance = abs(_center_x - _collision_width/2 - _id_center_x - _id_width/2)
		var _up_distance = abs(_id_center_y - _id_height/2 - _center_y - _collision_height/2)
		var _down_distance = abs(_center_y - _collision_height/2 - _id_center_y - _id_height/2)
		var _min_distance = min(_left_distance, _right_distance, _down_distance, _up_distance) //This one stores the closest distance to 0 so it compares with the distances.
		
		if (_left_distance == _min_distance){ //Right pushing
			//_direction = 0 //It is already 0.
			_id.x++
		}else if (_right_distance == _min_distance){ //Left pushing
			_direction = 180
			_id.x--
		}else if (_down_distance == _min_distance){ //Down pushing
			_direction = 90
			_id.y--
		}else{ //Up pushing
			_direction = 270
			_id.y++
		}
	}else{
		_angle = _angle%180
		var _cos = dcos(_angle)
		var _sin = dsin(_angle)
		var _point_x = _center_x
		var _point_y = _center_y
		var _point_orientation = 0
		var _point_x2 = _center_x
		var _point_y2 = _center_y
		var _point_orientation2 = 0
		var _points_collided = 0
		var _image_xscale = abs(image_xscale)
		var _image_yscale = abs(image_yscale)
		
		if ((_id_center_y >= _center_y and ((_angle < 90 and _id_center_x < _center_x + 10*(_image_yscale*_sin - _image_xscale*_cos)) or (_angle > 90 and _id_center_x < _center_x - 10*(_image_xscale*_cos + _image_yscale*_sin)))) or (_id_center_y < _center_y and ((_angle < 90 and _id_center_x < _center_x + 10*(_image_xscale*_cos - _image_yscale*_sin)) or (_angle > 90 and _id_center_x < _center_x + 10*(_image_xscale*_cos + _image_yscale*_sin))))){
			_point_orientation = 180
			
			if (_angle < 90){
				_point_x -= 10*(_image_xscale*_cos + _image_yscale*_sin)
				_point_y += 10*(_image_xscale*_sin - _image_yscale*_cos)
			}else{
				_point_x += 10*(_image_xscale*_cos - _image_yscale*_sin)
				_point_y -= 10*(_image_yscale*_cos + _image_xscale*_sin)
			}
		}else{
			//_point_orientation = 0 //It is already 0 XD.
			
			if (_angle < 90){
				_point_x += 10*(_image_xscale*_cos + _image_yscale*_sin)
				_point_y += 10*(_image_yscale*_cos - _image_xscale*_sin)
			}else{
				_point_x += 10*(_image_yscale*_sin - _image_xscale*_cos)
				_point_y += 10*(_image_yscale*_cos + _image_xscale*_sin)
			}
		}
		
		if ((_id_center_x >= _center_x and ((_angle < 90 and _id_center_y < _center_y + 10*(_image_yscale*_cos - _image_xscale*_sin)) or (_angle > 90 and _id_center_y < _center_y + 10*(_image_yscale*_cos + _image_xscale*_sin)))) or (_id_center_x < _center_x and ((_angle < 90 and _id_center_y < _center_y + 10*(_image_xscale*_sin - _image_yscale*_cos)) or (_angle > 90 and _id_center_y < _center_y - 10*(_image_yscale*_cos + _image_xscale*_sin))))){
			_point_orientation2 = 90
			
			if (_angle < 90){
				_point_x2 += 10*(_image_xscale*_cos - _image_yscale*_sin)
				_point_y2 -= 10*(_image_yscale*_cos + _image_xscale*_sin)
			}else{
				_point_x2 += 10*(_image_xscale*_cos + _image_yscale*_sin)
				_point_y2 += 10*(_image_yscale*_cos - _image_xscale*_sin)
			}
		}else{
			_point_orientation2 = 270
			
			if (_angle < 90){
				_point_x2 += 10*(_image_yscale*_sin - _image_xscale*_cos)
				_point_y2 += 10*(_image_yscale*_cos + _image_xscale*_sin)
			}else{
				_point_x2 -= 10*(_image_xscale*_cos + _image_yscale*_sin)
				_point_y2 += 10*(_image_xscale*_sin - _image_yscale*_cos)
			}
		}
		
		if (!_id.round_collision_behavior){
			if (collision_point(_point_x, _point_y, _id, true, true)){
				var _offset_x = _center_x - (xprevious + 10*image_xscale*dcos(previous_angle_of_this_instance) + 10*image_yscale*dsin(previous_angle_of_this_instance))
				var _distance = abs(_id.xprevious - _id.x) + abs(xprevious - x + _offset_x) + abs(_offset_x) + 1
				_points_collided++
				
				if (_point_orientation == 180 and !collision_point(_point_x + _distance, _point_y, _id, true, true)){ //Left pushing
					_direction = 180
				}else if (_point_orientation == 0 and !collision_point(_point_x - _distance, _point_y, _id, true, true)){ //Right pushing
					//_direction = 0 //It is already 0.
					//Although in here nothing is done, it's essentially the same as if I placed the condition for the last case.
				}else{ //Invalidate the point pushing.
					_points_collided++
				}
			}
			
			if (_points_collided <= 1 and collision_point(_point_x2, _point_y2, _id, true, true)){
				var _offset_y = _center_y - (yprevious + 10*image_yscale*dcos(previous_angle_of_this_instance) - 10*image_xscale*dsin(previous_angle_of_this_instance))
				var _distance = abs(_id.yprevious - _id.y) + abs(yprevious - y + _offset_y) + abs(_offset_y) + 1
				_points_collided++
				
				if (_point_orientation2 == 90 and !collision_point(_point_x2, _point_y2 + _distance, _id, true, true)){ //Up pushing
					_direction = 90
				}else if (_point_orientation2 == 270 and !collision_point(_point_x2, _point_y2 - _distance, _id, true, true)){ //Down pushing
					_direction = 270
				}else{ //Invalidate the point pushing.
					_points_collided++
				}
			}
		}
		
		if (_id.round_collision_behavior or _points_collided != 1){
			if (_point_orientation == 0 and _point_orientation2 == 270){
				_direction = 270
			}else{
				_direction = min(_point_orientation, _point_orientation2)
			}
			
			_direction += _angle%90
		}
		
		_id.x += dcos(_direction)
		_id.y -= dsin(_direction)
	}
	
	return _direction
}

function handle_entity_collision(_id){
	var _direction = 0
	
	var _collision_center_x = x + ((sprite_get_bbox_right(sprite_index) + 1 + sprite_get_bbox_left(sprite_index))/2 - sprite_get_xoffset(sprite_index))*image_xscale
	var _collision_center_y = y + ((sprite_get_bbox_bottom(sprite_index) + 1 + sprite_get_bbox_top(sprite_index))/2 - sprite_get_yoffset(sprite_index))*image_yscale
	var _collision_width = (sprite_get_bbox_right(sprite_index) + 1 - sprite_get_bbox_left(sprite_index))*abs(image_xscale)
	var _collision_height = (sprite_get_bbox_bottom(sprite_index) + 1 - sprite_get_bbox_top(sprite_index))*abs(image_yscale)
	
	var _id_width = (sprite_get_bbox_right(_id.sprite_index) + 1 - sprite_get_bbox_left(_id.sprite_index))*abs(_id.image_xscale)
	var _id_height = (sprite_get_bbox_bottom(_id.sprite_index) + 1 - sprite_get_bbox_top(_id.sprite_index))*abs(_id.image_yscale)
	var _id_center_x = _id.x + _id_width*sign(_id.image_xscale)/2 + (sprite_get_bbox_left(_id.sprite_index) - sprite_get_xoffset(_id.sprite_index))*_id.image_xscale
	var _id_center_y = _id.y + _id_height*sign(_id.image_yscale)/2 + (sprite_get_bbox_top(_id.sprite_index) - sprite_get_yoffset(_id.sprite_index))*_id.image_yscale
	
	if (round_collision_behavior){
		_direction = point_direction(_collision_center_x, _collision_center_y, _id_center_x, _id_center_y)
		_id.x += dcos(_direction)
		_id.y -= dsin(_direction)
	}else{
		var _left_collision = _collision_center_x - _collision_width/2
		var _top_collision = _collision_center_y - _collision_height/2
		
		if (_id.round_collision_behavior){
			if (_id_center_x >= _left_collision and _id_center_x <= _left_collision + _collision_width){
				if (_id_center_y <= _collision_center_y){ //Up pushing
					_direction = 90
					_id.y--
				}else{ //Down pushing
					_direction = 270
					_id.y++
				}
			}else if(_id_center_y >= _top_collision and _id_center_y <= _top_collision + _collision_height){
				if (_id_center_x <= _collision_center_x){ //Left pushing
					_direction = 180
					_id.x--
				}else{ //Right pushing
					//_direction = 0 //It is already 0.
					_id.x++
				}
			}else{
				_direction = point_direction(_collision_center_x, _collision_center_y, _id_center_x, _id_center_y)
				_id.x += dcos(_direction)
				_id.y -= dsin(_direction)
			}
		}else{
			//Checking the closest direction to push out.
			//In theory, when 2 rectangles collide, the distance will yield always negative values, just in case goes positive the absolute is used.
			var _left_distance = abs(_id_center_x - _id_width/2 - _collision_center_x - _collision_width/2)
			var _right_distance = abs(_collision_center_x - _collision_width/2 - _id_center_x - _id_width/2)
			var _up_distance = abs(_id_center_y - _id_height/2 - _collision_center_y - _collision_height/2)
			var _down_distance = abs(_collision_center_y - _collision_height/2 - _id_center_y - _id_height/2)
			var _min_distance = min(_left_distance, _right_distance, _down_distance, _up_distance) //This one stores the closest distance to 0 so it compares with the distances.
			
			if (_left_distance == _min_distance){ //Right pushing
				//_direction = 0 //It is already 0.
				_id.x++
			}else if (_right_distance == _min_distance){ //Left pushing
				_direction = 180
				_id.x--
			}else if (_down_distance == _min_distance){ //Down pushing
				_direction = 90
				_id.y--
			}else{ //Up pushing
				_direction = 270
				_id.y++
			}
		}
	}
	
	return _direction
}
