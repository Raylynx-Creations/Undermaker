add_instance_reference(id, "inst_kris_2")

movement_speed = 2

sprite_index = spr_kris_dog

move_entity = function(){
	path_start(path_npc_movement_1, movement_speed, path_action_stop, true)
	movement_speed = -movement_speed
}

interaction = function(_direction){
	if (path_position == path_positionprevious){
		overworld_dialog(global.dialogues.hot_room.kris_2,, false)
	}
}

after_step = function(){ //Must use after_step (which run in the end_step event) function since paths update after the update event (which run on the step event)
	if (path_position == 1 and path_positionprevious != 1){
		image_xscale = -image_xscale
	}
}