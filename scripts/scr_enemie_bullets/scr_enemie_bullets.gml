//Normal bullets

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
	
	array_push(get_battle_bullets_array(), _platform) //It's not really a bullet, but it does clear it from screen if added to this table
	
	return _platform
}

function spawn_bullet(_sprite, _x, _y, _direction, _depth=0, _damage=3, _type=BULLET_TYPE.WHITE){
	var _bullet = instance_create_depth(_x + obj_battle_box.x, _y + obj_battle_box.y - obj_battle_box.height/2 - 5, _depth, obj_battle_bullet)
	with (_bullet){
		sprite_index = _sprite
		damage = _damage
		direction = _direction
		
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
	
	array_push(get_battle_bullets_array(), _bullet)
	
	return _bullet
}

//Menu bullets

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
	
	array_push(get_battle_menu_bullets_array(), _bullet)
	
	return _bullet
}