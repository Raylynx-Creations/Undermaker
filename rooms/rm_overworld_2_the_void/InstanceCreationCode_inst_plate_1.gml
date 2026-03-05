can_overlap = true
can_player_collide = false
depth_ordering = false
can_update = true //Variable for handling its animation with one of the kris dog entities (yes I'm gonna call them like that XD).

depth = 100 //Background depth
sprite_index = spr_rock_button

step = function(){
	if (can_update){
		if (place_meeting(x, y, inst_rock_1) or place_meeting(x, y, inst_rock_2)){
			image_index = 1
		}else{
			image_index = 0
		}
	
		if (!global.save_data.puzzle_1 and image_index and inst_plate_2.image_index){
			inst_rock_1.can_player_push = false
			inst_rock_2.can_player_push = false
	
			overworld_dialog(["Test successful!", "You are done with this puzzle."],, false)
		
			global.save_data.puzzle_1 = true
			inst_collision_door.when_colliding = undefined
			inst_collision_door.collision_id = 1
			inst_collision_door.image_blend = c_red
		}
	}
}