/// @description Bullet handling

if (other.can_damage and image_alpha >= 0.5 and invulnerability_frames <= 0 and (get_battle_state() == BATTLE_STATE.ENEMY_ATTACK or get_battle_state() == BATTLE_STATE.END_DODGE_ATTACK or is_player_battle_turn())){
	switch (mode){
		case SOUL_MODE.GRAVITY:{
			var _bullet = other
			var _orange = false
			
			with (gravity_data){
				if (orange_mode){
					_orange = true
					
					if (_bullet.type == BULLET_TYPE.ORANGE){
						if ((get_up_button(false) and direction == GRAVITY_SOUL.DOWN) or (get_down_button(false) and direction == GRAVITY_SOUL.UP) or (get_right_button(false) and direction == GRAVITY_SOUL.LEFT) or (get_left_button(false) and direction == GRAVITY_SOUL.RIGHT)){
							jump.speed = (2*jump.max_height/power(jump.duration, 2))*jump.duration*0.75
						
							instance_destroy(_bullet)
						}
					}else{
						damage_player_bullet_instance(_bullet, other)
					}
				}
			}
			
			if (_orange){
				break
			}
		}
		default:{
			if ((other.type == BULLET_TYPE.CYAN and is_player_soul_moving(self)) or (other.type == BULLET_TYPE.ORANGE and !is_player_soul_moving(self)) or (other.type != BULLET_TYPE.CYAN and other.type != BULLET_TYPE.ORANGE)){
				damage_player_bullet_instance(other, self)
			}
		break}
	}
}