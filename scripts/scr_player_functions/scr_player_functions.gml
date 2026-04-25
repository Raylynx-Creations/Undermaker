function player_update_collision(){
	if (can_collide){
		var _colliding_instances = []
		var _instance_directions = []
		var _collision_amount = 0
	
		with (obj_collision){
			if (place_meeting(x, y, other) and !is_undefined(when_colliding) and !has_collided){
				when_colliding()
				has_collided = true
			}
		}
	
		with (obj_interaction){
			if (place_meeting(x, y, other) and !is_undefined(when_colliding) and !has_collided){
				when_colliding()
				has_collided = true
			}
		}
	
		with (obj_entity){
			if (place_meeting(x, y, other) and !is_undefined(when_colliding) and !has_collided){
				when_colliding()
				has_collided = true
			}
		}
	
		var _current_x = x
		var _current_y = y
		var _has_checked = false
		var _a_valid_direction_found = false
		
		var _loop_count = 0
		do{
			_loop_count++
			
			//This is for the obj_collision, which if the collision_id is 0, it will make the player collide with it.
			//Different ids of collision are used so other objects like obj_entity can interact with these in different ways, shaping mazes where you push rocks, etc.
			with (obj_collision){
				if (collision_id == 0){
					_collision_amount = general_object_collision_handler(other, _colliding_instances, _instance_directions, _collision_amount, handle_collision_object_and_interaction_collision)
				}
			}
		
			//obj_interaction acts like collision as well if their variable is set.
			//These pack dialog if interacted with of course, but most of the time they are paired with a collision to interact on the wall or to an object you cannot pass trough.
			//So I made it a feature of the object itself, so you save space on putting it paired with a collision.
			with (obj_interaction){
				if (can_player_collide){
					_collision_amount = general_object_collision_handler(other, _colliding_instances, _instance_directions, _collision_amount, handle_collision_object_and_interaction_collision)
				}
			}
		
			with (obj_entity){
				if (can_player_collide and !can_player_push){
					_collision_amount = general_object_collision_handler(other, _colliding_instances, _instance_directions, _collision_amount, handle_entity_collision)
				}
			}
		
			if (!_has_checked){
				_has_checked = true
			
				if (_collision_amount >= 2){
					for (var _i=0; _i < _collision_amount; _i++){
						var _valid_direction = true
						var _direction = _instance_directions[_i]
						var _offset_x = dcos(_direction)
						var _offset_y = -dsin(_direction)
						
						var _loop_count_2 = 0
						do{
							_loop_count_2++
							
							for (var _j=0; _j < _collision_amount; _j++){
								if (_i == _j){
									continue
								}
						
								if (!place_meeting(_current_x + _offset_x, _current_y + _offset_y, _colliding_instances[_j])){
									_valid_direction = false
							
									break
								}
							}
					
							if (!_valid_direction){
								break
							}
					
							_offset_x += dcos(_direction)/4
							_offset_y -= dsin(_direction)/4
							
							if (_loop_count_2 >= 50){
								break
							}
						}until (!place_meeting(_current_x + _offset_x, _current_y + _offset_y, _colliding_instances[_i]))
				
						if (_valid_direction){
							for (var _j=0; _j < _collision_amount; _j++){
								if (_i == _j){
									continue
								}
						
								if (place_meeting(_current_x + _offset_x, _current_y + _offset_y, _colliding_instances[_j])){
									_valid_direction = false
							
									break
								}
							}
					
							if (_valid_direction){
								for (var _j=0; _j < _collision_amount; _j++){
									if (_i == _j){
										continue
									}
							
									_instance_directions[_j] = _direction
								}
						
								_a_valid_direction_found = true
								x = _current_x
								y = _current_y
						
								break
							}
						}
					}
				}
			}
		
			if (!_a_valid_direction_found){
				if (_current_x == x and _current_y == y){
					break
				}else{
					_current_x = x
					_current_y = y
				}
			}else{
				_a_valid_direction_found = false
			}
			
			if (_loop_count >= 50){
				break
			}
		}until (_collision_amount == 0)
	
		//obj_entity represents a being or an interactable object to do various stuff.
		//So they act as a collision to the player no matter what, you may control what to do once the player collides with them with its collision function, like trigger some death scene perhaps from a foe.
		with (obj_entity){
			if (can_player_collide and place_meeting(x, y, other)){
				//If the pushable flag is true, then the object may be moved around by the player.
				if (can_player_push){
					push_entity(other)
				
					//When the pushing has taken effect and the object cannot be pushed around any further, then it may overlap the player, so a collsion has to be checked to see if the player is still colliding with it after the push action.
					if (place_meeting(x, y, other)){
						_loop_count = 0
						do{
							_loop_count++
							
							_collision_amount = general_object_collision_handler(other, _colliding_instances, _instance_directions, _collision_amount, handle_entity_collision)
							
							if (_loop_count >= 50){
								break
							}
						}until (_collision_amount == 0)
					}
				}
			}
		}
	}
}

function player_movement_update(){
	timer-- //Timer that makes the player behave like if it was in 30 FPS running in a 60 FPS enviroment.
	var _movement_speed = movement_speed
	var _animation_speed = animation_speed
	
	if (can_run and get_cancel_button() and any_direction_button()){
		_movement_speed = movement_run_speed
		_animation_speed = animation_run_speed
		
		if (!is_undefined(run_sprite)){
			sprite_index = run_sprite
		}
	}else{
		sprite_index = walk_sprite
	}
	
	if (timer == 0){
		timer = 2 //Reset the timer each time.
		
		//Animation timer to animate the player, of course.
		if (any_direction_button()){
			animation_timer++
		}else{ //Reset the animation and timer if it's not moving.
			animation_timer = _animation_speed - 1 //Set to 1 frame of changing the animation so it looks like it moves immediatelly after pressing.
			player_anim_stop()
		}
		
		//If the timer has reached the animation speed, update the frame of the animation.
		if (animation_timer >= _animation_speed){
			animation_timer -= _animation_speed
			image_index++
			
			//Walk and run frames constitute of 4 frames, if you need more than that, make sure to change it on all parts of the code, there's one above to set the player in neutral position.
			if (image_index%animation_frames == 0){
				image_index -= animation_frames
			}
		}
		
		var _y_upper_collision = false
		
		//Special case check for the frisk_dance trigger, cannot do it the normal way because of the collision id system.
		//By the way, I see you saying it's not accurate, you don't need it accurate, the feature is there and you can see it "dance", if you don't like it then do it yourself or deactivate it, this is what you're getting.
		if (frisk_dance and can_collide){
			with (obj_collision){
				if (collision_id == 0 and place_meeting(x, y + _movement_speed*get_up_button(), other)){
					_y_upper_collision = true
					
					break
				}
			}
		}
		
		//The priority on up and right is intentional, you will have to edit this part of the code if you want that if both buttons are held, it doesn't move this priority system is also benefitial for the frisk dance feature and moon walk.
		if (get_up_button() and (!_y_upper_collision or !get_down_button())){
			move_y = -_movement_speed*get_up_button()
			while (image_index >= 3*animation_frames){
				image_index -= animation_frames
			}
			while (image_index < 2*animation_frames){
				image_index += animation_frames
			}
		}else if (get_down_button()){
			move_y = _movement_speed*get_down_button()
			while (image_index >= animation_frames){
				image_index -= animation_frames
			}
		}
		
		//Left and right movements, priority on right button, so you can only moon walk to the right, if you want it for both sides, do it differently than this.
		if (get_right_button()){
			move_x = _movement_speed*get_right_button()
			if (!get_left_button() or !moon_walk){
				while (image_index >= 2*animation_frames){
					image_index -= animation_frames
				}
				while (image_index < animation_frames){
					image_index += animation_frames
				}
			}
		}else if (get_left_button()){
			move_x = -_movement_speed*get_left_button()
			while (image_index < 3*animation_frames){
				image_index += animation_frames
			}
			while (image_index >= 4*animation_frames){
				image_index -= animation_frames
			}
		}
	}
}