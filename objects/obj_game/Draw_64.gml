///@description Drawing of the whole Game surface and border management, as well as size management.

//Get screen size of the current game
var _screen_height = resolutions_height[global.game_settings.resolution_active]
var _game_width = _screen_height*(4/3)
//Detrminate if the UI should draw or not
var _show_ui = (quit_timer > 0 or input_system.can_draw() or state == GAME_STATE.MENU_CONTROL or state == GAME_STATE.PLAYER_MENU_CONTROL or state == GAME_STATE.BATTLE_END or (state == GAME_STATE.BATTLE and (battle_system.battle_black_alpha > 0 or battle_get_state() == BATTLE_STATE.END_DODGE_ATTACK)) or state == GAME_STATE.GAME_OVER or state == GAME_STATE.ROOM_CHANGE or state == GAME_STATE.BATTLE_START_ANIMATION or !battle_system.battle_dialog.is_finished() or !dialog.is_finished())

if (_show_ui){
	if (!surface_exists(ui_surface)){
		ui_surface = surface_create(GAME_WIDTH, GAME_HEIGHT) //Define the surface of the game if it doesn't exist
	}
	surface_set_target(ui_surface)
	
	draw_clear_alpha(c_black, 0) //Clear the contents
	
	switch (state){
		case GAME_STATE.MENU_CONTROL:{ //Menu control system
			game_menu_system.draw()
		break}
		case GAME_STATE.GAME_OVER:{ //Game over system
			game_over_system.draw()
		break}
	}
	
	dialog.draw() //Draw the dialog
	
	switch (state){
		case GAME_STATE.BATTLE_END:{ //Black foreground that fades out for getting back to the overworld
			draw_sprite_ext(spr_pixel, 0, 0, 0, 640, 480, 0, c_black, 1 - anim_timer/20)
		break}
		case GAME_STATE.BATTLE:{ //Battle system drawing gui
			battle_system.draw_gui()
		break}
		case GAME_STATE.ROOM_CHANGE:{ //Room changing system draw
			room_transition_system.draw()
		break}
		case GAME_STATE.BATTLE_START_ANIMATION:{ //Drawing the animation for starting battles
			if (anim_timer >= 0){
				draw_sprite_ext(spr_pixel, 0, 0, 0, 640, 480, 0, c_black, 1)
				
				var _camera_x = camera_get_view_x(view_camera[0])
				var _camera_y = camera_get_view_y(view_camera[0])
				
				//If multiple players are on screen, they will do this, makes for a cool effect if you ever need multiple player instances on screen, kinda like surreal.
				with (obj_player_overworld){
					var _player_x = (obj_player_overworld.x - _camera_x)
					var _player_y = (obj_player_overworld.y - _camera_y)
					
					if (other.anim_timer < 24){
						draw_sprite_ext(sprite_index, image_index, _player_x, _player_y, image_xscale, image_yscale, image_angle, image_blend, image_alpha)
					}
					
					_player_x += image_xscale
					_player_y += image_yscale*(5 - round(sprite_height/(2*image_yscale)))
					
					if (other.anim_timer >= 20 or (other.anim_timer < 20 and other.anim_timer%8 < 4)){
						var _lerp = clamp(other.anim_timer - 24, 0, 20)/20
						
						draw_sprite_ext(spr_player_heart, other.player_heart_subimage, _player_x + _lerp*(other.battle_start_animation_player_heart_x - _player_x), _player_y + _lerp*(other.battle_start_animation_player_heart_y - _player_y), 1, 1, 0, other.player_heart_color, 1)
					}
				}
			}
		break}
		case GAME_STATE.DIALOG_PLUS_CHOICE:{ //Choice drawing, this is for the plus one
			for (var _i = 0; _i < 4; _i++){
				if (!is_undefined(plus_options[_i])){
					plus_options[_i][4].draw() //Draw every single dialog
				}
			}
			
			//Draw the heart location
			if (selection >= 0){
				draw_sprite_ext(choice_sprite, choice_index, options_x + plus_options[selection][0], options_y + plus_options[selection][1], 1, 1, 0, player_heart_color, 1)
			}else{
				draw_sprite_ext(choice_sprite, choice_index, options_x, options_y, 1, 1, 0, player_heart_color, 1)
			}
		break}
		case GAME_STATE.DIALOG_GRID_CHOICE:{ //This one is for the grid one
			var _length = array_length(grid_options)
			for (var _i = 0; _i < _length; _i++){
				grid_options[_i][4].draw() //Draw the dialog choies
			}
			
			//Also draw the player location
			if (selection >= 0){
				draw_sprite_ext(choice_sprite, choice_index, options_x + grid_options[selection][0], options_y + grid_options[selection][1], 1, 1, 0, player_heart_color, 1)
			}else{
				draw_sprite_ext(choice_sprite, choice_index, options_x, options_y, 1, 1, 0, player_heart_color, 1)
			}
		break}
		case GAME_STATE.PLAYER_MENU_CONTROL:{ //Player menu system drawing
			player_menu_system.draw()
		break}
	}
	
	input_system.draw() //Input drawing in case a controller/gamepad is connected
	
	if (quit_timer > 0){
		draw_set_font(fnt_determination_sans)
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		
		draw_text_transformed_color(10, 6 + (is_undefined(input_system.control_message) ? 0 : 20), global.UI_texts.quitting + string_repeat(".", ceil((quit_timer - 60)/30)), 1.5, 1.5, 0, c_white, c_white, c_white, c_white, min(quit_timer/120, 1))
	}

	surface_reset_target()
}

//Clear the back
draw_clear(c_black)

//Draw the game surface and the border if it's active
if (global.game_settings.border_active){
	//If border is dynamic, we use the variable for dynamic borders, if not use the defined one.
	var _border_id = (is_border_dynamic() ? border_id : global.game_settings.border_id)
	
	//The drawing is done differently depending if you're on fullscreen or not
	if (window_get_fullscreen()){
		_game_width /= 1.125
		
		var _screen_width = resolutions_width[global.game_settings.resolution_active]
		var _game_height = _screen_height/1.125
		var _border_width = _screen_height*(16/9)
		var _x = (_screen_width - _game_width)/2
		var _y = _screen_height*0.0625/1.125
		
		var _x_scale = _game_width/GAME_WIDTH
		var _y_scale = _game_height/GAME_HEIGHT
		
		draw_sprite_ext(spr_border, _border_id, (_screen_width - _border_width)/2, 0, _border_width/1920, _screen_height/1080, 0, c_white, border_alpha)
		draw_surface_ext(application_surface, _x, _y, _x_scale, _y_scale, 0, c_white, 1)
		
		//The UI always draws on front
		if (_show_ui){
			draw_surface_ext(ui_surface, _x, _y, _x_scale, _y_scale, 0, c_white, 1)
		}
	}else{
		var _x = (1.5*resolutions_width[global.game_settings.resolution_active] - _game_width)/2
		var _y = _screen_height*0.0625
		var _x_scale = _game_width/GAME_WIDTH
		var _y_scale = _screen_height/GAME_HEIGHT
		
		draw_sprite_ext(spr_border, _border_id, 0, 0, _screen_height*(16/9)*1.125/1920, _screen_height*1.125/1080, 0, c_white, border_alpha)
		draw_surface_ext(application_surface, _x, _y, _x_scale, _y_scale, 0, c_white, 1)
		
		if (_show_ui){
			draw_surface_ext(ui_surface, _x, _y, _x_scale, _y_scale, 0, c_white, 1)
		}
	}
}else{
	var _x = (resolutions_width[global.game_settings.resolution_active] - _game_width)/2
	var _x_scale = _game_width/GAME_WIDTH
	var _y_scale = _screen_height/GAME_HEIGHT
	
	draw_surface_ext(application_surface, _x, 0, _x_scale, _y_scale, 0, c_white, 1)
	
	if (_show_ui){
		draw_surface_ext(ui_surface, _x, 0, _x_scale, _y_scale, 0, c_white, 1)
	}
}

//If the UI was drawn and its surface exists, free it
if (!_show_ui and surface_exists(ui_surface)){
	surface_free(ui_surface)
	ui_surface = -1
}