/*
Available languages on your game.

These are not texts that display in the game, but the name it has on the text files the game loads for language management.
For example "UI texts spanish.json" is the name of the file in language of spanish, in actual spanish the word is different of course, but we don't care about that here.
*/
global.languages_available = ["english", "spanish"]

/*
Global variable that holds persistent data for configuration settings.

You don't have to create or remove any variable in it tho, you just have to define the default settings the game starts with.
Since player don't start with configuration settings file, so give them a default to start with.
*/
global.game_settings = {
	language: 0, //This is the index of the available languages list, the one that is selected
	resolution_active: 0, //This is the resolution index of all the possible resolutions the game can have in the user's PC, recommended to leave it at 0, you don't know what resource the user can have depending of their PC.
	resolution_last_active: -1, //Auxiliar to the previous variable, keeps the last active resolution index when toggling between fullscreen and back
	fullscreen: false, //If the game is in fullscreen or not, when starting the game you don't want them fullscreen probably, recommended to be false, but up to you if you want true.
	border_active: false, //If the borders are active on the game, even if your game doesn't use any, or have any, this setting must exist, just don't set any functions to change it, leave it however you want, true or false.
	border_id: 0, //Id of the border to use if active, use -1 for dynamic borders, saveable configuration.
	border_last_id: 0, //Auxiliar to the border ID in case you enter battles with dynamic borders, gets overwritten so don't touch.
	sound_volume: 50, //Volumes of audio sounds.
	music_volume: 50 //And musics.
}

/*
This is a list of all the stats you get when you reach the specific level by reaching the EXP needed for it, these apply when you level up which can only happen when you kill monsters, triggering the battle_apply_rewards() function in the battle functions.
If you need to trigger leveling by other means outside of the battle, copy the battle_apply_rewards() function and edit it to your needs to make sure levels are met up (try to make sure EXP is met and makes sense with the next_exp requirements from before too).
*/
global.stat_levels = [
	{atk: 0, def: 0, max_hp: 20, hp_bar_width: 24, next_exp: 10}, //Level 1 (You start with these)
	{atk: 2, def: 0, max_hp: 24, hp_bar_width: 29, next_exp: 20}, //Level 2
	{atk: 4, def: 0, max_hp: 28, hp_bar_width: 34, next_exp: 40},//Level 3
	{atk: 6, def: 0, max_hp: 32, hp_bar_width: 38, next_exp: 50}, //Level 4
	{atk: 8, def: 1, max_hp: 36, hp_bar_width: 43, next_exp: 80}, //Level 5
	{atk: 10, def: 1, max_hp: 40, hp_bar_width: 48, next_exp: 100}, //Level 6
	{atk: 12, def: 1, max_hp: 44, hp_bar_width: 53, next_exp: 200}, //Level 7
	{atk: 14, def: 1, max_hp: 48, hp_bar_width: 58, next_exp: 300}, //Level 8
	{atk: 16, def: 2, max_hp: 52, hp_bar_width: 62, next_exp: 400}, //Level 9
	{atk: 18, def: 2, max_hp: 56, hp_bar_width: 67, next_exp: 500}, //Level 10
	{atk: 20, def: 2, max_hp: 60, hp_bar_width: 72, next_exp: 800}, //Level 11
	{atk: 22, def: 2, max_hp: 64, hp_bar_width: 77, next_exp: 1000}, //Level 12
	{atk: 24, def: 3, max_hp: 68, hp_bar_width: 82, next_exp: 1500}, //Level 13
	{atk: 26, def: 3, max_hp: 72, hp_bar_width: 86, next_exp: 2000}, //Level 14
	{atk: 28, def: 3, max_hp: 76, hp_bar_width: 91, next_exp: 3000}, //Level 15
	{atk: 30, def: 3, max_hp: 80, hp_bar_width: 96, next_exp: 5000}, //Level 16
	{atk: 32, def: 4, max_hp: 84, hp_bar_width: 101, next_exp: 10000}, //Level 17
	{atk: 34, def: 4, max_hp: 88, hp_bar_width: 106, next_exp: 25000}, //Level 18
	{atk: 36, def: 4, max_hp: 92, hp_bar_width: 110, next_exp: 49999}, //Level 19
	{atk: 38, def: 4, max_hp: 99, hp_bar_width: 119, next_exp: infinity} //Level 20 (Last level, when next_exp is infinity, in the game is actually displayed as "None")
]