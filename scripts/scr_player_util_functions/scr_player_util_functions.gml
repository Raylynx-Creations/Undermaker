function battle_move_player_to(_x, _y, _obj){
	with (_obj){
		move_to_x = _x
		move_to_y = _y
	}
}

function battle_move_player_from_boxs_center_to(_x, _y, _box=obj_battle_box, _obj=obj_player_battle){
	with (_obj){
		with (_box){
			other.x = x + _x
			other.y = y + _y + round(height)/2
		}
	}
}

function set_soul_mode(_mode, _args_struct=undefined, _obj=obj_player_battle){
	with (_obj){
		if (mode != _mode){
			conveyor_push.x = 0
			conveyor_push.y = 0
		}
	
		switch (_mode){
			case SOUL_MODE.NORMAL:{
				image_blend = c_red
				image_angle = 0
			break}
			case SOUL_MODE.GRAVITY:{
				with (gravity_data){
					if (other.mode != _mode){
						direction = GRAVITY_SOUL.DOWN
					}
					orange_mode = false
					jump.speed = 0
					jump.movement_offset = 0
					movement.speed = 0
					other.image_angle = 90*direction
			
					if (is_undefined(_args_struct)){
						other.image_blend = make_color_rgb(0,60,255)
					}else{
						if (variable_struct_exists(_args_struct, "box_bound") and !_args_struct.box_bound){
							box_bound = false
						}
					
						if (variable_struct_exists(_args_struct, "orange") and !_args_struct.orange){
							other.image_blend = make_color_rgb(0,60,255)
						}else{
							other.image_blend = make_color_rgb(255,127,0)
				
							orange_mode = true
							movement_direction = 0
						}
					}
				}
			break}
		}
	
		mode = _mode
	}
}

//Only applicable if soul_mode is SOUL_MODE.GRAVITY
function set_soul_gravity(_direction=GRAVITY_SOUL.DOWN, _slam=false, _obj=obj_player_battle){
	with (_obj){
		image_angle = 90*_direction
		
		with (gravity_data){
			direction = _direction
		
			if (_slam){
				jump.speed = -10
				slam = true
			}
		}
	}
}

function set_soul_trail(_trail=true, _obj=obj_player_battle){
	with (_obj){
		trail = _trail
	}
}

function is_player_soul_moving(_player=obj_player_battle){
	with (_player){
		var _extra_x = conveyor_push.x
		var _extra_y = conveyor_push.y
		
		_extra_x += platform_vel.x
		_extra_y += platform_vel.y
		
		if (mode == SOUL_MODE.GRAVITY){
			if (gravity_data.box_bound){
				_extra_x += obj_battle_box.x - obj_battle_box.xprevious
				_extra_y -= obj_battle_box.y - obj_battle_box.yprevious
			}
		}
		
		return x != xprevious + _extra_x or y != yprevious + _extra_y or move_x != _extra_x or move_y != _extra_y or (!is_undefined(move_to_x) and move_to_x != x + _extra_x) or (!is_undefined(move_to_y) and move_to_y != y + _extra_y)
	}
}

function is_player_battle_turn(){
	return obj_game.state == GAME_STATE.BATTLE and (battle_get_state() == BATTLE_STATE.PLAYER_BUTTONS or battle_get_state() == BATTLE_STATE.PLAYER_ENEMY_SELECT or battle_get_state() == BATTLE_STATE.PLAYER_ACT or battle_get_state() == BATTLE_STATE.PLAYER_ITEM or battle_get_state() == BATTLE_STATE.PLAYER_MERCY)
}

function heal_player(_number){
	global.player.hp = min(global.player.hp + abs(_number), global.player.max_hp)
	
	audio_play_sound(snd_player_heal, 0, false)
}

function damage_player(_number, _invulnerability_frames=-1, _player=obj_player_battle){
	global.player.hp = max(global.player.hp - abs(_number), 0)
	_player.invulnerability_frames = ((_invulnerability_frames == -1) ? global.player.invulnerability_frames : _invulnerability_frames)
	
	audio_play_sound(snd_player_hurt, 0, false)
}

function is_overworld_player_moving(_player=obj_player_overworld){
	with (_player){
		return ((x_previous != x or y_previous != y) and obj_game.state == GAME_STATE.PLAYER_CONTROL)
	}
}

function is_overworld_player_running(_player=obj_player_overworld){
	return (_player.can_run and get_cancel_button() and is_overworld_player_moving(_player))
}

function get_player_atk(){
	return global.player.atk + global.player.battle_atk
}

function get_player_def(){
	return global.player.def + global.player.battle_def
}

function get_player_equipped_atk(){
	return global.player.equipped_atk
}

function get_player_equipped_def(){
	return global.player.equipped_def
}

function get_player_total_atk(){
	return get_player_atk() + get_player_equipped_atk()
}

function get_player_total_def(){
	return get_player_def() + get_player_equipped_def()
}
