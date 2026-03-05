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

function set_soul_mode(_mode, _args=undefined, _obj=obj_player_battle){
	with (_obj){
		set_mode(_mode, _args)
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
	return obj_game.state == GAME_STATE.BATTLE and (get_battle_state() == BATTLE_STATE.PLAYER_BUTTONS or get_battle_state() == BATTLE_STATE.PLAYER_ENEMY_SELECT or get_battle_state() == BATTLE_STATE.PLAYER_ACT or get_battle_state() == BATTLE_STATE.PLAYER_ITEM or get_battle_state() == BATTLE_STATE.PLAYER_MERCY)
}

function heal_player(_number){
	global.player.hp = min(global.player.hp + abs(_number), global.player.max_hp)
	
	audio_play_sound(snd_player_heal, 0, false)
}

function damage_player(_number){
	global.player.hp = max(global.player.hp - abs(_number), 0)
	
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
