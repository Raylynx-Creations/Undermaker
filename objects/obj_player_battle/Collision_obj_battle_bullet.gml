/// @description Bullet handling

if (other.box_depth != box_depth){
	return
}

if (!is_undefined(other.when_colliding)){
	other.when_colliding()
}

//If the player collides with a bullet that can_damage and it's visible by greater than 0.5 alpha and it's on the appropiate battle state to damage, then follow along for damaging
if (instance_exists(other) and other.can_damage and image_alpha >= 0.5 and invulnerability_frames <= 0 and (battle_get_state() == BATTLE_STATE.ENEMY_ATTACK or battle_get_state() == BATTLE_STATE.END_DODGE_ATTACK or is_player_battle_turn())){
	switch (mode){
		//Gravity soul behaves in a unique way with blue and orange bullets
		//They cannot be damage by orange if they are in the air, but they can be hurt by blue if they are in the air, regardless of if you are pressing or not a movement key
		//If you want to change that, the place to do that is the function damage_player_bullet_instance
		case SOUL_MODE.GRAVITY:{
			var _bullet = other
			var _orange = false
			
			with (gravity_data){
				if (orange_mode){
					_orange = true
					
					//If the bullet is orange, and you are orange soul, you are not damaged as you're always moving, but you can parry them by pressing the jump button again, consuming the bullet and giving a jump boost of 0.75 your maximum jump
					//Due to this nature of the orange soul, blue bullets are essentially white bullets for the orange soul
					if (_bullet.type == BULLET_TYPE.ORANGE){
						if ((get_up_button(false) and direction == GRAVITY_SOUL.DOWN) or (get_down_button(false) and direction == GRAVITY_SOUL.UP) or (get_right_button(false) and direction == GRAVITY_SOUL.LEFT) or (get_left_button(false) and direction == GRAVITY_SOUL.RIGHT)){
							jump.speed = (2*jump.max_height/power(jump.duration, 2))*jump.duration*0.75
						
							instance_destroy(_bullet) //Consume the bullet
						}
					//If it's another color, do the normal checking, as it will damage the soul if it's a blue bullet cause it's constantly moving
					}else{
						if (!is_undefined(_bullet.before_hit)){
							_bullet.before_hit()
						}
						
						damage_player_bullet_instance(_bullet, other)
						
						if (!is_undefined(_bullet.after_hit)){
							_bullet.after_hit()
						}
					}
				}
			}
			
			//If it's an orange soul, the checking stops here, but if it's blue it continues down the next one to apply the effects normally for the bullet types
			if (_orange){
				break
			}
		}
		//Default bullet type checking, orange damages if you move, blue damage if you don't move, green heals, white always damages (gray is not coded, but you can add an exception rule if you add the type)
		default:{
			if ((other.type == BULLET_TYPE.CYAN and is_player_soul_moving(self)) or (other.type == BULLET_TYPE.ORANGE and !is_player_soul_moving(self)) or (other.type != BULLET_TYPE.CYAN and other.type != BULLET_TYPE.ORANGE)){
				if (!is_undefined(other.before_hit)){
					other.before_hit()
				}
				
				damage_player_bullet_instance(other, self)
				
				if (!is_undefined(other.after_hit)){
					other.after_hit()
				}
			}
		break}
	}
}