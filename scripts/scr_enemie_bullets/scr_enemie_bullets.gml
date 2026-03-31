/*
This is just an optional script where I simplify the creation of bullets in functions.
Avoid repeating yourself and just fill this script with the bullet behaviours you want and call them in the proper attacks.
Alternative you can just do inheritance on the obj_bullet and create your own behaviours too and just call the objects.
Maybe you will still want to use functions but these is how I do it, you're free to choose your own method.
*/

//Normal bullets

//This funciton spawns a platform from the obj_platform in the game, sets some properties and the player can interact with them.
//The platforms come only with step and destroy events since they are very specific.
//Platforms come with the engine included, you can modify and edit them if you need to, knowledge on the system is needed to do so, check the programmer manual for that.
function spawn_platform(_x, _y, _direction=0, _length=60, _vel_x=0, _vel_y=0, _depth=0, _type=PLATFORM_TYPE.NORMAL, _conveyor_speed=1, _fragile=0, _respawn_time=1, _respawn=true){
	var _platform = instance_create_depth(_x + obj_battle_box.x, _y + obj_battle_box.y - obj_battle_box.height/2 - 5, _depth, obj_battle_platform)
	with (_platform){
		type = _type
		image_angle = _direction
		length = _length
		conveyor_speed = _conveyor_speed
		
		move_x = _vel_x
		move_y = _vel_y
		
		fragile.respawn = _respawn
		fragile.duration_time = _fragile
		fragile.respawn_time = _respawn_time
	}
	
	array_push(battle_get_bullets_array(), _platform) //It's not really a bullet, but it does clear it from screen if added to this table
	
	return _platform
}

//Set some default bullet behavior and some cool behavior on them, the obj_bullet comes with step, draw, destroy and clean_up event calls too.
//In addition to the events it comes with begin_draw and end_draw too events if you need them, just set the variables with the proper name.
function spawn_bullet(_sprite, _x, _y, _direction, _mask_to_box=false, _depth=0, _damage=3, _type=BULLET_TYPE.WHITE){
	var _bullet = instance_create_depth(_x + obj_battle_box.x, _y + obj_battle_box.y - obj_battle_box.height/2 - 5, _depth, obj_battle_bullet)
	with (_bullet){
		sprite_index = _sprite
		damage = _damage
		direction = _direction
		mask_to_box = _mask_to_box
		
		timer = 0
		can_damage = false
		color_value = 64
		type = _type
		bounce = function(){
			return false
		}
		
		switch (type){
			case BULLET_TYPE.WHITE:{
				image_blend = c_dkgrey
			break}
			case BULLET_TYPE.CYAN:{
				image_blend = make_colour_rgb(64*33/255, 64*195/255, 64)
			break}
			case BULLET_TYPE.ORANGE:{
				image_blend = make_colour_rgb(64, 64*150/255, 0)
			break}
			case BULLET_TYPE.GREEN:{
				image_blend = make_colour_rgb(64*18/255, 64*64/255, 0)
			break}
		}
		
		step = function(){
			timer++
		
			if (timer == 60){
				depth = 0
			}else if (timer >= 120 and (x < obj_battle_box.x - obj_battle_box.width/2 or x > obj_battle_box.x + obj_battle_box.width/2 or y > obj_battle_box.y - 5 or y < obj_battle_box.y - 5 - obj_battle_box.height)){
				image_alpha -= 0.05
			}
			
			var _movement = 5*pi*dcos(1.5*min(timer, 120))/6
					
			if (!can_damage and _movement <= 0){
				can_damage = true
			}
					
			if (_movement < 1 and color_value < 255){
				color_value = min(color_value + 5, 255)
				var _number = color_value
				
				switch (type){
					case BULLET_TYPE.WHITE:{
						image_blend = make_colour_rgb(_number, _number, _number)
					break}
					case BULLET_TYPE.CYAN:{
						image_blend = make_colour_rgb(_number*33/255, _number*195/255, _number)
					break}
					case BULLET_TYPE.ORANGE:{
						image_blend = make_colour_rgb(_number, _number*150/255, 0)
					break}
					case BULLET_TYPE.GREEN:{
						image_blend = make_colour_rgb(_number*18/255, _number*64/255, 0)
					break}
				}
			}
					
			x += _movement*dcos(direction)
			y -= _movement*dsin(direction)
			
			if (bounce()){
				timer = 30
			}
					
			if (image_alpha <= 0){
				instance_destroy()
			}
		}
	}
	
	array_push(battle_get_bullets_array(), _bullet)
	
	return _bullet
}

//Menu bullets

//This single function is for doing an attack in the menu, uses the obj_bullet too, behavior is similar but adjusted for use case of the menu attack.
function menu_spawn_bullet(_sprite, _x, _y, _direction, _ignore_movement=false, _depth=0, _damage=3, _type=BULLET_TYPE.WHITE){
	var _bullet = instance_create_depth(_x, _y, _depth, obj_battle_bullet)
	with (_bullet){
		sprite_index = _sprite
		damage = _damage
		direction = _direction
		
		timer = 0
		can_damage = false
		color_value = 64
		type = _type
		ignore_movement = _ignore_movement
		original_depth = _depth
		
		var _number = 64 + 191*ignore_movement
		switch (type){
			case BULLET_TYPE.WHITE:{
				image_blend = make_colour_rgb(_number, _number, _number)
			break}
			case BULLET_TYPE.CYAN:{
				image_blend = make_colour_rgb(_number*33/255, _number*195/255, _number)
			break}
			case BULLET_TYPE.ORANGE:{
				image_blend = make_colour_rgb(_number, _number*150/255, 0)
			break}
			case BULLET_TYPE.GREEN:{
				image_blend = make_colour_rgb(_number*18/255, _number*64/255, 0)
			break}
		}
		
		step = function(){
			timer++
		
			if (timer == 45){
				depth = 0
			}
			
			var _movement = (5 + 3*ignore_movement)*pi*dcos(2*min(timer, 90))/6
					
			if (!can_damage and (_movement <= 0 or ignore_movement)){
				can_damage = true
			}
					
			if (_movement < 1 and color_value < 255){
				color_value = min(color_value + 5, 255)
				var _number = color_value
				
				switch (type){
					case BULLET_TYPE.WHITE:{
						image_blend = make_colour_rgb(_number, _number, _number)
					break}
					case BULLET_TYPE.CYAN:{
						image_blend = make_colour_rgb(_number*33/255, _number*195/255, _number)
					break}
					case BULLET_TYPE.ORANGE:{
						image_blend = make_colour_rgb(_number, _number*150/255, 0)
					break}
					case BULLET_TYPE.GREEN:{
						image_blend = make_colour_rgb(_number*18/255, _number*64/255, 0)
					break}
				}
			}
					
			x += _movement*dcos(direction)
			y -= _movement*dsin(direction)
			
			if (timer == 90){
				if (!is_player_battle_turn()){
					instance_destroy()
					
					return
				}
				
				timer = -1
				depth = original_depth
				can_damage = false
				color_value = 64 + 191*ignore_movement
				
				var _number = color_value
				switch (type){
					case BULLET_TYPE.WHITE:{
						image_blend = make_colour_rgb(_number, _number, _number)
					break}
					case BULLET_TYPE.CYAN:{
						image_blend = make_colour_rgb(_number*33/255, _number*195/255, _number)
					break}
					case BULLET_TYPE.ORANGE:{
						image_blend = make_colour_rgb(_number, _number*150/255, 0)
					break}
					case BULLET_TYPE.GREEN:{
						image_blend = make_colour_rgb(_number*18/255, _number*64/255, 0)
					break}
				}
			}
		}
	}
	
	array_push(battle_get_menu_bullets_array(), _bullet)
	
	return _bullet
}