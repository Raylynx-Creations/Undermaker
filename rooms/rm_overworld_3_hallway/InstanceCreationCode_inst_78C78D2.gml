array_push(collision_ids, 1) //Add collision type of 1.

timer = -120
direction_to_go = choose(0,4,8,12)
count = true

sprite_index = spr_unknown_walk

interaction = function(_direction){
	count = false
	timer = -irandom_range(75, 120)
	
	overworld_dialog(["I'm a moving entity.[w:20]\nI'm made so I turn towards you when you talk to me.","I also push you around if you are on the way I wanna go.","I'm dumb enough to not know when I'm hitting a wall so I still move towards the direction I choose","I use the exact same sprite you have since there's not another one available.","No hard feelings about that[w:20], right?"],, (obj_player_overworld.y > 210))
	
	image_index = (8 + _direction/22.5)%16
}

step = function(){
	if (count){
		timer++
	}else if (obj_game.dialog.is_finished()){
		count = true
	}
	
	if (timer == 0){
		image_index = direction_to_go
	}else if (timer > 0){
		switch (direction_to_go){
			case 0: //Down
				y += 2
			break
			case 4: //Right
				x += 2
			break
			case 8: //Up
				y -= 2
			break
			default: //Left
				x -= 2
			break
		}
		
		switch (timer){
			case 1: case 13:
				image_index++
			break			
			case 20:
				timer = -irandom_range(75, 120)
				direction_to_go = choose(0,4,8,12) //Doesn't take into account if it's going against a wall.
			break
		}
	}
}