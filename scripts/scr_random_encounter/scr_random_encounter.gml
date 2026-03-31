/*
With this function you can define the initial dialog the battle will have when it starts that the engine uses.
The dialog that indicates how these enemies approached the player or give tips at the beginning of it.

ARRAY OF ENEMY CONSTANTS _enemies -> List of enemies the encounter will have which correspond to the constants of ENEMY that they represent.

RETURNS -> STRING/ARRAY OF STRINGS --Returns the dialog that will display first on battles automatically handled by the random encounter system toggled by toggle_random_encounters() and set_random_encounters() functions.
*/
function get_encounter_initial_dialog(_enemies){
	//Do stuff depending on enemies, you got a list of them as paramenters, usually to add flavour text, look at the example provided.
	var _initial_dialogues = global.dialogues.battle.initial_dialogues //All dialog is in the Dialogues text file of its corresponding language, keep it that way for easy translation, they get loaded in the global.dialogues variable.
	var _dialog = ""
	var _length = array_length(_enemies)
	
	if (_length <= 2){
		//If there's 2 enemies of the same type, handle them here accordingly
		if (_length == 2 and _enemies[0] == _enemies[1]){
			switch (_enemies[0]){
				case ENEMY.MAD_DUMMY_DRAWN:{
					_dialog = _initial_dialogues.two_mad_dummies_drawn
				break}
				case ENEMY.MAD_DUMMY_SPRITED:{
					_dialog = _initial_dialogues.two_mad_dummies_sprited
				break}
				case ENEMY.MONSTER_3:{
					_dialog = _initial_dialogues.two_monsters
				break}
			}
			
			return _dialog
		}
	
		switch (_enemies[0]){ //Filter by first enemie
			case ENEMY.MAD_DUMMY_DRAWN:{
				_dialog += _initial_dialogues.mad_dummy_drawn_1
			break}
			case ENEMY.MAD_DUMMY_SPRITED:{
				_dialog += _initial_dialogues.mad_dummy_sprited_1
			break}
			case ENEMY.MONSTER_1:{
				_dialog += _initial_dialogues.monster_1
			break}
			case ENEMY.MONSTER_2:{
				_dialog += _initial_dialogues.angy_monster_1
			break}
		}
		
		if (_length == 2){ //If there's a second enemie, give data
			switch (_enemies[1]){
				case ENEMY.MAD_DUMMY_DRAWN:{
					_dialog += _initial_dialogues.mad_dummy_drawn_2
				break}
				case ENEMY.MAD_DUMMY_SPRITED:{
					_dialog += _initial_dialogues.mad_dummy_sprited_2
				break}
				//Some enemies never appear in second being different types, so they are not here for that reason nor in the first one.
			}
		}
	}else{
		_dialog = _initial_dialogues.default_dialog //Default dialog
	}
	
	return _dialog
}

/*
This function returns an array of always size 7 to fill in the data that you need in the start_battle() function except for the first 2 parameters in the start_battle() function.
This function is called whenever a random encounter is starting by the random encounter system toggled by the toggle_random_encounters() and set_random_encounters() functions.
You can give random enemies that way their own data that controls what music, background and starting animation these random enemies can have, give them more flavour depending on who they pair up with and much more!

ARRAY OF ENEMY CONSTANTS _enemies -> List of enemies the encounter will have which correspond to the constants of ENEMY that they represent.

RETURNS -> ARRAY[INTEGER, INTEGER/UNDEFINED, INTEGER, FUNCTION/METHOD/UNDEFINED, FUNCTION/METHOD/UNDEFINED, INTEGER, INTEGER] --The data is ordered containing the following structure: [Battle start animation constant, Battle music, Background constant, Battle start function, Battle end function, Starting battle soul X, Starting battle soul Y] used by the engine.
																																The first and third come from their corresponding constants BATTLE_START_ANIMATION and BATTLE_BACKGROUND, and the second is the audio asset you want to use for the music, some data on the array can be Undefined so it's not taken into account, in the case of music this doesn't remove the overworld music instead.
*/
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
	
	//By default these are the values of the start_battle() parameters after the first 2 (except the _end_function one, that is undefined by default).
	//The last 2 arguments are the position of the heart in the FIGHT button, set in the room to be 48, 453, of course you can change this depending on the enemies you are battling.
	return [BATTLE_START_ANIMATION.NORMAL, mus_enemy_approaching, BATTLE_BACKGROUND.SQUARE_GRID, undefined, _end_function, 48, 453]
}
