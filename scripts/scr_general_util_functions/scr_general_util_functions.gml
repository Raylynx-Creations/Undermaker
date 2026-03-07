	function save_game_settings(){
	var _file = file_text_open_write(working_directory + "/settings.save")
	file_text_write_string(_file, json_stringify(global.game_settings))
	file_text_close(_file)
}

function set_resolution(_index){
	with (obj_game){
		global.game_settings.resolution_active = _index
	
		var _curr_width = resolutions_width[global.game_settings.resolution_active]
		var _curr_height = resolutions_height[global.game_settings.resolution_active]
		var _display_width = display_get_width()
		var _display_height = display_get_height()
	
		// Set to fullscreen if on fullscreen resolution, otherwise, set to windowed
		if (array_length(resolutions_width) - 1 == global.game_settings.resolution_active){
			display_set_gui_size(_curr_width, _curr_height)
			window_set_fullscreen(true)
		}else{
			if (global.game_settings.border_active){
				_curr_width *= 1.5
				_curr_height *= 1.125
			}
		
			display_set_gui_size(_curr_width, _curr_height)
			window_set_fullscreen(false)

			// The margin on both sides of the window from the edge of the screen
			// is half the difference between the display size and current size.
			// We use this to center the window.
			window_set_rectangle((_display_width - _curr_width)/2, (_display_height - _curr_height)/2, _curr_width, _curr_height)
		}
	}
}

function toggle_border(_state){
	with (obj_game){
		global.game_settings.border_active = _state
	
		var _curr_width = resolutions_width[global.game_settings.resolution_active]
		var _curr_height = resolutions_height[global.game_settings.resolution_active]
		var _display_width = display_get_width()
		var _display_height = display_get_height()
	
		if (window_get_fullscreen()){
			display_set_gui_size(_curr_width, _curr_height)
		}else{
			if (global.game_settings.border_active){
				_curr_width *= 1.5
				_curr_height *= 1.125
			}
			display_set_gui_size(_curr_width, _curr_height)
			window_set_rectangle((_display_width - _curr_width)/2, (_display_height - _curr_height)/2, _curr_width, _curr_height)
		}
	}
}

function set_fullscreen(_state){
	with (obj_game){
		if (_state){
			global.game_settings.resolution_last_active = global.game_settings.resolution_active
	
			set_resolution(array_length(resolutions_width) - 1)
		}else{
			set_resolution(global.game_settings.resolution_last_active)
		}
	}
}

function trigger_game_over(_music=mus_game_over, _dialog=undefined){ //This function is also used for the battle room, so it has a condition to separate both cases.
	with (obj_game){
		state = GAME_STATE.GAME_OVER
		
		audio_stop_all()
		overworld_music_system.music_instance = undefined
		battle_music_system.music_instance = undefined
		overworld_music_system.change_music_to = undefined
		battle_music_system.change_music_to = undefined
		
		while (!dialog.is_finished()){
			dialog.next_dialog()
		}
		
		with (battle_system){
			while (!battle_dialog.is_finished()){
				battle_dialog.next_dialog()
			}
		}
		
		with (game_over_system){
			game_over_timer = 0
			game_over_music = _music
		
			if (is_undefined(_dialog)){
				var _dialog2 = global.UI_texts[$"game over dialogs"]
				game_over_dialog = _dialog2[irandom(array_length(_dialog2) - 1)]
			}else{
				game_over_dialog = _dialog
			}
		
			var _length = array_length(game_over_dialog)
			for (var _i=0; _i<_length; _i++){
				var _dialog2 = game_over_dialog[_i]
				if (string_pos("[PlayerName]", _dialog2)){
					game_over_dialog[_i] = string_replace(_dialog2, "[PlayerName]", global.player.name)
				}
			}
		
			audio_play_sound(snd_player_hurt, 0, false)
		
			if (room == rm_battle){
				game_over_heart_index = obj_player_battle.image_index
				game_over_heart_x = obj_player_battle.x
				game_over_heart_y = obj_player_battle.y
				game_over_heart_xscale = obj_player_battle.image_xscale
				game_over_heart_yscale = obj_player_battle.image_yscale
				game_over_heart_angle = obj_player_battle.image_angle
				game_over_heart_color = obj_player_battle.image_blend
				
				with (other.battle_system){
					_length = array_length(battle_enemies_dialogs)
					for (var _i=0; _i<_length; _i++){
						array_pop(battle_enemies_dialogs)
					}
			
					_length = array_length(battle_bullets)
					for (var _i=0; _i<_length; _i++){
						instance_destroy(battle_bullets[0])
						array_delete(battle_bullets, 0, 1)
					}
				}
			}else{
				game_over_heart_index = 0
				game_over_heart_x = obj_player_overworld.x + obj_player_overworld.image_xscale - camera_get_view_x(view_camera[0])
				game_over_heart_y = obj_player_overworld.y - 15*obj_player_overworld.image_yscale - camera_get_view_y(view_camera[0])
				game_over_heart_xscale = 1
				game_over_heart_yscale = 1
				game_over_heart_angle = 0
				game_over_heart_color = c_red
			}
		}
	}
}

function add_instance_reference(_id, _name){
	struct_set(global.instance_references, _name, _id)
}

function remove_instance_reference(_id, _name=undefined){
	var _instances = global.instance_references
	
	if (is_undefined(_name)){
		var _names = struct_get_names(_instances)
		var _length = array_length(_names)
		
		for (var _i = 0; _i < _length; _i++){
			_name = _names[_i]
			
			if (struct_get(_instances, _name) == _id){
				struct_remove(_instances, _name)
			}
		}
	}else{
		struct_remove(_instances, _name)
	}
}

function get_instance_reference(_name){
	return struct_get(global.instance_references, _name)
}
