add_instance_reference(id, "inst_flowey_5")

no_double_interaction = false

end_battle = function(_enemies_left, _enemies_killed, _enemies_spared, _battle_fled){ //Custom function for the encounter
	//Although it's not any different from the normal one, you can write custom stuff here
	var _text = ""
		
	var _length = array_length(_enemies_left)
	for (var _i=0; _i<_length; _i++){
		var _enemy = _enemies_left[_i]
		_text += string_concat(_enemy.name, " was left alive.\n") //These dialogs are not in files, these are to demonstrate you can do stuff here with enemies.
	}
	
	_length = array_length(_enemies_killed)
	for (var _i=0; _i<_length; _i++){
		var _enemy = _enemies_killed[_i]
		_text += string_concat(_enemy.name, " was killed.\n")
	}
		
	_length = array_length(_enemies_spared)
	for (var _i=0; _i<_length; _i++){
		var _enemy = _enemies_spared[_i]
		_text += string_concat(_enemy.name, " was spared.\n")
	}
		
	_text += string_concat("You ", ((_battle_fled) ? "fled" : "didn't flee"), " the battle.")
	
	overworld_dialog(_text,, (obj_player_overworld.y > 210))
}

interaction = function(){
	if (no_double_interaction){
		no_double_interaction = false
		
		return
	}
	
	var _start_battle = function(){
		obj_game.dialog.next_dialog()
		
		var _enemies = [ENEMY.MONSTER_3, ENEMY.MONSTER_3]
		var _initial_dialog = get_encounter_initial_dialog(_enemies)
		start_battle(_enemies, _initial_dialog, BATTLE_START_ANIMATION.NO_WARNING,, BATTLE_BACKGROUND.MOVING_SQUARE_GRID,, end_battle)
	}
	
	var _no_battle = function(){
		obj_game.dialog.next_dialog()
		no_double_interaction = true //This will make it so you don't reactivate the dialog interaction again.
	}
	
	var _options = global.dialogues.arena.flowey_5.options
	create_plus_choice_option(PLUS_CHOICE_DIRECTION.LEFT, 120, _options[0], _start_battle)
	create_plus_choice_option(PLUS_CHOICE_DIRECTION.RIGHT, 120, _options[1], _no_battle)
	
	overworld_dialog(global.dialogues.arena.flowey_5.dialog,, false)
}