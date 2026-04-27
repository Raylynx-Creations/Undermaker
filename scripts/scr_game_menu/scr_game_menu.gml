/*
Constants used to represent the states of the game's menu.
*/
enum GAME_MENU{
	ENTERING_MAIN_MENU,
	MAIN_MENU,
	VOLUME_MENU,
	BORDER_AND_RESOLUTION_MENU,
	GO_TO_GAME
}

/*
Helper functions used to get back to the game's menu after holding ESC for a period of time.
It's meant to stop all musics, reset any variables in game that need to be reset so on loading the game or new game, the game works just fine.
It removes the overworld player since it is not needed in this room.
And creates a new menu instance from the constructor function.
IT DOESN'T CLEAR PERSISTENT OBJECTS, MAKE SURE YOU KNOW WHEN YOU CALL THIS FUNCTION AND REMOVE ANY STUFF NOT TAKEN INTO ACCOUNT MANUALLY OR INCLUDE IT HERE TOO.
IT'S ALSO IMPORTANT THAT YOU DEFINE IT, THE OBJ_GAME USES IT.
*/
function go_to_game_menu(){
	audio_stop_all() //Stop all sounds
	
	with (obj_game){
		previous_room = -1 //No previous room data saved
		overworld_music_system.ignore = false //Reset variable of ignore
		
		while (!dialog.is_finished()){
			dialog.next_dialog() //Skip any dialog currently playing
		}
		
		if (room == rm_battle){
			battle_system.clear_battle() //Clear battle stuff like arrays and persistent stuff
		}
		
		state = GAME_STATE.MENU_CONTROL
		game_menu_system = new GameMenu() //Game menu instance
		
		if (room == rm_menu){
			room_restart() //Restart the room so activations on room end and start happen again
		}else{
			start_room_function = function(){
				instance_destroy(obj_player_overworld) //If a player exists, make sure it doesn't exist, in the menu there shouldn't be any players yet.
			}
			
			room_goto(rm_menu)
		}
	}
}

/*
This function creates the overworld player for the game.
A game is not a game without the player, although not essential, like obj_game to do stuff, without a player what will our users control and have fun with?
A player must be created only when you want to start the game so its logic and inputs don't interfere with whatever you are doin in this menu.
*/
function create_initial_player_overworld(){
	instance_create_depth(0, 0, 0, obj_player_overworld, {image_xscale: 2, image_yscale: 2}) //Just create it, set the scale as well, doesn't matter the other data
}

/*
This function loads the game's initial save state, the first room the player spawns on, the first area they will start on.
*/
function load_initial_room(){
	set_initial_game_data() //Load the initial save state data which you can define on scr_initial_save_file_data script.
	room_goto(rm_overworld_1_grass_land) //Go to the room the player will start on.
	
	obj_game.start_room_function = function(){ //Always make a new save file for the player, so if they die before they are able to save, they don't crash for not having a save file.
		perform_game_save_with_spawn_point(inst_spawn_point_grass_land)
	}
	
	obj_player_overworld.spawn_point_reference = inst_spawn_point_grass_land //Set a reference spawn point for the player to position when the room loads, it must exist in the room of course.
}

/*
This is a game menu constructor, here I define all the necessary variables and draws that will be used for the whole menu.
This is just a sample menu, very simple one, but whenever a player wants to quit the game by holding ESC or when the player
reaches an ending or it's in a side content accessible from the menu and comes back, you want to recreate the menu variable
in obj_game.
I made a sample function too to define the Game Menu, it has no states tho, you would want to give some arguments to the
function so you can start in different submenus when coming back from specific stuff, use global variables to gestion unlockable
content and let the creation flow.
Even made some enums for it.

RETURNS -> STRUCT OF GAME MENU DATA --The game menu and it's representation is given here, use it on go_to_game_menu() function.
*/
function GameMenu() constructor{
	timer = 0
	save_file_exists = does_save_file_0_exist()
	state = GAME_MENU.ENTERING_MAIN_MENU
	selection = [0, 0]
	resolutions_amount = get_resolutions_amount()
	borders_amount = get_borders_amount()
	languages_amount = get_languages_amount()
	
	/*
	The Game Menu constrcutor must have an step and draw functions, that's pretty much all the engine asks for.
	Of course it's you who has to define the whole behavior of the menu, there's a room dedicated to the menu that the engine uses.
	Use that room as you desire to make the menu happen but never change to a room of the overworld without a player.
	*/
	
	//Logic of the menu
	step = function(){
		switch (state){
			case GAME_MENU.ENTERING_MAIN_MENU:{
				timer++
				
				if (timer == 240){
					state = GAME_MENU.MAIN_MENU
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
			break}
			case GAME_MENU.GO_TO_GAME:{
				timer++
				
				switch (timer){
					case 150:{
						create_initial_player_overworld()
						load_initial_room() //Does something similar to perform_game_load but simplified, cause the initial_game_data was set already above, doing most of the job of the function, it just calls it in this function and sets the rest data.
					break}
					case 300:{
						//We make a little event to showcase the example of cutscenes when creating a new game.
						//In this case the event is just a dialog, we use the overworld_dialog function to set the event with the second argument being true (which is the default).
						overworld_dialog(global.dialogues.welcome,, false) //We lose control after this since it sets the obj_game.state to another value.
						obj_game.border_alpha = 1 //Since the draw phase is skipped in the last frame, we set it to 1 here.
					break}
				}
			break}
			case GAME_MENU.MAIN_MENU:{
				if (get_confirm_button(false)){
					//You can put some transitions here, but for simplicity we ignore that and go directly to the menus
					switch (selection[0]){
						//You can make a fade in animation with states and then load the game, there's no limit on what you can do.
						case 0:{
							//You can make the player select the name here, for simplicity we skip that menu and just straight up load the game, with an already defined name.
							state = GAME_MENU.GO_TO_GAME
							timer = 0
						break}
						case 1:{
							create_initial_player_overworld() //This function creates the overworld player with the initial settings (in this case none, just creates the object, but if you need you can edit and add stuff)
							perform_game_load()
							
							obj_game.state = GAME_STATE.PLAYER_CONTROL //When you set the state, the menu loses control, so be mindful of this, you can make fades last like that, an example is seen in the new game option.
							obj_player_overworld.state = PLAYER_STATE.MOVEMENT
						break}
						case 2:{
							state = GAME_MENU.VOLUME_MENU
							selection[1] = 0
						break}
						case 3:{
							state = GAME_MENU.BORDER_AND_RESOLUTION_MENU
							selection[1] = 0
						break}
					}
					
					if (selection[0] != 4){
						audio_play_sound(snd_menu_confirm, 0, false)
					}
				}else if (get_left_button(false) and selection[0] == 4){
					load_game_texts((get_current_language_id() - 1 + languages_amount)%languages_amount)
					save_game_settings()
				}else if (get_right_button(false) and selection[0] == 4){
					load_game_texts((get_current_language_id() + 1)%languages_amount)
					save_game_settings()
				}else if (get_up_button(false)){
					selection[0] = (selection[0] + 4)%5
					if (selection[0] == 1 and !save_file_exists){
						selection[0]--
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}else if (get_down_button(false)){
					selection[0] = (selection[0] + 1)%5
					if (selection[0] == 1 and !save_file_exists){
						selection[0]++
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}else if (global.is_mobile and get_escape_button(false)){ //Quitting feature for mobile only
					if (obj_game.quit_timer <= 0){
						obj_game.quit_timer = 180
					}else{
						obj_game.quit_timer = 0
				
						game_end()
					}
				}
			break}
			case GAME_MENU.VOLUME_MENU:{
				if ((get_confirm_button(false) and selection[1] == 2) or get_escape_button(false)){
					state = GAME_MENU.MAIN_MENU
					
					save_game_settings()
					audio_play_sound(snd_menu_confirm, 0, false)
				}else if (get_left_button()){
					switch (selection[1]){
						case 0:{
							set_music_volume(get_music_volume() - 1)
						break}
						case 1:{
							set_sound_volume(get_sound_volume() - 1)
							
							audio_play_sound(snd_menu_selecting, 0, false)
						break}
					}
				}else if (get_right_button()){
					switch (selection[1]){
						case 0:{
							set_music_volume(get_music_volume() + 1)
						break}
						case 1:{
							set_sound_volume(get_sound_volume() + 1)
							
							audio_play_sound(snd_menu_selecting, 0, false)
						break}
					}
				}else if (get_up_button(false)){
					selection[1] = (selection[1] + 2)%3
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}else if (get_down_button(false)){
					selection[1] = (selection[1] + 1)%3
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
			break}
			case GAME_MENU.BORDER_AND_RESOLUTION_MENU:{
				if ((get_confirm_button(false) and selection[1] == 4) or get_escape_button(false)){
					state = GAME_MENU.MAIN_MENU
					
					save_game_settings()
					audio_play_sound(snd_menu_confirm, 0, false)
				}else if (get_left_button(false)){
					switch (selection[1]){
						case 0:{
							var _id = get_current_resolution_id()
							
							if (window_get_fullscreen()){
								set_resolution(resolutions_amount - 1) //Setting the resolution undoes the fullscreen and sets a resolution as long as it's not the fullscreen id.
							}else if (_id == 0){
								set_fullscreen(true) //Always use set_fullscreen function to set fullscreen on and off, so there's a resolution saved to go for when exiting fullscreen by the player pressing F4, do not use set_resolution() for it.
							}else{
								set_resolution(get_current_resolution_id() - 1)
							}
						break}
						case 1:{
							toggle_border(!is_border_enabled())
						break}
						case 2:{
							toggle_dynamic_borders(!is_border_dynamic())
						break}
						case 3:{
							set_border((get_current_border_id() - 1 + borders_amount)%borders_amount)
						break}
					}
				}else if (get_right_button(false)){
					switch (selection[1]){
						case 0:{
							var _id = get_current_resolution_id()
							
							if (window_get_fullscreen()){
								set_resolution(0) //Setting the resolution undoes the fullscreen and sets a resolution as long as it's not the fullscreen id.
							}else if (_id == resolutions_amount - 1){
								set_fullscreen(true) //Always use set_fullscreen function to set fullscreen on and off, so there's a resolution saved to go for when exiting fullscreen by the player pressing F4, do not use set_resolution() for it.
							}else{
								set_resolution(get_current_resolution_id() + 1)
							}
						break}
						case 1:{
							toggle_border(!is_border_enabled())
						break}
						case 2:{
							toggle_dynamic_borders(!is_border_dynamic())
						break}
						case 3:{
							set_border((get_current_border_id() + 1)%borders_amount)
						break}
					}
				}else if (get_up_button(false)){
					selection[1] = (selection[1] + 4)%5
					if (selection[1] == 3){
						if (!is_border_enabled()){
							selection[1] = 1
						}else if (is_border_dynamic()){
							selection[1] = 2
						}
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}else if (get_down_button(false)){
					selection[1] = (selection[1] + 1)%5
					if ((selection[1] == 2 and !is_border_enabled()) or (selection[1] == 3 and is_border_dynamic())){
						selection[1] = 4
					}
					
					audio_play_sound(snd_menu_selecting, 0, false)
				}
			break}
		}
	}
	
	//Drawing of the menu
	draw = function(){
		if ((state == GAME_MENU.GO_TO_GAME and timer < 150) or state != GAME_MENU.GO_TO_GAME){
			draw_sprite_ext(get_language_sprite("spr_undermaker_logo"), 0, 320, 150, 0.5, 0.5, 0, c_white, 1)
		}
		
		draw_set_font(get_language_font("fnt_determination_sans"))
		draw_set_halign(fa_center)
		
		switch (state){
			case GAME_MENU.ENTERING_MAIN_MENU:{
				draw_text_transformed_color(320, 280, global.UI_texts[$"game menu"][$"new game"], 2, 2, 0, c_white, c_white, c_white, c_white, 1)
				var _color = (save_file_exists ? c_white : c_gray)
				draw_text_transformed_color(320, 320, global.UI_texts[$"game menu"][$"load game"], 2, 2, 0, _color, _color, _color, _color, 1)
				draw_text_transformed_color(320, 360, global.UI_texts[$"game menu"][$"sound settings"], 2, 2, 0, c_white, c_white, c_white, c_white, 1)
				draw_text_transformed_color(320, 400, global.UI_texts[$"game menu"][$"video settings"], 2, 2, 0, c_white, c_white, c_white, c_white, 1)
				draw_text_transformed_color(320, 440, string_concat(global.UI_texts[$"game menu"].language, ": ", global.UI_texts[$"game menu"][$"current language"]), 2, 2, 0, c_white, c_white, c_white, c_white, 1)
				
				var _alpha = 1 - min(timer/180, 1)
				draw_sprite_ext(spr_pixel, 0, 0, 0, GAME_WIDTH, GAME_HEIGHT, 0, c_black, _alpha)
				
				if (is_border_dynamic()){
					obj_game.border_alpha = 1 - _alpha
				}
			break}
			case GAME_MENU.GO_TO_GAME:{
				if (timer < 150){
					draw_text_transformed_color(320, 280, global.UI_texts[$"game menu"][$"new game"], 2, 2, 0, c_lime, c_lime, c_lime, c_lime, 1)
					var _color = (save_file_exists ? c_white : c_gray)
					draw_text_transformed_color(320, 320, global.UI_texts[$"game menu"][$"load game"], 2, 2, 0, _color, _color, _color, _color, 1)
					draw_text_transformed_color(320, 360, global.UI_texts[$"game menu"][$"sound settings"], 2, 2, 0, c_white, c_white, c_white, c_white, 1)
					draw_text_transformed_color(320, 400, global.UI_texts[$"game menu"][$"video settings"], 2, 2, 0, c_white, c_white, c_white, c_white, 1)
					draw_text_transformed_color(320, 440, string_concat(global.UI_texts[$"game menu"].language, ": ", global.UI_texts[$"game menu"][$"current language"]), 2, 2, 0, c_white, c_white, c_white, c_white, 1)
				}
				
				var _alpha = min(timer/120, 1) - max((timer - 180)/120, 0)
				draw_sprite_ext(spr_pixel, 0, 0, 0, GAME_WIDTH, GAME_HEIGHT, 0, c_black, _alpha)
				
				if (is_border_dynamic()){
					obj_game.border_alpha = 1 - _alpha
				}
			break}
			case GAME_MENU.MAIN_MENU:{
				var _color = ((selection[0] == 0) ? c_yellow : c_white)
				draw_text_transformed_color(320, 280, global.UI_texts[$"game menu"][$"new game"], 2, 2, 0, _color, _color, _color, _color, 1)
				_color = ((selection[0] == 1) ? c_yellow : (save_file_exists ? c_white : c_gray))
				draw_text_transformed_color(320, 320, global.UI_texts[$"game menu"][$"load game"], 2, 2, 0, _color, _color, _color, _color, 1)
				_color = ((selection[0] == 2) ? c_yellow : c_white)
				draw_text_transformed_color(320, 360, global.UI_texts[$"game menu"][$"sound settings"], 2, 2, 0, _color, _color, _color, _color, 1)
				_color = ((selection[0] == 3) ? c_yellow : c_white)
				draw_text_transformed_color(320, 400, global.UI_texts[$"game menu"][$"video settings"], 2, 2, 0, _color, _color, _color, _color, 1)
				_color = ((selection[0] == 4) ? c_yellow : c_white)
				draw_text_transformed_color(320, 440, string_concat(global.UI_texts[$"game menu"].language, ": ", global.UI_texts[$"game menu"][$"current language"]), 2, 2, 0, _color, _color, _color, _color, 1)
			break}
			case GAME_MENU.VOLUME_MENU:{
				var _color = ((selection[1] == 0) ? c_yellow : c_white)
				draw_text_transformed_color(320, 330, string_concat(global.UI_texts[$"game menu"][$"music volume"], ": < ", global.game_settings.music_volume, " >"), 2, 2, 0, _color, _color, _color, _color, 1)
				_color = ((selection[1] == 1) ? c_yellow : c_white)
				draw_text_transformed_color(320, 370, string_concat(global.UI_texts[$"game menu"][$"sounds volume"], ": < ", global.game_settings.sound_volume, " >"), 2, 2, 0, _color, _color, _color, _color, 1)
				_color = ((selection[1] == 2) ? c_yellow : c_white)
				draw_text_transformed_color(320, 410, global.UI_texts[$"game menu"][$"go back"], 2, 2, 0, _color, _color, _color, _color, 1)
			break}
			case GAME_MENU.BORDER_AND_RESOLUTION_MENU:{
				var _color = ((selection[1] == 0) ? c_yellow : c_white)
				var _resolution = get_current_resolution()
				draw_text_transformed_color(320, 280, string_concat(global.UI_texts[$"game menu"].resolution, ": < ", ((window_get_fullscreen()) ? global.UI_texts[$"game menu"].fullscreen : string_concat(_resolution[0], "x", _resolution[1])), " >"), 2, 2, 0, _color, _color, _color, _color, 1)
				_color = ((selection[1] == 1) ? c_yellow : c_white)
				draw_text_transformed_color(320, 320, string_concat(global.UI_texts[$"game menu"].border, ": < ", (is_border_enabled() ? global.UI_texts[$"game menu"].enabled : global.UI_texts[$"game menu"].disabled), " >"), 2, 2, 0, _color, _color, _color, _color, 1)
				_color = ((selection[1] == 2) ? c_yellow : (is_border_enabled() ? c_white : c_gray))
				draw_text_transformed_color(320, 360, string_concat(global.UI_texts[$"game menu"][$"dynamic borders"], ": < ", (is_border_dynamic() ? global.UI_texts[$"game menu"].enabled : global.UI_texts[$"game menu"].disabled), " >"), 2, 2, 0, _color, _color, _color, _color, 1)
				_color = ((selection[1] == 3) ? c_yellow : ((is_border_dynamic() or !is_border_enabled()) ? c_gray : c_white))
				draw_text_transformed_color(320, 400, string_concat(global.UI_texts[$"game menu"][$"border style"], ": < ", get_current_border_id(is_border_dynamic()), " >"), 2, 2, 0, _color, _color, _color, _color, 1)
				_color = ((selection[1] == 4) ? c_yellow : c_white)
				draw_text_transformed_color(320, 440, global.UI_texts[$"game menu"][$"go back"], 2, 2, 0, _color, _color, _color, _color, 1)
			break}
		}
	}
}