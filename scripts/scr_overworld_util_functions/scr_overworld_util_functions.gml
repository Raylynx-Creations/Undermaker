function start_battle(_enemies, _initial_dialog, _animation=BATTLE_START_ANIMATION.NORMAL, _music=undefined, _background=BATTLE_BACKGROUND.NO_BG, _init_function=undefined, _end_function=undefined, _heart_x=48, _heart_y=453){ //By default points to where the FIGHT button would be
	if (typeof(_enemies) != "array"){
		global.battle_enemies = [_enemies]
	}else{
		global.battle_enemies = _enemies
	}
	
	with (obj_game){
		state = GAME_STATE.BATTLE_START_ANIMATION
		battle_pause_music = !is_undefined(_music)
		battle_music_system.schedule_music_change_to(_music)
		
		while (!dialog.is_finished()){
			dialog.next_dialog(false)
		}
		
		with (battle_system){
			battle_state = BATTLE_STATE.START
			battle_current_box_dialog = _initial_dialog
			battle_selection[0] = 0
			battle_only_attack = undefined
		
			set_battle_scene(_animation, _background, _init_function, _end_function, _heart_x, _heart_y)
		}
	}
}

function start_attack(_attacks, _animation=BATTLE_START_ANIMATION.NO_WARNING_FAST, _music=undefined, _background=BATTLE_BACKGROUND.NO_BG, _init_function=undefined, _end_function=undefined, _heart_x=GAME_WIDTH/2, _heart_y=2*GAME_HEIGHT/3){
	with (obj_game){
		state = GAME_STATE.BATTLE_START_ANIMATION
		battle_pause_music = !is_undefined(_music)
		battle_music_system.schedule_music_change_to(_music)
		
		while (!dialog.is_finished()){
			dialog.next_dialog(false)
		}
		
		with (battle_system){
			battle_state = BATTLE_STATE.START_DODGE_ATTACK
			battle_only_attack = _attacks
		
			set_battle_scene(_animation, _background, _init_function, _end_function, _heart_x, _heart_y)
		}
	}
}

function start_save_menu(_spawn_point_inst=undefined){
	obj_game.player_menu_system.open_save_menu(_spawn_point_inst)
}

function start_box_menu(_index){
	obj_game.player_menu_system.open_box_menu(_index)
}

function create_plus_choice_option(_direction, _distance, _text, _function){
	var _option_index = _direction
	var _x = -_distance*dcos(90*_direction)
	var _y = _distance*dsin(90*_direction)
	
	if (_option_index >= 0){
		obj_game.plus_options[_option_index] = [_x, _y, _text, _function]
	}
}

function create_grid_choice_option(_text, _function){
	array_push(obj_game.grid_options, [0, 0, _text, _function])
}

function start_plus_choice(_x, _y, _start_centered=true){
	_x = real(_x)
	_y = real(_y)
	_start_centered = bool(_start_centered)
	
	var _found_option = -1
	
	with (obj_game){
		var _sprite_half_width = sprite_get_width(choice_sprite)/2
		var _sprite_half_height = sprite_get_height(choice_sprite)/2
		
		for (var _i = 0; _i < 4; _i++){
			if (!is_undefined(plus_options[_i])){
				if (_found_option == -1){
					_found_option = _i
				}
			
				var _dialog_system = new DialogSystem(0, 0, "[skip:false][progress_mode:none][asterisk:false]" + plus_options[_i][2], 640,, 2, 2)
				plus_options[_i][4] = _dialog_system //Yes it literally loads a dialog displaying for each one, for the effects it contains.
			
				switch (_i){
					case 0:
						plus_options[0][0] -= _dialog_system.get_current_text_width() + _sprite_half_width + 8
						plus_options[0][1] -= _dialog_system.get_current_text_height()/2 - _sprite_half_height
					break
					case 1:
						plus_options[1][0] -= _dialog_system.get_current_text_width()/2 + _sprite_half_width + 8
						plus_options[1][1] += _sprite_half_height
					break
					case 2:
						plus_options[2][0] -= _sprite_half_width + 8
						plus_options[2][1] -= _dialog_system.get_current_text_height()/2 - _sprite_half_height
					break
					default: //3
						plus_options[3][0] -= _dialog_system.get_current_text_width()/2 + _sprite_half_width + 8
						plus_options[3][1] -= _dialog_system.get_current_text_height() - _sprite_half_height
					break
				}
			
				_dialog_system.move_to(_x + plus_options[_i][0] + _sprite_half_width + 8, _y + plus_options[_i][1] - 14)
			}
		}
	
		if (_found_option >= 0){
			state = GAME_STATE.DIALOG_PLUS_CHOICE
			options_x = _x
			options_y = _y
	
			if (_start_centered){
				selection = -1
			}else{
				selection = _found_option //The first one that finds is left, if not then, down, if not then, right, if not then, up it's always secure it's one of those 4 cases.
				plus_options[_found_option][4].set_dialogues("[skip:false][progress_mode:none][asterisk:false][color_rgb:255,255,0]" + plus_options[_found_option][2])
			}
		}
	}
}

function start_grid_choice(_x, _y, _x_spacing=280, _y_spacing=-1){
	_x = real(_x)
	_y = real(_y)
	_x_spacing = real(_x_spacing)
	_y_spacing = real(_y_spacing)
	
	var _found_option = -1
	
	with (obj_game){
		var _length = array_length(grid_options)
		var _sprite_half_width = sprite_get_width(choice_sprite)/2
		var _sprite_half_height = sprite_get_height(choice_sprite)/2
		var _option_x = 0
		var _option_y = 0
		var _line_jump_height = 0
		
		if (_length > 0){
			_found_option = 0
		}
		
		for (var _i=0; _i<_length; _i++){
			var _dialog_system = new DialogSystem(0, 0, "[skip:false][progress_mode:none][asterisk:false]" + grid_options[_i][2], 640,, 2, 2)
			grid_options[_i][4] = _dialog_system //Yes it literally loads a dialog displaying for each one, for the effects it contains.
			
			grid_options[_i][0] = _option_x
			grid_options[_i][1] = _option_y + _sprite_half_height
			
			_dialog_system.move_to(_x + grid_options[_i][0] + _sprite_half_width + 8, _y + grid_options[_i][1] - 14)
			
			_line_jump_height = _dialog_system.line_jump_height*_dialog_system.yscale
			if (_y_spacing != -1){
				_line_jump_height = max(_y_spacing, _line_jump_height)
			}
			
			if (_option_x == 0){
				_option_x = _x_spacing
			}else{
				_option_x = 0
				_option_y += _line_jump_height
			}
		}
		
		if (_length > 0){
			state = GAME_STATE.DIALOG_GRID_CHOICE
			options_x = _x
			options_y = _y
	
			selection = 0
			grid_options[_found_option][4].set_dialogues("[skip:false][progress_mode:none][asterisk:false][color_rgb:255,255,0]" + grid_options[_found_option][2])
		}
	}
}

function overworld_dialog(_dialogues, _set_event=true, _top=true, _width=261, _height=56, _face_sprite=undefined, _face_subimages=undefined, _box=spr_box_normal, _tail=-1, _tail_mask=-1){
	with (obj_game){
		dialog.text_speed = 2
		dialog.set_dialogues(_dialogues, _width, _height, _face_sprite, _face_subimages)
		dialog.set_scale(2, 2)
		dialog.set_container_sprite(_box)
		dialog.set_container_tail_sprite(_tail)
		dialog.set_container_tail_mask_sprite(_tail_mask)
		dialog.move_to(292 - _width, 320 - 310*_top)
		
		if (_set_event and state != GAME_STATE.EVENT and state != GAME_STATE.PLAYER_MENU_CONTROL){
			if (state != GAME_STATE.BATTLE_END){
				state = GAME_STATE.EVENT
			}
			
			if (is_undefined(event_end_condition)){
				event_end_condition = dialog.is_finished
			}
		}
	}
}

function change_room(_room_id, _spawn_point_instance, _sides=true, _room_change_fade_in_time=20, _room_change_wait_time=0, _room_change_fade_out_time=20, _end_room_func=undefined, _start_room_func=undefined, _after_transition_func=undefined){
	with (obj_game){
		state = GAME_STATE.ROOM_CHANGE
		end_room_function = _end_room_func
		start_room_function = _start_room_func
		
		with (room_transition_system){
			anim_timer = 0
			update_border_alpha = !is_undefined(get_border_id_by_room(_room_id))
			
			room_change_fade_in_time = max(ceil(_room_change_fade_in_time), 1) //Cannot allow decimals and negatives.
			room_change_wait_time = max(room_change_fade_in_time + ceil(_room_change_wait_time), 1)
			room_change_fade_out_time = max(room_change_wait_time + ceil(_room_change_fade_out_time), room_change_fade_in_time + 1)
			
			goto_room = _room_id
			after_transition_function = _after_transition_func
		}
	}
	
	var _x_offset = 10*image_xscale
	var _y_offset = 10*image_yscale
	var _x = x + _x_offset*dcos(image_angle) + _y_offset*dsin(image_angle)
	var _y = y + _y_offset*dcos(image_angle) - _x_offset*dsin(image_angle)
	var _distance = point_distance(_x, _y, obj_player_overworld.x, obj_player_overworld.y)
	var _direction = point_direction(_x, _y, obj_player_overworld.x, obj_player_overworld.y) - image_angle
	_x = _distance*dcos(_direction)
	_y = _distance*dsin(_direction)
	
	obj_player_overworld.spawn_point_reference = _spawn_point_instance
	obj_player_overworld.spawn_point_offset = (_sides ? _y : _x)
}

function is_random_encounters_active(){
	return obj_game.random_encounter_system.can_player_encounter_enemies
}

function toggle_random_encounters(_active=true, _reset_steps=false){
	obj_game.random_encounter_system.toggle_encounters(_active, _reset_steps)
}

function set_random_encounters(_enemie_pool, _steps_to_trigger, _minimum_enemies=1, _maximum_enemies=3, _selection_type=ENCOUNTER_ENEMIE_SELECTION.COMBINE, _exclude_enemie_combinations=undefined){
	obj_game.random_encounter_system.set_encounters(_enemie_pool, _steps_to_trigger, _minimum_enemies, _maximum_enemies, _selection_type, _exclude_enemie_combinations)
}

function set_player_state(_state=PLAYER_STATE.MOVEMENT){
	if (obj_game.state == GAME_STATE.PLAYER_CONTROL){
		obj_player_overworld.state = _state
	}
}
