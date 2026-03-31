/*
List of constants for the enemies of your game.
*/
enum ENEMY{
	MAD_DUMMY_SPRITED,
	MAD_DUMMY_DRAWN,
	MONSTER_1,
	MONSTER_2,
	MONSTER_3
}

/*
List of all available ACT commands on the game for all enemies.
All enemies can use these if needed, but you can define which one an enemies uses.
For purposes of translation and creativity it was made this way that you can populate this enum with your data.
HOWEVER in the language files specifically in the UI texts file you have to define the "battle acts" list in the same order they are defined here, the same applies for the ITEM and CELL constants.
For more information check the user manual.
*/
enum ACT_COMMAND{
	CHECK,
	ANNOY,
	FLUSTER,
	DISTRACT
}

/*
This function is used to calculate the damage the enemy attacks will do on the game, usually you want a formula that depends on the ATK of the enemy and the DEF of the player.
To get data from the player you can use the get_player_* functions.
You don't have to call this function either, you just have to fill it with code and return the data the engine expects.

STRUCT OF ENEMY DATA _enemy -> The enemie from which you gather data from to make damage calculation.

RETURNS -> REAL --The damage the enemy's attack makes.
*/
function calculate_enemy_damage_amount(_enemy){
	return ceil(_enemy.atk/5 - get_player_total_def()) //You can make your separate calculations based on many other data from the enemy if you want, you just have to define them.
}

/*
This is the enemy constructor, where all the variables and data for representing an enemy in battle is put.
Again you don't have to call this function, you just have to fill it up with the code needed and the stuff you want to do.
Unlike CYF this one doesn't come with a sprite variable/object to define a static image on battle, you are given complete freedom on how you want to draw and represent your enemy, could be nothing if you desire to.

INTEGER _monster -> Constant of ENEMY enum that determiantes what monster to choose and the data it will be filled with.
INTEGER _index ---> Number which indicates the order of the enemy, you can do that way stuff different if the enemy is in second place, first or third.
REAL _x_pos ------> The X position of the enemy on the battle room, calculated by the amount of enemies and arranged in a way they all fit (it is expected to be 3 the maximum number of enemies, 4 and above were not considered).
REAL _y_pos ------> The Y position of the enemy on the battle room, calculated by the amount of enemies and arranged in a way they all fit (it is expected to be 3 the maximum number of enemies, 4 and above were not considered).

CONSTRUCTS -> STRUCT OF ENEMY DATA --The representation of the enemy in battle, this is used by the engine to do various stuff, from managing rewards for killing or sparing the enemy to the attacks and dialogs it says and all stuff you code in the proper eventss.
*/
function Enemy(_monster, _index, _x_pos, _y_pos) constructor{
	/*
	IMPORTANT: You can use battle_get_current_enemies_amount() function to get the number of enemies that are active (not killed or spared).
	You can also get the enemy count when even if you killed or spared enemies at any point if you give it false as a parameter.
	You can that way set enemy behavior when there's only a certain number of enemies, if you want name of specific enemies use battle_get_current_enemies() which gives you a list of the enemies data for you to edit.
	The same applies as the previous function, you can get enemy data from only active enemies (no arguments in the function or true as an argument) or all included killed and spared enemies (by giving false as an argument).
	*/
	//initial_enemy_amount = battle_get_current_enemies_amount()
	//enemies_in_battle = battle_get_current_enemies()
	
	{ //Default variable data, compressed in a block of code.
	x = _x_pos //Position of the enemie, although nothing is drawn this position serves as data for reference on your enemies and other elements.
	y = _y_pos
	bubble_x = 0 //Position of the bubble dialog based on the origin of the bubble sprite, relative to the position of the enemie.
	bubble_y = 0
	bubble_width = 1 //Data to define the dialog bubble, width of the bubble.
	player_attack_x = 0 //Position of the player attack animation, relative to the position of the enemie.
	player_attack_y = 0
	damage_ui_x = 0 //Position of the damage UI numbers/text when damaged, relative to the position of the enemie.
	damage_ui_y = 0
	bubble_sprite = spr_bubble_normal //Default dialog bubble sprite
	bubble_tail_sprite = spr_bubble_normal_tail //Default dialog bubble tail sprite, you can adjust this in the dialog with the command [tail_position:x,y] to set the position within the dialog itself.
	bubble_tail_mask_sprite = undefined //Default dialog bubblet masking for the tail sprite
	
	//These sprites will be set in the x and y position of the monster when you either spare or kill the enemy, make sure to line up with the sprites you use.
	sprite_spared = 0 //This is the sprite for when the monster is spared, by default it points to the sprite with index 0, fail safe.
	sprite_killed = 0 //This is the sprite that will turn to dust when the monster is killed
	sprite_spared_index = 0 //This is the index to use of said sprite when spared
	sprite_killed_index = 0 //This is the index to use of said sprite when killed instead
	sprite_xscale = 2 //This is the sprite scale in which the spared and killed sprites will appear on screen and do their behavior, if the sprites are separate and require different sizes, you can know when an enemie is killed or spared and set the correct values to these variables as needed.
	sprite_yscale = 2
	dust_y_pixels_amount_per_frame = 1 //This affects how fast sprites dust away, good for when you are using 
	
	//Variables needed for actions on the battle.
	next_dialog = undefined //This sets the dialog the enemie will say when it's enemy's dialog turn and enemy's end attack turn too, you have to set the variable independently on those before those ocassions to execute the dialog.
	next_attack = undefined //This sets the attack the enemie will play in the enemy's attack turn, can only be one and it's the constant of ENEMY_ATTACK.
	next_menu_attack = undefined //This sets the menu attack of the enemie, which plays when it's the player's turn on the buttons and menus, set before the end turn of the enemy to set a meny attack being one of the constant of MENU_ATTACK.
	
	//Optional events, commented out events are mandatory tho.
	//calculate_damage = undefined //This function is mandatory to be in the enemy data, it is called when the player is about to attack the enemy and plays their attack animation, takes one argument and it's the accuracy of the attack the player is doing, must return an integer representating the amount of damage the enemy will take.
	//hurt = undefined //Complementary to the calculate_damage function and mandatory as well, this function is called when the enemy takes the damage, showing the numbers and the health bar decrease, takes one argument and it's the damage the enemy will receive (previously calculated), must return a string or number which shows displayed as the damage taken by the enemy, you can show something different from what actually happens (PD: You have to manually decrease the hp on the monster, it is not done automatically).
	//act = undefined //This function is mandatory and it is called when the player performs an ACT command action to the enemy, takes one argument which is the constant enum act command the player used, must return a string or list of strings that represent the dialog to display in the box after the action has been done, you can do other stuff as well but at return that's what it's expected.
	turn_starts = undefined //Function that executes when a turn cycle starts, aka the player's turn with the buttons, you can set the next_menu_attack variable here to define a menu attack.
	spare = undefined //Function that executes when the player spares the enemies (either yellow name or not).
	flee = undefined //Function that executes when the player attempts to flee either succed or failed, you can change the flee event in here using battle_set_flee_event() funciton, as well as the chance and other factors.
	item_used = undefined //Function that executes whenever a player uses an item, it takes one parameter and it's the ID of the ITEM constant corresponding of the item the player used, that way you can do effects depending on the item with specific enemies, this cannot set the box dialog, use battle_get_current_enemies() functions or similar to handle them in the scr_item_functions with a room check.
	dialog_starts = undefined //Function that executes whenever the turn of enemy starts, here you can set the dialog it will say by setting next_dialog if it hasn't been defined by other functions already if you want or overwrite them.
	attack_starts = undefined //Function that executes whenever the enemy finished their dialog and the attack turn starts, set the next_attack here for the enemy to perform that attack.
	turn_ends = undefined //Function that executes whenever the attack finishes, it takes one parameter the box_dialog and must return a box_dialog, this is so you can edit what the box dialog is gonna be displayed, it chain on all the enemies on the battle so you can craft dialogues that way, you can also set an enemy dialog here using next_dialog variable here.
	step = undefined //Function that executes every frame of the game, so you can do the logic of your animations on the enemies and much more.
	draw = undefined //Function that executes every frame of the game, to draw stuff on screen on the same layer as the obj_game which also draws the stats of the player.
	destroy = undefined //Function that executes whenever the enemie has been killed or spared, meant to be used to free memory on stuff that you use to render the enemie or other data that persists outside the battle.
	forgiven = undefined //Function that executes only when the enemie has been spared, this can trigger other enemies's actions, etc.
	killed = undefined //Function that executes only when the enemie has been killed, you can use this to trigger enragement on other enemies, etc.
	
	give_gold_on_kill = 1 //Gives this amount of gold when killed, usually gold rewarded on kill is more than when spared.
	give_gold_on_spared = 0 //Gives this amount of gold when spared.
	give_exp = 1 //EXP amount it gives obviously only when killed.
	
	can_spare = false //Flag that turns monster's name yellow and tells the player they can spare the enemie, you can set this to false immediatelly on the spare function so it doesn't get spared and more.
	can_player_flee = false //Flag used to determinate if the player is able to just run away without failing chance, if all monsters in battle have this flag set to true, the flee is guaranteed to success.
	show_hp = true //Flag that determinates if it shows the HP bar when selecting the enemie to attack and when the enemie is being damaged.
	selectionable = true //Flag that determinates if the enemie can be selected to ACT or FIGHT, make sure to not softlock your player by letting this always be false in battle.
	hp = 1 //HP of the enemie, when it reaches 0, the enemie becomes dust only if there's no next_attack or next_dialog happening at the moment.
	max_hp = 1 //Maximum HP the enemie can have, this doesn't control the HP variable and limits it from going above the max_hp, this is for displaying the health bar, so the HP is compared to the Max HP.
	atk = 0 //ATK of the enemie, usually every 5 ATK = 1 damage to the player since player defense scales so slow in Undertale, but you can define your own system, used in calculate_enemy_damage_amount() function above to determinate how much damage their attacks do to the player.
	def = 0 //DEF of the enemie, used in calculate_damage() function variable of the enemie to calculate how much damage you want the enemie to receive from the player's attack.
	hp_bar_color = c_lime //HP bar color in the menu and when attacked.
	hp_bar_width = 100 //HP bar width, by default is 100.
	hp_bar_width_attacked = 100 //The HP bar width when damaged can be different, but it's by default 100 too.
	name = "" //Nmae of the enemy to display, by default it's just empty, use the global.UI_texts to get the names aka the UI texts files, it's not recommended you hardcode them, for more information check the user manual.
	act_commands = [ACT_COMMAND.CHECK] //Act commands enemies can have, by default they always have a CHECK command, use constants to set the commands, the text that displays is handled on the UI texts file for language translation, for more info see the user manual.
	
	spared = false //DON'T TOUCH, variable used to determinate if an enemie has alread been spared or not, used by the engine in certain scenarios, use battle_forgive_enemie() and the index of the enemie to spare it.
	}
	
	//The following just defines some of the functions needed to do stuff depending on the enemy and sets variables as well for stuff.
	switch (_monster){
		case ENEMY.MAD_DUMMY_SPRITED:{
			//Remember to always set the spared and killed sprites.
			sprite_spared = spr_mad_dummy_death
			sprite_killed = sprite_spared
			y -= 40
			atk = 15 //Every 5 atk = 1 damage
			bubble_x = 50
			bubble_y = -100
			bubble_width = 100
			player_attack_x = 0
			player_attack_y = -50
			hp_bar_width_attacked = 200
			
			name = get_enemie_name("mad_dummy") //I made auxiliar functions to handle the getting of the UI texts for the names of the enemies, check scr_get_texts_functions.
			hp = 100
			max_hp = 100
			layer_inst = layer_create(400) //Layer for the parts of the enemie
			timer = 0 //Timer for animation of course
			can_spare = true
			
			//My own way to create sprites
			sprites = {
				torso: layer_sprite_create(layer_inst, x + 26, y - 36, spr_mad_dummy_torso),
				base: layer_sprite_create(layer_inst, x, y, spr_mad_dummy_base),
				belly: layer_sprite_create(layer_inst, x, y - 10, spr_mad_dummy_belly),
				head: layer_sprite_create(layer_inst, x + 16, y - 46, spr_mad_dummy_head)
			}
			
			var _auxiliar = [sprites.head, sprites.torso, sprites.belly, sprites.base]
			for (var _i=0; _i<array_length(_auxiliar); _i++){
				layer_sprite_xscale(_auxiliar[_i], 2)
				layer_sprite_yscale(_auxiliar[_i], 2)
			}
			
			calculate_damage = function(_accuracy){
				return 100*_accuracy //Pretty straight forward... not dependant on ATK or DEF of enemy
			}
			
			hurt = function(_damage){ //FIGHT
				if (typeof(_damage) != "string"){ //If attack is not a string then it's a number and can reduce the amount of HP of an enemie
					audio_play_sound(snd_enemie_hurt, 100, false) //Play sound, you can not play it if you wish to.
				
					hp -= round(_damage) //Reduce HP manually
					
					return round(_damage)
				}
			}
			
			act = function(_command){ //ACT
				var _dialogues = get_enemie_dialogues("mad_dummy_sprited").act_dialogues //Auxiliar function for getting text of the dialogues of a monster, check scr_get_texts_functions
				switch (_command){
					case ACT_COMMAND.CHECK:{
						return _dialogues.check
					}
				}
			}
			
			item_used = function(_item_index){ //ITEM
				//Nothing is done but this is how you define the function.
			}
			
			dialog_starts = function(){ //Set dialogues in the dialog_starts function
				next_dialog = get_enemie_dialogues("mad_dummy_sprited").dialogues.dialog
			}
			
			attack_starts = function(){ //Set attack the enemy will execute in the attack_starts function
				next_attack = choose(ENEMY_ATTACK.MAD_DUMMY_1, ENEMY_ATTACK.MAD_DUMMY_2)
			}
			
			//When turn ends you can set a dialog too, not mandatory to do so, but you can set next_dialog here too if you want.
			//Main function of this is to set and modify the _box_dialog.
			turn_ends = function(_box_dialog){
				next_dialog = get_enemie_dialogues("mad_dummy_sprited").dialogues.end_turn
				
				return _box_dialog
			}
			
			//Animation of the enemy is handled in the step function.
			step = function(){
				timer += 10
				y += dcos(timer)/3
				var _angle = 12*dsin(timer)
				
				if (timer >= 360){
					timer = 0
				}
				
				layer_sprite_angle(sprites.head, 1.1*_angle)
				layer_sprite_angle(sprites.torso, _angle)
				layer_sprite_angle(sprites.belly, _angle)
				layer_sprite_angle(sprites.base, -2*_angle)
				
				layer_sprite_y(sprites.head, y - 46)
				layer_sprite_y(sprites.torso, y - 36)
				layer_sprite_y(sprites.belly, y - 10)
				layer_sprite_y(sprites.base, y)
				
				layer_sprite_index(sprites.head, 0)
			}
			
			//Free the resources when the enemy is not active anymore.
			destroy = function(){
				var _auxiliar = [sprites.head, sprites.torso, sprites.belly, sprites.base]
				for (var _i=0; _i<array_length(_auxiliar); _i++){
					layer_sprite_destroy(_auxiliar[_i]) //Game Maker automatically deletes them when you change to another room, but still you should do clean up I guess and not rely on Game Maker much.
				}
				if (layer_exists(layer_inst)){
					layer_destroy(layer_inst)
				}
			}
		break}
		case ENEMY.MAD_DUMMY_DRAWN:{
			sprite_spared = spr_mad_dummy_death
			sprite_killed = sprite_spared
			y -= 40
			bubble_x = 50
			bubble_y = -100
			bubble_width = 100
			player_attack_x = 0
			player_attack_y = -50
			
			//Different color
			hp_bar_color = c_aqua
			hp = 74 //Can start with low HP
			max_hp = 100
			name = get_enemie_name("mad_dummy")
			layer_inst = layer_create(100)
			timer = 0
			can_spare = true
			
			calculate_damage = function(_accuracy){
				return 50*_accuracy
			}
			
			hurt = function(_damage){ //FIGHT
				if (typeof(_damage) != "string"){
					hp -= round(_damage)
					
					return round(_damage)
				}
			}
			
			act = function(_command){ //ACT
				var _dialogues = get_enemie_dialogues("mad_dummy_drawn").act_dialogues
				switch (_command){
					case ACT_COMMAND.CHECK:{
						return _dialogues.check
					}
				}
			}
			
			flee = function(){ //FLEE
				next_dialog = get_enemie_dialogues("mad_dummy_drawn").dialogues.flee
			}
			
			attack_starts = function(){
				next_attack = choose(ENEMY_ATTACK.MAD_DUMMY_1, ENEMY_ATTACK.MAD_DUMMY_2)
			}
			
			step = function(){
				timer += 6
				y += dcos(timer)/3
				
				if (timer >= 360){
					timer = 0
				}
			}
			
			//This time this enemie is using the draw function to exist.
			draw = function(){
				var _angle = 7*dsin(timer)
				
				draw_sprite_ext(spr_mad_dummy_torso, 0, x + 26, y - 36, 2, 2, _angle, c_white, 1)
				draw_sprite_ext(spr_mad_dummy_base, 0, x, y, 2, 2, -2*_angle, c_white, 1)
				draw_sprite_ext(spr_mad_dummy_belly, 0, x, y - 10, 2, 2, _angle, c_white, 1)
				draw_sprite_ext(spr_mad_dummy_head, 0, x + 16, y - 46, 2, 2, 1.1*_angle, c_white, 1)
			}
		break}
		case ENEMY.MONSTER_1:{
			sprite_spared = spr_enemy_monster
			sprite_killed = sprite_spared
			sprite_xscale = 1
			sprite_yscale = 1
			atk = 15
			def = 10
			bubble_x = 100
			bubble_y = -200
			bubble_width = 100
			player_attack_x = 0
			player_attack_y = -100
			damage_ui_y = -100
			dust_y_pixels_amount_per_frame = 4 //It's a pretty big sprite so set the dust chunks by 4
			bubble_sprite = spr_box_round
			bubble_tail_sprite = spr_box_normal_tiny_tail
			bubble_tail_mask_sprite = spr_box_round_mask
			
			hp = 100
			max_hp = 100
			name = get_enemie_name("monster")
			layer_inst = layer_create(301)
			timer = -1
			array_push(act_commands, ACT_COMMAND.ANNOY, ACT_COMMAND.FLUSTER) //Add more ACT commands!
			
			sprite = layer_sprite_create(layer_inst, x, y, spr_enemy_monster)
			
			calculate_damage = function(_accuracy){
				return (100 + 2*(get_player_total_atk() - def))*_accuracy //Custom formula
			}
			
			hurt = function(_damage){ //FIGHT
				if (typeof(_damage) != "string"){
					audio_play_sound(snd_enemie_hurt, 100, false)
					
					hp -= round(_damage)
					timer = 0 //Timer for hurt animation, yes you have to animate yourself the enemies
					
					return round(_damage)
				}
			}
			
			act = function(_command){ //ACT
				var _dialogues = get_enemie_dialogues("monster").act_dialogues
				switch (_command){
					case ACT_COMMAND.CHECK:{
						var _dialog = _dialogues.check
						_dialog[0] = string_replace(string_replace(_dialog[0], "[ATK]", string(atk)), "[DEF]", string(def))
						
						return _dialog
					}
					case ACT_COMMAND.ANNOY:{
						atk += 5
						def += 5
						
						return _dialogues.annoy
					}
					case ACT_COMMAND.FLUSTER:{
						atk -= 5
						def -= 5
						can_spare = true
						
						return _dialogues.fluster
					}
				}
			}
			
			item_used = function(_item_index){ //ITEM
				next_dialog = get_enemie_dialogues("monster").dialogues.item_used //No specific check for item but you could give it a unique dialog for it and other stuff.
			}
			
			dialog_starts = function(){
				if (is_undefined(next_dialog)){
					next_dialog = get_enemie_dialogues("monster").dialogues.dialog
				}
			}
			
			attack_starts = function(){
				next_attack = choose(ENEMY_ATTACK.PLATFORM_2, ENEMY_ATTACK.PLATFORM_3)
			}
			
			turn_ends = function(_box_dialog){
				var _dialog
				var _dialogues = get_enemie_dialogues("monster").box_dialogues
				
				//This is probably a very inefficient way of doing the random dialog, but that's how I organized it, you can just use an array in the json file and grab them all.
				switch (irandom(2)){
					case 0:{
						_dialog = _dialogues.random_1
					break}
					case 1:{
						_dialog = _dialogues.random_2
					break}
					case 2:{
						_dialog = _dialogues.random_3
					break}
				}
				
				return _dialog
			}
			
			step = function(){
				if (timer >= 0){
					timer++
					
					//The hurt animation is not accurate but you can make it better, this is so you animate your own monsters however you wish.
					switch (timer){
						case 1:{
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) - 20)
						break}
						case 21: case 61:{
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) + 40)
						break}
						case 41: case 81:{
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) - 40)
						break}
						case 101:{
							timer = -1
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) + 20)
						break}
					}
				}
			}
			
			destroy = function(){
				layer_sprite_destroy(sprite) //Game Maker automatically deletes them when you change to another room, but still you should do clean up I guess and not rely on Game Maker much.
				if (layer_exists(layer_inst)){
					layer_destroy(layer_inst)
				}
			}
			
			spare = function(){
				if (can_spare){
					next_dialog = 0 //No dialog
				}
			}
		break}
		case ENEMY.MONSTER_2:{
			sprite_spared = spr_enemy_monster
			sprite_killed = sprite_spared
			sprite_xscale = 1
			sprite_yscale = 1
			atk = 25
			def = 15
			bubble_x = 100
			bubble_y = -200
			bubble_width = 100
			player_attack_x = 0
			player_attack_y = -100
			damage_ui_y = -100
			dust_y_pixels_amount_per_frame = 4
			bubble_sprite = spr_box_normal
			bubble_tail_sprite = spr_box_normal_tail
			bubble_tail_mask_sprite = spr_box_normal_mask
			
			hp = 10
			max_hp = 10
			name = get_enemie_name("angy_monster")
			layer_inst = layer_create(301)
			timer = -1
			dodge = -1
			distracted = false
			array_push(act_commands, ACT_COMMAND.DISTRACT)
			
			sprite = layer_sprite_create(layer_inst, x, y, spr_enemy_monster)
			layer_sprite_blend(sprite, c_red)
			
			calculate_damage = function(_accuracy){
				if (!distracted){
					dodge = 0
				}
				
				return 100*_accuracy/max(def - get_player_total_atk(), 1) //Custom formula
			}
			
			hurt = function(_damage){ //FIGHT
				if (typeof(_damage) != "string" and distracted){
					audio_play_sound(snd_enemie_hurt, 100, false)
					
					hp -= round(_damage)
					timer = 0
					distracted = false
					can_spare = false
					next_dialog = get_enemie_dialogues("angy_monster").dialogues.focused
					
					return round(_damage)
				}else{
					return battle_get_ui_damage_text("miss")
				}
			}
			
			act = function(_command){ //ACT
				var _dialogues = get_enemie_dialogues("angy_monster").act_dialogues
				switch (_command){
					case ACT_COMMAND.CHECK:{
						var _dialog = _dialogues.check
						_dialog[0] = string_replace(string_replace(_dialog[0], "[ATK]", string(atk)), "[DEF]", string(def))
						
						return _dialog
					}
					case ACT_COMMAND.DISTRACT:{
						distracted = true
						can_spare = true
						
						return _dialogues.distract
					}
				}
			}
			
			turn_starts = function(){
				next_menu_attack = choose(MENU_ATTACK.MENU_ATTACK, MENU_ATTACK.BUTTON_ATTACK, MENU_ATTACK.MENU_AND_BUTTON_ATTACK)
			}
			
			item_used = function(_item_index){ //ITEM
				if (!distracted){
					next_dialog = get_enemie_dialogues("angy_monster").dialogues.item_complain
				}
			}
			
			dialog_starts = function(){
				var _dialogues = get_enemie_dialogues("angy_monster").dialogues
				if (is_undefined(next_dialog)){
					if (distracted){
						next_dialog = _dialogues.distracted
					}else{
						next_dialog = _dialogues.anger
					}
				}
			}
			
			attack_starts = function(){
				if (!distracted){
					next_attack = choose(ENEMY_ATTACK.PLATFORM_2, ENEMY_ATTACK.PLATFORM_3)
				}
			}
			
			turn_ends = function(_box_dialog){
				var _dialog
				var _dialogues = get_enemie_dialogues("angy_monster").box_dialogues
				
				if (distracted){
					_dialog = _dialogues.distracted
				}else{
					switch (irandom(1)){
						case 0:{
							_dialog = _dialogues.random_1
						break}
						case 1:{
							_dialog = _dialogues.random_2
						break}
					}
				}
				
				return _dialog
			}
			
			step = function(){
				//Basic dodge animation, kinda 3Dish
				if (dodge >= 0){
					dodge++
					var _scale = 1 - 0.5*dsin(90*min(dodge/20, 1) + 90*clamp((dodge - 80)/20, 0, 1))
					
					layer_sprite_xscale(sprite, 0.5 + _scale/2)
					layer_sprite_yscale(sprite, 0.5 + _scale/2)
					layer_sprite_blend(sprite, make_color_hsv(0, 255, 255*_scale))
					
					if (dodge >= 100){
						dodge = -1
					}
				}else if (timer >= 0){
					timer++
					
					switch (timer){
						case 1:{
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) - 20)
						break}
						case 21: case 61:{
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) + 40)
						break}
						case 41: case 81:{
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) - 40)
						break}
						case 101:{
							timer = -1
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) + 20)
						break}
					}
				}
			}
			
			destroy = function(){
				layer_sprite_destroy(sprite) //Game Maker automatically deletes them when you change to another room, but still you should do clean up I guess and not rely on Game Maker much.
				if (layer_exists(layer_inst)){
					layer_destroy(layer_inst)
				}
			}
			
			spare = function(){
				if (can_spare){
					next_dialog = 0 //No dialog
				}
			}
		break}
		case ENEMY.MONSTER_3:{
			sprite_spared = spr_enemy_monster
			sprite_killed = sprite_spared
			sprite_xscale = 1
			sprite_yscale = 1
			atk = 15
			def = 10
			bubble_x = 100
			bubble_y = -200
			bubble_width = 100
			player_attack_x = 0
			player_attack_y = -100
			damage_ui_y = -100
			dust_y_pixels_amount_per_frame = 4
			can_spare = true
			selectionable = _index%2
			
			hp = 100
			max_hp = 100
			name = get_enemie_name("turn_monster")
			layer_inst = layer_create(301)
			timer = -1
			
			sprite = layer_sprite_create(layer_inst, x, y, spr_enemy_monster)
			if (selectionable){
				layer_sprite_blend(sprite, c_white)
			}else{
				layer_sprite_blend(sprite, c_gray)
			}
			
			calculate_damage = function(_accuracy){
				return (100 + 2*(get_player_total_atk() - def))*_accuracy //Custom formula
			}
			
			hurt = function(_damage){ //FIGHT
				if (typeof(_damage) != "string"){
					audio_play_sound(snd_enemie_hurt, 100, false)
					
					hp -= round(_damage)
					timer = 0
					
					return round(_damage)
				}
			}
			
			act = function(_command){ //ACT
				var _dialogues = get_enemie_dialogues("turn_monster").act_dialogues
				switch (_command){
					case ACT_COMMAND.CHECK:{
						var _dialog = _dialogues.check
						_dialog[0] = string_replace(string_replace(_dialog[0], "[ATK]", string(atk)), "[DEF]", string(def))
						
						return _dialog
					}
				}
			}
			
			dialog_starts = function(){
				if (!is_undefined(next_dialog) or hp <= 0){
					return
				}
				
				//Everytime the dialog turn enters if alternates their states
				selectionable = !selectionable
				can_spare = selectionable
				var _dialogues = get_enemie_dialogues("turn_monster").dialogues
				if (selectionable){
					layer_sprite_blend(sprite, c_white)
					next_dialog = _dialogues.can_be_targeted
				}else{
					layer_sprite_blend(sprite, c_gray)
					next_dialog = _dialogues.cant_be_targeted
				}
			}
			
			attack_starts = function(){
				if (selectionable){
					next_attack = choose(ENEMY_ATTACK.PLATFORM_2, ENEMY_ATTACK.PLATFORM_3)
				}
			}
			
			turn_ends = function(_box_dialog){
				var _dialog
				var _dialogues = get_enemie_dialogues("turn_monster").box_dialogues
				
				//This is the efficient way of doing random dialogues
				return _dialogues[irandom(1)]
			}
			
			step = function(){
				if (timer >= 0){
					timer++
					
					switch (timer){
						case 1:{
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) - 20)
						break}
						case 21: case 61:{
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) + 40)
						break}
						case 41: case 81:{
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) - 40)
						break}
						case 101:{
							timer = -1
							layer_sprite_x(sprite, layer_sprite_get_x(sprite) + 20)
						break}
					}
				}
			}
			
			destroy = function(){
				layer_sprite_destroy(sprite) //Game Maker automatically deletes them when you change to another room, but still you should do clean up I guess and not rely on Game Maker much.
				if (layer_exists(layer_inst)){
					layer_destroy(layer_inst)
				}
			}
			
			spare = function(){
				if (can_spare){
					next_dialog = 100 //No dialog (just put an integer and it's not undefined, technically I set the dialog but I don't want to show a dialog, so I give a number so I can check in other places so a dialog is not given)
				}
			}
		break}
	}
}