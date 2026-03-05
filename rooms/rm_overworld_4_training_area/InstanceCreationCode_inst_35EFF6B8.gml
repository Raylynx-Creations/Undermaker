no_double_interaction = false

interaction = function(){
	if (no_double_interaction){
		no_double_interaction = false
		
		return
	}
	
	var _start_attack = function(){
		obj_game.dialog.next_dialog()
		start_attack(ENEMY_ATTACK.PLATFORM_1,,,,, 320, 240)
	}
	
	var _no_attack = function(){
		obj_game.dialog.next_dialog()
		no_double_interaction = true //This will make it so you don't reactivate the dialog interaction again.
	}
	
	create_plus_choice_option(PLUS_CHOICE_DIRECTION.LEFT, 120, "Yes", _start_attack)
	create_plus_choice_option(PLUS_CHOICE_DIRECTION.RIGHT, 120, "No", _no_attack)
	
	overworld_dialog(["[progress_mode:none][bind_instance:" + string(real(id)) + "]Do you want to test out the platform attacks?[w:30][func:" + string(start_plus_choice) + ", 320, 430]"],, false)
}