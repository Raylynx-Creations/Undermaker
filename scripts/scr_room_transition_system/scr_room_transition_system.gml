function RoomTransitionSystem() constructor{
	anim_timer = 0
	room_change_fade_in_time = 0
	room_change_wait_time = 0
	room_change_fade_out_time = 0
	
	goto_room = undefined
	after_transition_function = undefined
	
	step = function(){
		anim_timer++
		
		if (anim_timer == room_change_fade_in_time){
			room_goto(goto_room)
		}else if (anim_timer == room_change_fade_out_time){
			obj_game.state = GAME_STATE.PLAYER_CONTROL
			
			if (!is_undefined(after_transition_function)){
				after_transition_function()
				after_transition_function = undefined
			}
		}
	}
	
	draw = function(){
		draw_sprite_ext(spr_pixel, 0, 0, 0, 640, 480, 0, c_black, (min(anim_timer, room_change_fade_in_time) - max(anim_timer - room_change_wait_time, 0))/20)
	}
}