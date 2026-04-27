function add_item_to_player_inventory(_item){
	var _is_inventory_full = (array_length(global.player.inventory) >= global.player.inventory_size)
	if (!_is_inventory_full){
		array_push(global.player.inventory, _item)
	}
	
	return !_is_inventory_full
}

function save_game_settings(){
	var _file = file_text_open_write(working_directory + "/settings.save")
	file_text_write_string(_file, json_stringify(global.game_settings))
	file_text_close(_file)
}

function load_game_texts(_id){
	var _texts = global.language_texts[_id]
	global.game_settings.language = _id
	
	load_ui_texts(_texts[0])
	load_dialogues_file(_texts[1])
	load_items_info(_texts[2])
	load_save_info()
}

function get_current_language_id(){
	return global.game_settings.language
}

function get_languages_amount(){
	return array_length(global.language_texts)
}

function set_resolution(_index){
	if (global.is_mobile){
		return
	}
	
	with (obj_game){
		if (_index == array_length(resolutions_width) - 1){
			return //Invalidate, that space contains the size for the fullscreen window, use set_fullscreen() to set fullscreen and not set_resolution.
		}
		
		global.game_settings.fullscreen = false
		global.game_settings.resolution_active = _index
	
		var _curr_width = resolutions_width[global.game_settings.resolution_active]
		var _curr_height = resolutions_height[global.game_settings.resolution_active]
		var _display_width = display_get_width()
		var _display_height = display_get_height()
	
		// Always set to windowed
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

function set_fullscreen(_state){
	if (global.is_mobile and _state == false){
		return
	}
	
	global.game_settings.fullscreen = _state
	
	with (obj_game){
		if (_state){
			var _id = array_length(resolutions_width) - 1
			var _resolution_id = global.game_settings.resolution_active
			if (_resolution_id < _id){
				global.game_settings.resolution_last_active = _resolution_id
			}
			
			var _curr_width = resolutions_width[_id]
			var _curr_height = resolutions_height[_id]
			global.game_settings.resolution_active = _id
			
			display_set_gui_size(_curr_width, _curr_height)
			window_set_fullscreen(true)
		}else{
			set_resolution(global.game_settings.resolution_last_active)
		}
	}
}

function get_current_resolution(){
	with (obj_game){
		return [resolutions_width[get_current_resolution_id()], resolutions_height[get_current_resolution_id()]]
	}
}

function get_current_resolution_id(){
	return global.game_settings.resolution_active
}

function get_resolutions_amount(){
	if (global.is_mobile){
		return 1
	}
	
	return array_length(obj_game.resolutions_width) - 1 //Last ID is always fullscreen, use the set_fullscreen function for that.
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

function toggle_dynamic_borders(_active){
	global.game_settings.border_id = (_active ? -1 : global.game_settings.border_last_id)
}

function set_border(_id=0){
	global.game_settings.border_last_id = _id
	
	if (!is_border_dynamic()){
		obj_game.border_alpha = 1
		
		global.game_settings.border_id = _id
	}
}

function get_current_border_id(_dynamic=false){
	if (_dynamic){
		return obj_game.border_id
	}else{
		return global.game_settings.border_id
	}
}

function get_borders_amount(){
	return sprite_get_number(spr_border)
}

function is_border_dynamic(){
	return (global.game_settings.border_id == -1)
}

function is_border_enabled(){
	return global.game_settings.border_active
}

function set_music_volume(_volume){
	global.game_settings.music_volume = clamp(_volume, 0, 100)
	audio_group_set_gain(audiogroup_music, global.game_settings.music_volume/100, 0)
}

function set_sound_volume(_volume){
	global.game_settings.sound_volume = clamp(_volume, 0, 100)
	audio_group_set_gain(audiogroup_sound, global.game_settings.sound_volume/100, 0)
}

function get_music_volume(){
	return global.game_settings.music_volume
}

function get_sound_volume(){
	return global.game_settings.sound_volume
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

function set_event_update(_function){
	obj_game.event_update = _function
}

function set_event_end_condition(_function){
	obj_game.event_end_condition = _function
}

function gpu_set_default_blendmode(){
	gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_inv_dest_alpha, bm_one);
}

function get_language_sprite(_name){
	return variable_struct_get(global.language_sprites, _name)[get_current_language_id()]
}

function get_language_font(_name){
	return variable_struct_get(global.language_fonts, _name)[get_current_language_id()]
}

function mobile_toggle_left_handed(_state){
	var _mobile = global.game_settings.mobile_buttons
	if (_state != _mobile.left_handed){
		var _width = display_get_width()
		
		_mobile.move_button.x = _width - _mobile.move_button.x
		_mobile.confirm_button.x = _width - _mobile.confirm_button.x
		_mobile.cancel_button.x = _width - _mobile.cancel_button.x
		_mobile.menu_button.x = _width - _mobile.menu_button.x
		
		_mobile.left_handed = _state
	}
}

function mobile_set_move_button_position(_x, _y){
	var _mobile = global.game_settings.mobile_buttons
	
	_mobile.move_button.x = _x
	_mobile.move_button.y = display_get_height() - _y
}

function mobile_set_confirm_button_position(_x, _y){
	var _mobile = global.game_settings.mobile_buttons
	
	_mobile.confirm_button.x = display_get_width() - _x
	_mobile.confirm_button.y = display_get_height() - _y
}

function mobile_set_cancel_button_position(_x, _y){
	var _mobile = global.game_settings.mobile_buttons
	
	_mobile.cancel_button.x = display_get_width() - _x
	_mobile.cancel_button.y = display_get_height() - _y
}

function mobile_set_menu_button_position(_x, _y){
	var _mobile = global.game_settings.mobile_buttons
	
	_mobile.menu_button.x = display_get_width() - _x
	_mobile.menu_button.y = display_get_height() - _y
}

function mobile_set_button_size(_size){
	global.game_settings.mobile_buttons.button_size = _size
}

function mobile_set_button_alpha(_alpha){
	global.game_settings.mobile_buttons.alpha = _alpha
}

function mobile_toggle_movable_move_button(_state){
	global.game_settings.mobile_buttons.movable_move_button = _state
}

function mobile_set_move_button_type(_type){
	global.game_settings.mobile_buttons.type = _type
}
