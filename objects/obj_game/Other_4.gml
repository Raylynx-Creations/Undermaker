/// @description Start room function

//Set room persistency to false always when entering rooms, you can change a room_persistance always any time, but remember that they are not persistent every time you enter them
room_persistent = false

//Depending on what room you are entering, the music updates accordingly
if (room == rm_battle){
	var _border_id = get_border_id_by_room(room)
	
	if (!is_undefined(_border_id)){
		change_border_dynamicly(_border_id)
	}
	
	battle_music_system.update_music_change()
	overworld_music_system.ignore_next_update()
}else{
	if (previous_room != rm_battle){
		var _border_id = get_border_id_by_room(room)
		
		if (!is_undefined(_border_id)){
			change_border_dynamicly(_border_id)
		}
	}else{
		change_border_dynamicly(border_prev_id)
		border_prev_id = 0
	}
	
	overworld_music_system.schedule_music_change_to(get_music_id_by_room(room))
	overworld_music_system.update_music_change(global.room_music_settings.fade_out_time, global.room_music_settings.fade_in_time)
}

//Execution of the starting room function if defined
if (!is_undefined(start_room_function)){
	if (is_undefined(start_room_function())){
		start_room_function = undefined
	}
}