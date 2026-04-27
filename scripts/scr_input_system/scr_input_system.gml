/*
Control types that are mainly used for obj_game to set the global inputs of the user.
You can use them for something else as well in other variables and your own systems.
*/
enum CONTROL_TYPE{
	KEYBOARD,
	CONTROLLER,
	MAPPING_CONTROLLER,
	MOBILE
}

enum MOBILE_CONTROL{
	CROSS,
	JOYSTICK
}

/*
Constants for the CONTROLLER_MAPPING state of a controller when there's no control map that game maker can assign in it.
*/
enum CONTROLLER_MAPPING{
	WAITING_ENTER,
	GET_CONFIRM,
	GET_CANCEL,
	GET_MENU,
	TESTING,
	ERROR,
	DONE
}

function InputSystem() constructor{
	control_type = (global.is_mobile ? CONTROL_TYPE.MOBILE : CONTROL_TYPE.KEYBOARD)
	control_message = undefined
	control_timer = -1
	control_alpha = 0
	controller_id = -1 //-1 means that there's no controller assigned, either not connected or not supported.
	controller_mapping_state = -1
	controller_confirm_button = -1
	controller_cancel_button = -1
	controller_menu_button = -1
	
	temp_up_button = 0
	temp_down_button = 0
	temp_left_button = 0
	temp_right_button = 0
	temp_confirm_button = 0
	temp_cancel_button = 0
	temp_menu_button = 0
	
	mobile_movement = -1
	mobile_confirm = -1
	mobile_cancel = -1
	mobile_menu = -1
	
	mobile_distance = 0
	mobile_direction = 0
	
	step = function(){
		switch (control_type){
			case CONTROL_TYPE.MAPPING_CONTROLLER:{
				switch (controller_mapping_state){
					case CONTROLLER_MAPPING.WAITING_ENTER:{ //make macros for this in scr_init.
						if (keyboard_check_pressed(vk_enter)){
							controller_mapping_state = CONTROLLER_MAPPING.GET_CONFIRM
						}
					break}
					case CONTROLLER_MAPPING.GET_CONFIRM:{
						var _button_z = get_controller_button_pressed(controller_id)
				
						if (_button_z != -1){
							controller_confirm_button = _button_z
							controller_mapping_state = CONTROLLER_MAPPING.GET_CANCEL
						}
					break}
					case CONTROLLER_MAPPING.GET_CANCEL:{
						var _button_x = get_controller_button_pressed(controller_id)
				
						if (_button_x != -1){
							controller_cancel_button = _button_x
							controller_mapping_state = CONTROLLER_MAPPING.GET_MENU
						}
					break}
					case CONTROLLER_MAPPING.GET_MENU:{
						var _button_c = get_controller_button_pressed(controller_id)
				
						if (_button_c != -1){
							controller_menu_button = _button_c
							controller_mapping_state = CONTROLLER_MAPPING.TESTING
						}
					break}
					case CONTROLLER_MAPPING.TESTING:{
						if (keyboard_check(vk_backspace)){
							controller_mapping_state = CONTROLLER_MAPPING.GET_CONFIRM
							controller_confirm_button = -1
							controller_cancel_button = -1
							controller_menu_button = -1
						}else if (keyboard_check(vk_enter)){
							controller_mapping_state = CONTROLLER_MAPPING.DONE
							control_type = CONTROL_TYPE.CONTROLLER
							save_controller_config(controller_id)
						}
					break}
					case CONTROLLER_MAPPING.ERROR:{
						if (keyboard_check(vk_enter)){
							control_type = CONTROL_TYPE.KEYBOARD
							controller_mapping_state = -1
						}
					break}
				}
		
				global.up_button = 0
				global.left_button = 0
				global.down_button = 0
				global.right_button = 0
				global.confirm_button = 0
				global.cancel_button = 0
				global.menu_button = 0
		
				global.up_hold_button = 0
				global.left_hold_button = 0
				global.down_hold_button = 0
				global.right_hold_button = 0
				global.confirm_hold_button = 0
				global.cancel_hold_button = 0
				global.menu_hold_button = 0
			break}
			case CONTROL_TYPE.KEYBOARD:{
				global.up_button = (keyboard_check_pressed(ord("W")) or keyboard_check_pressed(vk_up))
				global.left_button = (keyboard_check_pressed(ord("A")) or keyboard_check_pressed(vk_left))
				global.down_button = (keyboard_check_pressed(ord("S")) or keyboard_check_pressed(vk_down))
				global.right_button = (keyboard_check_pressed(ord("D")) or keyboard_check_pressed(vk_right))
				global.confirm_button = (keyboard_check_pressed(ord("Z")) or keyboard_check_pressed(vk_enter))
				global.cancel_button = (keyboard_check_pressed(ord("X")) or keyboard_check_pressed(vk_shift))
				global.menu_button = (keyboard_check_pressed(ord("C")) or keyboard_check_pressed(vk_control))
		
				global.up_hold_button = (keyboard_check(ord("W")) or keyboard_check(vk_up))
				global.left_hold_button = (keyboard_check(ord("A")) or keyboard_check(vk_left))
				global.down_hold_button = (keyboard_check(ord("S")) or keyboard_check(vk_down))
				global.right_hold_button = (keyboard_check(ord("D")) or keyboard_check(vk_right))
				global.confirm_hold_button = (keyboard_check(ord("Z")) or keyboard_check(vk_enter))
				global.cancel_hold_button = (keyboard_check(ord("X")) or keyboard_check(vk_shift))
				global.menu_hold_button = (keyboard_check(ord("C")) or keyboard_check(vk_control))
			break}
			case CONTROL_TYPE.CONTROLLER:{
				var _axislv = gamepad_axis_value(controller_id, gp_axislv)
				var _axislh = gamepad_axis_value(controller_id, gp_axislh)
				var _axislv_round = round(_axislv)
				var _axislh_round = round(_axislh)
				var _padd = gamepad_button_check(controller_id, gp_padd)
				var _padl = gamepad_button_check(controller_id, gp_padl)
				var _padu = gamepad_button_check(controller_id, gp_padu)
				var _padr = gamepad_button_check(controller_id, gp_padr)
				var _up_button = max(-_axislv_round, _padu, 0)
				var _left_button = max(-_axislh_round, _padl, 0)
				var _down_button = max(_axislv_round, _padd, 0)
				var _right_button = max(_axislh_round, _padr, 0)
		
				if (temp_up_button == _up_button){
					global.up_button = 0
				}else{
					temp_up_button = _up_button
			
					global.up_button = _up_button
				}
		
				if (temp_down_button == _down_button){
					global.down_button = 0
				}else{
					temp_down_button = _down_button
			
					global.down_button = _down_button
				}
		
				if (temp_left_button == _left_button){
					global.left_button = 0
				}else{
					temp_left_button = _left_button
			
					global.left_button = _left_button
				}
		
				if (temp_right_button == _right_button){
					global.right_button = 0
				}else{
					temp_right_button = _right_button
			
					global.right_button = _right_button
				}
		
				global.up_hold_button = max(-_axislv, _padu, 0)
				global.left_hold_button = max(-_axislh, _padl, 0)
				global.down_hold_button = max(_axislv, _padd, 0)
				global.right_hold_button = max(_axislh, _padr, 0)
		
				if (controller_mapping_state == CONTROLLER_MAPPING.DONE){
					global.confirm_button = gamepad_button_check_pressed(controller_id, controller_confirm_button)
					global.cancel_button = gamepad_button_check_pressed(controller_id, controller_cancel_button)
					global.menu_button = gamepad_button_check_pressed(controller_id, controller_menu_button)
			
					global.confirm_hold_button = gamepad_button_check(controller_id, controller_confirm_button)
					global.cancel_hold_button = gamepad_button_check(controller_id, controller_cancel_button)
					global.menu_hold_button = gamepad_button_check(controller_id, controller_menu_button)
				}else{
					global.confirm_button = gamepad_button_check_pressed(controller_id, gp_face1)
					global.cancel_button = gamepad_button_check_pressed(controller_id, gp_face2)
					global.menu_button = gamepad_button_check_pressed(controller_id, gp_face4)
			
					global.confirm_hold_button = gamepad_button_check(controller_id, gp_face1)
					global.cancel_hold_button = gamepad_button_check(controller_id, gp_face2)
					global.menu_hold_button = gamepad_button_check(controller_id, gp_face4)
				}
		
				//Keyboard included
				global.up_button = max(global.up_button, keyboard_check_pressed(ord("W")) or keyboard_check_pressed(vk_up))
				global.left_button = max(global.left_button, keyboard_check_pressed(ord("A")) or keyboard_check_pressed(vk_left))
				global.down_button = max(global.down_button, keyboard_check_pressed(ord("S")) or keyboard_check_pressed(vk_down))
				global.right_button = max(global.right_button, keyboard_check_pressed(ord("D")) or keyboard_check_pressed(vk_right))
				global.confirm_button = max(global.confirm_button, keyboard_check_pressed(ord("Z")) or keyboard_check_pressed(vk_enter))
				global.cancel_button = max(global.cancel_button, keyboard_check_pressed(ord("X")) or keyboard_check_pressed(vk_shift))
				global.menu_button = max(global.menu_button, keyboard_check_pressed(ord("C")) or keyboard_check_pressed(vk_control))
		
				global.up_hold_button = max(global.up_hold_button, keyboard_check(ord("W")) or keyboard_check(vk_up))
				global.left_hold_button = max(global.left_hold_button, keyboard_check(ord("A")) or keyboard_check(vk_left))
				global.down_hold_button = max(global.down_hold_button, keyboard_check(ord("S")) or keyboard_check(vk_down))
				global.right_hold_button = max(global.right_hold_button, keyboard_check(ord("D")) or keyboard_check(vk_right))
				global.confirm_hold_button = max(global.confirm_hold_button, keyboard_check(ord("Z")) or keyboard_check(vk_enter))
				global.cancel_hold_button = max(global.cancel_hold_button, keyboard_check(ord("X")) or keyboard_check(vk_shift))
				global.menu_hold_button = max(global.menu_hold_button, keyboard_check(ord("C")) or keyboard_check(vk_control))
			break}
			case CONTROL_TYPE.MOBILE:{
				var _mobile = global.game_settings.mobile_buttons
				
				for (var _i = 0; _i < 10; _i++){
					if (device_mouse_check_button(_i, mb_left)){
						var _x = device_mouse_x_to_gui(_i)
						var _y = device_mouse_y_to_gui(_i)
						var _width = display_get_width()
						var _height = display_get_height()
						var _button_size = 13*_mobile.button_size
						
						if (mobile_confirm == _i or mobile_confirm == -1){
							if (point_distance(_mobile.confirm_button.x + 0.5, _mobile.confirm_button.y - 0.5, _width - _x, _height - _y) < _button_size){
								if (temp_confirm_button == 1){
									global.confirm_button = 0
								}else{
									temp_confirm_button = 1
			
									global.confirm_button = 1
								}
						
								mobile_confirm = _i
								global.confirm_hold_button = 1
							}else{
								mobile_confirm = -1
								temp_confirm_button = 0
						
								global.confirm_button = 0
								global.confirm_hold_button = 0
							}
						}
						
						if (mobile_cancel == _i or mobile_cancel == -1){
							if (point_distance(_mobile.cancel_button.x + 0.5, _mobile.cancel_button.y - 0.5, _width - _x, _height - _y) < _button_size){
								if (temp_cancel_button == 1){
									global.cancel_button = 0
								}else{
									temp_cancel_button = 1
			
									global.cancel_button = 1
								}
						
								mobile_cancel = _i
								global.cancel_hold_button = 1
							}else{
								mobile_cancel = -1
								temp_cancel_button = 0
						
								global.cancel_button = 0
								global.cancel_hold_button = 0
							}
						}
					
						if (mobile_menu == _i or mobile_menu == -1){
							if (point_distance(_mobile.menu_button.x + 0.5, _mobile.menu_button.y - 0.5, _width - _x, _height - _y) < _button_size){
								if (temp_menu_button == 1){
									global.menu_button = 0
								}else{
									temp_menu_button = 1
			
									global.menu_button = 1
								}
						
								mobile_menu = _i
								global.menu_hold_button = 1
							}else{
								mobile_menu = -1
								temp_menu_button = 0
						
								global.menu_button = 0
								global.menu_hold_button = 0
							}
						}
						
						if (mobile_movement == _i or mobile_movement == -1){
							var _movement_size = 29*_mobile.button_size
							
							if (device_mouse_check_button_pressed(_i, mb_left) and ((!_mobile.movable_move_button and point_distance(_mobile.move_button.x, _mobile.move_button.y, _x, _height - _y) < _movement_size) or (_mobile.movable_move_button and ((!_mobile.left_handed and _x < _width/2 - _movement_size) or (_mobile.left_handed and _x > _width/2 + _movement_size))))){
								mobile_movement = _i
								
								if (_mobile.movable_move_button){
									_mobile.move_button.x = _x
									_mobile.move_button.y = clamp(_height - _y, _movement_size, _height - _movement_size)
								}
							}
							
							if (mobile_movement == _i){
								var _deadzone = (8 + 3*(_mobile.type == MOBILE_CONTROL.CROSS))*_mobile.button_size
								mobile_distance = min(point_distance(_mobile.move_button.x, _mobile.move_button.y, _x, _height - _y), _movement_size)
								mobile_direction = point_direction(_mobile.move_button.x, _mobile.move_button.y, _x, _height - _y)
							
								while (mobile_direction < 0){
									mobile_direction += 360
								}
								while (mobile_direction >= 360){
									mobile_direction -= 360
								}
							
								switch (_mobile.type){
									case MOBILE_CONTROL.CROSS:{
										if (mobile_distance > _deadzone){
											if (mobile_direction <= 67.5 or mobile_direction > 292.5){
												if (temp_right_button == 1){
													global.right_button = 0
												}else{
													temp_right_button = 1
			
													global.right_button = 1
												}
												
												global.right_hold_button = 1
											}else{
												temp_right_button = 0
												
												global.right_button = 0
												global.right_hold_button = 0
											}
											
											if (mobile_direction > 22.5 and mobile_direction <= 157.5){
												if (temp_down_button == 1){
													global.down_button = 0
												}else{
													temp_down_button = 1
			
													global.down_button = 1
												}
												
												global.down_hold_button = 1
											}else{
												temp_down_button = 0
												
												global.down_button = 0
												global.down_hold_button = 0
											}
											
											if (mobile_direction > 112.5 and mobile_direction <= 247.5){
												if (temp_left_button == 1){
													global.left_button = 0
												}else{
													temp_left_button = 1
			
													global.left_button = 1
												}
												
												global.left_hold_button = 1
											}else{
												temp_left_button = 0
												
												global.left_button = 0
												global.left_hold_button = 0
											}
											
											if (mobile_direction > 202.5 and mobile_direction <= 337.5){
												if (temp_up_button == 1){
													global.up_button = 0
												}else{
													temp_up_button = 1
			
													global.up_button = 1
												}
												
												global.up_hold_button = 1
											}else{
												temp_up_button = 0
												
												global.up_button = 0
												global.up_hold_button = 0
											}
										}else{
											temp_up_button = 0
											temp_down_button = 0
											temp_left_button = 0
											temp_right_button = 0
						
											global.up_button = 0
											global.left_button = 0
											global.down_button = 0
											global.right_button = 0
											global.up_hold_button = 0
											global.left_hold_button = 0
											global.down_hold_button = 0
											global.right_hold_button = 0
										}
									break}
									case MOBILE_CONTROL.JOYSTICK:{
										var _valid_zone = _movement_size - _deadzone
										var _valid_distance = max(mobile_distance - _deadzone, 0)
										var _axislv = _valid_distance*dsin(mobile_direction)/_valid_zone
										var _axislh = _valid_distance*dcos(mobile_direction)/_valid_zone
										var _axislv_round = round(_axislv)
										var _axislh_round = round(_axislh)
										var _up_button = max(-_axislv_round, 0)
										var _left_button = max(-_axislh_round, 0)
										var _down_button = max(_axislv_round, 0)
										var _right_button = max(_axislh_round, 0)
		
										if (temp_up_button == _up_button){
											global.up_button = 0
										}else{
											temp_up_button = _up_button
			
											global.up_button = _up_button
										}
		
										if (temp_down_button == _down_button){
											global.down_button = 0
										}else{
											temp_down_button = _down_button
			
											global.down_button = _down_button
										}
		
										if (temp_left_button == _left_button){
											global.left_button = 0
										}else{
											temp_left_button = _left_button
			
											global.left_button = _left_button
										}
		
										if (temp_right_button == _right_button){
											global.right_button = 0
										}else{
											temp_right_button = _right_button
			
											global.right_button = _right_button
										}
		
										global.up_hold_button = max(-_axislv, 0)
										global.left_hold_button = max(-_axislh, 0)
										global.down_hold_button = max(_axislv, 0)
										global.right_hold_button = max(_axislh, 0)
									break}
								}
							}
						}
					}else{
						if (mobile_confirm == _i){
							mobile_confirm = -1
							temp_confirm_button = 0
						
							global.confirm_button = 0
							global.confirm_hold_button = 0
						}
						
						if (mobile_cancel == _i){
							mobile_cancel = -1
							temp_cancel_button = 0
						
							global.cancel_button = 0
							global.cancel_hold_button = 0
						}
						
						if (mobile_menu == _i){
							mobile_menu = -1
							temp_menu_button = 0
						
							global.menu_button = 0
							global.menu_hold_button = 0
						}
						
						if (mobile_movement == _i){
							mobile_movement = -1
							mobile_distance = 0
							mobile_direction = 0
							
							temp_up_button = 0
							temp_down_button = 0
							temp_left_button = 0
							temp_right_button = 0
						
							global.up_button = 0
							global.left_button = 0
							global.down_button = 0
							global.right_button = 0
							global.up_hold_button = 0
							global.left_hold_button = 0
							global.down_hold_button = 0
							global.right_hold_button = 0
						}
					}
				}
			break}
			//If you want to add more type of controls or variantions of the previous ones add them as cases and define their macros in this script.
			//After that set the control_type variable to the initial control type or handle its connection and disconnection in the corresponding place.
		}
		
		if (control_timer >= 0){
			control_timer++
	
			if (control_timer > 120){
				control_alpha = (240 - control_timer)/120
			}
	
			if (control_timer == 240){
				control_timer = -1
				control_message = undefined
				control_alpha = 0
			}
		}
		
		if (global.is_mobile){
			global.escape_button = keyboard_check_pressed(vk_backspace)
			global.escape_hold_button = keyboard_check(vk_backspace)
		}else{
			global.escape_button = keyboard_check_pressed(vk_escape) //Exclusive to keyboard.
			global.escape_hold_button = keyboard_check(vk_escape) //Exclusive to keyboard.
		}
	}
	
	can_draw = function(){
		return (control_type == CONTROL_TYPE.MAPPING_CONTROLLER or !is_undefined(control_message))
	}
	
	draw = function(){
		if (control_type == CONTROL_TYPE.MAPPING_CONTROLLER){
			draw_set_halign(fa_center)
			draw_set_valign(fa_top)
			draw_set_font(get_language_font("fnt_determination_mono"))
		
			draw_sprite_ext(spr_pixel, 0, 0, 0, GAME_WIDTH, GAME_HEIGHT, 0, c_black, 0.75)
	
			switch (controller_mapping_state){
				case CONTROLLER_MAPPING.WAITING_ENTER:{
					draw_text_transformed(GAME_WIDTH/2, 140, global.UI_texts.controller[$"discovered with no mapping"], 2, 2, 0)
				break}
				case CONTROLLER_MAPPING.GET_CONFIRM:{
					draw_text_transformed(GAME_WIDTH/2, 180, string_replace(global.UI_texts.controller[$"mapping button"], "[Action]", "Z/Confirm"), 2, 2, 0)
				break}
				case CONTROLLER_MAPPING.GET_CANCEL:{
					draw_text_transformed(GAME_WIDTH/2, 180, string_replace(global.UI_texts.controller[$"mapping button"], "[Action]", "X/Cancel"), 2, 2, 0)
				break}
				case CONTROLLER_MAPPING.GET_MENU:{
					draw_text_transformed(GAME_WIDTH/2, 180, string_replace(global.UI_texts.controller[$"mapping button"], "[Action]", "C/Menu"), 2, 2, 0)
				break}
				case CONTROLLER_MAPPING.TESTING:{
					draw_text_transformed(GAME_WIDTH/2, 20, global.UI_texts.controller[$"mapping complete"], 2, 2, 0)
				
					var _axislv = gamepad_axis_value(controller_id, gp_axislv)
					var _axislh = gamepad_axis_value(controller_id, gp_axislh)
					var _padd = gamepad_button_check(controller_id, gp_padd)
					var _padl = gamepad_button_check(controller_id, gp_padl)
					var _padu = gamepad_button_check(controller_id, gp_padu)
					var _padr = gamepad_button_check(controller_id, gp_padr)
					var _vertical = max(_axislv, _padd, 0) - max(-_axislv, _padu, 0)
					var _horizontal = max(_axislh, _padr, 0) - max(-_axislh, _padl, 0)
				
					draw_circle_color(210, 180, 40, c_dkgray, c_dkgray, true)
					draw_circle_color(210 + 20*_horizontal, 180 + 20*_vertical, 20, c_white, c_white, false)
					draw_circle_color(210 + 20*_horizontal, 180 + 20*_vertical, 16, c_gray, c_gray, true)
					draw_circle_color(290, 180, 20, c_white, c_white, gamepad_button_check(controller_id, controller_confirm_button))
					draw_circle_color(350, 180, 20, c_white, c_white, gamepad_button_check(controller_id, controller_cancel_button))
					draw_circle_color(410, 180, 20, c_white, c_white, gamepad_button_check(controller_id, controller_menu_button))
				
					draw_set_color(c_black)
					draw_text_transformed(290, 164, "Z", 2, 2, 0)
					draw_text_transformed(350, 164, "X", 2, 2, 0)
					draw_text_transformed(410, 164, "C", 2, 2, 0)
					draw_set_color(c_white)
				
					draw_text_transformed(GAME_WIDTH/2, 240, global.UI_texts.controller[$"mapping again"], 2, 2, 0)
				break}
				case CONTROLLER_MAPPING.ERROR:{
					draw_text_transformed(GAME_WIDTH/2, 100, global.UI_texts.controller[$"mapping error"], 2, 2, 0)
				break}
			}
		}else{
			draw_set_halign(fa_left)
			draw_set_valign(fa_top)
			draw_set_font(get_language_font("fnt_determination_sans"))
		
			draw_set_alpha(control_alpha)
			draw_text_transformed(10, 6, control_message, 1.5, 1.5, 0)
			draw_set_alpha(1)
		}
	}
	
	async_event = function(_event){
		switch (ds_map_find_value(_event, "event_type")){
			case "gamepad discovered":{
				if (controller_id == -1){
					var _index_connected = ds_map_find_value(_event, "pad_index")
					var _config = get_controller_config(_index_connected)
					if (_config == -1){
						gamepad_set_axis_deadzone(_index_connected, 0.2)
					}else{
						gamepad_set_axis_deadzone(_index_connected, _config.deadzone)
					}
					var _mapping = gamepad_get_mapping(_index_connected)
					if (_index_connected >= 4 and _mapping == "no mapping"){
						controller_id = _index_connected
						if (_config == -1){
							control_type = CONTROL_TYPE.MAPPING_CONTROLLER
							controller_mapping_state = CONTROLLER_MAPPING.WAITING_ENTER
							map_controller(_index_connected)
						}else{
							control_timer = 0
							control_message = global.UI_texts.controller.discovered
							control_alpha = 1
							control_type = CONTROL_TYPE.CONTROLLER
							controller_mapping_state = CONTROLLER_MAPPING.DONE
							controller_confirm_button = _config.confirm
							controller_cancel_button = _config.cancel
							controller_menu_button = _config.menu
						}
					}else if (_mapping != "device index out of range" and _mapping != ""){
						control_timer = 0
						control_message = global.UI_texts.controller.discovered
						control_alpha = 1
						control_type = CONTROL_TYPE.CONTROLLER
						controller_id = _index_connected
						controller_mapping_state = -1
					}
				}/*else{
					//There's already a controller connected, cannot assign another.	
				}*/
			break}
			case "gamepad lost":{
				var _index_disconnected = ds_map_find_value(_event, "pad_index")
				if (controller_id == _index_disconnected){
					if (control_type == CONTROL_TYPE.MAPPING_CONTROLLER){
						controller_mapping_state = CONTROLLER_MAPPING.ERROR
					}else{
						control_type = CONTROL_TYPE.KEYBOARD
						control_timer = 0
						control_message = global.UI_texts.controller.lost
						control_alpha = 1
						controller_mapping_state = -1
					}
					controller_id = -1
					controller_confirm_button = -1
					controller_cancel_button = -1
					controller_menu_button = -1
				}
			break}
		}
	}

	/*
	This function starts the sequence to assign the controller's button to the confirm, cancel and menu actions of the game.
	Only executes if game maekr has no CONTROLLER_MAPPING for the controller when connected from the Async - System event.
	You can also run it to remap the controller in a configuration menu too.

	INTEGER _index -> Must be the index of the controller that you are trying to map, get it from the Async - System event or use the controller_id variable from this object that gets sets to the first connected controller that is supported by game maker (see that process in the Async - System event of this object).
	*/
	map_controller = function(_index){
		control_type = CONTROL_TYPE.MAPPING_CONTROLLER
		controller_id = _index
		controller_mapping_state = CONTROLLER_MAPPING.WAITING_ENTER
	}

	get_controller_button_pressed = function(_index){
		if (gamepad_button_check_pressed(_index, gp_face1)){
			return gp_face1
		}
		if (gamepad_button_check_pressed(_index, gp_face2)){
			return gp_face2
		}
		if (gamepad_button_check_pressed(_index, gp_face3)){
			return gp_face3
		}
		if (gamepad_button_check_pressed(_index, gp_face4)){
			return gp_face4
		}
		if (gamepad_button_check_pressed(_index, gp_start)){
			return gp_start
		}
		if (gamepad_button_check_pressed(_index, gp_select)){
			return gp_select
		}
		if (gamepad_button_check_pressed(_index, gp_home)){
			return gp_home
		}
		if (gamepad_button_check_pressed(_index, gp_extra1)){
			return gp_extra1
		}
		if (gamepad_button_check_pressed(_index, gp_extra2)){
			return gp_extra2
		}
		if (gamepad_button_check_pressed(_index, gp_extra3)){
			return gp_extra3
		}
		if (gamepad_button_check_pressed(_index, gp_extra4)){
			return gp_extra4
		}
		if (gamepad_button_check_pressed(_index, gp_extra5)){
			return gp_extra5
		}
		if (gamepad_button_check_pressed(_index, gp_extra6)){
			return gp_extra6
		}
		return -1
	}

	get_controller_config = function(_index){
		if (file_exists("controller settings.save")){
			var _data = ""
			var _guid = gamepad_get_guid(_index)
			var _description = gamepad_get_description(_index)
		
			var _file = file_text_open_read("controller settings.save")
			var _list = json_parse(file_text_read_string(_file))
			file_text_close(_file)
		
			var _length = array_length(_list)
			for (var _i = 0; _i < _length; _i++){
				_data = _list[_i]
				if (_data.guid == _guid and _data.description == _description){
					return _data
				}
			}
		}
	
		return -1
	}

	save_controller_config = function(_index){
		if (!file_exists("controller settings.save")){
			var _file = file_text_open_write("controller settings.save")
			file_text_write_string(_file, "[]")
			file_text_close(_file)
		}
	
		var _guid = gamepad_get_guid(_index)
		var _description = gamepad_get_description(_index)
	
		var _file = file_text_open_read("controller settings.save")
		var _list = json_parse(file_text_read_string(_file))
		file_text_close(_file)
	
		var _length = array_length(_list)
		var _found = false
		for (var _i = 0; _i < _length; _i++){
			var _data = _list[_i]
			if (_data.guid == _guid and _data.description == _description){
				_data.confirm = controller_confirm_button
				_data.cancel = controller_cancel_button
				_data.menu = controller_menu_button
				_data.deadzone = gamepad_get_axis_deadzone(_index)
			
				_found = true
				break
			}
		}
	
		if (!_found){
			array_push(_list, {"guid": _guid, "description": _description, "confirm": controller_confirm_button, "cancel": controller_cancel_button, "menu": controller_menu_button, "deadzone": gamepad_get_axis_deadzone(_index)})
		}
	
		_file = file_text_open_write("controller settings.save")
		file_text_write_string(_file, json_stringify(_list))
		file_text_close(_file)
	}
}

function draw_mobile_buttons(){
	var _mobile = global.game_settings.mobile_buttons
	var _scale = _mobile.button_size
	var _alpha = _mobile.alpha
	var _width = display_get_width()
	var _height = display_get_height()
		
	draw_sprite_ext(spr_mobile_buttons, get_confirm_button(), _width - _mobile.confirm_button.x, _height - _mobile.confirm_button.y, _scale, _scale, 0, c_white, _alpha)
	draw_sprite_ext(spr_mobile_buttons, 2 + get_cancel_button(), _width - _mobile.cancel_button.x, _height - _mobile.cancel_button.y, _scale, _scale, 0, c_white, _alpha)
	draw_sprite_ext(spr_mobile_buttons, 4 + get_menu_button(), _width - _mobile.menu_button.x, _height - _mobile.menu_button.y, _scale, _scale, 0, c_white, _alpha)
		
	if (_mobile.type == MOBILE_CONTROL.CROSS){
		var _sum = abs(get_horizontal_button_force()) + abs(get_vertical_button_force())
		var _direction = 0
			
		if (get_left_button()){
			_direction = 90
				
			if (get_down_button()){
				_direction += 90
			}
		}else if (get_up_button()){
			//Nothing
		}else if (get_right_button()){
			_direction = -90
		}else if (get_down_button()){
			_direction = 180
		}
			
		draw_sprite_ext(spr_mobile_cross, _sum, _mobile.move_button.x, _height - _mobile.move_button.y, _scale, _scale, _direction, c_white, _alpha)
		draw_sprite_ext(spr_mobile_cross_pointer, 0, _mobile.move_button.x + input_system.mobile_distance*dcos(input_system.mobile_direction), _height - _mobile.move_button.y + input_system.mobile_distance*dsin(input_system.mobile_direction), _scale, _scale, 0, c_white, _alpha)
	}else{
		draw_sprite_ext(spr_mobile_joystick_background, 0, _mobile.move_button.x, _height - _mobile.move_button.y, _scale, _scale, 0, c_white, _alpha)
		draw_sprite_ext(spr_mobile_joystick, 0, _mobile.move_button.x + input_system.mobile_distance*dcos(input_system.mobile_direction), _height - _mobile.move_button.y + input_system.mobile_distance*dsin(input_system.mobile_direction), _scale, _scale, 0, c_white, _alpha)
	}
}
