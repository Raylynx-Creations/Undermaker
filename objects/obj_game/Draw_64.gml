var _screen_height = resolutions_height[global.game_settings.resolution_active]
var _game_width = _screen_height*(4/3)
var _ui_not_showing = (input_system.can_draw() or state == GAME_STATE.PLAYER_MENU_CONTROL or state == GAME_STATE.BATTLE_END or (state == GAME_STATE.BATTLE and (battle_system.battle_black_alpha > 0 or get_battle_state() == BATTLE_STATE.END_DODGE_ATTACK)) or state == GAME_STATE.GAME_OVER or state == GAME_STATE.ROOM_CHANGE or state == GAME_STATE.BATTLE_START_ANIMATION or !battle_system.battle_dialog.is_finished() or !dialog.is_finished())

if (_ui_not_showing){
	if (!surface_exists(ui_surface)){
		ui_surface = surface_create(GAME_WIDTH, GAME_HEIGHT)
	}
	surface_set_target(ui_surface)
	
	draw_clear_alpha(c_black, 0)
	
	switch (state){
		case GAME_STATE.GAME_OVER:{
			game_over_system.draw()
		break}
	}
	
	dialog.draw()
	
	switch (state){
		case GAME_STATE.BATTLE_END:{
			draw_sprite_ext(spr_pixel, 0, 0, 0, 640, 480, 0, c_black, 1 - anim_timer/20)
		break}
		case GAME_STATE.BATTLE:{
			battle_system.draw_gui()
		break}
		case GAME_STATE.ROOM_CHANGE:{
			room_transition_system.draw()
		break}
		case GAME_STATE.BATTLE_START_ANIMATION:{
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
		case GAME_STATE.DIALOG_PLUS_CHOICE:{
			for (var _i = 0; _i < 4; _i++){
				if (!is_undefined(plus_options[_i])){
					plus_options[_i][4].draw()
				}
			}
			
			if (selection >= 0){
				draw_sprite_ext(choice_sprite, choice_index, options_x + plus_options[selection][0], options_y + plus_options[selection][1], 1, 1, 0, player_heart_color, 1)
			}else{
				draw_sprite_ext(choice_sprite, choice_index, options_x, options_y, 1, 1, 0, player_heart_color, 1)
			}
		break}
		case GAME_STATE.DIALOG_GRID_CHOICE:{
			var _length = array_length(grid_options)
			for (var _i = 0; _i < _length; _i++){
				grid_options[_i][4].draw()
			}
			
			if (selection >= 0){
				draw_sprite_ext(choice_sprite, choice_index, options_x + grid_options[selection][0], options_y + grid_options[selection][1], 1, 1, 0, player_heart_color, 1)
			}else{
				draw_sprite_ext(choice_sprite, choice_index, options_x, options_y, 1, 1, 0, player_heart_color, 1)
			}
		break}
		case GAME_STATE.PLAYER_MENU_CONTROL:{
			player_menu_system.draw()
		break}
	}
	
	input_system.draw()

	surface_reset_target()
}

if (global.game_settings.border_active){
	if (window_get_fullscreen()){
		_game_width /= 1.125
		
		var _screen_width = resolutions_width[global.game_settings.resolution_active]
		var _game_height = _screen_height/1.125
		var _border_width = _screen_height*(16/9)
		var _x = (_screen_width - _game_width)/2
		var _y = _screen_height*0.0625/1.125
		
		var _x_scale = _game_width/GAME_WIDTH
		var _y_scale = _game_height/GAME_HEIGHT
		
		draw_sprite_ext(spr_border, global.game_settings.border_id, (_screen_width - _border_width)/2, 0, _border_width/1920, _screen_height/1080, 0, c_white, 1)
		draw_surface_ext(application_surface, _x, _y, _x_scale, _y_scale, 0, c_white, 1)
		
		if (_ui_not_showing){
			draw_surface_ext(ui_surface, _x, _y, _x_scale, _y_scale, 0, c_white, 1)
		}
	}else{
		var _x = (1.5*resolutions_width[global.game_settings.resolution_active] - _game_width)/2
		var _y = _screen_height*0.0625
		var _x_scale = _game_width/GAME_WIDTH
		var _y_scale = _screen_height/GAME_HEIGHT
		
		draw_sprite_ext(spr_border, global.game_settings.border_id, 0, 0, _screen_height*(16/9)*1.125/1920, _screen_height*1.125/1080, 0, c_white, 1)
		draw_surface_ext(application_surface, _x, _y, _x_scale, _y_scale, 0, c_white, 1)
		
		if (_ui_not_showing){
			draw_surface_ext(ui_surface, _x, _y, _x_scale, _y_scale, 0, c_white, 1)
		}
	}
}else{
	var _x = (resolutions_width[global.game_settings.resolution_active] - _game_width)/2
	var _x_scale = _game_width/GAME_WIDTH
	var _y_scale = _screen_height/GAME_HEIGHT
	
	draw_surface_ext(application_surface, _x, 0, _x_scale, _y_scale, 0, c_white, 1)
	
	if (_ui_not_showing){
		draw_surface_ext(ui_surface, _x, 0, _x_scale, _y_scale, 0, c_white, 1)
	}
}

if (!_ui_not_showing and surface_exists(ui_surface)){
	surface_free(ui_surface)
	ui_surface = -1
}