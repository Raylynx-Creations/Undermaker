function GameOverSystem() constructor{
	game_over_timer = 0
	game_over_heart_x = 0
	game_over_heart_y = 0
	game_over_heart_color = 0
	game_over_dialog = undefined
	game_over_music = undefined
	game_over_dialog = []
	game_over_shards = []
	
	game_over_dialog_system = new DialogSystem(0, 0, [], 1)
	game_over_music_system = new MusicSystem()
	
	step = function(){
		game_over_timer++
		
		switch (game_over_timer){
			case 75:{
				audio_play_sound(snd_player_heart_break, 100, false)
			break}
			case 150:{
				audio_play_sound(snd_player_heart_shatter, 100, false)
				
				for (var _i=0; _i<6; _i++){
					array_push(game_over_shards, {x: game_over_heart_x, y: game_over_heart_y, x_speed: irandom_range(-40, 40), y_speed: irandom(40)})
				}
			break}
			case 225:{
				game_over_music_system.set_music(game_over_music)
			break}
			case 350:{
				game_over_dialog_system.set_dialogues(game_over_dialog, 170)
				game_over_dialog_system.set_scale(2, 2)
				game_over_dialog_system.set_container_sprite(undefined)
				game_over_dialog_system.set_container_tail_sprite(undefined)
				game_over_dialog_system.set_container_tail_mask_sprite(undefined)
				game_over_dialog_system.move_to(150, 340)
			break}
			case 351:{
				if (!game_over_dialog_system.is_finished()){
					game_over_timer--
				}
			break}
			case 352:{
				if (!global.confirm_button){
					game_over_timer--	
				}else{
					game_over_music_system.set_gain(0, 1333)
				}
			break}
			case 472:{
				if (room == rm_battle){
					with (obj_game){
						battle_system.clear_battle()
					
						obj_game.start_room_function = death_reset
				
						room_goto(obj_game.player_prev_room)
					}
				}else{
					perform_game_load()
				}
			break}
			case 492:{
				while (!game_over_dialog_system.is_finished()){
					game_over_dialog_system.next_dialog()
				}
				
				game_over_music_system.stop_music()
				
				obj_game.state = GAME_STATE.PLAYER_CONTROL
			break}
		}
		
		var _length = array_length(game_over_shards)
		for (var _i=0; _i<_length; _i++){
			var _shard = game_over_shards[_i]
			
			_shard.x += _shard.x_speed/10
			_shard.y -= _shard.y_speed/10
			_shard.y_speed--
			
			if (_shard.y > 490){
				array_delete(game_over_shards, _i, 1)
				_i--
				_length--
			}
		}
		
		game_over_dialog_system.step()
	}
	
	draw = function(){
		var _number = 255*(clamp(game_over_timer - 225, 0, 75) - clamp(game_over_timer - 352, 0, 75))/75
		var _color = make_colour_rgb(_number, _number, _number)
			
		draw_clear_alpha(c_black, 1 - max(game_over_timer - 472, 0)/20)
		draw_sprite_ext(spr_game_over, 0, 320, 160, 1, 1, 0, _color, 1 - clamp(game_over_timer - 472, 0, 1))
			
		if (game_over_timer < 75){
			draw_sprite_ext(spr_player_heart, game_over_heart_index, game_over_heart_x, game_over_heart_y, game_over_heart_xscale, game_over_heart_yscale, game_over_heart_angle, game_over_heart_color, 1)
		}else if (game_over_timer < 150){
			draw_sprite_ext(spr_player_heart_broken, game_over_heart_index, game_over_heart_x, game_over_heart_y, game_over_heart_xscale, game_over_heart_yscale, game_over_heart_angle, game_over_heart_color, 1)
		}
			
		var _length = array_length(game_over_shards)
		for (var _i=0; _i<_length; _i++){
			var _shard = game_over_shards[_i]
				
			draw_sprite_ext(spr_player_heart_shard, floor(game_over_timer/6), _shard.x, _shard.y, 1, 1, 0, game_over_heart_color, 1)
		}
		
		game_over_dialog_system.draw()
	}
}