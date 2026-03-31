function death_reset(){
	perform_game_load()
	
	return 0
}

function battle_apply_rewards(_sound=true){
	global.player.gold += battle_gold
	global.player.exp += battle_exp
	global.player.next_exp -= battle_exp
	global.player.battle_atk = 0
	global.player.battle_def = 0
		
	if (global.player.next_exp <= 0){ //Here is where the stats are applied once the EXP is met.
		if (_sound){
			audio_play_sound(snd_player_love_up, 100, false)	
		}
			
		var _stats = global.stat_levels[global.player.lv]
			
		global.player.lv++
		global.player.atk = _stats.atk
		global.player.def = _stats.def
		global.player.next_exp += _stats.next_exp
		global.player.max_hp = _stats.max_hp
		global.player.hp_bar_width = _stats.hp_bar_width
	}
		
	battle_gold = 0
	battle_exp = 0
}

function battle_set_box_dialog(_dialogues, _x_offset=0, _face_sprite=undefined, _face_subimages=undefined){
	battle_dialog_x_offset = _x_offset
		
	battle_dialog.text_speed = 2
	battle_dialog.set_dialogues(_dialogues, obj_battle_box.box_size.x/2 - 15 - _x_offset/2, 0, _face_sprite, _face_subimages)
	battle_dialog.set_scale(2, 2)
	battle_dialog.set_container_sprite(-1)
	battle_dialog.set_container_tail_sprite(-1)
	battle_dialog.set_container_tail_mask_sprite(-1)
	battle_dialog.move_to(obj_battle_box.x - obj_battle_box.width/2 + 14.5 + battle_dialog_x_offset, obj_battle_box.y - obj_battle_box.height + 10)
		
	//By order of constant definition, BATTLE_STATE.END is the last integer that will keep the dialogs from progressing because it's the player moving in the UI or animations, the other states after that are meant that the player presses a button to advance the dialogs.
	if (battle_state <= BATTLE_STATE.END){
		battle_dialog.can_progress = false
	}
}

function battle_box_update_points_by_position(_x_offset, _y_offset, _box){
	if (_x_offset == 0 and _y_offset == 0){
		return
	}
	
	with (_box.box_polygon_points){
		var _length = array_length(inside)
		for (var _i = 0; _i < _length; _i += 2){
			inside[_i] += _x_offset
			inside[_i+1] += _y_offset
			outside[_i] += _x_offset
			outside[_i+1] += _y_offset
		}
		
		_length = array_length(triangles)
		for (var _i = 0; _i < _length; _i++){
			var _triangle = triangles[_i]
			for (var _j = 0; _j < 6; _j += 2){
				_triangle[_j] += _x_offset
				_triangle[_j+1] += _y_offset
			}
		}
	}
}

function battle_box_update_points_by_resize(_box){
	with (_box.box_polygon_points){
		default_points[0] = _box.x - round(_box.width)/2
		default_points[1] = _box.y - 5
		default_points[2] = _box.x + round(_box.width)/2
		default_points[3] = _box.y - 5
		default_points[4] = _box.x + round(_box.width)/2
		default_points[5] = _box.y - round(_box.height) - 5
		default_points[6] = _box.x - round(_box.width)/2
		default_points[7] = _box.y - round(_box.height) - 5
		
		update = true
	}
}

function battle_box_update_points_by_rotation(_angle_offset, _box){
	if (_angle_offset == 0){
		return
	}
	
	with (_box.box_polygon_points){
		var _origin_x = battle_get_box_x_origin(false,, _box)
		var _origin_y = battle_get_box_y_origin(false,, _box)
		
		var _length = array_length(inside)
		for (var _i = 0; _i < _length; _i += 2){
			var _direction = point_direction(_origin_x, _origin_y, inside[_i], inside[_i+1])
			var _distance = point_distance(_origin_x, _origin_y, inside[_i], inside[_i+1])
			
			inside[_i] = _origin_x + _distance*dcos(_direction)
			inside[_i+1] = _origin_y - _distance*dsin(_direction)
			
			_direction = point_direction(_origin_x, _origin_y, outside[_i], outside[_i+1])
			_distance = point_distance(_origin_x, _origin_y, outside[_i], outside[_i+1])
			
			outside[_i] += _origin_x + _distance*dcos(_direction)
			outside[_i+1] += _origin_y - _distance*dsin(_direction)
		}
		
		_length = array_length(triangles)
		for (var _i = 0; _i < _length; _i++){
			var _triangle = triangles[_i]
			for (var _j = 0; _j < 6; _j += 2){
				var _direction = point_direction(_origin_x, _origin_y, _triangle[_i], _triangle[_i+1])
				var _distance = point_distance(_origin_x, _origin_y, _triangle[_i], _triangle[_i+1])
				
				_triangle[_j] += _x
				_triangle[_j+1] += _y
			}
		}
	}
}

function battle_box_update_points_by_origin(_x_offset, _y_offset, _box){
	if (_x_offset == 0 and _y_offset == 0){
		return
	}
	
	with (_box.box_polygon_points){
		var _direction = _box.image_angle + 180
		var _x = _x_offset + _x_offset*dcos(_direction) + _y_offset*dsin(_direction)
		var _y = _y_offset + _y_offset*dcos(_direction) - _x_offset*dsin(_direction)
		
		var _length = array_length(inside)
		for (var _i = 0; _i < _length; _i += 2){
			inside[_i] += _x
			inside[_i+1] += _y
			outside[_i] += _x
			outside[_i+1] += _y
		}
		
		_length = array_length(triangles)
		for (var _i = 0; _i < _length; _i++){
			var _triangle = triangles[_i]
			for (var _j = 0; _j < 6; _j += 2){
				_triangle[_j] += _x
				_triangle[_j+1] += _y
			}
		}
	}
}

function battle_set_enemy_dialog(_enemy){
	if (typeof(_enemy.next_dialog) == "array"){
		_enemy.next_dialog[0] = "[font:" + string(int64(fnt_monster)) + "][color_rgb:0,0,0][asterisk:false]" + _enemy.next_dialog[0]
	}else{
		_enemy.next_dialog = "[font:" + string(int64(fnt_monster)) + "][color_rgb:0,0,0][asterisk:false]" + _enemy.next_dialog
	}
	
	var _dialog = new DialogSystem(_enemy.x + _enemy.bubble_x, _enemy.y + _enemy.bubble_y, _enemy.next_dialog, _enemy.bubble_width, 0, 1, 1,,,, _enemy.bubble_sprite, _enemy.bubble_tail_sprite, _enemy.bubble_tail_mask_sprite)
	
	_enemy.next_dialog = undefined
	
	array_push(battle_enemies_dialogs, _dialog)
}

function damage_player_bullet_instance(_bullet, _player){
	with (_player){
		var _prev_hp = global.player.hp
		global.player.hp = clamp(global.player.hp + ((_bullet.type == BULLET_TYPE.GREEN) ? _bullet.damage : -_bullet.damage), (battle_get_state() != BATTLE_STATE.ENEMY_ATTACK), global.player.max_hp)
		
		if (_prev_hp != global.player.hp){
			if (global.player.status_effect.type == PLAYER_STATUS_EFFECT.KARMIC_RETRIBUTION){
				global.player.status_effect.value = min(global.player.status_effect.value + _bullet.karma, _bullet.player.hp - 1, 40)
				_bullet.karma = min(_bullet.karma, 1) //There are more steps to karmic retribution but I'm doing it the simple way really.
			}
			
			if (_bullet.type == BULLET_TYPE.GREEN){
				audio_play_sound(snd_player_heal, 0, false)
			}else{
				audio_play_sound(snd_player_hurt, 0, false)
			}
			
			invulnerability_frames = global.player.invulnerability_frames
		}
	}
}
