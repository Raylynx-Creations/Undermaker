function PlayerAttack(_weapon, _enemie) constructor{
	enemy_attacked = _enemie 
	
	switch (_weapon) {
		case ITEM.WILTED_VINE:{
			x = (irandom(1) == 0) ? -280 : 280
			x2 = 0
			dir = sign(-x)
			vel = 7*dir
			timer = 0
			timer2 = 0
			damage = 0
			attacked = false
			color = c_white
			color2 = c_gray
			second_bar = false
			
			step = function(){
				if (!attacked){
					if (second_bar){
						timer2++
						vel = clamp(vel - dir/2, -7, 7)
						x2 += vel
						
						if (sign(vel) == sign(-dir)){
							color2 = c_white
							if (global.confirm_button){
								audio_play_sound(snd_player_slice, 0, false)
								attacked = true
							
								var _bonus = 0
								if (x == x2){
									color2 = c_yellow
									_bonus = 0.2
								}else if (abs(x - x2) > 60){
									color2 = c_red
								}
							
								damage = enemy_attacked.calculate_damage(((184 - abs(x - x2))/184)*(280 - abs(x))/350 + _bonus)
							}
						}
						
						if (abs(x - x2) > 91 and !attacked){
							audio_play_sound(snd_player_slice, 0, false)
							attacked = true
							
							damage = enemy_attacked.calculate_damage((280 - abs(x))/700)
						}
					}else{
						x += vel
						if (global.confirm_button){
							if (x <= 140 and x >= -140){
								//Sound here maybe
								second_bar = true
								x2 = x
								
								if (x == 0){
									color = c_yellow
								}
							}else{
								audio_play_sound(snd_player_slice, 0, false)
								attacked = true
								color = c_red
								
								damage = enemy_attacked.calculate_damage((280 - abs(x))/350)
							}
						}
						
						if (x > 280 or x < -280){
							enemy_attacked.hurt("MISS")
							array_push(get_battle_damage_text_array(), new DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NO_ANIMATION, "MISS", c_gray, enemy_attacked.x + enemy_attacked.damage_ui_x, enemy_attacked.y + enemy_attacked.damage_ui_y))
							
							battle_go_to_state(BATTLE_STATE.ENEMY_DIALOG)
						}
					}
				}else{
					timer++
					if (second_bar){
						timer2++
						
						if (abs(x - x2) > 91){
							x2 += vel
						}
					}
					
					if (timer == 60){
						var _x = enemy_attacked.x + enemy_attacked.damage_ui_x
						var _y = enemy_attacked.y + enemy_attacked.damage_ui_y
						var _hp = enemy_attacked.hp
						var _max_hp = enemy_attacked.max_hp
						damage = enemy_attacked.hurt(damage)
						
						if (typeof(damage) == "string"){
							array_push(get_battle_damage_text_array(), new DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NORMAL, damage, c_gray, _x, _y, false))
						}else{
							var _text_color = c_white
							if (damage < 0){
								_text_color = c_lime
							}else if (damage > 0){
								_text_color = c_red
							}
							
							array_push(get_battle_damage_text_array(), new DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NORMAL, string(damage), _text_color, _x, _y, true, _hp, _max_hp, damage, enemy_attacked.hp_bar_width_attacked, enemy_attacked.hp_bar_color))
						}
					}
					
					if (timer >= 150){
						battle_go_to_state(BATTLE_STATE.ENEMY_DIALOG)
					}
				}
			}
			
			draw = function(){
				draw_sprite(spr_player_target, 0, obj_battle_box.x, obj_battle_box.y - round(obj_battle_box.height)/2 - 5)
				
				var _anim = 0
				if (second_bar){
					_anim = timer2
				}else{
					_anim = timer
				}
				
				draw_sprite_ext(spr_player_target_bar, floor(_anim/4.8)%2, obj_battle_box.x + x, obj_battle_box.y - round(obj_battle_box.height)/2 - 5, 1, 1, 0, color, 1)
				
				if (second_bar){
					if (x == x2){
						draw_sprite_ext(spr_player_target_bar, floor(timer/4.8)%2, obj_battle_box.x + x2, obj_battle_box.y - round(obj_battle_box.height)/2 - 5, 1 + timer/60, 1 + timer/60, 0, color2, max(1 - timer/40, 0))
					}else{
						draw_sprite_ext(spr_player_target_bar, floor(timer/4.8)%2, obj_battle_box.x + x2, obj_battle_box.y - round(obj_battle_box.height)/2 - 5, 1, 1, 0, color2, (abs(x - x2) > 91) ? max(1 - timer/30, 0) : 1)
					}
				}
				if (timer > 0 and timer < 60){
					draw_sprite(spr_player_slice_attack, floor(timer/12), enemy_attacked.x + enemy_attacked.player_attack_x, enemy_attacked.y + enemy_attacked.player_attack_y)
				}
			}
		break}
		default:{
			x = -280
			timer = 0
			damage = 0
			attacked = false
			
			step = function(){
				if (!attacked){
					x += 7
					if (global.confirm_button){
						attacked = true
						
						audio_play_sound(snd_player_slice, 0, false)
						
						damage = enemy_attacked.calculate_damage((280 - abs(x))/280)
					}
					
					if (x > 280){
						enemy_attacked.hurt("MISS")
						array_push(get_battle_damage_text_array(), new DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NO_ANIMATION, "MISS", c_gray, enemy_attacked.x + enemy_attacked.damage_ui_x, enemy_attacked.y + enemy_attacked.damage_ui_y))
						
						battle_go_to_state(BATTLE_STATE.ENEMY_DIALOG)
					}
				}else{
					timer++
					if (timer == 60){
						var _x = enemy_attacked.x + enemy_attacked.damage_ui_x
						var _y = enemy_attacked.y + enemy_attacked.damage_ui_y
						var _hp = enemy_attacked.hp
						var _max_hp = enemy_attacked.max_hp
						damage = enemy_attacked.hurt(damage)
						
						if (typeof(damage) == "string"){
							array_push(get_battle_damage_text_array(), new DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NORMAL, damage, c_gray, _x, _y, false))
						}else{
							var _text_color = c_white
							if (damage < 0){
								_text_color = c_lime
							}else if (damage > 0){
								_text_color = c_red
							}
							
							array_push(get_battle_damage_text_array(), new DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NORMAL, string(damage), _text_color, _x, _y, true, _hp, _max_hp, damage, enemy_attacked.hp_bar_width_attacked, enemy_attacked.hp_bar_color))
						}
					}
					
					if (timer >= 150){
						battle_go_to_state(BATTLE_STATE.ENEMY_DIALOG)
					}
				}
			}
			
			draw = function(){
				draw_sprite(spr_player_target, 0, obj_battle_box.x, obj_battle_box.y - round(obj_battle_box.height)/2 - 5)
				draw_sprite(spr_player_target_bar, floor(timer/4.8)%2, obj_battle_box.x + x, obj_battle_box.y - round(obj_battle_box.height)/2 - 5)
				
				if (timer > 0 and timer < 60){
					draw_sprite(spr_player_slice_attack, floor(timer/12), enemy_attacked.x + enemy_attacked.player_attack_x, enemy_attacked.y + enemy_attacked.player_attack_y)
				}
			}
		break}
	}
}