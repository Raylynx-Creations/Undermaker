/// @description Variable declaration

movement_speed = 2 //Speed of the soul is usually 2
trail = false //Flag to draw or not trail on the player, you can use player_set_trail() function too

//Gravity soul data to apply gravity and momentum plus some effects and mechanics.
//Ahead more data is added but here is the data you can modify, only these ones!
gravity_data = {
	allowed_angle_range_to: {
		grip: 20,
		jump: 40,
		bonk: 45
	},
	movement: {
		direction_change_time: 4
	},
	jump: {
		duration: 38,
		max_height: 80
	}
}

//------------------Programmer area-------------------

mode = -1 //Mode of the soul is controlled by this variable
invulnerability_frames = 0 //Counter for invulnerability frames

box_depth = inst_battle_box.depth

//Trail layer and arrays
layer_trail = layer_create(depth + 1, "Soul Trail")
trail_sprites = []

//Array to make sure the collision is not looping forever, recording all positions it has been, if any repeat, we stop collision early.
soul_previous_positions = []

//Animation for when the player is stuck on the sticky platform
sticky_animation = {timer: 0, direction: 0, distance: 2, keep_animation: false}
//Gravity soul data to apply gravity and momentum plus some effects and mechanics
gravity_data.direction = GRAVITY_SOUL.DOWN
gravity_data.on_platform = false
gravity_data.slam = false
gravity_data.cannot_jump = false
gravity_data.cannot_stop_jump = false
gravity_data.ignore_first_frame = false
gravity_data.movement.direction = 0
gravity_data.movement.speed = 0
gravity_data.jump.movement_offset = 0
gravity_data.jump.speed = 0
gravity_data.orange_mode = false

//Conveyor force applied when on conveyor platforms
conveyor_push = {x: 0, y: 0}
platform_vel = {x: 0, y: 0} //Force that applies when platforms are moving and you collide with them
extra_vertical_movement = {multiplier: 0, speed: 0, max_force: 80, duration: 38} //These kinda mimic the gravity behavior of the gravity soul, but this one is used for the red soul since it doesn't have a jump.speed attribute
extra_horizontal_movement = {multiplier: 0, speed: 0, max_force: 80, duration: 38} //These kinda mimic the gravity behavior of the gravity soul

//Sticky platform animation offsets
animation_offset_x = 0
animation_offset_y = 0

//Player movement variables, we don't update x or y directly
move_x = 0
move_y = 0
move_to_x = undefined
move_to_y = undefined

//Calculate the collision offsets and assign them to 4 variables, one for each side
calculate_object_collision_offset()

//Set the player soul mode to the normal one (Red soul)
set_soul_mode(SOUL_MODE.NORMAL)
