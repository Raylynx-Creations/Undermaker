function load_ui_texts(_script){
	/*
	var _file = file_text_open_read(working_directory + "/" + _path)
	var _text = ""
	
	while (!file_text_eof(_file)){
		_text += file_text_read_string(_file)
		file_text_readln(_file)
	}
	file_text_close(_file)
	
	global.UI_texts = json_parse(_text)
	*/
	global.UI_texts = _script()
}

function load_dialogues_file(_script){
	/*
	var _file = file_text_open_read(working_directory + "/" + _path)
	var _text = ""
	
	while (!file_text_eof(_file)){
		_text += file_text_read_string(_file)
		file_text_readln(_file)
	}
	file_text_close(_file)
	
	global.dialogues = json_parse(_text)
	*/
	global.dialogues = _script()
}

function load_items_info(_script){
	/*
	var _file = file_text_open_read(working_directory + "/" + _path)
	var _text = ""
	
	while (!file_text_eof(_file)){
		_text += file_text_read_string(_file)
		file_text_readln(_file)
	}
	file_text_close(_file)
	
	global.item_pool = json_parse(_text)
	*/
	global.item_pool = _script()
}

function load_game_settings(){
	var _file_path = working_directory + "/settings.save"
	
	if (file_exists(_file_path)){
		var _file = file_text_open_read(working_directory + "/settings.save")
		var _text = ""
		
		while (!file_text_eof(_file)){
			_text += file_text_read_string(_file)
			file_text_readln(_file)
		}
		file_text_close(_file)
	
		global.game_settings = json_parse(_text)
	}
	
	var _fullscreen = global.game_settings.fullscreen
	if (_fullscreen){
		set_fullscreen(_fullscreen)
	}else{
		set_resolution(global.game_settings.resolution_active)
	}
}

function load_game_data(){
	load_game_settings()
	load_game_texts(global.game_settings.language)
}

function load_audio(){
	audio_group_load(audiogroup_sound)
	audio_group_load(audiogroup_music)
}

function is_audio_loaded(){
	var _is_loaded = (audio_group_is_loaded(audiogroup_sound) and audio_group_is_loaded(audiogroup_music))
	
	if (_is_loaded){
		audio_group_set_gain(audiogroup_sound, global.game_settings.sound_volume/100, 0)
		audio_group_set_gain(audiogroup_music, global.game_settings.music_volume/100, 0)
	}
	
	return _is_loaded
}

function calculate_resolutions(){
	var _display_width = display_get_width()
	var _display_height = display_get_height()

	for (var _i = 1; GAME_WIDTH * _i < _display_width and GAME_HEIGHT * _i < _display_height; _i++) {
	    array_push(resolutions_width, GAME_WIDTH * _i)
		array_push(resolutions_height, GAME_HEIGHT * _i)
	}

	array_push(resolutions_width, _display_width)
	array_push(resolutions_height, _display_height)

	set_resolution(array_length(resolutions_width) - 2)
}

function change_border_dynamicly(_id=0){
	obj_game.border_id = _id
}

function get_border_id_by_room(_room_id){
	return struct_get(global.room_borders, room_get_name(_room_id))
}

function get_music_id_by_room(_room_id){
	return struct_get(global.room_musics, room_get_name(_room_id))
}
