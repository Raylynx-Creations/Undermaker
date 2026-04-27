function battle_forgive_enemy(_index){
	var _enemy = global.battle_enemies[_index]
	if (!is_undefined(_enemy.destroy)){
		_enemy.destroy()
	}
	
	if (!is_undefined(_enemy.forgiven)){
		_enemy.forgiven()
	}
	
	audio_play_sound(snd_enemie_vanish, 100, false)
	array_push(obj_game.battle_system.battle_cleared_enemies, _enemy)
	
	var _length = irandom_range(7, 12)
	for (var _i=0; _i<_length; _i++){
		var _width = sprite_get_width(_enemy.sprite_spared)
		var _height = sprite_get_height(_enemy.sprite_spared)
		var _offset_x = (_width/2 - sprite_get_xoffset(_enemy.sprite_spared))*_enemy.sprite_xscale
		var _offset_y = (_height/2 - sprite_get_yoffset(_enemy.sprite_spared))*_enemy.sprite_yscale
		var _range_x = _width*_enemy.sprite_xscale/2
		var _range_y = _height*_enemy.sprite_yscale/2
		var _x = irandom_range(-_range_x, _range_x)
		var _y = irandom_range(-_range_y, _range_y)
		var _direction = point_direction(0, 0, _x, _y)
		
		array_push(obj_game.battle_system.battle_dust_clouds, {timer: 0, x: _enemy.x + _offset_x + _x, y: _enemy.y + _offset_y + _y, direction: _direction, distance: min(point_distance(0, 0, _x, _y)/point_distance(0, 0, dcos(_direction)*_range_x, -dsin(_direction)*_range_y), 1)})
	}
	
	obj_game.battle_system.battle_gold += _enemy.give_gold_on_spared
	
	global.battle_enemies[_index] = undefined
}

function battle_kill_enemy(_index){
	var _enemy = global.battle_enemies[_index]
	if (!is_undefined(_enemy.destroy)){
		_enemy.destroy()
	}
	
	if (!is_undefined(_enemy.killed)){
		_enemy.killed()
	}
	
	audio_play_sound(snd_enemie_vanish, 100, false)
	array_push(obj_game.battle_system.battle_cleared_enemies, _enemy)
	
	_enemy.last_animation_timer = 0
	obj_game.battle_system.battle_gold += _enemy.give_gold_on_kill
	obj_game.battle_system.battle_exp += _enemy.give_exp
	
	global.battle_enemies[_index] = undefined
}

function battle_set_player_status_effect(_type=PLAYER_STATUS_EFFECT.NONE, _apply_effects_immediatelly_on_change=false){
	if (room != rm_battle or battle_get_state() == BATTLE_STATE.END or battle_get_state() == BATTLE_STATE.PLAYER_WON){
		return
	}
	
	with (global.player.status_effect){
		switch (_type){
			case PLAYER_STATUS_EFFECT.KARMIC_RETRIBUTION:{
				type = _type
				color = make_color_rgb(232, 0, 255)
				value = 0
				timer = 0
			break}
			default:{ //PLAYER_STATUS_EFFECT.NONE
				if (_apply_effects_immediatelly_on_change){
					switch (type){
						case PLAYER_STATUS_EFFECT.KARMIC_RETRIBUTION:{
							if (value > 0){
								global.player.hp -= value
							}
						}
					}
				}
				
				type = PLAYER_STATUS_EFFECT.NONE
				color = 0
				value = 0
				timer = 0
			break}
		}
	}
}

function battle_create_box(_x, _y, _width, _height, _rotation=0, _depth=undefined, _type=BATTLE_BOX_TYPE.NORMAL){
	if (is_undefined(_depth)){
		_depth = 200
	}
	
	battle_clear_box_line_collisions_cache()
	
	var _box = instance_create_depth(_x, _y, _depth, obj_battle_box)
	_box.type = _type
	_box.prev_depth = _depth
	
	battle_move_box_to(_x, _y, true, _box)
	battle_resize_box(_width, _height, true, _box)
	battle_rotate_box_to(_rotation, true, _box)
	
	return _box
}

function battle_destroy_box(_box){
	instance_destroy(_box)
	
	battle_clear_box_line_collisions_cache()
}

function battle_set_box_depth(_depth, _box=inst_battle_box){
	if (_box.depth != _depth){
		_box.depth = _depth
		_box.prev_depth = _depth
		
		battle_clear_box_line_collisions_cache()
	}
}

function battle_resize_box(_x, _y, _instant=false, _box=inst_battle_box){
	with (_box){
		box_size.x = _x
		box_size.y = _y
		
		if (_instant){
			width = box_size.x
			height = box_size.y
			battle_box_update_points_by_resize(_box)
		}
	}
}

function battle_move_box_to(_x, _y, _instant=false, _box=inst_battle_box){
	with (_box){
		box_position.x = _x
		box_position.y = _y
		
		if (_instant){
			var _diff_x = _x - x
			var _diff_y = _y - y
			
			x = _x
			y = _y
			
			battle_box_update_points_by_position(_diff_x, _diff_y, _box)
		}
	}	
}

function battle_move_box(_x, _y, _instant=false, _box=inst_battle_box){
	with (_box){
		box_position.x += _x
		box_position.y += _y
		
		if (_instant){
			var _diff_x = box_position.x - x
			var _diff_y = box_position.y - y
			
			x = box_position.x
			y = box_position.y
			
			battle_box_update_points_by_position(_diff_x, _diff_y, _box)
		}
	}	
}

function battle_reset_box_origin(_box=inst_battle_box){
	with (_box.box_origin){
		var _diff_x = -x
		var _diff_y = y
		
		defined = false
		x = 0
		if (polygon_defined){
			y = 0
		}else{
			y = -5 - round(height)/2
		}
		_diff_y = y - _diff_y
		
		battle_box_update_points_by_origin(_diff_x, _diff_y, _box)
	}
}

function battle_reset_box_polygon_points(_box=inst_battle_box){
	with (_box.box_polygon_points){
		with (_box.box_origin){
			polygon_defined = false
			if (!defined){
				x = 0
				y = -5 - round(_box.height)/2
			}
		}
		
		update = true
		var _length = array_length(defined)
		
		if (_length > 0){
			array_delete(defined, 0, _length)
		}
	}
}

function battle_set_box_origin(_x, _y, _relative=true, _box=inst_battle_box){
	with (_box.box_origin){
		var _diff_x = x
		var _diff_y = y
		
		defined = true
		x = _x - (_relative ? _box.x : 0)
		y = _y - (_relative ? _box.y : 0)
		
		_diff_x = x - _diff_x
		_diff_y = y - _diff_y
		
		battle_box_update_points_by_origin(_diff_x, _diff_y, _box)
	}
}

function battle_set_box_polygon_points(_points, _relative=true, _invert=false, _box=inst_battle_box){
	if (array_length(_points) < 4){
		show_message("The box must have at least 2 points to be shown.")
		
		return
	}
	
	var _length = array_length(_points)
	var _points_copy = []
	array_copy(_points_copy, 0, _points, 0, _length)
	_points = _points_copy
	
	if (_invert){
		_points_copy = []
		for (var _i=0; _i<_length; _i += 2){
			var _value = array_pop(_points) //array_pops -> Y
			array_push(_points_copy, array_pop(_points), _value) //array_pops -> X
		}
		
		_points = _points_copy
	}
	
	with (_box.box_polygon_points){
		with (_box.box_origin){
			polygon_defined = true
			if (!defined){
				x = 0
				y = 0
			}
		}
		
		if (_relative){
			for (var _i = 0; _i < _length; _i += 2){
				_points[_i] += _box.x
				_points[_i+1] += _box.y
			}
		}
		
		if (_length >= 6){ //Do the point reduction as long as there 3 or more points
			for (var _i = 0; _i < _length; _i += 2){
				var _distance = point_distance(_points[(_i - 2 + _length)%_length], _points[(_i - 1 + _length)%_length], _points[_i], _points[_i+1])
				var _remove = false
				
				if (_distance == 0){
					_remove = true
				}else{			
					var _prev_direction = point_direction(_points[(_i - 2 + _length)%_length], _points[(_i - 1 + _length)%_length], _points[_i], _points[_i+1])
					var _direction = point_direction(_points[_i], _points[_i+1], _points[(_i + 2)%_length], _points[(_i + 3)%_length])
					var _angle_difference = angle_difference(_prev_direction, _direction)
			
					//Remove points that are in the middle of a straight line and in the opposite direction too
					if (_angle_difference == 0 or _angle_difference == 180){
						_remove = true
					}
				}
				
				if (_remove){
					array_delete(_points, _i, 2)
					
					_i -= 2
					_length -= 2
					
					if (_length <= 4){
						break //If it got reduced to 2 points, stop, no more reduction.
					}
				}
			}
		}
		
		update = true
		defined = _points
	}
}

function battle_set_box_alpha(_alpha, _with_fill=true, _box=inst_battle_box){
	with (_box){
		image_alpha = _alpha
		if (_with_fill){
			box_fill_alpha = _alpha
		}
	}
}

function battle_rotate_box_to(_angle, _instant=false, _box=inst_battle_box){
	with (_box){
		box_rotation = _angle
		
		if (_instant){
			var _diff_angle = angle_difference(_angle, image_angle)
			
			image_angle = box_rotation
			
			battle_box_update_points_by_rotation(_diff_angle, _box)
		}
	}
}

function battle_rotate_box(_angle, _instant=false, _box=inst_battle_box){
	with (_box){
		box_rotation += _angle
		
		if (_instant){
			var _diff_angle = angle_difference(_angle, image_angle)
			
			image_angle = box_rotation
			
			battle_box_update_points_by_rotation(_diff_angle, _box)
		}
	}
}

function battle_set_background(_background=BATTLE_BACKGROUND.NO_BG, _depth=500){
	with (obj_game.battle_system){
		if (!is_undefined(battle_background)){
			instance_destroy(battle_background)
		}
		
		battle_background = BattleBackground(_background, _depth)
	}
}

function battle_toggle_flee(_state){
	obj_game.battle_system.battle_can_flee = _state
}

function battle_set_flee_event(_flee_event){
	obj_game.battle_system.battle_flee_event_type = _flee_event
}

function battle_set_flee_chance(_amount){
	obj_game.battle_system.battle_flee_chance = clamp(_amount, 0, 100)
}

function battle_add_flee_chance(_amount){
	with (obj_game.battle_system){
		battle_flee_chance = clamp(battle_flee_chance + _amount, 0, 100)
	}
}

function battle_add_enemie(_monster, _x, _y){
	if (room != rm_battle){
		show_error("You can't add enemies or spawn enemies if you're not on battle, you must be in room rm_battle to do so aka the battle room.", true)
	}
	
	var _position = array_length(global.battle_enemies) + array_length(obj_game.battle_system.battle_cleared_enemies)
	var _enemy = new Enemy(_monster, _position, _x, _y)
	
	array_push(global.battle_enemies, _enemy)
}

function battle_get_flee_state(){
	return obj_game.battle_system.battle_can_flee
}

function battle_get_flee_chance(){
	return obj_game.battle_system.battle_flee_chance
}

function battle_get_current_attack_amount(){
	return obj_game.battle_system.battle_attack_count
}

function battle_get_current_enemies_amount(_only_active_enemies=true){
	var _length = array_length(global.battle_enemies)
	if (_only_active_enemies){
		return _length
	}else{
		return _length + array_length(obj_game.battle_system.battle_cleared_enemies)
	}
}

function battle_get_current_enemies(_only_active_enemies=true){
	var _list = []
	var _length = array_length(global.battle_enemies)
	
	array_copy(_list, 0, global.battle_enemies, 0, _length)
	
	if (!_only_active_enemies){
		array_copy(_list, _length, obj_game.battle_system.battle_cleared_enemies, 0, array_length(obj_game.battle_system.battle_cleared_enemies))
	}
	
	return _list
}

function battle_get_box_width(_expected=false, _box=obj_battle_box){
	return (_expected ? _box.boxsize.x : _box.width)
}

function battle_get_box_height(_expected=false, _box=obj_battle_box){
	return (_expected ? _box.boxsize.y : _box.height)
}

function battle_get_box_rotation(_expected=false, _box=obj_battle_box){
	return (_expected ? _box.box_rotation : _box.image_angle)
}

function battle_get_box_x_position(_expected=false, _box=obj_battle_box){
	return (_expected ? _box.box_position.x : _box.x)
}

function battle_get_box_y_position(_expected=false, _box=obj_battle_box){
	return (_expected ? _box.box_position.y : _box.y)
}

function battle_get_box_x_origin(_relative=true, _expected=false, _box=obj_battle_box){
	return (_relative ? 0 : battle_get_box_x_position(_expected, _box)) + _box.box_origin.x
}

function battle_get_box_y_origin(_relative=true, _expected=false, _box=obj_battle_box){
	return (_relative ? 0 : battle_get_box_y_position(_expected, _box)) + _box.box_origin.y
}

function battle_get_state(){
	return obj_game.battle_system.battle_state
}

function battle_get_bullets_array(){
	return obj_game.battle_system.battle_bullets
}

function battle_get_menu_bullets_array(){
	return obj_game.battle_system.menu_bullets
}

function battle_get_damage_text_array(){
	return obj_game.battle_system.battle_damage_text
}

function battle_get_button_order_options_array(){
	return obj_game.battle_system.battle_button_order
}

function battle_get_button_options_amount(){
	return array_length(battle_get_button_order_options_array())
}

function battle_set_button_order_options(_array){
	obj_game.battle_system.battle_button_order = _array
}

function battle_set_button_selecting_left_function(_func=undefined){
	obj_game.battle_system.battle_button_selecting_left = _func
}

function battle_set_button_selecting_right_function(_func=undefined){
	obj_game.battle_system.battle_button_selecting_right = _func
}

function battle_set_button_selecting_up_function(_func=undefined){
	obj_game.battle_system.battle_button_selecting_up = _func
}

function battle_set_button_selecting_down_function(_func=undefined){
	obj_game.battle_system.battle_button_selecting_down = _func
}
