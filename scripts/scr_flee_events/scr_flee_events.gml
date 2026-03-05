enum FLEE_EVENT{
	NORMAL,
	IMPROVED
}

function FleeEvent(_type, _success) constructor{
	type = _type
	success = _success
	is_finished = false
	
	switch (_type){
		case FLEE_EVENT.IMPROVED:{
			timer = 0
			
			audio_play_sound(snd_flee, 100, false)
			
			step = function(){
				with (obj_player_battle){
					if (!other.success and x <= 42){
						if (x == 42){
							audio_stop_sound(snd_flee)
							audio_play_sound(snd_switch_flip, 100, false)
							
							x--
							image_speed = 0
						}else if (image_angle < 90){
							image_angle += 9
							x--
							
							if (image_angle == 90){
								audio_play_sound(snd_player_hurt, 100, false)
								
								image_index = 1
							}
						}else if (x > 22){
							x -= 0.5
						}else{
							other.timer++
							
							if (other.timer >= 60){
								image_angle = 0
								image_speed = 1
								
								other.is_finished = true
							}
						}
					}else{
						x--
						
						if (x <= -10){
							other.is_finished = true
						}
					}
				}
			}
		break}
		default:{ //FLEE_EVENT.NORMAL
			if (!success){
				is_finished = true
			}
			
			step = function(){
				with (obj_player_battle){
					x--
				
					if (x <= -10){
						other.is_finished = true
					}
				}
			}
		break}
	}
}