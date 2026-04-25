function PlayerMenuSystem() constructor{
	player_menu_state = PLAYER_MENU_STATE.INITIAL
	player_menu_prev_state = 0
	player_prev_room = undefined
	player_menu_box = spr_player_menu_UI
	player_menu_tail = undefined
	player_menu_tail_mask = undefined
	player_menu_top = true //If menu is on the top or not.
	player_menu_selection = [0, 0, 0] //Initial menu, submenu for cell or inventory, action for item or grid of dimensional box.
	ignore_first_frame_menu = false

	player_box_index = 0 //Index for deciding which box inventory to use.
	player_box_cursor = [0, 0]

	player_save_cursor = 0
	player_save_spawn_point_inst = undefined
	
	step = function(){
		ignore_first_frame_menu = false
		
		if (obj_game.state != GAME_STATE.PLAYER_MENU_CONTROL){
			return
		}
		
		switch (player_menu_state){
			case PLAYER_MENU_STATE.INITIAL:{
				if (get_up_button(false) and player_menu_selection[0] > 0){
					player_menu_selection[0]--
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}else if (get_down_button(false) and player_menu_selection[0] < 1 + global.player.cell){
					player_menu_selection[0]++
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
				
				if (get_confirm_button(false)){
					switch (player_menu_selection[0]){
						case PLAYER_MENU_OPTIONS.ITEM:
							if (array_length(global.player.inventory) > 0){
								player_menu_state = PLAYER_MENU_STATE.INVENTORY
								player_menu_selection[1] = 0
							}
						break
						case PLAYER_MENU_OPTIONS.STAT:
							player_menu_state = PLAYER_MENU_STATE.STATS
						break
						case PLAYER_MENU_OPTIONS.CELL:
							if (array_length(global.player.cell_options) > 0){
								player_menu_state = PLAYER_MENU_STATE.CELL
								player_menu_selection[1] = 0
							}
						break
					}
					
					if (player_menu_state != PLAYER_MENU_STATE.INITIAL){
						audio_play_sound(snd_menu_confirm, 0, false)
					}
				}else if (get_cancel_button(false) or get_menu_button(false)){
					ignore_first_frame_menu = true
					obj_game.state = GAME_STATE.PLAYER_CONTROL
					obj_player_overworld.state = PLAYER_STATE.MOVEMENT
				}
			break}
			case PLAYER_MENU_STATE.STATS:{
				if (get_cancel_button(false)){
					player_menu_state = PLAYER_MENU_STATE.INITIAL
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
			break}
			case PLAYER_MENU_STATE.INVENTORY:{
				if (get_up_button(false)){
					player_menu_selection[1]--
					
					if (player_menu_selection[1] == -1){
						player_menu_selection[1] += array_length(global.player.inventory)
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}else if (get_down_button(false)){
					player_menu_selection[1]++
					
					if (player_menu_selection[1] == array_length(global.player.inventory)){
						player_menu_selection[1] -= array_length(global.player.inventory)
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
				
				if (get_confirm_button(false)){
					player_menu_state = PLAYER_MENU_STATE.ITEM_SELECTED
					player_menu_selection[2] = 0
					
					audio_play_sound(snd_menu_confirm, 0, false)
				}else if (get_cancel_button(false)){
					player_menu_state = PLAYER_MENU_STATE.INITIAL
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
			break}
			case PLAYER_MENU_STATE.ITEM_SELECTED:{
				if (get_left_button(false) and player_menu_selection[2] > 0){
					player_menu_selection[2]--
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}else if (get_right_button(false) and player_menu_selection[2] < 2){
					player_menu_selection[2]++
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
				
				if (get_confirm_button(false)){
					player_menu_state = PLAYER_MENU_STATE.WAITING_DIALOG_END
					var _dialog = ""
					
					switch (player_menu_selection[2]){
						case PLAYER_MENU_INVENTORY_OPTIONS.USE:
							_dialog = use_item(player_menu_selection[1])[0]
						break
						case PLAYER_MENU_INVENTORY_OPTIONS.INFO:
							_dialog = item_info(player_menu_selection[1])
						break
						case PLAYER_MENU_INVENTORY_OPTIONS.DROP:
							_dialog = drop_item(player_menu_selection[1])
						break
					}
					
					if (_dialog != ""){
						player_menu_prev_state = PLAYER_MENU_STATE.INVENTORY
						
						overworld_dialog(_dialog,, !player_menu_top,,,,, player_menu_box, player_menu_tail, player_menu_tail_mask)
					}
				}else if (get_cancel_button(false)){
					player_menu_state = PLAYER_MENU_STATE.INVENTORY
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
			break}
			case PLAYER_MENU_STATE.CELL:{
				if (get_up_button(false)){
					player_menu_selection[1]--
					
					if (player_menu_selection[1] == -1){
						player_menu_selection[1] += array_length(global.player.cell_options)
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}else if (get_down_button(false)){
					player_menu_selection[1]++
					
					if (player_menu_selection[1] == array_length(global.player.cell_options)){
						player_menu_selection[1] -= array_length(global.player.cell_options)
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
				
				if (get_confirm_button(false)){
					player_menu_state = PLAYER_MENU_STATE.WAITING_DIALOG_END
					var _dialog = cell_use(player_menu_selection[1])
					
					if (_dialog != ""){
						player_menu_prev_state = PLAYER_MENU_STATE.CELL
						
						overworld_dialog(_dialog,, !player_menu_top,,,,, player_menu_box, player_menu_tail, player_menu_tail_mask)
					}
				}else if (get_cancel_button(false)){
					player_menu_state = PLAYER_MENU_STATE.INITIAL
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
			break}
			case PLAYER_MENU_STATE.BOX:{
				var _box = global.box.inventory[player_box_index]
				var _box_amount = array_length(_box)
				var _inventory_amount = array_length(global.player.inventory)
				
				if (get_left_button(false) or get_right_button(false)){
					var _amount = ((player_box_cursor[0] == 0) ? _box_amount : _inventory_amount)
					
					if (_amount > 0){
						player_box_cursor[0] += 1 - 2*(player_box_cursor[0] == 1)
						
						_amount = ((player_box_cursor[0] == 0) ? _inventory_amount : _box_amount)
						player_box_cursor[1] = min(player_box_cursor[1], _amount - 1)
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
				
				if (get_up_button(false)){
					player_box_cursor[1]--
					
					if (player_box_cursor[1] == -1){
						player_box_cursor[1] += ((player_box_cursor[0] == 0) ? _inventory_amount : _box_amount)
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}else if (get_down_button(false)){
					player_box_cursor[1]++
					
					var _amount = ((player_box_cursor[0] == 0) ? _inventory_amount : _box_amount)
					if (player_box_cursor[1] == _amount){
						player_box_cursor[1] -= _amount
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
				
				if (get_confirm_button(false) and (_inventory_amount > 0 or _box_amount > 0)){
					if (player_box_cursor[0] == 0 and _box_amount < global.box.inventory_size[player_box_index]){
						array_push(global.box.inventory[player_box_index], global.player.inventory[player_box_cursor[1]])
						array_delete(global.player.inventory, player_box_cursor[1], 1)
						_inventory_amount--
						
						if (_inventory_amount == 0){
							player_box_cursor[0] = 1
						}else{
							player_box_cursor[1] = min(player_box_cursor[1], _inventory_amount - 1)
						}
					}else if (player_box_cursor[0] == 1 and _inventory_amount < global.player.inventory_size){
						array_push(global.player.inventory, global.box.inventory[player_box_index][player_box_cursor[1]])
						array_delete(global.box.inventory[player_box_index], player_box_cursor[1], 1)
						_box_amount--
						
						if (_box_amount == 0){
							player_box_cursor[0] = 0
						}else{
							player_box_cursor[1] = min(player_box_cursor[1], _box_amount - 1)
						}
					}
				}else if (get_cancel_button(false)){
					if (player_menu_prev_state == PLAYER_MENU_STATE.CELL){
						player_menu_state = PLAYER_MENU_STATE.CELL
					}else{
						obj_game.state = GAME_STATE.PLAYER_CONTROL
						obj_player_overworld.state = PLAYER_STATE.MOVEMENT
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
			break}
			case PLAYER_MENU_STATE.SAVE:{
				if (get_left_button(false) and player_save_cursor == 1){
					player_save_cursor--
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}else if (get_right_button(false) and player_save_cursor == 0){
					player_save_cursor++
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
				
				if (get_confirm_button(false)){
					if (player_save_cursor == 0){
						if (player_menu_prev_state == PLAYER_MENU_STATE.CELL){
							perform_game_save(room, obj_player_overworld.x, obj_player_overworld.y, 0)
						}else{
							perform_game_save_with_spawn_point(player_save_spawn_point_inst)
						}
						
						audio_play_sound(snd_game_saved, 100, false)
						
						player_save_cursor = 2
					}else{
						if (player_menu_prev_state == PLAYER_MENU_STATE.CELL){
							player_menu_state = PLAYER_MENU_STATE.CELL
							
							audio_play_sound(snd_menu_selecting, 100, false)
						}else{
							obj_game.state = GAME_STATE.PLAYER_CONTROL
							obj_player_overworld.state = PLAYER_STATE.MOVEMENT
							player_menu_prev_state = -2 //Necessary so it doesn't trigger again.
						}
					}
				}else if (get_cancel_button(false)){
					if (player_menu_prev_state == PLAYER_MENU_STATE.CELL){
						player_menu_state = PLAYER_MENU_STATE.CELL
						
						audio_play_sound(snd_menu_selecting, 0, false)
					}else{
						obj_game.state = GAME_STATE.PLAYER_CONTROL
						obj_player_overworld.state = PLAYER_STATE.MOVEMENT
					}
				}
			break}
			case PLAYER_MENU_STATE.WAITING_DIALOG_END:{
				if (obj_game.dialog.is_finished()){
					player_menu_state = player_menu_prev_state
					
					switch (player_menu_state){
						case PLAYER_MENU_STATE.INVENTORY:{
							var _items_remaining = array_length(global.player.inventory)
							
							if (_items_remaining == 0){
								player_menu_state = PLAYER_MENU_STATE.INITIAL
							}else{
								player_menu_selection[1] = min(player_menu_selection[1], array_length(global.player.inventory) - 1)
							}
						break}
					}
				}
			break}
		}
	}
	
	draw = function(){
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		draw_set_font(get_language_font("fnt_determination_sans"))
		
		var _heart_x = 0
		var _heart_y = 0
		
		switch (player_menu_state){
			case PLAYER_MENU_STATE.BOX:{
				var _items_string = ""
				var _box_string = ""
				var _amount_items = array_length(global.player.inventory)
				var _amount_box = array_length(global.box.inventory[player_box_index])
				_heart_x = 49 + 302*player_box_cursor[0]
				_heart_y = 88 + 32*player_box_cursor[1]
					
				draw_sprite_ext(player_menu_box, 0, 15, 15, 610/30, 450/30, 0, c_white, 1)
					
				draw_line_color(318, 92, 318, 392, c_white, c_white)
				draw_line_color(320, 92, 320, 392, c_white, c_white)
					
				for (var _i = 0; _i < min(global.player.inventory_size, 10); _i++){
					if (_i < _amount_items){
						var _item = global.item_pool[global.player.inventory[_i]]
						var _item_name = _item[$"inventory name"]
							
						_items_string += _item_name + "\n"
					}else{
						var _height = 92 + 32*_i
							
						draw_line_color(78, _height, 258, _height, c_red, c_red)
					}
				}
					
				for (var _i = 0; _i < min(global.box.inventory_size[player_box_index], 10); _i++){
					if (_i < _amount_box){
						var _item = global.item_pool[global.box.inventory[player_box_index][_i]]
						var _item_name = _item[$"inventory name"]
							
						_box_string += _item_name + "\n"
					}else{
						var _height = 92 + 32*_i
							
						draw_line_color(380, _height, 560, _height, c_red, c_red)
					}
				}
					
				draw_text_ext_transformed(67, 71, _items_string, 16, 400, 2, 2, 0)
				draw_text_ext_transformed(369, 71, _box_string, 16, 400, 2, 2, 0)
					
				draw_set_halign(fa_center)
					
				draw_text_transformed(167, 29, global.UI_texts[$"box inventory"], 2, 2, 0)
				draw_text_transformed(472, 29, global.UI_texts[$"box box"], 2, 2, 0)
				draw_text_transformed(320, 405, global.UI_texts[$"box exit"], 2, 2, 0)
			break}
			case PLAYER_MENU_STATE.SAVE:{
				_heart_x = 151 + 180*player_save_cursor
				_heart_y = 257
					
				if (player_save_cursor == 2){
					draw_set_color(c_yellow)
				}
					
				draw_sprite_ext(player_menu_box, 0, 108, 118, 424/30, 174/30, 0, c_white, 1)
					
				draw_text_transformed(140, 140, global.last_save.player.name, 2, 2, 0)
				draw_text_transformed(300, 140, string_concat(global.UI_texts.lv, " ", global.last_save.player.lv), 2, 2, 0)
				draw_text_transformed(140, 180, global.last_save.room_name, 2, 2, 0)
				draw_text_transformed(170, 240, global.UI_texts[$"save save"], 2, 2, 0)
				draw_text_transformed(350, 240, global.UI_texts[$"save return"], 2, 2, 0)
					
				draw_set_halign(fa_right)
					
				draw_text_transformed(498, 140, string_concat(global.last_save.minutes, (global.last_save.seconds >= 10) ? ":" : ":0", global.last_save.seconds), 2, 2, 0)
					
				if (player_save_cursor == 2){
					draw_set_color(c_white)
				}
			break}
			default:{
				var _stats_x = 32
				var _stats_y = 320
				var _box_height = 0 //Height of the box of the items, cell and stats.
				var _amount_items = array_length(global.player.inventory)
				var _amount_cell = array_length(global.player.cell_options)
				var _item_color = (_amount_items > 0) ? c_white : c_gray 
				var _cell_color = (_amount_cell > 0) ? c_white : c_gray//Color of the item option.
					
				if (player_menu_top){
					_stats_y = 52
				}
					
				switch (player_menu_state){
					case PLAYER_MENU_STATE.INITIAL:{
						_heart_x = 64
						_heart_y = 204 + 36*player_menu_selection[0]
					break}
					case PLAYER_MENU_STATE.STATS:{
						_box_height = 418
					break}
					case PLAYER_MENU_STATE.INVENTORY:{
						_box_height = 362
						_heart_x = 217
						_heart_y = 97 + 32*player_menu_selection[1]
					break}
					case PLAYER_MENU_STATE.ITEM_SELECTED:{
						_box_height = 362
						_heart_x = 217 + min(96*player_menu_selection[2], 105)*player_menu_selection[2]
						_heart_y = 377
					break}
					case PLAYER_MENU_STATE.CELL:{
						_box_height = 270
						_heart_x = 217
						_heart_y = 97 + 32*player_menu_selection[1]
					break}
				}
				
				draw_sprite_ext(player_menu_box, 0, 32, 167, 142/30, 148/30, 0, c_white, 1) //Menu box
				draw_sprite_ext(player_menu_box, 0, _stats_x, _stats_y, 142/30, 110/30, 0, c_white, 1) //Stats box
				
				if (player_menu_state != PLAYER_MENU_STATE.INITIAL and player_menu_state != PLAYER_MENU_STATE.WAITING_DIALOG_END){
					draw_sprite_ext(player_menu_box, 0, 188, 52, 346/30, _box_height/30, 0, c_white, 1) //Multi-purpose box
				
					switch (player_menu_state){
						case PLAYER_MENU_STATE.STATS:{
							_box_height = 418
							var _player_weapon = global.UI_texts.none
							var _player_armor = global.UI_texts.none
								
							if (!is_undefined(global.player.weapon) and global.player.weapon >= 0){
								var _weapon = global.item_pool[global.player.weapon]
								_player_weapon = _weapon[$"inventory name"]
							}
							
							if (!is_undefined(global.player.armor) and global.player.armor >= 0){
								var _armor = global.item_pool[global.player.armor]
								_player_armor = _armor[$"inventory name"]
							}
						
							draw_text_transformed(216, 84, "\"" + global.player.name + "\"", 2, 2, 0)
							draw_text_ext_transformed(216, 144, string_concat(global.UI_texts.lv ,"  ", global.player.lv, "\n", global.UI_texts.hp, "  ", global.player.hp, " / ", global.player.max_hp, "\n\n", global.UI_texts[$"stat attack"], "  ", global.player.atk, " (", global.player.equipped_atk, ")\n", global.UI_texts[$"stat defense"], "  ", global.player.def, " (", global.player.equipped_def, ")\n\n", global.UI_texts[$"stat weapon"], ": ", _player_weapon, "\n", global.UI_texts[$"stat armor"], ": ", _player_armor), 16, 400, 2, 2, 0)
							draw_text_ext_transformed(384, 240, string_concat(global.UI_texts[$"stat exp"], ": ", global.player.exp, "\n", global.UI_texts[$"stat next"], ": ", (is_infinity(global.player.next_exp) ? global.UI_texts.none : global.player.next_exp)), 16, 400, 2, 2, 0)
							draw_text_transformed(216, 408, string_concat(global.UI_texts[$"stat gold"], ": ", global.player.gold), 2, 2, 0)
						break}
						case PLAYER_MENU_STATE.INVENTORY:
						case PLAYER_MENU_STATE.ITEM_SELECTED:{
							_box_height = 362
							var _items_string = ""
						
							for (var _i = 0; _i < _amount_items; _i++){
								var _item = global.item_pool[global.player.inventory[_i]]
								var _item_name = _item[$"inventory name"]
							
								_items_string += _item_name + "\n"
							}
						
							draw_text_ext_transformed(232, 80, _items_string, 16, 400, 2, 2, 0)
							draw_text_transformed(232, 360, global.UI_texts[$"item use"], 2, 2, 0)
							draw_text_transformed(328, 360, global.UI_texts[$"item info"], 2, 2, 0)
							draw_text_transformed(442, 360, global.UI_texts[$"item drop"], 2, 2, 0)
						break}
						case PLAYER_MENU_STATE.CELL:{
							_box_height = 270
							var _cell_string = ""
						
							for (var _i = 0; _i < _amount_cell; _i++){
								var _option = global.UI_texts[$"cell options"][global.player.cell_options[_i]]
							
								_cell_string += _option + "\n"
							}
						
							draw_text_ext_transformed(232, 80, _cell_string, 16, 400, 2, 2, 0)
						break}
					}
				}
				
				draw_text_transformed(_stats_x + 13, _stats_y + 7, global.player.name, 2, 2, 0)
				draw_text_transformed_color(83, 187, global.UI_texts[$"menu item"], 2, 2, 0, _item_color, _item_color, _item_color, _item_color, 1)
				draw_text_transformed(83, 223, global.UI_texts[$"menu stat"], 2, 2, 0)
			
				if (global.player.cell){
					draw_text_transformed_color(83, 259, global.UI_texts[$"menu cell"], 2, 2, 0, _cell_color, _cell_color, _cell_color, _cell_color, 1)
				}
			
				draw_set_font(get_language_font("fnt_crypt_of_tomorrow"))
			
				draw_text_ext_transformed(_stats_x + 13, _stats_y + 49, string_concat(global.UI_texts.lv, "\n", global.UI_texts.hp, "\n", global.UI_texts.gold), 9, 100, 2, 2, 0)
				draw_text_ext_transformed(_stats_x + 49, _stats_y + 49, string_concat(global.player.lv, "\n", global.player.hp, "/", global.player.max_hp, "\n", global.player.gold), 9, 100, 2, 2, 0)
			break}
		}
			
		if ((player_menu_state != PLAYER_MENU_STATE.BOX or player_box_cursor[0] != -1) and (player_menu_state != PLAYER_MENU_STATE.SAVE or player_save_cursor < 2) and player_menu_state != PLAYER_MENU_STATE.WAITING_DIALOG_END and player_menu_state != PLAYER_MENU_STATE.STATS){
			draw_sprite_ext(obj_game.player_heart_sprite, obj_game.player_heart_subimage, _heart_x, _heart_y, 1, 1, 0, obj_game.player_heart_color, 1)
		}
	}
	
	open_menu = function(){
		if (!ignore_first_frame_menu){
			obj_game.state = GAME_STATE.PLAYER_MENU_CONTROL
			player_menu_state = PLAYER_MENU_STATE.INITIAL
			player_menu_selection[0] = 0
			player_menu_top = ((obj_player_overworld.y - camera_get_view_y(view_camera[0])) < 310)
		}
		
		return !ignore_first_frame_menu
	}
	
	open_box_menu = function(_index){
		if (obj_game.state == GAME_STATE.PLAYER_MENU_CONTROL){
			player_menu_prev_state = PLAYER_MENU_STATE.CELL
		}else{
			player_menu_prev_state = -1
		}
	
		obj_game.state = GAME_STATE.PLAYER_MENU_CONTROL
		player_menu_state = PLAYER_MENU_STATE.BOX
		player_box_index = _index
		player_box_cursor[1] = 0
	
		if (array_length(global.player.inventory) > 0){
			player_box_cursor[0] = 0
		}else if (array_length(global.box.inventory[_index]) > 0){
			player_box_cursor[0] = 1
		}else{
			player_box_cursor[0] = -1
		}
	}
	
	open_save_menu = function(_spawn_point_inst){
		if (player_menu_prev_state == -2){
			player_menu_prev_state = -1
		
			return
		}
	
		if (obj_game.state == GAME_STATE.PLAYER_MENU_CONTROL){
			player_menu_prev_state = PLAYER_MENU_STATE.CELL
		}else{
			player_menu_prev_state = -1
		
			global.player.hp = max(global.player.hp, global.player.max_hp)
		
			audio_play_sound(snd_player_heal, 100, false)
		}
	
		player_save_spawn_point_inst = _spawn_point_inst
		obj_game.state = GAME_STATE.PLAYER_MENU_CONTROL
		player_menu_state = PLAYER_MENU_STATE.SAVE
		player_save_cursor = 0
	}
}