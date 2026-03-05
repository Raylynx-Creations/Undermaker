/// @description Variable declaration

width = 565
height = 130

//(The origin of the box is in the middle bottom)
x = 320
y = 390

resize_speed = 20
movement_speed = 10
rotation_speed = 5

//--------------------------------------------------------------------

box_size = {x: 565, y: 130}
box_position = {x: 320, y: 390}
box_rotation = 0
box_center_offset = {x: 0, y: -5 - round(height)/2} //Offset to move the origin of the box for the rotation of it

//Data for the collision of the box with player
box_collision_updated = false //Flag to avoid repeating collision logic more than once
can_collide = true //You can set the box to not collide at all if you want

/*
Definition of the polygon points for the box
The way points are defined in this struct is that defined variable sets the points to use for your custom box shape
the inside, outside and direction are automatically calculated to fit the defined points shape
in case the defined points are empty (like now), then 4 automatic points are put in inside, outside and direction variables

Points are stored in the arrays like this: [x1, y1, x2, y2, x3, y3, ..., xn, yn], you don't set structs, just put the numbers in that order, use battle_set_box_polygon_points() to set the points with that order.
*/
box_polygon_points = {
	defined: [], //Use the battle_set_box_polygon_points() to set the points for your own polygonal box, if not defined, the 4 corners of the rectangular box are used for the box drawing
	inside: [], //Don't touch the rest of the variables in this struct
	outside: [],
	direction: []
}
box_background_color = c_black

/*
Method of the box that determinates how should if it should push the player out of the collision given certain parameters.
The collisions of the box's walls are made of lines that are checked if the player is colliding with them.
Since it's a line, some special conditions are made to determinate how should it and when should it push out of the collision.
You see those conditions in the obj_platform, since this is a box, it's always meant to collide, so some arguments are not really used.

INTEGER _id ------------------> ID of the player instance that is colliding.
REAL _push_direction ---------> Direction in degrees in which the player is going to be pushed.
BOOL _counter_clockwise_push -> (This argument is not used for this method, but it's used in obj_platform's method) Tells if the direction in which is being pushed was calculated doing a 90° counter-clockwise rotation, useful for determinating the normal angle of the line collision.

RETURNS -> ARRAY[BOOL, REAL] --The BOOL tells if it should push out of the collision or not, the REAL indicates in what direction to push, overriding the _push_direction given (normally you return the same number as the _push_direction, but since there's a grip mechanic for the blue soul, it can be another direction).
*/
player_collision_function = function(_id, _push_direction, _counter_clockwise_push){
	//If the box cannot collide with the player, we do nothing.
	if (!can_collide){
		return [false, 0] //Return false as first element to prevent collision being executed, the second element doesn't matter if the first one is false.
	}
	
	var _grip = _push_direction //Grip mechanic, usually is the same direction as _push_direction unless stated otherwise.
	
	//The grip mechanic only applies to the gravity soul, no changes are made if it's not this soul mode.
	if (_id.mode == SOUL_MODE.GRAVITY){
		var _offset_to_grip = abs(_id.gravity_data.allowed_angle_range_to.grip)
		var _base_angle_to_jump = 90 + 90*_id.gravity_data.direction
		if (abs(angle_difference(_push_direction, _base_angle_to_jump)) <= _offset_to_grip){
			_grip = 90*_id.gravity_data.direction + 90
		}
	}
	
	if (box_collision_updated){
		return [true, _grip]
	}
	box_collision_updated = true
	
	if (_id.mode == SOUL_MODE.GRAVITY){
		with (_id.gravity_data){
			var _gravity = 2*jump.max_height/power(jump.duration, 2)
			
			var _offset_to_jump = abs(allowed_angle_range_to.jump)
			var _offset_to_bonk = abs(allowed_angle_range_to.bonk)
			var _base_angle_to_jump = 90 + 90*direction
			var _base_angle_to_bonk = 270 + 90*direction
			
			var _speed = point_distance(0, 0, _id.move_x, _id.move_y)
			var _speed_angle = point_direction(0, 0, _id.move_x, _id.move_y)
			var _reflected_angle = _push_direction - angle_difference(_speed_angle + 180, _push_direction)
			
			switch (direction){
				case GRAVITY_SOUL.DOWN: case GRAVITY_SOUL.UP:{
					if (abs(angle_difference(_push_direction, _base_angle_to_jump)) <= _offset_to_jump){
						if (orange_mode or (get_up_button() and direction == GRAVITY_SOUL.DOWN) or (get_down_button() and direction == GRAVITY_SOUL.UP)){
							jump.speed = _gravity*jump.duration
						}else{
							jump.speed = -1
						}
						
						_id.conveyor_push.x /= 1.1
						_id.conveyor_push.y /= 1.1
						
						if (abs(_id.conveyor_push.x) <= 0.1){
							_id.conveyor_push.x = 0
						}
						if (abs(_id.conveyor_push.y) <= 0.1){
							_id.conveyor_push.y = 0
						}
					
						if (slam){
							audio_play_sound(snd_player_slam, 0, false)
							
							slam = false
						}
					}else if (abs(angle_difference(_push_direction, _base_angle_to_bonk)) <= _offset_to_bonk){
						if (orange_mode){
							jump.speed = -_speed*dsin(_reflected_angle)/(direction - 1) + _gravity/2
							movement.speed = clamp(_speed*dcos(_reflected_angle), -_id.movement_speed, _id.movement_speed)
						}else{
							jump.speed = min(jump.speed*abs(angle_difference(_push_direction, _base_angle_to_bonk))/90, jump.speed)
						}
					}else{ //Walls
						_id.extra_horizontal_movement.multiplier *= -1
						movement.speed -= movement.speed*abs(dcos(_push_direction))
						_id.conveyor_push.x -= _id.conveyor_push.x*abs(dcos(_push_direction))
						_id.conveyor_push.y -= _id.conveyor_push.y*abs(dsin(_push_direction))
					}
				break}
				default:{ //GRAVITY_SOUL.RIGHT, GRAVITY_SOUL.LEFT
					if (abs(angle_difference(_push_direction, _base_angle_to_jump)) <= _offset_to_jump){
						if (orange_mode or (get_left_button() and direction == GRAVITY_SOUL.RIGHT) or (get_right_button() and direction == GRAVITY_SOUL.LEFT)){
							jump.speed = _gravity*jump.duration
						}else{
							jump.speed = -1
						}
						
						_id.conveyor_push.x /= 1.1
						_id.conveyor_push.y /= 1.1
						
						if (abs(_id.conveyor_push.x) <= 0.1){
							_id.conveyor_push.x = 0
						}
						if (abs(_id.conveyor_push.y) <= 0.1){
							_id.conveyor_push.y = 0
						}
					
						if (slam){
							audio_play_sound(snd_player_slam, 0, false)
							
							slam = false
						}
					}else if (abs(angle_difference(_push_direction, _base_angle_to_bonk)) <= _offset_to_bonk){
						if (orange_mode){
							_reflected_angle -= 90
						
							jump.speed = -_speed*dsin(_reflected_angle)/(direction - 2) + _gravity/2
							movement.speed = clamp(-_speed*dcos(_reflected_angle), -_id.movement_speed, _id.movement_speed)
						}else{
							jump.speed = min(jump.speed*abs(angle_difference(_push_direction, _base_angle_to_bonk))/90, jump.speed)
						}
					}else{ //Walls
						_id.extra_horizontal_movement.multiplier *= -1
						movement.speed -= movement.speed*dcos(_push_direction)
						_id.conveyor_push.x -= _id.conveyor_push.x*abs(dcos(_push_direction))
						_id.conveyor_push.y -= _id.conveyor_push.y*abs(dsin(_push_direction))
					}
				break}
			}
		}
	}
	
	return [true, _grip]
}
