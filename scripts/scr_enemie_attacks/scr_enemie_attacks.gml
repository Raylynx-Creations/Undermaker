enum ENEMY_ATTACK{
	SPARE,
	MAD_DUMMY_1,
	MAD_DUMMY_2,
	PLATFORM_1,
	PLATFORM_2,
	PLATFORM_3
}

function EnemyAttack(_attack_name, _position, _damage) constructor{
	timer = 0 //Every attack contains a timer for you to do stuff, if you don't need it ignore it, if you plan to design your attacks without a timer, might as well remove it, I do not recommend it tho.
	attack_done = false //A variable to read when the attack is flagged as finished and therefor must end the enemy attack state.
	draw = undefined
	cleanup = undefined
	
	switch (_attack_name){
		case ENEMY_ATTACK.PLATFORM_1: {
			battle_resize_box(290, 290, true)
			platforms = []
			array_push(platforms,
				spawn_platform(0, -110, 180,,,,, PLATFORM_TYPE.STICKY,, 0, 120),
				spawn_platform(-40, -40, -135,,,,, PLATFORM_TYPE.STICKY,, 60, 120, false),
				spawn_platform(-100, -100, -160,,,,, PLATFORM_TYPE.STICKY,, 60, 120),
				spawn_platform(-110, 0, -90,,,,, PLATFORM_TYPE.STICKY,, 0, 120),
				spawn_platform(-40, 40, -45,,,,, PLATFORM_TYPE.STICKY,, 60, 120, false),
				spawn_platform(-100, 100, -70,,,,, PLATFORM_TYPE.STICKY,, 60, 120),
				spawn_platform(0, 110, 0,,,,, PLATFORM_TYPE.STICKY,, 0, 120),
				spawn_platform(40, 40, 45,,,,, PLATFORM_TYPE.STICKY,, 60, 120, false),
				spawn_platform(100, 100, 20,,,,, PLATFORM_TYPE.STICKY,, 60, 120),
				spawn_platform(110, 0, 90,,,,, PLATFORM_TYPE.STICKY,, 0, 120),	
				spawn_platform(40, -40, 135,,,,, PLATFORM_TYPE.STICKY,, 60, 120, false),
				spawn_platform(100, -100, 110,,,,, PLATFORM_TYPE.STICKY,, 60, 120)
			)
			
			step = function(){
				if (keyboard_check_pressed(ord("1"))){
					set_soul_mode(SOUL_MODE.NORMAL)
				}
				if (keyboard_check_pressed(ord("2"))){
					set_soul_mode(SOUL_MODE.GRAVITY)
				}
				if (keyboard_check_pressed(ord("3"))){
					set_soul_mode(SOUL_MODE.GRAVITY, {orange_mode: true})
				}
				if (keyboard_check_pressed(ord("4"))){
					var _length = array_length(platforms)
					for (var _i = 0; _i < _length; _i++){
						platforms[_i].type = PLATFORM_TYPE.NORMAL
					}
				}
				if (keyboard_check_pressed(ord("5"))){
					var _length = array_length(platforms)
					for (var _i = 0; _i < _length; _i++){
						platforms[_i].type = PLATFORM_TYPE.CONVEYOR
					}
				}
				if (keyboard_check_pressed(ord("6"))){
					var _length = array_length(platforms)
					for (var _i = 0; _i < _length; _i++){
						platforms[_i].type = PLATFORM_TYPE.TRAMPOLINE
					}
				}
				if (keyboard_check_pressed(ord("7"))){
					var _length = array_length(platforms)
					for (var _i = 0; _i < _length; _i++){
						platforms[_i].type = PLATFORM_TYPE.STICKY
					}
				}
				if (keyboard_check_pressed(ord("I"))){
					set_soul_gravity(GRAVITY_SOUL.UP)
				}
				if (keyboard_check_pressed(ord("J"))){
					set_soul_gravity(GRAVITY_SOUL.LEFT)
				}
				if (keyboard_check_pressed(ord("K"))){
					set_soul_gravity() //GRAVITY_SOUL.DOWN
				}
				if (keyboard_check_pressed(ord("L"))){
					set_soul_gravity(GRAVITY_SOUL.RIGHT)
				}
				if (keyboard_check_pressed(ord("H"))){
					attack_done = true
				}
			}
			
			draw = function(){
				draw_set_font(fnt_crypt_of_tomorrow)
				draw_text_transformed(2, 2, "Press 1 to change to Red Soul.\nPress 2 to change to Blue Soul.\nPress 3 to change to Orange Soul.\nUse IJKL to change direction with gravity soul.\n\nPress 4,5,6,7 to change platform types.\nPress H to finish attack.", 2, 2, 0)
			}
		break}
		case ENEMY_ATTACK.PLATFORM_2: {
			battle_resize_box(360, 130)
			set_soul_mode(SOUL_MODE.GRAVITY)
			damage = _damage
			
			step = function(){
				timer++
				
				if (timer%90 == 30){
					with (spawn_platform(250, 30, 180, 100, -2,,, PLATFORM_TYPE.NORMAL,, 0, 120)){
						image_alpha = 0
						step = function(){
							if (x <= 70){
								image_alpha -= 0.05
							}else{
								image_alpha = min(image_alpha + 0.05, 1)
							}
						
							if (image_alpha <= 0){
								instance_destroy()
							}
						}
					}
				}
				
				if (timer%120 == 20){
					for (var _i = -170; _i <= 170; _i += 20){
						with (spawn_bullet(spr_circle_bullet, _i, 0, 90, 300, damage)){
							bounce = function(){
								with (obj_battle_platform){
									var _size = length/2
								
									if (collision_line(x - _size, y - 6, x + _size, y - 6, other.id, true, false)){
										return true
									}
								}
							
								return false
							}
						}
					}
				}
				
				if (timer == 500){
					attack_done = true
				}
			}
		break}
		case ENEMY_ATTACK.PLATFORM_3: {
			battle_resize_box(360, 130)
			set_soul_mode(SOUL_MODE.GRAVITY, {orange_mode: true})
			damage = _damage
			
			step = function(){
				timer++
				
				if (timer%90 == 30){
					for (var _i = 0; _i < 2; _i++){
						with (spawn_platform(250 - 500*_i, 30 - 60*_i, 180*_i, 80, 3*_i - 1.5,,, (_i ? ((timer%180 == 30) ? PLATFORM_TYPE.STICKY : PLATFORM_TYPE.TRAMPOLINE) : PLATFORM_TYPE.CONVEYOR), 2 - 4*irandom(1), 60 - 60*_i, 120, false)){
							image_alpha = 0
							step = function(){
								if (x < 70 or x > 570){
									image_alpha -= 0.05
								}else{
									image_alpha = min(image_alpha + 0.05, 1)
								}
						
								if (image_alpha <= 0){
									instance_destroy()
								}
							}
						}
					}
				}
				
				if (timer%60 == 20){
					var _direction = floor(timer/120)%2
					spawn_bullet(spr_circle_bullet, 115*(1 - 2*_direction), 35*irandom(2) - 20, 180*_direction, 300, damage)
				}
				
				if (timer == 600){
					attack_done = true
				}
			}
		break}
		case ENEMY_ATTACK.MAD_DUMMY_1: {
			battle_resize_box(130, 130)
			timer -= 15*_position
			damage = _damage
			
			step = function(){
				timer++
				
				if (timer%30 == 10){
					spawn_bullet(spr_circle_bullet, 0, 0, irandom(359), 300, damage)
				}
				
				if (timer > 300){
					attack_done = true
				}
			}
		break}
		case ENEMY_ATTACK.MAD_DUMMY_2: {
			battle_resize_box(130, 130)
			timer -= 15*_position
			direction = 0
			damage = _damage
			
			step = function(){
				timer++
				
				if (timer%30 == 10){
					spawn_bullet(spr_circle_bullet, 0, -55 + irandom(110), direction, 300, damage)
					direction = (direction + 180)%360
				}
				
				if (timer > 300){
					attack_done = true
				}
			}
		break}
		case ENEMY_ATTACK.SPARE: { //Yeah this is just a Spare Attack
			step = function(){
				timer++
				
				if (timer > 60){
					attack_done = true
				}
			}
		break}
	}
}