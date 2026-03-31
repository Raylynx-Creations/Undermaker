/*
Define the constant for your attack name.
I am aware this list can become very very big an extensive on a full fangame, it's up to you to put the order in how you do the attacks and enums.
You can create multiple enum lists for every area you want to cover, and as for the constructor function, you can subdivide into other functions to cover each section.
Or you can just use {} to enclose chunks of code and minimize them, make sure to label them tho.
*/
enum ENEMY_ATTACK{
	SPARE, //This one must always exist, do not remove by any change, you will have to keep ENEMY_ATTACK.SPARE enum, if you want to create other enums you can but do not delete this one.
	MAD_DUMMY_1,
	MAD_DUMMY_2,
	PLATFORM_1,
	PLATFORM_2,
	PLATFORM_3,
	ATTACK_1,
	ATTACK_2
}

/*
The constructor function that creates a struct containing the data of an attack to trigger step, draw and clean_up events, but it's not an object really.
obj_game is in charge of creating and destroying these as needed, all you have to do is fill in the code, you don't have to call the constructor and handle your own attacks.
Avoid deleting this function as it is necessary for the engine, just fill the data inside, that's it.
The function comes with variables for you to use on your attacks as listed:

INTEGER _attack_name ---> Constant ENEMY_ATTACK or equivalent that determinates what attack to use.
INTEGER _position ------> Position on which the attack is placed, useful if you want to balance out the enemy attacks when using multiple and such.
REAL _damage -----------> Usually integer, it's the damage that the attack inflicts to the player, usually this damage is calculated on the scr_enemies the function calculate_enemy_damage_amount().

CONSTRUCTS -> STRUCT OF ATTACK DATA -- Usually used by the engine to perform and know when the attack is over, for the battle cycle, you don't have to call this function.
*/
function EnemyAttack(_attack_name, _position, _damage) constructor{
	/*
	IMPORTANT: For some attacks specially those of random enemies to balance well your bullets you probably need to know how many attacks are happening at the same time (since every enemie can have one attack).
	For that use the function battle_get_current_attack_amount() and you will get the number of current attacks happening, I recommend storing it in a variable.
	Not all attacks will require that, but in case they do you can use that function.
	*/
	//attack_amount = battle_get_current_attack_amount()
	
	timer = 0 //Every attack contains a timer for you to do stuff, if you don't need it ignore it, if you plan to design your attacks without a timer, might as well remove it, I do not recommend it tho.
	attack_done = false //A variable to read when the attack is flagged as finished and therefor must end the enemy attack state.
	
	//These are some of functions you define but are not mandatory, commented out events are mandatory to define on the attack.
	//step = undefined //You must define a step function in the constructor.
	draw = undefined
	cleanup = undefined
	
	//With this switch you can create your attacks, put the proper name calling and write the code to handle the attack.
	//Just don't forget to set attack_done as true when you want the attack to be over, or you will softlock the player on the game.
	//You use the battle_* functions and set_* functions corresponding to this section, consult the user manual in the documentation to know all the functions.
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
						with (spawn_bullet(spr_circle_bullet, _i, 0, 90,, 300, damage)){
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
					spawn_bullet(spr_circle_bullet, 115*(1 - 2*_direction), 35*irandom(2) - 20, 180*_direction,, 300, damage)
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
					spawn_bullet(spr_circle_bullet, 0, 0, irandom(359),, 300, damage)
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
					spawn_bullet(spr_circle_bullet, 0, -55 + irandom(110), direction,, 300, damage)
					direction = (direction + 180)%360
				}
				
				if (timer > 300){
					attack_done = true
				}
			}
		break}
		case ENEMY_ATTACK.ATTACK_1: {
			damage = _damage
			points = [140, 385, 320, 385, 500, 385, 500, 255, 320, 255, 140, 255]
			
			step = function(){
				timer++
				
				points[1] = 385 - 50*dsin(2*timer)
				points[3] = 385 - 50*dsin(2*max(timer - 30, 0))
				points[5] = 385 - 50*dsin(2*max(timer - 60, 0))
				points[7] = 255 - 50*dsin(2*max(timer - 60, 0))
				points[9] = 255 - 50*dsin(2*max(timer - 30, 0))
				points[11] = 255 - 50*dsin(2*timer)
				
				battle_set_box_polygon_points(points, false)
				
				if (timer%120 == 10){
					var _except = -40 + 20*irandom(4)
					for (var _i = -120; _i <= 120; _i += 20){
						if (_except == _i){
							continue
						}
						
						with (spawn_bullet(spr_circle_bullet, 210, _i, 0, true,, damage)){
							image_blend = c_white
							can_damage = true
							
							step = function(){
								x -= 1.5
							
								if (x < 110){
									instance_destroy()
								}
							}
						}
					}
				}
				
				if (timer > 360){
					attack_done = true
				}
			}
		break}
		case ENEMY_ATTACK.ATTACK_2: {
			battle_set_box_polygon_points([140, 385, 500, 385], false)
			set_soul_mode(SOUL_MODE.GRAVITY)
			damage = _damage
			
			step = function(){
				timer++
				
				if (timer%60 == 10){
					var _except = 60 - 20*irandom(4)
					for (var _i = -120; _i <= 60; _i += 20){
						if (_except == _i){
							continue
						}
						
						with (spawn_bullet(spr_circle_bullet, 210, _i, 0,,, damage)){
							image_blend = c_white
							can_damage = true
							image_alpha = 0
							
							step = function(){
								x -= 3
								
								if (x < 110){
									image_alpha -= 0.05
									
									if (image_alpha <= 0){
										instance_destroy()
									}
								}else if (image_alpha < 1){
									image_alpha += 0.05
								}
							}
						}
					}
				}
				
				if (obj_player_battle.y >= 500){
					damage_player(5)
					
					obj_player_battle.gravity_data.jump.speed = 6
					obj_player_battle.gravity_data.cannot_stop_jump = true
				}
				
				if (timer > 360){
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
	
	if (is_undefined(step)){
		show_error("You must define a step function in a variable of the same name in your attack, it is a rule.", true)
	}
}