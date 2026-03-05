/// @description Variable declaration

movement_speed = 2
mode = -1
invulnerability_frames = 0
trail = false

//-------------------------------------

layer_trail = layer_create(depth + 1, "Soul Trail")
trail_sprites = []
soul_previous_positions = []

sticky_animation = {timer: 0, direction: 0, distance: 2, keep_animation: false}
gravity_data = {direction: GRAVITY_SOUL.DOWN, box_bound: true, on_platform: false, slam: false, allowed_angle_range_to: {grip: 20, jump: 40, bonk: 45}, cannot_jump: false, cannot_stop_jump: false, ignore_first_frame: false, movement: {direction: 0, speed: 0, direction_change: {time: 4, speed: movement_speed}}, jump: {movement_offset: 0, speed: 0, duration: 38, max_height: 80}, orange_mode: false}
conveyor_push = {x: 0, y: 0}
platform_vel = {x: 0, y: 0}
extra_vertical_movement = {multiplier: 0, speed: 0, max_force: 80, duration: 38} //These kinda mimic the gravity behavior of the gravity soul, but this one is used for the red soul since it doesn't have a jump.speed attribute
extra_horizontal_movement = {multiplier: 0, speed: 0, max_force: 80, duration: 38} //These kinda mimic the gravity behavior of the gravity soul

animation_offset_x = 0
animation_offset_y = 0
move_x = 0
move_y = 0
move_to_x = undefined
move_to_y = undefined

calculate_object_collision_offset()

set_mode = function(_mode, _args_struct=undefined){
	if (mode != _mode){
		conveyor_push.x = 0
		conveyor_push.y = 0
	}
	
	switch (_mode){
		case SOUL_MODE.NORMAL:{
			image_blend = c_red
			image_angle = 0
		break}
		case SOUL_MODE.GRAVITY:{
			with (gravity_data){
				if (other.mode != _mode){
					direction = GRAVITY_SOUL.DOWN
				}
				orange_mode = false
				jump.speed = 0
				jump.movement_offset = 0
				movement.speed = 0
				other.image_angle = 90*direction
			
				if (is_undefined(_args_struct)){
					other.image_blend = make_color_rgb(0,60,255)
				}else{
					if (variable_struct_exists(_args_struct, "box_bound") and !_args_struct.box_bound){
						box_bound = false
					}
					
					if (variable_struct_exists(_args_struct, "orange") and !_args_struct.orange){
						other.image_blend = make_color_rgb(0,60,255)
					}else{
						other.image_blend = make_color_rgb(255,127,0)
				
						orange_mode = true
						movement_direction = 0
					}
				}
			}
		break}
	}
	
	mode = _mode
}

set_mode(SOUL_MODE.NORMAL)
