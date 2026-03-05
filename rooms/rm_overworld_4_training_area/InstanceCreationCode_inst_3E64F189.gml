timer = 0
steps = 0

end_battle = function(_enemies_left, _enemies_killed, _enemies_spared, _battle_fled){ //Custom function for the encounter
	//Although it's not any different from the normal one, you can write custom stuff here
	var _text = ""
		
	var _length = array_length(_enemies_left)
	for (var _i=0; _i<_length; _i++){
		var _enemy = _enemies_left[_i]
		_text += string_concat(_enemy.name, " was left alive.\n")
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

trigger_function = function(){
	if (obj_game.state == GAME_STATE.PLAYER_CONTROL and is_overworld_player_moving()){
		timer += 1 + is_overworld_player_running()
		
		if (timer >= 6){ //I choose the steps to be 6 frames
			timer -= 6
		
			steps++
		}
		
		if (steps >= 31){
			timer = 0
			steps = 0
			
			var _enemies = get_random_enemies(ENCOUNTER_ENEMIE_SELECTION.PICK_ONE, [ENEMY.MONSTER_1, ENEMY.MONSTER_2])
			var _dialog = get_encounter_initial_dialog(_enemies)
			//var _data = get_encounter_functions(_enemies) //We don't use this since we are supplementing our custom functions instead
			
			start_battle(_enemies, _dialog, BATTLE_START_ANIMATION.NO_WARNING,,, end_battle)
		}
	}
}