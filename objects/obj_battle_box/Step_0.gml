/// @description Arena resizing step and polygon points calculation

if (is_undefined(prev_depth) or prev_depth != depth or prev_type != type){
	prev_depth = depth
	prev_type = type
	
	battle_clear_box_line_collisions_cache()
}

//box_size is never a real number, only integer number, this is so we avoid precision problems with decimals.
box_size.x = round(box_size.x)
box_size.y = round(box_size.y)

//Get the angle difference in which the box has to rotate to.
var _angle_difference = angle_difference(box_rotation, image_angle)

//To avoid writting the full names, we use local variables named shorter for simplier use.
//Just remember these are the polygon data of the box.
var _defined_points = box_polygon_points.defined
var _default_points = box_polygon_points.default_points
var _inside_points = box_polygon_points.inside
var _outside_points = box_polygon_points.outside

//Variables that determinate what is updating from the box to do the corresponding point modification to it.
var _position_update = (x != box_position.x or y != box_position.y)
var _resize_update = (width != box_size.x or height != box_size.y)
var _angle_update = (_angle_difference != 0)
var _update_points = (array_length(_defined_points) == 0 and _resize_update)

//Depending on the angle difference, rotate the box based on the speed rotation to get to the desired angle.
//To set the angle, position and other properties of the box remember to use box functions in battle attacks and scripts.
//These variables hold the difference of some changes, specifically rotation and position for updating.
var _diff_angle = image_angle
if (_angle_difference > 0){
	image_angle += min(rotation_speed, _angle_difference)
}
if (_angle_difference < 0){
	image_angle += max(-rotation_speed, _angle_difference)
}
_diff_angle = angle_difference(image_angle, _diff_angle)

//Box resizes to get to the target size.
if (width > box_size.x){
	width = max(width - resize_speed, box_size.x)
}
if (width < box_size.x){
	width = min(width + resize_speed, box_size.x)
}

if (height > box_size.y){
	height = max(height - resize_speed, box_size.y)
}
if (height < box_size.y){
	height = min(height + resize_speed, box_size.y)
}

//Box moves to get to the target position.
var _diff_x = x
if (x > box_position.x){
	x = max(x - movement_speed, box_position.x)
}
if (x < box_position.x){
	x = min(x + movement_speed, box_position.x)
}
_diff_x = x - _diff_x

var _diff_y = y
if (y > box_position.y){
	y = max(y - movement_speed, box_position.y)
}
if (y < box_position.y){
	y = min(y + movement_speed, box_position.y)
}
_diff_y = y - _diff_y

//Update the box_origin position as long as it's not defined by the user using the battle_box_set_origin() function.
if (!box_origin.defined){
	box_origin.x = 0
	if (box_origin.polygon_defined){ //If it's a polygon defined box by the player, the origin is set to the position of the box instead.
		box_origin.y = 0
	}else{ //Otherwise the actual center of the rectangle box.
		box_origin.y = -5 - round(height)/2
	}
}

//If it's resizing, update the points by said property
if (_resize_update){
	battle_box_update_points_by_resize(id)
}

//If the box has changed size while undefined points have been set, changed rotation or redefined new points, we clear the data and recalculate everything.
if (box_polygon_points.update or _update_points){
	box_polygon_points.update = false //No more updates
	_position_update = false
	_angle_update = false
	
	battle_clear_box_line_collisions_cache()
	
	//Clear the points, since they are going to be recalculated.
	var _length = array_length(_outside_points)
	if (_length > 0){
		array_delete(_outside_points, 0, _length)
	}
	_length = array_length(_inside_points)
	if (_length > 0){
		array_delete(_inside_points, 0, _length)
	}
	
	//If there are points defined for a polygonal box, then we use those.
	//We assign them one by one to avoid referencing the array.
	//This is to copy the array basically since we'll do transformations to the points and we want to keep an original copy.
	_length = array_length(_defined_points)
	if (_length > 0){
		for (var _i = 0; _i < _length; _i++){
			_inside_points[_i] = _defined_points[_i]
		}
	}else{
		_length = array_length(_default_points)
		for (var _i = 0; _i < _length; _i++){
			_inside_points[_i] = _default_points[_i]
		}
	}
	
	//We define the origin in an absolute way.
	var _x = x + box_origin.x
	var _y = y + box_origin.y

	//We apply a rotation transformation to the points, these will define the inside of the box.
	for (var _i = 0; _i < _length; _i += 2){
		var _px = _inside_points[_i]
		var _py = _inside_points[_i+1]
	
		var _distance = point_distance(_x, _y, _px, _py)
		var _direction = point_direction(_x, _y, _px, _py) + image_angle
		_px = _x + _distance*dcos(_direction)
		_py = _y - _distance*dsin(_direction)
	
		_inside_points[_i] = _px
		_inside_points[_i+1] = _py
	}
	
	//With the points we calculate the triangles needed to fill the box.
	box_polygon_points.triangles = triangulate_polygon(_inside_points)
	
	//If there are at least 3 point, then we can calculate each corner and its directions
	if (_length >= 6){
		//For every single point its outside point which is the intersection of an offset of 5 to make a line which is the border of the box
		//We also calculate for each point the direction it goes to connect to the next point in the sucession.
		//We require the previous point's direction to make the intersection work.
		var _prev_direction = point_direction(_inside_points[_length-2], _inside_points[_length-1], _inside_points[0], _inside_points[1])
		for (var _i = 0; _i < _length; _i += 2) {
			//Get the point
			var _p1_x = _inside_points[_i]
			var _p1_y = _inside_points[_i+1]
			
			//Get its direction to the next point
			var _direction = point_direction(_p1_x, _p1_y, _inside_points[(_i + 2)%_length], _inside_points[(_i + 3)%_length])
			
			//Use the direction of the point to offset it by 5 pixels.
			var _p2_x = _p1_x + 5*dcos(_direction - 90)
			var _p2_y = _p1_y - 5*dsin(_direction - 90)
			
			//Use the previous direction of the previous point to offset it by 5 pixels.
			var _p_1_x = _p1_x + 5*dcos(_prev_direction - 90)
			var _p_1_y = _p1_y - 5*dsin(_prev_direction - 90)
			
			//Calculate the intersection of the lines defined by 2 points with its directions.
			var _intersection = intersection_of_lines(_p_1_x, _p_1_y, _prev_direction, _p2_x, _p2_y, _direction)
			var _p_intersection_x = _intersection[0]
			var _p_intersection_y = _intersection[1]
			
			//Update previous direction.
			_prev_direction = _direction
			
			//Add point and direction to its corresponding arrays.
		    array_push(_outside_points, _p_intersection_x, _p_intersection_y)
		}
	//Otherwise if there's only 2 points defined, then we define the outside points to draw the line.
	}else if (_length >= 4){
		var _p1_x = _inside_points[0]
		var _p1_y = _inside_points[1]
		var _p2_x = _inside_points[2]
		var _p2_y = _inside_points[3]
		
		var _direction = point_direction(_p1_x, _p1_y, _p2_x, _p2_y) - 90
		
		var _p3_x = _p1_x + 5*dcos(_direction)
		var _p3_y = _p1_y - 5*dsin(_direction)
		var _p4_x = _p2_x + 5*dcos(_direction)
		var _p4_y = _p2_y - 5*dsin(_direction)
		
		array_push(_outside_points, _p3_x, _p3_y, _p4_x, _p4_y)
	}
}

//These functions are better than recalculating the points again.
if (_position_update){
	battle_box_update_points_by_position(_diff_x, _diff_y, id)
}

if (_angle_update){
	battle_box_update_points_by_rotation(_diff_angle, id)
}
