/*
This function constructor defines the player attacking the monsters, you just have to fill in the code for your own custom made ways the player can attack.
The engine automatically calls this constructor as needed, so you don't have to worry about calling the function.

INTEGER _weapon --------------> It is a constant of ITEM which determinates the type of player attack that happens, usually you have defined the ITEM as a weapon for this to work of course.
STRUCT OF ENEMY DATA _enemie -> Reference to the enemy the player is targetting for attacking it.

CONSTRUCTS -> STRUCT OF PLAYER ATTACK DATA --Represents the player attack for the engine to execute its behavior.
*/
function PlayerAttack(_weapon, _enemie) constructor{
	enemy_attacked = _enemie //Save the reference in a variable so you can use it on the functions of this constructor.
	player_attack_done = false //Flag variable that when set to true, it makes it so the player attack finishes.
	
	//These are the only two function variables this constructor executes, they should be pretty self explanatory at this point.
	//step = undefined //Step function to iterate the behavior.
	//draw = undefined //Drawing function to draw on screen stuff.
	
	//If you want one of your weapons to hit all enemies, use the appropiate battle_get_* functions for fetching and handling the enemies.
	switch (_weapon) {
		case ITEM.WILTED_VINE:{ //These are some examples of player attacks assigned to an ITEM that you can equip, all the variables and stuff in it are unique to how you want the attack to behave, there's nothing necessary, other than defining the functions step and draw and the player_attack_done variable.
			//Variables and data needed for this attack, you can use some of the battle_* functions here too like the battle_resize_box().
			x = (irandom(1) == 0) ? -280 : 280 //Random direction of the attack
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
			
			//Logic of the attack
			step = function(){
				if (!attacked){ //This is the input part, the little minigame you play to calculate how much damage you do to the enemie
					if (second_bar){
						timer2++
						vel = clamp(vel - dir/2, -7, 7)
						x2 += vel
						
						if (sign(vel) == sign(-dir)){
							color2 = c_white
							if (get_confirm_button(false)){
								audio_play_sound(snd_player_slice, 0, false)
								attacked = true
							
								var _bonus = 0
								if (x == x2){
									color2 = c_yellow
									_bonus = 0.2
								}else if (abs(x - x2) > 60){
									color2 = c_red
								}
							
								damage = enemy_attacked.calculate_damage(((184 - abs(x - x2))/184)*(280 - abs(x))/350 + _bonus) //Whenever the attack is done, you call the calculate_damage of the enemie being attacked and perform animations as intended.
							}
						}
						
						if (abs(x - x2) > 91 and !attacked){
							audio_play_sound(snd_player_slice, 0, false)
							attacked = true
							
							damage = enemy_attacked.calculate_damage((280 - abs(x))/700) //The only argument you pass is like a multiplier to the damage the player can make to the enemie, which is then used in the proper function in the scr_enemies.
						}
					}else{
						x += vel
						
						if (get_confirm_button(false)){
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
						
						//This is the miss part by not interacting with anything on the attack, finish the attack.
						if (x > 280 or x < -280){
							enemy_attacked.hurt("MISS") //This is for data management, it doesn't display it on screen, no need to use language functions, keep it consisten for your code with a string and do stuff as you need.
							//This is how you show damage UI numbers.
							array_push(battle_get_damage_text_array(), DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NO_ANIMATION, battle_get_ui_damage_text("miss"), c_gray, enemy_attacked.x + enemy_attacked.damage_ui_x, enemy_attacked.y + enemy_attacked.damage_ui_y))
							
							player_attack_done = true //Flag to finish the player attack.
						}
					}
				}else{ //Here no more inputs are taken and only animations data is performed, the attack happens.
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
						damage = enemy_attacked.hurt(damage) //Apply the hurt damage to the enemie and set off the flags for animation in that function.
						
						//We receive the damage back from the hurt function either as string or number, we handle it accordingly here.
						if (typeof(damage) == "string"){
							array_push(battle_get_damage_text_array(), DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NORMAL, damage, c_gray, _x, _y,, false))
						}else{
							var _text_color = c_white
							if (damage < 0){
								_text_color = c_lime
							}else if (damage > 0){
								_text_color = c_red
							}
							
							array_push(battle_get_damage_text_array(), DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NORMAL, string(damage), _text_color, _x, _y,, enemy_attacked.show_hp, _hp, _max_hp, damage, enemy_attacked.hp_bar_width_attacked, enemy_attacked.hp_bar_color))
						}
					}
					
					if (timer >= 150){
						player_attack_done = true //The attack is done
					}
				}
			}
			
			//Draw stuff on screen on the battle box's layer, if you need a different layer, use an obj_renderer in the step function and define it on create of these events.
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
		default:{ //This is the default attacking bar that you all know.
			x = -280
			timer = 0
			damage = 0
			attacked = false
			
			//Logic of the player attack.
			step = function(){
				if (!attacked){ //Attack is happening
					x += 7
					if (get_confirm_button(false)){
						attacked = true //Set flag
						
						audio_play_sound(snd_player_slice, 0, false)
						
						damage = enemy_attacked.calculate_damage((280 - abs(x))/280)
					}
					
					//When no input.
					if (x > 280){
						enemy_attacked.hurt("MISS") //This is for data management, it doesn't display it on screen, no need to use language functions, keep it consisten for your code with a string and do stuff as you need.
						array_push(battle_get_damage_text_array(), DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NO_ANIMATION, battle_get_ui_damage_text("miss"), c_gray, enemy_attacked.x + enemy_attacked.damage_ui_x, enemy_attacked.y + enemy_attacked.damage_ui_y))
						
						player_attack_done = true
					}
				}else{ //Player defined their precission adn you can proceed with the attack animation data.
					timer++
					if (timer == 60){
						var _x = enemy_attacked.x + enemy_attacked.damage_ui_x
						var _y = enemy_attacked.y + enemy_attacked.damage_ui_y
						var _hp = enemy_attacked.hp
						var _max_hp = enemy_attacked.max_hp
						damage = enemy_attacked.hurt(damage)
						
						if (typeof(damage) == "string"){
							array_push(battle_get_damage_text_array(), DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NORMAL, damage, c_gray, _x, _y,, false))
						}else{
							var _text_color = c_white
							if (damage < 0){
								_text_color = c_lime
							}else if (damage > 0){
								_text_color = c_red
							}
							
							array_push(battle_get_damage_text_array(), DamageUIAnimation(DAMAGE_UI_ANIMATION_TYPE.NORMAL, string(damage), _text_color, _x, _y,, enemy_attacked.show_hp, _hp, _max_hp, damage, enemy_attacked.hp_bar_width_attacked, enemy_attacked.hp_bar_color))
						}
					}
					
					if (timer >= 150){
						player_attack_done = true
					}
				}
			}
			
			//Draw stuff on the box layer.
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