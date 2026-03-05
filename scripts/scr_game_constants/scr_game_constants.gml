/*
If you are gonna change the game size then you will have to redo the border system to fit the new game size and probably also change the border's size.
Also take into account the fullscreen feature with the dialogs, you might also need to change some stuff in it.
All that can be found in obj_game.
*/
#macro GAME_WIDTH 640
#macro GAME_HEIGHT 480

/*
Constant that tells how many pixels should the asterisk from the begginning of dialogs should be separated from the text.
It doesn't count the asterisk's size.
*/
#macro ASTERISK_SPACING 15

/*
Pretty self explanatory.
*/
#macro PLAYER_BASE_INVULNERABILITY_FRAMES 90

/*
Constant that determinates custom created fonts, following the same name syntax that fonts use to keep consistency between fonts.
DO NOT UNDER ANY CIRCUMSTANCE PUT THE FUNCTION TO ADD FONTS DIRECTLY IN THE MACRO, USE A GLOBAL VARIABLE TO PASS THE INDEX.
Otherwise it will create the font everytime you call the macro, potentially causing memory leak or massive usage of memory.
*/
global.custom_fnt_hachiko = font_add_sprite(spr_fnt_hachiko, 32, true, 4)

#macro fnt_hachiko global.custom_fnt_hachiko

/*
Player states for the overworld, used in the Player Overworld object, and changed with the Trigger events to do various stuff with the player, such as disabling it and moving it for cutscenes, or wait a certain amount of time to move.
Read the programmer manual to know more about this.
*/
enum GAME_STATE{
	MENU_CONTROL, //This state is not used in the engine, it is for you to use in your menu so you have your own logic and doesn't affect anything inside this engine, you can chane it, remove it, whatever you want.
	ROOM_CHANGE,
	PLAYER_CONTROL,
	PLAYER_MENU_CONTROL,
	EVENT,
	BATTLE_START_ANIMATION,
	BATTLE,
	BATTLE_END,
	DIALOG_PLUS_CHOICE,
	DIALOG_GRID_CHOICE,
	GAME_OVER
}