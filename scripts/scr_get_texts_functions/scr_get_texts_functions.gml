/*
This script contains helper functions to make shortcuts on accessing data from the text files.
Such as enemy names in the UI texts file and dialogues text file that were loaded into their corresponding variables.
*/

function get_enemie_name(_name){
	return struct_get(global.UI_texts.enemie_names, _name)
}

function battle_get_ui_damage_text(_name){
	return struct_get(global.UI_texts[$"battle damage texts"], _name)
}

function get_enemie_dialogues(_enemy){
	return struct_get(global.dialogues.battle.enemies, _enemy)
}