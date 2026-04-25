collided_with_player = false
innactive_timer = 0

step = function(){
	if (collided_with_player){
		innactive_timer++
		
		if (innactive_timer >= 120){
			image_blend = c_white
			innactive_timer = 0
			collided_with_player = false
		}
	}
}

trigger_function = function(){
	if (!collided_with_player){
		collided_with_player = true
		image_blend = c_gray
		
		var _attacks = [ENEMY_ATTACK.BOX_ATTACK]
	
		start_attack(_attacks,,,,,,, 240)
	}
}