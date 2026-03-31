/*
List of the constants for the actions the player can select with Cell in their menu.
The order of these matters just like it does with the ITEM constants and the ACT_COMMAND constants of battle.
In the UI texts file you have to define the "cell options" list in the exact same order for their corresponding text to match.
See user manual for more information.
*/
enum CELL{
	CALL_GASTER,
	DIMENTIONAL_BOX_A,
	DIMENTIONAL_BOX_B,
	LOAD_GAME
}

/*
Function that executes whenever the player selects a Cell option in their menu.

INTEGER _cell_index -> The index of the option the player is selecting from his cell_options list.

RETURNS -> STRING/ARRAY OF STRINGS/UNDEFINED --Dialog to display for the option, if Undefined there will be a single frame where the box of options will disappear and then reappear as there's no dialog to process.
*/
function cell_use(_cell_index){
	var _cell_option = global.player.cell_options[_cell_index] //Accessing the player data directly for it.
	var _message = undefined //A default message, althought empty string is the equivalent of Undefined.
	
	//Filter the options.
	switch (_cell_option){
		case CELL.CALL_GASTER:{
			_message = global.dialogues.cell.gaster_call //Fetching a dialog in the Dialogues text file that were loaded in the game.
		break}
		case CELL.DIMENTIONAL_BOX_A:{
			start_box_menu(0) //Make dimentional boxes using this.
		return} //Return so no dialog is displayed and no sound is played at the very bottom.
		case CELL.DIMENTIONAL_BOX_B:{
			start_box_menu(1) //The same code is used for the boxes funningly enough.
		return} //Return
		case CELL.LOAD_GAME:{ //Usually you don't want a LOAD GAME option in the phone, but you could do a menu and add more steps to this as long as you put the correct states on the scr_player_menu_system.
			if (does_save_file_0_exist()){
				perform_game_load()
			
				audio_play_sound(snd_game_saved, 100, false)
			}
		return} //Return
	}
	
	audio_play_sound(snd_cell_ring, 100, false) //Ring tone since you used the phone and the dialog goes here
	
	return _message
}