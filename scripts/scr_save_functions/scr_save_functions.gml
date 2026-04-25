function perform_game_save(_rm, _x, _y, _direction){
	var _items_amount = array_length(global.player.inventory)
	var _cell_amount = array_length(global.player.cell_options)
	var _box_count = array_length(global.box.inventory)
	var _save_struct_string = json_stringify(global.save_data)
	var _room_index_name = room_get_name(_rm)
	var _save_array = [
		_room_index_name,
		_x,
		_y,
		_direction,
		global.player.max_hp,
		global.player.hp,
		global.player.lv,
		global.player.gold,
		global.player.name,
		global.player.atk,
		global.player.def,
		global.player.exp,
		global.player.next_exp,
		global.player.weapon,
		global.player.armor,
		global.player.cell,
		_items_amount,
	]
	
	for (var _i = 0; _i < _items_amount; _i++){
		array_push(_save_array, global.player.inventory[_i])
	}
	
	array_push(_save_array,
		global.player.inventory_size,
		_cell_amount
	)
	
	for (var _i = 0; _i < _cell_amount; _i++){
		array_push(_save_array, global.player.cell_options[_i])
	}
	
	array_push(_save_array, _box_count)
	
	for (var _i = 0; _i < _box_count; _i++){
		var _box_amount = array_length(global.box.inventory[_i])
		
		array_push(_save_array, _box_amount, global.box.inventory_size[_i])
		
		for (var _j = 0; _j < _box_amount; _j++){
			array_push(_save_array, global.box.inventory[_i][_j])
		}
	}
	
	array_push(_save_array,
		global.minutes,
		global.seconds,
		_save_struct_string
	)
	
	var _file = file_text_open_write(working_directory + "/save0.save")
	file_text_write_string(_file, json_stringify(_save_array))
	file_text_close(_file)
	
	global.last_save.player = {
		name: global.player.name,
		lv: global.player.lv
	}
	global.last_save.room_name = get_room_name(_rm)
	global.last_save.minutes = global.minutes
	global.last_save.seconds = global.seconds
}

function perform_game_save_with_spawn_point(_inst){
	var _angle = _inst.image_angle
	var _size_x = 10*_inst.image_xscale
	var _size_y = 10*_inst.image_yscale
	var _x = _inst.x + _size_x*dcos(_angle) + _size_y*dsin(_angle)
	var _y = _inst.y + _size_y*dcos(_angle) - _size_x*dsin(_angle)
							
	if (_angle < 0){
		_angle = 359 - (abs(_angle) - 1)%360
	}else if (_angle >= 360){
		_angle %= 360
	}
							
	var _direction = 0
	var _x_direction = sign(_inst.image_xscale)
	if (_angle <= 45 or _angle > 315){
		_direction = 2 - _x_direction
	}else if (_angle <= 135){
		_direction = 1 + _x_direction
	}else if (_angle <= 225){
		_direction = 2 + _x_direction
	}else{
		_direction = 1 - _x_direction
	}
							
	perform_game_save(room, _x, _y, _direction)
}

function perform_game_load(){
	audio_stop_all()
	
	var _save_data = load_save_info()
	var _items_amount = _save_data[16]
	var _cell_amount = _save_data[18 + _items_amount] + _items_amount
	var _box_count = _save_data[19 + _cell_amount]
	
	room_goto(asset_get_index(_save_data[0]))
	
	obj_game.start_room_function = function(){ //I need to avoid doing this, but I'm too lazy to change it now, if I don't forget, you won't see this message... maybe
		obj_player_overworld.x = obj_game.obj_player_x
		obj_player_overworld.y = obj_game.obj_player_y
		obj_player_overworld.image_alpha = 1
		obj_player_overworld.player_sprite_reset(obj_game.obj_player_direction)
		alarm[1] = 60
	}
	
	obj_game.obj_player_x = _save_data[1]
	obj_game.obj_player_y = _save_data[2]
	obj_game.obj_player_direction = _save_data[3]
	
	global.player.max_hp = _save_data[4]
	global.player.hp = _save_data[5]
	global.player.lv = _save_data[6]
	global.player.gold = _save_data[7]
	global.player.name = _save_data[8]
	global.player.atk = _save_data[9]
	global.player.def = _save_data[10]
	global.player.exp = _save_data[11]
	global.player.next_exp = _save_data[12]
	global.player.weapon = _save_data[13]
	global.player.armor = _save_data[14] //Yeah a consumable can be equipped as armor, even weapon.
	global.player.cell = _save_data[15]
	global.player.inventory = []
	
	for (var _i = 0; _i < _items_amount; _i++){
		array_push(global.player.inventory, _save_data[17 + _i])
	}
	
	global.player.inventory_size = _save_data[17 + _items_amount]
	global.player.cell_options = []
	
	for (var _i = _items_amount; _i < _cell_amount; _i++){
		array_push(global.player.cell_options, _save_data[19 + _i])
	}
	
	for (var _i = 0; _i < _box_count; _i++){
		global.box.inventory[_i] = []
		global.box.inventory_size[_i] = _save_data[21 + _cell_amount]
		
		var _box_amount = _cell_amount + _save_data[20 + _cell_amount]
		
		for (var _j = _cell_amount; _j < _box_amount; _j++){
			array_push(global.box.inventory[_i], _save_data[22 + _j])
		}
		
		_cell_amount = _box_amount + 2
	}

	global.minutes = _save_data[20 + _cell_amount]
	global.seconds = _save_data[21 + _cell_amount]
	global.save_data = json_parse(_save_data[22 + _cell_amount])
}

function load_save_info(){
	var _file_path = working_directory + "/save0.save"
	var _save_info = undefined
	
	if (file_exists(_file_path)){
		var _file = file_text_open_read(_file_path)
		var _text = ""
		
		while (!file_text_eof(_file)){
			_text += file_text_read_string(_file)
			file_text_readln(_file)
		}
		file_text_close(_file)
		
		_save_info = json_parse(_text)
		
		var _save_size = array_length(_save_info)
		
		global.last_save.player = {
			name: _save_info[8],
			lv: _save_info[6]
		}
		global.last_save.room_name = get_room_name(asset_get_index(_save_info[0]))
		global.last_save.minutes = _save_info[_save_size - 3]
		global.last_save.seconds = _save_info[_save_size - 2]
	}else{
		global.last_save.player = {
			name: global.UI_texts[$"save empty player name"],
			lv: 0
		}
		global.last_save.room_name = "--"
		global.last_save.minutes = 0
		global.last_save.seconds = 0
	}
	
	return _save_info
}

function does_save_file_0_exist(){
	return file_exists(working_directory + "/save0.save")
}

function get_room_name(_rm){
	var room_name = room_get_name(_rm)
	
	return global.UI_texts.rooms[$room_name]
}
