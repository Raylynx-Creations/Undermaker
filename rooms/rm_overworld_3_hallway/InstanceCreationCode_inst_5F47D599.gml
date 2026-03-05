array_pop(collision_ids) //This one doesn't need collision ids.

timer = -120
direction_to_go = choose(0,4,8,12)
count = true

sprite_index = spr_unknown_walk

interaction = function(_direction){
	count = false
	timer = -irandom_range(75, 120)
	
	overworld_dialog(["I'm a different moving entity.[w:20]\nI'm made so I take into consideration your position and my surroundings.","Unlike the other one.[w:20]\nThis means I move where there's space always.","Try as you want, you can't force me into a corner.","Your collision is rectangular[w:20], that's why you can't.","And even if you somehow manage to do it by changing your collision[w:20], I just won't move."],, (obj_player_overworld.y > 210))
	
	image_index = (8 + _direction/22.5)%16
}

step = function(){
	if (count){
		timer++
	}else if (obj_game.dialog.is_finished()){
		count = true
	}
	
	if (timer == 0 and direction_to_go != 1){
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
			case 12: //Left - it is not default so I can put a not valid direction so it doesn't move.
				x -= 2
			break
		}
		
		switch (timer){
			case 1: case 13:
				image_index++
			break			
			case 20:
				timer = -irandom_range(75, 120)
				do{
					direction_to_go = choose(0,4,8,12) //Doesn't take into account if it's going against a wall.
					
					if (!place_empty(x, y + 40, [obj_player_overworld, obj_collision]) and !place_empty(x + 40, y, [obj_player_overworld, obj_collision]) and !place_empty(x, y - 40, [obj_player_overworld, obj_collision]) and !place_empty(x - 40, y, [obj_player_overworld, obj_collision])){
						direction_to_go = 1
						
						break
					}
				}until (!place_meeting(x + 40*dsin(22.5*direction_to_go), y + 40*dcos(22.5*direction_to_go), obj_player_overworld) and !place_meeting(x + 40*dsin(22.5*direction_to_go), y + 40*dcos(22.5*direction_to_go), obj_collision))
			break
		}
	}
}