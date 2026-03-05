collided_with_player = false
innactive_timer = 0
timer = 0

step = function(){
	if (obj_game.state == GAME_STATE.PLAYER_CONTROL){
		timer++
		
		if (collided_with_player){
			innactive_timer++
		
			if (innactive_timer >= 120){
				image_blend = c_white
				innactive_timer = 0
				collided_with_player = false
			}
		}
	
		x = 180 + 140*dcos(2*timer)
	}
}

trigger_function = function(){
	if (obj_game.state == GAME_STATE.PLAYER_CONTROL){
		if (!collided_with_player){
			collided_with_player = true
			image_blend = c_gray
	
			var _attacks = [ENEMY_ATTACK.MAD_DUMMY_1, ENEMY_ATTACK.MAD_DUMMY_2]
			var _random_number = irandom(2)
	
			if (_random_number == 0){
				array_delete(_attacks, 0, 1)
			}else if (_random_number == 1){
				array_delete(_attacks, 1, 1)
			}
	
			start_attack(_attacks)
		}
	}
}