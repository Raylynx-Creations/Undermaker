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
box_origin = {defined: false, polygon_defined: false, x: 0, y: -5 - round(height)/2} //Offset to move the origin of the box for the rotation of it

//Data for the collision of the box with player
box_collision_updated = false //Flag to avoid repeating collision logic more than once
can_collide = true //You can set the box to not collide at all if you want

/*
Definition of the polygon points for the box
The way points are defined in this struct is that defined variable sets the points to use for your custom box shape
the inside, outside and direction are automatically calculated to fit the defined points shape
in case the defined points are empty (like now), then 4 automatic points are put in inside, outside and direction variables

Triangles are calculated too to fill the box's insides, depending on the points given.
All this data is cached, in these variables, if the box changes data, we reschedule an update to recalculate the points positions.

Points are stored in the arrays like this: [x1, y1, x2, y2, x3, y3, ..., xn, yn], you don't set structs, just put the numbers in that order, use battle_set_box_polygon_points() to set the points with that order.
*/
box_polygon_points = {
	update: true, //Flag to determinate if it should update the data or not.
	defined: [], //Use the battle_set_box_polygon_points() to set the points for your own polygonal box, if not defined, the default points of a rectangular box are used for the box drawing
	default_points: [],
	inside: [], //Don't touch the rest of the variables in this struct
	outside: [],
	direction: [],
	triangles: [] //Holds the triangles for the drawing of the polygon for the filling.
}
box_fill_color = c_black
box_fill_alpha = 1

var _default_points = box_polygon_points.default_points
_default_points[0] = x - round(width)/2
_default_points[1] = y - 5
_default_points[2] = x + round(width)/2
_default_points[3] = y - 5
_default_points[4] = x + round(width)/2
_default_points[5] = y - round(height) - 5
_default_points[6] = x - round(width)/2
_default_points[7] = y - round(height) - 5

/*
Method of the box that determinates how should if it should push the player out of the collision given certain parameters.
The collisions of the box's walls are made of lines that are checked if the player is colliding with them.
Since it's a line, some special conditions are made to determinate how should it and when should it push out of the collision.
You see those conditions in the obj_platform, since this is a box, it's always meant to collide, so some arguments are not really used.

INTEGER _id ------------------> ID of the player (usually soul aka the obj_player_battle) instance that is colliding.
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
			//Set the grip angle depending on the direction, this is the angle the push of the collision is set so the player doesn't slide down ramps slightly tilted.
			//If the grip is in range it does set it paralel in the opposite direction the gravity is going, so down is a -90° push, then it is set to 90 degrees instead, and so for all directions.
			_grip = 90*_id.gravity_data.direction + 90
		}
	}
	
	//If it already did the collision checking, just return true on the collision with the _grip angle, since it's a collision meant to always be collided with.
	if (box_collision_updated){
		return [true, _grip]
	}
	box_collision_updated = true //Flag to know it already updated, in the begin step of the obj_battle_box is being reset.
	
	//Since the gravity soul is the one that constantly makes you go in one direction and has somewhat of physics to it, it has some specific behaviors when colliding in different angles of the walls.
	if (_id.mode == SOUL_MODE.GRAVITY){
		//All the data relating the gravity soul is in the obj_player_battle.gravity_data.
		with (_id.gravity_data){
			//Gravity constant calculated by the max_height the soul can reach with its jump and the time we want that to last in the air with maximum jump height.
			var _gravity = 2*jump.max_height/power(jump.duration, 2)
			
			//Angle threshold in which some stuff is allowed, to be precisse, angles of floor in which the gravity soul can jump and when it bonks reflecting the force back.
			var _offset_to_jump = abs(allowed_angle_range_to.jump)
			var _offset_to_bonk = abs(allowed_angle_range_to.bonk)
			var _base_angle_to_jump = 90 + 90*direction //Depending on orientation of soul the base angles for floor and ceiling are different.
			var _base_angle_to_bonk = 270 + 90*direction
			
			//Variables to get a line distance, its angle and reflected angle from the wall it's colliding from, for further use on conditions.
			var _speed = point_distance(0, 0, _id.move_x, _id.move_y)
			var _speed_angle = point_direction(0, 0, _id.move_x, _id.move_y)
			var _reflected_angle = _push_direction - angle_difference(_speed_angle + 180, _push_direction)
			
			//I only manage 4 directions of soul modes, so it's separated to angle x and y coordinates properly.
			//The logic on both of the cases is similar however, the only difference it's that the x and y assignments are swapped.
			switch (direction){
				case GRAVITY_SOUL.DOWN: case GRAVITY_SOUL.UP:{ //Vertical gravity.
					//This condition determinates if the collision is considered a floor by it's pushing angle.
					//Floor pushes you up to nullify the gravity, that's kinda how you stay in place, if rotated may have different effects depending of the Grip Settings of the player soul.
					if (abs(angle_difference(_push_direction, _base_angle_to_jump)) <= _offset_to_jump){ //Floor
						//If the player is pressing the appropiate key to jump depending on their gravity or they are in orange soul mode, they jump, if not they stay in place.
						if (orange_mode or (get_up_button() and direction == GRAVITY_SOUL.DOWN) or (get_down_button() and direction == GRAVITY_SOUL.UP)){
							jump.speed = _gravity*jump.duration //Apply the gravity force times the duration of the jump, the gravity will reduce this number by its value every frame, that's how you secure the time duration to be the one you specify.
						}else{
							jump.speed = -1 //We apply a negative jump force so next frame it's still colliding with the floor so you can jump at any frame.
						}
						
						//This is for the conveyor platform, it applies a force on the player soul when you get dropped off from it.
						//What we do here is apply a friction value stronger than the air friction since on the floor you stop more.
						_id.conveyor_push.x /= 1.1
						_id.conveyor_push.y /= 1.1
						
						//Division cannot get the value to be 0, so below a threshold it's set to 0.
						if (abs(_id.conveyor_push.x) <= 0.1){
							_id.conveyor_push.x = 0
						}
						if (abs(_id.conveyor_push.y) <= 0.1){
							_id.conveyor_push.y = 0
						}
						
						//If it's a slam, next time a floor is touched, the sound is played.
						//The slam force is set when you use the set_soul_gravity() function with the adequate arguments.
						if (slam){
							audio_play_sound(snd_player_slam, 0, false)
							
							slam = false
						}
					//Using the pushing angle if it's not determined to be a floor, it checks if it can be considered a ceiling by the bonk angle threshold.
					}else if (abs(angle_difference(_push_direction, _base_angle_to_bonk)) <= _offset_to_bonk){ //Ceiling
						//We handle the bonk behavior different depending on if it's either orange soul or not.
						//That's because orange soul is constantly moving, the blue soul is not, you have more control over the blue soul.
						if (orange_mode){
							//Jump speed is inverted being set to negative value, usually you can collide to a ceiling only by going upwards towards it, so this system has not much issue with it.
							//If by any chance you have a negative jump and somehow touches a ceiling, you might see some weird behavior due to the angle being reflected and the reflected angle from above a ceiling will result in it going up.
							//The collision will push you all the way until you're no longer colliding with it, then you will retouch the collision and bounce to negative jump, normalizing your behaviour, technically it's fool proof.
							jump.speed = -_speed*dsin(_reflected_angle)/(direction - 1) + _gravity/2
							movement.speed = clamp(_speed*dcos(_reflected_angle), -_id.movement_speed, _id.movement_speed) //Vertical movement is also reflected (as long as it doesn't exceed the movement_speed)
						}else{
							//Since this is the blue soul, we don't apply momentum like the orange soul, so we only set the jump.speed depending on the angle difference to the base_angle_to_bonk and not a reflected angle.
							jump.speed = min(jump.speed*abs(angle_difference(_push_direction, _base_angle_to_bonk))/90, jump.speed)
						}
					//If the angle is not considered none of the above, then it's determined to be a wall.
					}else{ //Wall
						//Walls bounce extra forces that are perpendicular back and nullify perpendicular movement on them too.
						_id.extra_horizontal_movement.multiplier *= -1 //Bounce
						movement.speed -= movement.speed*abs(dcos(_push_direction)) //Nullify
						_id.conveyor_push.x -= _id.conveyor_push.x*abs(dcos(_push_direction)) //Nullify
						_id.conveyor_push.y -= _id.conveyor_push.y*abs(dsin(_push_direction)) //Nullify
					}
				break}
				default:{ //GRAVITY_SOUL.RIGHT, GRAVITY_SOUL.LEFT //Horizontal gravity.
					//Same stuff as vertical gravity cases, but horizontally.
					if (abs(angle_difference(_push_direction, _base_angle_to_jump)) <= _offset_to_jump){
						if (orange_mode or (get_left_button() and direction == GRAVITY_SOUL.RIGHT) or (get_right_button() and direction == GRAVITY_SOUL.LEFT)){
							jump.speed = _gravity*jump.duration //jump.speed variable is used for any angle to apply the speed, in the step of the obj_player_battle we apply these to the X position instead of the Y, same for the movement.speed.
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
	
	//After all the extra data for the gravity soul is being made (if it's in that mode), we return true for the collision and the Grip angle (if applicable for the gravity soul).
	return [true, _grip]
}
