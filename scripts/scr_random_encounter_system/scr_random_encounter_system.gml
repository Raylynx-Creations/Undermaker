enum ENCOUNTER_ENEMIE_SELECTION{
	COMBINE,
	COMBINE_UNIQUE,
	PICK_ONE
}

function RandomEncounterSystem() constructor{
	can_player_encounter_enemies = false
	encounters_enemie_selection = ENCOUNTER_ENEMIE_SELECTION.COMBINE
	encounters_timer = 0
	encounters_steps = 0
	encounters_minimum_steps_to_trigger = 0
	encounters_enemie_pool = []
	encounters_exclude_enemie_combination = [] //Only applicable with combinations
	encounters_selected_enemies_ids = []
	encounters_enemie_amount = {minimum: 1, maximum: 1}
	encounters_music = undefined
	
	step = function(){
		if (can_player_encounter_enemies and is_overworld_player_moving()){
			var _animation_speed = obj_player_overworld.animation_speed
			
			encounters_timer += 1 + is_overworld_player_running()
			
			while (encounters_timer >= _animation_speed){
				encounters_timer -= _animation_speed
				encounters_steps++
			}
			
			if (encounters_steps >= encounters_minimum_steps_to_trigger){
				encounters_steps = 0
				
				var _enemies = get_random_enemies(encounters_enemie_selection, encounters_enemie_pool, encounters_selected_enemies_ids, encounters_enemie_amount.minimum, encounters_enemie_amount.maximum, encounters_exclude_enemie_combination)
				var _dialog = get_encounter_initial_dialog(_enemies)
				var _data = get_encounter_functions(_enemies)
				
				start_battle(_enemies, _dialog, _data[0], _data[1], _data[2], _data[3], _data[4], _data[5])
			}
		}
	}

	set_encounters = function(_enemie_pool, _steps_to_trigger, _minimum_enemies=1, _maximum_enemies=3, _selection_type=ENCOUNTER_ENEMIE_SELECTION.COMBINE, _exclude_enemie_combinations=undefined){
		can_player_encounter_enemies = true
		encounters_enemie_selection = _selection_type
		encounters_timer = 0
		encounters_steps = 0
		encounters_minimum_steps_to_trigger = _steps_to_trigger
		encounters_enemie_pool = _enemie_pool
		encounters_enemie_amount.minimum = _minimum_enemies
		encounters_enemie_amount.maximum = _maximum_enemies
		
		if (is_undefined(_exclude_enemie_combinations)){
			var _length = array_length(encounters_exclude_enemie_combination)
			if (_length > 0){
				array_delete(encounters_exclude_enemie_combination, 0, _length)
			}
		}else{
			encounters_exclude_enemie_combination = _exclude_enemie_combinations //Only applicable with combinations
		}
		
		var _length = array_length(encounters_exclude_enemie_combination)
		for (var _i = 0; _i < _length; _i++){
			array_sort(encounters_exclude_enemie_combination[_i], true)
		}
		
		_length = array_length(encounters_selected_enemies_ids)
		if (_length > 0){
			array_delete(encounters_selected_enemies_ids, 0, _length)
		}
	}

	toggle_encounters = function(_active=true, _reset_steps=false){
		can_player_encounter_enemies = _active
		
		if (_reset_steps){
			encounters_timer = 0
			encounters_steps = 0
		}
	}
}

function get_random_enemies(_select_type, _enemie_pool, _selected_ids=undefined, _minimum_enemies=1, _maximum_enemies=3, _excluded_enemie_combinations=undefined){
	var _length = array_length(_enemie_pool)
	var _enemies = []
	var _unique_enemies = false
	
	if (is_undefined(_selected_ids)){
		_selected_ids = []
	}
	
	if (is_undefined(_excluded_enemie_combinations)){
		_excluded_enemie_combinations = []
	}
				
	switch (_select_type){
		case ENCOUNTER_ENEMIE_SELECTION.COMBINE_UNIQUE:{
			_unique_enemies = true
		} //No break
		case ENCOUNTER_ENEMIE_SELECTION.COMBINE:{
			var _pass
			
			do{
				_pass = true
				
				var _amount = irandom_range(_minimum_enemies, _maximum_enemies)
				var _initial_amount = _amount
				var _selected_ids_amount = array_length(_selected_ids)
			
				if (_selected_ids_amount > 0){
					array_delete(_selected_ids, 0, _selected_ids_amount)
				}
			
				while (_amount > 0){
					var _id = irandom(_length - 1)
					var _enemie = _enemie_pool[_id]
							
					if (typeof(_enemie) == "array"){
						var _enemie_amount = array_length(_enemie)
								
						if (_enemie_amount > _amount){
							continue //Enemies overflow, pick another set
						}
								
						if (_unique_enemies){
							var _is_already_in_table = false
									
							for (var _i = 0; _i < _enemie_amount; _i++){
								var _enemie_to_add = _enemie[_i]
								var _enemies_length = _initial_amount - _amount
									
								for (var _j = 0; _j < _enemies_length; _j++){
									if (_enemie_to_add == _enemies[_j]){
										_is_already_in_table = true
											
										break
									}
								}
									
								if (_is_already_in_table){
									break
								}
							}
									
							if (_is_already_in_table){
								continue //Enemie is already in the enemies, select another
							}
						}
								
						for (var _i = 0; _i < _enemie_amount; _i++){
							array_push(_enemies, _enemie[_i])
						}
								
						_amount -= _enemie_amount
					}else{
						if (_unique_enemies){
							var _is_already_in_table = false
							var _enemies_length = _initial_amount - _amount
									
							for (var _i = 0; _i < _enemies_length; _i++){
								if (_enemie == _enemies[_i]){
									_is_already_in_table = true
											
									break
								}
							}
								
							if (_is_already_in_table){
								continue //Enemie is already in the enemies, select another
							}
						}
								
						array_push(_enemies, _enemie)
								
						_amount--
					}
							
					array_push(_selected_ids, _id)
				}
				
				var _enemies_copy = []
				var _excluded_combinations = array_length(_excluded_enemie_combinations)
				
				array_copy(_enemies_copy, 0, _enemies, 0, _initial_amount)
				array_sort(_enemies_copy, true)
				
				for (var _i = 0; _i < _excluded_combinations; _i++){
					var _combination = _excluded_enemie_combinations[_i]
					
					if (array_length(_combination) != _initial_amount){
						continue
					}
					
					var _is_same = true
					
					for (var _j = 0; _j < _initial_amount; _j++){
						if (_enemies_copy[_j] != _combination[_j]){
							_is_same = false
							
							break
						}
					}
					
					if (_is_same){
						_pass = false
						
						break
					}
				}
			}until (_pass)
		break}
		default:{ //ENCOUNTER_ENEMIE_SELECTION.PICK_ONE
			var _id = irandom(_length - 1)
			var _enemie = _enemie_pool[_id]
						
			array_push(_enemies, _enemie)
			array_push(_selected_ids, _id)
		break}
	}
				
	return _enemies
}

function get_encounter_initial_dialog(_enemies){
	//Do stuff depending on enemies, you got a list of them as paramenters, usually to add flavour text, look at the example provided.
	
	var _dialog = ""
	var _length = array_length(_enemies)
	
	if (_length <= 2){
		if (_length == 2 and _enemies[0] == _enemies[1]){
			switch (_enemies[0]){
				case ENEMY.MAD_DUMMY_DRAWN:{
					_dialog = "Two Mad Dummies join battle to persuade you to use drawing functions."
				break}
				case ENEMY.MAD_DUMMY_SPRITED:{
					_dialog = "Two Mad Dummies attempt to sell you sprited functions through battle."
				break}
			}
			
			return _dialog
		}
	
		switch (_enemies[0]){ //Filter by first enemie
			case ENEMY.MAD_DUMMY_DRAWN:{
				_dialog += "Mad Dummy draws into battle."
			break}
			case ENEMY.MAD_DUMMY_SPRITED:{
				_dialog += "Mad Dummy sprites into battle."
			break}
			case ENEMY.MONSTER_1:{
				_dialog += "A Monster engages with you.[w:30]\nNot in a romantic way."
			break}
			case ENEMY.MONSTER_2:{
				_dialog += "A Monster engages with you.[w:30]\nIn an angry way."
			break}
		}
		
		if (_length == 2){
			switch (_enemies[1]){
				case ENEMY.MAD_DUMMY_DRAWN:{
					_dialog += "[w:30]\nAnother one joins to draw your attention."
				break}
				case ENEMY.MAD_DUMMY_SPRITED:{
					_dialog += "[w:30]\nAnother one joins to sprite them away."
				break}
			}
		}
	}else{
		_dialog = "A battle has started!"
	}
	
	return _dialog
}

function get_encounter_functions(_enemies){
	//Do stuff depending on enemies, you got a list of them as paramenters
	
	var _end_function = function(_enemies_left, _enemies_killed, _enemies_spared, _battle_fled){ //Custom function for the encounter
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
	
	return [BATTLE_START_ANIMATION.NORMAL, undefined, undefined, _end_function, 48, 453] //By default these are the values of the start_battle() parameters after the first 2 (except the _end_function one, that is undefined by default)
}
