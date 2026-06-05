add_instance_reference(id, "inst_entity_11")

timer = 0
has_interacted = false
dialog_1 = new DialogSystem(self, 440, 740, [], 50,,,,,,, spr_box_normal, spr_box_normal_tiny_tail, spr_box_normal_mask)
dialog_2 = new DialogSystem(self, 360, 780, [], 50,,,,,,, spr_box_normal, spr_box_normal_tiny_tail, spr_box_normal_mask)
dialog_3 = new DialogSystem(self, 490, 780, [], 50,,,,,,, spr_box_normal, spr_box_normal_tiny_tail, spr_box_normal_mask)
dialog_1.set_container_tail_position(22, 50)
dialog_2.set_container_tail_position(90, 30)
dialog_3.set_container_tail_position(-15, 30)


detect_movement = function(){
	return (global.up_hold_button or global.down_hold_button or global.right_hold_button or global.left_hold_button)
}

interaction = function(){
	if (timer > 0 and obj_game.dialog.is_finished()){
		timer = -300
		overworld_dialog(global.dialogues.the_void.entity_11.dialog, false)
		dialog_1.bind_instance(undefined)
		dialog_2.bind_instance(undefined)
		dialog_3.bind_instance(undefined)
	}
}

step = function(){
	timer++
	
	//You will flow and slow your game if you keep using add_dialogues constantly and stay in the same room, eventually the array becomes too big to handle and we get somewhat of a memory leak, use instead set_dialogues.
	//You can debug the data of these with add_dialogues and set_dialogues so you see the difference.
	if (timer%180 == 61){
		dialog_1.set_dialogues(self, global.dialogues.the_void.entity_11.dialog_1)
		//dialog_1.add_dialogues(global.dialogues.the_void.entity_11.dialog_1)
		dialog_3.bind_instance(undefined)
	}
	
	if (timer%180 == 121){
		dialog_2.set_dialogues(self, global.dialogues.the_void.entity_11.dialog_2)
		//dialog_2.add_dialogues(global.dialogues.the_void.entity_11.dialog_2)
		dialog_1.bind_instance(undefined)
	}
	
	if (timer%180 == 1){
		dialog_3.set_dialogues(self, global.dialogues.the_void.entity_11.dialog_3)
		//dialog_3.add_dialogues(global.dialogues.the_void.entity_11.dialog_3)
		dialog_2.bind_instance(undefined)
	}
	
	dialog_1.step()
	dialog_2.step()
	dialog_3.step()
}

draw = function(){
	draw_self()
	dialog_1.draw()
	dialog_2.draw()
	dialog_3.draw()
}