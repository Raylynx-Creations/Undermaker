/// @description Soul modes, menu handling

//Blinking animation of invulnerability frames
if (invulnerability_frames > 0){
	invulnerability_frames--
	
	//As long as the state of the battle is showing the player it will blink, if not, it won't, but still will count down the invulnerability time
	if (battle_get_state() != BATTLE_STATE.TURN_END and battle_get_state() != BATTLE_STATE.PLAYER_ATTACK and battle_get_state() != BATTLE_STATE.PLAYER_DIALOG_RESULT and battle_get_state() != BATTLE_STATE.PLAYER_FLEE and battle_get_state() != BATTLE_STATE.PLAYER_WON){
		image_alpha = 1 - floor((invulnerability_frames%10)/5)
	}
}

switch (battle_get_state()){
	//Player movement when dodging attacks
	case BATTLE_STATE.END_DODGE_ATTACK:
	case BATTLE_STATE.ENEMY_ATTACK:{
		//Get the resistance for the extra forces and the current player speed (Holding X or not)
		var _current_movement_speed = (movement_speed/((get_cancel_button()) ? 2 : 1))
		var _horizontal_resistance = 2*extra_horizontal_movement.max_force/power(extra_horizontal_movement.duration, 2)
		var _vertical_resistance = 2*extra_vertical_movement.max_force/power(extra_vertical_movement.duration, 2)
		
		//Apply the movement of the platform if it's in any
		move_x += platform_vel.x
		move_y -= platform_vel.y
		
		switch (mode){
			//Red soul movement
			case SOUL_MODE.NORMAL:{
				//Directional movement
				move_x += _current_movement_speed*get_horizontal_button_force()
				move_y += _current_movement_speed*get_vertical_button_force()
				
				//If there's a movement force, apply the force here
				if (extra_horizontal_movement.speed != 0){
					move_x += (extra_horizontal_movement.speed - _horizontal_resistance/2)*extra_horizontal_movement.multiplier
				}
				if (extra_vertical_movement.speed != 0){
					move_y -= (extra_vertical_movement.speed - _vertical_resistance/2)*extra_vertical_movement.multiplier
				}
				
				//Push of the conveyor belt also applies to the red soul
				if (conveyor_push.x != 0 or conveyor_push.y != 0){
					move_x += conveyor_push.x
					move_y += conveyor_push.y
				}
				
				//Color and angle of the soul
				image_blend = c_red
				image_angle = 0
			break}
			case SOUL_MODE.GRAVITY:{
				//Gravity soul uses gravity data
				with (gravity_data){
					//Calculate gravity force
					var _gravity = 2*jump.max_height/power(jump.duration, 2)
					
					switch (direction){
						//Vertical gravity
						case GRAVITY_SOUL.DOWN: case GRAVITY_SOUL.UP:{
							var _move_x
							//If orange mode, we get the lateral movement in a unique way
							if (orange_mode){
								//If no direction is specified for the soul (usually when changing soul modes), we determinate one based on previous movement, otherwise default to the left
								if (movement.direction == 0){
									movement.direction = ((other.xprevious <= other.x) ? 1 : -1)
									movement.speed = _current_movement_speed*get_horizontal_button_force() //Put initial velocity depending on where the player is moving
									
									//If the player is not being slammed down, then determiante also jump speed by how the player is moving
									if (!slam){
										jump.speed = (1 - direction)*_current_movement_speed*get_vertical_button_force()
									}
								}
								
								//Replace the movement speed if there's a button direction defined every frame
								if (get_horizontal_button_force() > 0){
									movement.direction = 1
								}else if (get_horizontal_button_force() < 0){
									movement.direction = -1
								}
								
								//Update the movement horizontally for the orange soul as it's constantly moving
								var _speed_delta = movement.direction*movement.direction_change.speed/movement.direction_change.time
								var _new_speed = clamp(movement.speed + _speed_delta, -other.movement_speed, other.movement_speed)
								var _time = (_new_speed - movement.speed)/_speed_delta
								other.move_x += (movement.speed + _new_speed)*_time/2 + (1 - _time)*_new_speed
								movement.speed = _new_speed //Save the speed
							//If blue mode, just get the normal movement and apply it
							}else{
								other.move_x += _current_movement_speed*get_horizontal_button_force()
							}
							
							//If there's any extra lateral force, apply them, usually applied by trampoline.
							if (other.extra_horizontal_movement.speed != 0){
								other.move_x += (other.extra_horizontal_movement.speed - _horizontal_resistance/2)*other.extra_horizontal_movement.multiplier
							}
							
							//Update the vertical movement
							other.move_y += (direction - 1)*(jump.speed - _gravity/2)
							
							//If the flag box_bound is set, if the box moves, move the player as well with it
							if (box_bound){
								other.move_x += obj_battle_box.x - obj_battle_box.xprevious
								other.move_y += obj_battle_box.y - obj_battle_box.yprevious
							}
							
							//Always apply gravity force to the player
							jump.speed -= _gravity
							
							//Reset flag when it cannot stop going upwards in blue soul only when it's going down in speed
							if (jump.speed <= 0){
								cannot_stop_jump = false
							}
							
							if (orange_mode){
								//Orange soul has the unique behavior of being able to press down to stop going up in the jump
								if (((get_down_button(false) and direction == GRAVITY_SOUL.DOWN) or (get_up_button(false) and direction == GRAVITY_SOUL.UP)) and jump.speed > 0 and !cannot_stop_jump){
									jump.speed = 0 //Set no more jump speed
								}
							}else if (((!get_up_button() and direction == GRAVITY_SOUL.DOWN) or (!get_down_button() and direction == GRAVITY_SOUL.UP)) and jump.speed > 4*_gravity and !cannot_stop_jump){
								//If blue soul, then if you stop pressing upwards, you stop going up in the jump.
								jump.speed = 4*_gravity
							}
						break}
						//Horizontal gravity
						default:{ //GRAVITY_SOUL.LEFT, GRAVITY_SOUL.RIGHT
							//All the stuff here is the same as the vertical gravity, just applied to the appropiate coordinates, swapping X and Y
							var _move_y
							if (orange_mode){
								if (movement.direction == 0){
									movement.direction = ((other.yprevious <= other.y) ? 1 : -1)
									movement.speed = _current_movement_speed*get_vertical_button_force()
									
									if (!slam){
										jump.speed = (direction - 2)*_current_movement_speed*get_horizontal_button_force()
									}
								}
								
								if (get_vertical_button_force() > 0){
									movement.direction = 1
								}else if (get_vertical_button_force() < 0){
									movement.direction = -1
								}
								
								var _speed_delta = movement.direction*movement.direction_change.speed/movement.direction_change.time
								var _new_speed = clamp(movement.speed + _speed_delta, -other.movement_speed, other.movement_speed)
								var _time = (_new_speed - movement.speed)/_speed_delta
								other.move_y += (movement.speed + _new_speed)*_time/2 + (1 - _time)*_new_speed
								movement.speed = _new_speed
							}else{
								other.move_y += _current_movement_speed*get_vertical_button_force()
							}
							
							if (other.extra_horizontal_movement.speed != 0){
								other.move_y -= (other.extra_horizontal_movement.speed - _horizontal_resistance/2)*other.extra_horizontal_movement.multiplier
							}
							
							other.move_x += (direction - 2)*(jump.speed - _gravity/2)
							
							if (box_bound){
								other.move_x += obj_battle_box.x - obj_battle_box.xprevious
								other.move_y += obj_battle_box.y - obj_battle_box.yprevious
							}
							
							jump.speed -= _gravity
							
							if (jump.speed <= 0){
								cannot_stop_jump = false
							}
							
							if (orange_mode){
								if (((get_left_button(false) and direction == GRAVITY_SOUL.LEFT) or (get_right_button(false) and direction == GRAVITY_SOUL.RIGHT)) and jump.speed > 0 and !cannot_stop_jump){
									jump.speed = 0
								}
							}else if (((!get_right_button() and direction == GRAVITY_SOUL.LEFT) or (!get_left_button() and direction == GRAVITY_SOUL.RIGHT)) and jump.speed > 4*_gravity and !cannot_stop_jump){
								jump.speed = 4*_gravity
							}
						break}
					}
					
					//This applies the pushing forces, it doesn't apply any of the forces as long as you're touching the platform, that's what the flag ignore_first_frame is for
					if (!ignore_first_frame and (other.conveyor_push.x != 0 or other.conveyor_push.y != 0)){
						other.move_x += other.conveyor_push.x
						other.move_y += other.conveyor_push.y
						
						//Air friction, it's the half of the floor friction the platforms and box give
						other.conveyor_push.x /= 1.05
						other.conveyor_push.y /= 1.05
						
						//Forces nullify when below a certain threshold
						if (abs(other.conveyor_push.x) <= 0.1){
							other.conveyor_push.x = 0
						}
						if (abs(other.conveyor_push.y) <= 0.1){
							other.conveyor_push.y = 0
						}
					}
					
					//Reset important variables for behavior on the soul, like the force from conveyors, if it can't jump and if it's touching a platform
					ignore_first_frame = false
					cannot_jump = false
					on_platform = false
					
					//Set its angle depending on the diirection of the gravity
					other.image_angle = 90*direction
				}
			break}
		}
		
		//Set platform movement force to 0
		platform_vel.x = 0
		platform_vel.y = 0
		
		//Update additional forces to reduce them
		var _horizontal_speed = extra_horizontal_movement.speed
		if (_horizontal_speed > 0){
			extra_horizontal_movement.speed = max(_horizontal_speed - _horizontal_resistance, 0)
		}else if (_horizontal_speed < 0){
			extra_horizontal_movement.speed = min(_horizontal_speed + _horizontal_resistance, 0)
		}
		
		var _vertical_speed = extra_vertical_movement.speed
		if (_vertical_speed > 0){
			extra_vertical_movement.speed = max(_vertical_speed - _vertical_resistance, 0)
		}else if (_vertical_speed < 0){
			extra_vertical_movement.speed = min(_vertical_speed + _vertical_resistance, 0)
		}
		
		//Create the trail effect as long as the soul is showing in this dodging state
		if (is_player_soul_moving() and image_alpha == 1){
			var _trail = layer_sprite_create(layer_trail, x + animation_offset_x, y + animation_offset_y, sprite_index)
			layer_sprite_speed(_trail, 0)
			layer_sprite_blend(_trail, make_colour_hsv(colour_get_hue(image_blend), colour_get_saturation(image_blend), 91.8))
			layer_sprite_angle(_trail, image_angle)
			array_push(trail_sprites, _trail)
		}
		
		//Update every sprite of the trail
		var _length = array_length(trail_sprites)
		for (var _i = _length - 1; _i >= 0; _i--){
			var _sprite = trail_sprites[_i]
			var _scale = layer_sprite_get_xscale(_sprite)
			
			layer_sprite_xscale(_sprite, _scale - 1/16)
			layer_sprite_yscale(_sprite, _scale - 1/16)
			layer_sprite_alpha(_sprite, _scale - 1/16)
			
			if (_scale <= 0){
				layer_sprite_destroy(_sprite)
				array_delete(trail_sprites, _i, 1)
			}
		}
	break}
	//If player is not dodging an attack we just simply delete its trail if it exists
	default:{
		var _length = array_length(trail_sprites)
		if (_length > 0){
			for (var _i = _length - 1; _i >= 0; _i--){
				layer_sprite_destroy(trail_sprites[_i])
				array_delete(trail_sprites, _i, 1)
			}
		}
	break}
}

//Reset animation offsets
animation_offset_x = 0
animation_offset_y = 0

//Recalculate collision offsets in case the player is constantly changing size or sprite
calculate_object_collision_offset()
