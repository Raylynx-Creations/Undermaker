/// @description Initial variables

//Functions for the platform
step = undefined
destroy = undefined

type = PLATFORM_TYPE.NORMAL
length = 100 //Size of platform
conveyor_speed = 1 //Conveyor platform type speed
trampoline_pushing_strength = 6080/1444 //Numbers came from using the formula to calculate the jump.speed on the player gravity soul jumping variables, specifically 2*gravity_data.jump.max_height/power(gravity_data.jump.duration, 2)*gravity_data.jump.duration, where jump.duration is 38 and jump.max_height is 80

//Fragile platform data
fragile = {duration_time: 0, respawn_time: 90, respawn: true}

//-----------------Programmer area---------------------------

fragile.state = 0
fragile.timer = 0

surface = -1

//For movement of the platform, we don't use xprevious or x
move_x = 0
move_y = 0

anim_timer = 0 //For animation purposes
//Strength of the trampoline

//Platform update flags to avoid repeating the updates
platform_effects_updated = false
platform_updated = false
platform_sticky_updated = false
is_player_on = false //Flag that tells if the player is on the platform

//Function to check if it's collidable
is_collidable = function(){
	return (image_alpha >= 0.5 and fragile.state == 0)
}

//Collision functions
effect_collision_function = function(_id, _push_direction, _counter_clockwise_push){
	if (platform_effects_updated or !is_collidable()){
		return [false, 0]
	}
	platform_effects_updated = true
	
	var _platform_type = type
	var _platform_direction = _push_direction + 90 - 180*_counter_clockwise_push
	var _distance = point_distance(x, y, _id.x, _id.y)
	var _distance_direction = point_direction(x, y, _id.x, _id.y)
	var _player_y = y - _distance*dsin(_distance_direction - _platform_direction)
	var _speed_angle = point_direction(0, 0, _id.move_x, _id.move_y)
	
	with (_id){
		image_angle -= _platform_direction
		calculate_object_collision_offset()
		
		_player_y += sprite_bottom_collision_offset + 2
		
		image_angle += _platform_direction
		calculate_object_collision_offset()
	}
	
	if (type == PLATFORM_TYPE.STICKY){
		is_player_on = true
	}
	
	if (abs(angle_difference(_push_direction, _speed_angle)) < 90 or y < _player_y){
		return [false, 0]
	}
	
	switch (_platform_type){
		case PLATFORM_TYPE.CONVEYOR:{
			switch (_id.mode){
				case SOUL_MODE.NORMAL:{
					_id.conveyor_push.x += conveyor_speed*dsin(_push_direction)
					_id.conveyor_push.y += conveyor_speed*dcos(_push_direction)
				break}
				case SOUL_MODE.GRAVITY:{
					with (_id.gravity_data){
						var _conveyor_direction = point_direction(0, 0, other.conveyor_speed*dcos(other.image_angle), -other.conveyor_speed*dsin(other.image_angle))
						
						if (abs(angle_difference(_conveyor_direction, _speed_angle)) <= 90){
							_id.platform_vel.x += other.conveyor_speed*dsin(_push_direction)
							_id.platform_vel.y += other.conveyor_speed*dcos(_push_direction)
							
							_id.conveyor_push.x = _id.platform_vel.x
							_id.conveyor_push.y = _id.platform_vel.y
							
							ignore_first_frame = true
						}
					}
				break}
			}
		break}
		case PLATFORM_TYPE.STICKY:{
			_id.platform_vel.x += move_x
			_id.platform_vel.y += move_y
		break}
	}
	
	return [false, 0] //This is not a collision line, just an effect line
}

player_collision_function = function(_id, _push_direction, _counter_clockwise_push){
	if (!is_collidable()){
		return [false, 0]
	}
	
	var _grip = _push_direction
	
	var _base_angle_to_jump
	if (_id.mode == SOUL_MODE.GRAVITY){
		var _offset_to_grip = abs(_id.gravity_data.allowed_angle_range_to.grip)
		_base_angle_to_jump = 90 + 90*_id.gravity_data.direction
		if (abs(angle_difference(_push_direction, _base_angle_to_jump)) <= _offset_to_grip){
			_grip = 90*_id.gravity_data.direction + 90
		}
	}
	
	var _speed_angle = point_direction(0, 0, _id.move_x, _id.move_y)
	if (platform_updated){
		if (abs(angle_difference(_push_direction, _speed_angle)) < 90){
			return [false, 0]
		}else{
			return [true, _grip]
		}
	}
	platform_updated = true
	
	var _platform_type = type
	var _platform_direction = _push_direction + 90 - 180*_counter_clockwise_push
	var _distance = point_distance(x, y, _id.x, _id.y)
	var _distance_direction = point_direction(x, y, _id.x, _id.y)
	var _player_y = y - _distance*dsin(_distance_direction - _platform_direction)
	
	with (_id){
		image_angle -= _platform_direction
		calculate_object_collision_offset()
		
		_player_y += sprite_bottom_collision_offset + 2
		
		image_angle += _platform_direction
		calculate_object_collision_offset()
	}
	
	if (abs(angle_difference(_push_direction, _speed_angle)) <= 90 or y < _player_y){
		return [false, 0]
	}
	
	switch (_id.mode){
		case SOUL_MODE.NORMAL:{
			switch (_platform_type){
				case PLATFORM_TYPE.TRAMPOLINE:{
					anim_timer = 1
			
					var _force_strength = trampoline_pushing_strength
					_id.extra_vertical_movement.speed = _force_strength
					_id.extra_vertical_movement.multiplier = dsin(_push_direction)
					_id.extra_horizontal_movement.speed = _force_strength
					_id.extra_horizontal_movement.multiplier = dcos(_push_direction)
				break}
			}
		break}
		case SOUL_MODE.GRAVITY:{
			with (_id.gravity_data){
				var _gravity = 2*jump.max_height/power(jump.duration, 2)
			
				var _offset_to_jump = abs(allowed_angle_range_to.jump)
				var _offset_to_bonk = abs(allowed_angle_range_to.bonk)
				var _base_angle_to_bonk = 270 + 90*direction
				
				var _speed = point_distance(0, 0, _id.move_x, _id.move_y)
				var _reflected_angle = _push_direction - angle_difference(_speed_angle + 180, _push_direction)
				
				switch (direction){
					case GRAVITY_SOUL.DOWN: case GRAVITY_SOUL.UP:{
						if (_platform_type == PLATFORM_TYPE.TRAMPOLINE){
							other.anim_timer = 1
						
							var _force_strength = other.trampoline_pushing_strength
							jump.speed = _force_strength*dsin(_push_direction)
							_id.extra_horizontal_movement.speed = _force_strength
							_id.extra_horizontal_movement.multiplier = dcos(_push_direction)
						
							if (jump.speed > 0){
								cannot_stop_jump = true
							}
						
							if (slam){
								audio_play_sound(snd_player_slam, 0, false)
							
								slam = false
							}
						
							break
						}
						
						if (abs(angle_difference(_push_direction, _base_angle_to_jump)) <= _offset_to_jump){
							if (orange_mode or (get_up_button() and direction == GRAVITY_SOUL.DOWN) or (get_down_button() and direction == GRAVITY_SOUL.UP)){
								if (_platform_type != PLATFORM_TYPE.STICKY){
									jump.speed = _gravity*jump.duration
								}else if (jump.speed <= -1 and _id.sticky_animation.timer == 0){
									jump.speed = 1
								}else{
									jump.speed = -1
								}
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
						if (_platform_type == PLATFORM_TYPE.TRAMPOLINE){
							other.anim_timer = 1
						
							var _force_strength = other.trampoline_pushing_strength
							jump.speed = _force_strength*dsin(_push_direction - 90)
							_id.extra_horizontal_movement.speed = _force_strength
							_id.extra_horizontal_movement.multiplier = dsin(_push_direction)
						
							if (jump.speed > 0){
								cannot_stop_jump = true
							}
						
							if (slam){
								audio_play_sound(snd_player_slam, 0, false)
							
								slam = false
							}
						
							break
						}
						
						if (abs(angle_difference(_push_direction, _base_angle_to_jump)) <= _offset_to_jump){
							if (orange_mode or (get_left_button() and direction == GRAVITY_SOUL.RIGHT) or (get_right_button() and direction == GRAVITY_SOUL.LEFT)){
								if (_platform_type != PLATFORM_TYPE.STICKY){
									jump.speed = _gravity*jump.duration
								}else if (jump.speed <= -1 and _id.sticky_animation.timer == 0){
									jump.speed = 1
								}else{
									jump.speed = -1
								}
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
			
				on_platform = true
			}
		break}
	}
	
	if (_platform_type != PLATFORM_TYPE.STICKY){
		_id.platform_vel.x += move_x
		_id.platform_vel.y += move_y
	}
	
	if (fragile.duration_time > 0 and fragile.timer <= 0){
		fragile.timer = 1
	}
	
	return [true, _grip]
}

player_sticky_platform_collision_function = function(_id, _push_direction, _counter_clockwise_push){
	if (!is_collidable()){
		return [false, 0]
	}
	
	var _grip = _push_direction
	
	if (_id.mode == SOUL_MODE.GRAVITY){
		var _offset_to_grip = abs(_id.gravity_data.allowed_angle_range_to.grip)
		var _base_angle_to_jump = 90 + 90*_id.gravity_data.direction
		if (abs(angle_difference(_push_direction, _base_angle_to_jump)) <= _offset_to_grip){
			_grip = 90*_id.gravity_data.direction + 90
		}
	}
	
	var _speed_angle = point_direction(0, 0, _id.move_x, _id.move_y)
	if (platform_sticky_updated){
		if (abs(angle_difference(_push_direction, _speed_angle)) < 90){
			return [false, 0]
		}else{
			return [true, _grip]
		}
	}
	platform_sticky_updated = true
	
	var _platform_type = type
	var _speed = point_distance(0, 0, _id.move_x, _id.move_y)
	
	if (_speed > 0 and abs(angle_difference(_push_direction, _speed_angle)) > 90){
		if (_id.sticky_animation.timer == 0){
			_id.sticky_animation.timer = 1
			_id.sticky_animation.direction = _push_direction + 180
		}else{
			_id.sticky_animation.keep_animation = true
		}
	}
	
	switch (_id.mode){
		case SOUL_MODE.NORMAL:{
			//Nothing
		break}
		case SOUL_MODE.GRAVITY:{
			with (_id.gravity_data){
				var _gravity = 2*jump.max_height/power(jump.duration, 2)
			
				var _offset_to_jump = abs(allowed_angle_range_to.jump)
				var _offset_to_bonk = abs(allowed_angle_range_to.bonk)
				var _base_angle_to_jump = 90 + 90*direction
				var _base_angle_to_bonk = 270 + 90*direction
				
				var _reflected_angle = _push_direction - angle_difference(_speed_angle + 180, _push_direction)
				
				switch (direction){
					case GRAVITY_SOUL.DOWN: case GRAVITY_SOUL.UP:{
						if (abs(angle_difference(_push_direction, _base_angle_to_jump)) <= _offset_to_jump){
							jump.speed = -1
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
							jump.speed = -1
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
		break}
	}
	
	if (fragile.duration_time > 0 and fragile.timer <= 0){
		fragile.timer = 1
	}
	
	return [true, _grip]
}
