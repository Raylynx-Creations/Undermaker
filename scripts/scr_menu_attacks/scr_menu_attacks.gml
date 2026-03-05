enum MENU_ATTACK{
	MENU_ATTACK, //Very redundant heheh
	BUTTON_ATTACK,
	MENU_AND_BUTTON_ATTACK
}

function MenuAttack(_attack_name, _position, _damage) constructor{
	timer = 0
	menu_attack_done = false
	
	step = undefined
	force_end = undefined //Use this function to force clean the bullets on screen and clear resources in case the player goes too fast, and these may intervene on the dodging of the enemy attack actually.
	//By default you must make sure the bullets on their own can clean themselves if the player doesn't rush it, you can just never set menu_attack_done if you want to use it as your safe cleaning function.
	//The system by default deletes all bullets that are in the obj_game.menu_bullets, so if you don't require further action after that, you can just the need of force_end function at all.
	
	switch (_attack_name){
		case MENU_ATTACK.MENU_ATTACK:{ //This is how you would do it the manual way, this is just for one single bullet, more complex behaviors will have more code, you can simply a lot like in the next menu attack.
			bullet = instance_create_depth(-20, 290, 0, obj_battle_bullet)
			with (bullet){
				sprite_index = spr_circle_bullet
				damage = _damage
			}
			
			step = function(){
				timer++
				
				bullet.x = -20 + 130*dsin(2*timer)
				
				if (timer == 90){
					if (is_player_battle_turn()){
						timer = 0
					}else{
						instance_destroy(bullet)
						menu_attack_done = true //If it reaches this point it will not execute the force_end function
					}
				}
			}
			
			force_end = function(){
				instance_destroy(bullet)
			}
		break}
		case MENU_ATTACK.BUTTON_ATTACK:{ //This one doesn't require force_end function since it's managed automatically by the engine by just inserting the bullets on a table.
			//To avoid moving every bullet in the update function of the menu attack, you can just use the update of the bullets themselves, I made a custom menu_spawn_bullet for this case, that way we only use the update function to offset the bullets.
			//Mind the function is a bit more complex since it accounts for orange, blue and green bullet types too and some behavior you see on the normal attacks.
			damage = _damage
			menu_spawn_bullet(spr_circle_bullet, 516, 500, 90,, 301, damage)
			menu_spawn_bullet(spr_circle_bullet, 201, 500, 90,, 301, damage)
			
			//array_push(obj_game.menu_bullets, bullet) //We push the bullets inside this array, the function that creates the bullet already does it, so no need to do further action.
			
			step = function(){
				timer++
				
				if (timer == 45){ //Spawn the other two set of bullets
					menu_spawn_bullet(spr_circle_bullet, 361, 500, 90,, 301, damage)
					menu_spawn_bullet(spr_circle_bullet, 48, 500, 90,, 301, damage)
					
					step = undefined //We even disable update function since it's not needed anymore
				}
			}
		break}
		case MENU_ATTACK.MENU_AND_BUTTON_ATTACK:{ //Full simplification of both menu attacks combined.
			damage = _damage
			menu_spawn_bullet(spr_circle_bullet, -20, 290, 0, true,, damage) //This one has an argument that is adapted to simplify the code here, does the same behavior as the very first one above... sort of.
			menu_spawn_bullet(spr_circle_bullet, 516, 500, 90,, 301, damage)
			menu_spawn_bullet(spr_circle_bullet, 201, 500, 90,, 301, damage)
			
			//array_push(obj_game.menu_bullets, bullet) //We push the bullets inside this array, the function that creates the bullet already does it, so no need to do further action.
			
			step = function(){
				timer++
				
				if (timer == 45){ //Spawn the other two set of bullets
					menu_spawn_bullet(spr_circle_bullet, 361, 500, 90,, 301, damage)
					menu_spawn_bullet(spr_circle_bullet, 48, 500, 90,, 301, damage)
					
					step = undefined //We even disable update function since it's not needed anymore
				}
			}
		break}
	}
}