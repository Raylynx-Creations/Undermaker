function RoomTransitionSystem() constructor{
	anim_timer = 0
	room_change_fade_in_time = 0
	room_change_wait_time = 0
	room_change_fade_out_time = 0
	
	alpha = 0
	update_border_alpha = false
	
	goto_room = undefined
	after_transition_function = undefined
	
	step = function(){
		anim_timer++
		
		if (anim_timer == room_change_fade_in_time){
			room_goto(goto_room)
		}else if (anim_timer == room_change_fade_out_time){
			obj_game.state = GAME_STATE.PLAYER_CONTROL
			obj_player_overworld.state = PLAYER_STATE.MOVEMENT
			
			if (!is_undefined(after_transition_function)){
				after_transition_function()
				after_transition_function = undefined
			}
		}
		
		alpha = (min(anim_timer, room_change_fade_in_time) - max(anim_timer - room_change_wait_time, 0))/20
		
		if (is_border_dynamic() and update_border_alpha){
			obj_game.border_alpha = 1 - alpha
		}
	}
	
	draw = function(){
		draw_sprite_ext(spr_pixel, 0, 0, 0, 640, 480, 0, c_black, alpha)
	}
}