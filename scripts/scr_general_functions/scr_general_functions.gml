function load_ui_texts(_path){
	var _file = file_text_open_read(working_directory + "/" + _path)
	var _text = ""
	
	while (!file_text_eof(_file)){
		_text += file_text_read_string(_file)
		file_text_readln(_file)
	}
	file_text_close(_file)
	
	global.UI_texts = json_parse(_text)
}

function load_items_info(_path){
	var _file = file_text_open_read(working_directory + "/" + _path)
	var _text = ""
	
	while (!file_text_eof(_file)){
		_text += file_text_read_string(_file)
		file_text_readln(_file)
	}
	file_text_close(_file)
	
	global.item_pool = json_parse(_text)
}

function load_dialogues_file(_path){
	var _file = file_text_open_read(working_directory + "/" + _path)
	var _text = ""
	
	while (!file_text_eof(_file)){
		_text += file_text_read_string(_file)
		file_text_readln(_file)
	}
	file_text_close(_file)
	
	global.dialogues = json_parse(_text)
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
}

function load_game_data(){
	load_game_settings()
	
	var _lang = global.game_settings.language
	
	load_items_info("Item pool " + _lang + ".json")
	load_ui_texts("UI texts " + _lang + ".json")
	load_dialogues_file("Dialogues " + _lang + ".json")
	load_save_info()
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
