/// @description Start room function

room_persistent = false

if (room == rm_battle){
	battle_music_system.step()
	overworld_music_system.ignore_next_update()
}else{
	overworld_music_system.step()
}

if (!is_undefined(start_room_function)){
	if (is_undefined(start_room_function())){
		start_room_function = undefined
	}
}