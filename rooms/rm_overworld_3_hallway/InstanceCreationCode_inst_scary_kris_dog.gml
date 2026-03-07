add_instance_reference(id, "inst_scary_kris_dog")
event = false

sprite_change = function(){
	can_player_collide = false
	sprite_index = spr_hotdiggitydemondotcom
}
	
sprite_unchange = function(){
	can_player_collide = true
	sprite_index = spr_kris_dog
}

room_change = function(){
	room_persistent = true
	
	obj_player_overworld.can_collide = false //Turn off the collision checking of the player since it can touch one when interacting with this NPC in a certain position that may softlock the game.
	room_goto(rm_overworld_2_the_void)
	
	obj_game.start_room_function = function(){
		inst_kris_dog_angy.room_unchange = function(){
			obj_player_overworld.can_collide = true //Turn back on after all is done.
			room_goto(rm_overworld_3_hallway)
			
			obj_game.start_room_function = function(){
				overworld_dialog(["[bind_instance:inst_scary_kris_dog]Hey you still there?[w:20]\nYou should go find some water perhaps."])
				
				room_persistent = false
				obj_player_overworld.image_alpha = 1
			}
		}
		
		overworld_dialog(["[bind_instance:" + string(real(inst_kris_dog_angy.id)) + "]Achoo![w:20]\nI feel like someone is talking about me...","[func:" + string(inst_kris_dog_angy.id) + ",room_unchange]"])
		camera_set_view_target(view_camera[0], inst_kris_dog_angy)
		
		obj_player_overworld.image_alpha = 0
	}
}

interaction = function(){
	overworld_dialog(["[bind_instance:inst_scary_kris_dog]Boo![w:20]\nDid I scare you?","No?[w:20][func:inst_scary_kris_dog,sprite_change]\nHow about now?","Too scary?[w:20] Alright alright.[w:20][func:" + string(id) + ",sprite_unchange]\nThere[w:20], easy.","It's so easy to do that I don't understand how anyone could get stuck doing that.","[func:" + string(id) + ",room_change]"])
}