can_overlap = true
can_player_collide = false
depth_ordering = false

depth = 100 //Background depth.
sprite_index = spr_rock_button

step = function(){
	if (place_meeting(x, y, inst_rock_1) or place_meeting(x, y, inst_rock_2)){
		image_index = 1
	}else{
		image_index = 0
	}
}