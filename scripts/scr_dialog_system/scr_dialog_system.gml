/*
Constants for the commands of the dialog system.
*/
enum COMMAND_TYPE{
	WAIT,
	WAIT_KEY_PRESS,
	WAIT_FOR,
	SKIP_ENABLING,
	SKIP_DIALOG,
	STOP_SKIP,
	DISPLAY_TEXT,
	PROGRESS_MODE,
	NEXT_DIALOG,
	FUNCTION,
	COLOR_RGB,
	COLOR_HSV,
	TEXT_EFFECT,
	DISABLE_TEXT_EFFECT,
	SET_TEXT_SPEED,
	SET_SPRITE,
	SET_SUBIMAGES,
	SET_SPRITE_SPEED,
	PLAY_SOUND,
	SET_VOICE,
	VOICE_MUTING,
	APPLY_TO_ASTERISK,
	SET_ASTERISK,
	SET_FONT,
	SET_WIDTH_SPACING,
	SET_HEIGHT_SPACING,
	SET_SPRITE_X_OFFSET,
	SET_SPRITE_Y_OFFSET,
	SET_CONTAINER,
	SET_CONTAINER_TAIL,
	SET_CONTAINER_TAIL_MASK,
	SET_CONTAINER_TAIL_DRAW_MODE,
	SET_CONTAINER_TAIL_POSITION,
	SHOW_DIALOG_POP_UP,
	BIND_INSTANCE
}

/*
Constants for the various modes a dialog pop up can appear in a dialog, check the dialog system for more information on the user documentation.
*/
enum POP_UP_MODE{
	NONE,
	FADE,
	LEFT,
	RIGHT,
	UP,
	DOWN,
	INSTANT,
	LEFT_INSTANT,
	RIGHT_INSTANT,
	UP_INSTANT,
	DOWN_INSTANT,
}

/*
Constants for the various effects you can apply on dialog texts.
*/
enum EFFECT_TYPE{
	NONE,
	TWITCH,
	SHAKE,
	OSCILLATE,
	RAINBOW,
	SHADOW,
	MALFUNCTION,
	ZOOM,
	SLIDE
}

/*
Constants for the different ways of text displaying a dialog can have, only 2.
*/
enum DISPLAY_TEXT{
	LETTERS,
	WORDS
}

/*
Constants for the different draw modes the tail of a container can have, these are used in the dialog system when drawing the container with a tail.
*/
enum CONTAINER_TAIL_DRAW_MODE{
	BELOW,
	TOP,
	SPRITE_MASK,
	INVERTED_SPRITE_MASK
}

/*
This constructor/class allows for all types of dialogs to be displayed on screen.
This can be used separatedly to make dialogs anytime you want, anywhere you want for any use you want.
Some functionality it lacks that you need can be done by using the [func] command, so you call the functions yourself for whatever purpose you need, it's limited however due to how this system works.
For the masking of the container's tail sprite the shader shd_alpha_masking, it is a pretty simple shader that inverts the alpha like this: (1 - source_alpha), if you remove it, you may cause an error when using the masking sprite, avoid deleting it unless you know what you're doing.

REAL _x -------------------------------------> Initial X position of the dialog, being the origin the left top corner.
REAL _y -------------------------------------> Initial Y position of the dialog, being the origin the left top corner.
ARRAY OF STRINGS / STRING _dialogues --------> Dialogues that will be displayed on screen, using the proper format for dialogues.
INTEGER _width ------------------------------> Amount of text that can fit horizontally in pixels, you can use a REAL number but it functions as a truncated INTEGER instead 'cause pixels counting cannot be REAL, so just use integers please.
REAL _height --------------------------------> Minimum height of the dialog, if text doesn't fit in that height, it will be higher then to contain the text, but if the text leaves space, it will extend to that size.
REAL _xscale --------------------------------> Initial X scale of the dialog as a whole.
REAL _yscale --------------------------------> Initial Y scale of the dialog as a whole.
ARRAY OF INTEGERS / INTEGER _voices ---------> ID or IDs of the audios that will be used for the voice of every single letter being displayed, by default it uses the monster voice.
INTEGER _face_sprite ------------------------> ID of the sprite to be used as a portrait in the dialog, if undefined is given, no portrait sprite will be shown, by default is undefined.
ARRAY OF INTEGERS / INTEGER _face_subimages -> ID or IDs of the subimages of the sprite that will be used to animate it, if undefined is given, it will take all the subimages from the sprite and iterate through all of them by default for the animation, by default is undefined.
INTEGER _container_sprite -------------------> ID of the sprite to be used as a container to hold the entire dialog inside it, used to make dialog bubbles basically, its collision region determinates where the text of the dialog can be contained and it will scale to fit all of the text inside it, it is recommended to use a sprite with nine-slices activated.
INTEGER _container_tail_sprite --------------> ID of the sprite to be used as the tail of the container, used to make the dialog bubbles with tail, so you don't have to make multiple sprites with different position of the tail, the heavy calculation for its positioning was already made by me and a friend, really heavy math XD.
INTEGER _container_tail_mask_sprite ---------> ID of the sprite to be used as a mask region to determinate where the tail should be drawn, can be any size but have in mind that it will scale to fit the size of the container itself.
*/
function DialogSystem(_x, _y, _dialogues, _width, _height=0, _xscale=1, _yscale=1, _voices=snd_monster_voice, _face_sprite=undefined, _face_subimages=undefined, _container_sprite=undefined, _container_tail_sprite=undefined, _container_tail_mask_sprite=undefined) constructor{
	//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	//INITIALIZATION OF VARIABLES
	//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	//Timer variables for the text and its effects.
	text_timer = 0 //Starts at 0 so it executes the commands at the start of the dialog, if there are any, this happens at the very bottom.
	effect_timer = 0
	text_speed = 2
	
	//Variables to contain information.
	dialogues = []
	dialogues_amount = 0 //This is a variable that holds the lenght of the dialog array so there's no need to calculate it when needed.
	dialog_pop_ups = []
	dialog_pop_ups_amount = 0
	font = fnt_determination_mono //Fonts can only be changed per dialog with a command in the dialog and only if it's at the very beginning of it.
	use_font_space = true //Flag to determinate if use the space width of the font or not so a constant space width is used, by default true.
	spacing_width = 0 //This is the additional space between letters, the fonts themselves already have a space between each letter, this adds more between them, can be negative as well.
	spacing_height = 2 //Same as spacing_width but for space between line jumps.
	asterisk = true //Asterisk can be changed the same way as fonts.
	dialog = ""
	dialog_length = 0
	x = _x //X and Y coordinates of the dialog itself, can be moved around!
	y = _y
	dialog_width = max(_width, 1) //Width cannot be 0 or negative, minimum of 1.
	dialog_height = 0 //This will be calculated.
	dialog_minimum_height = max(_height, 1) //Same as width, cannot be negative, except this time it can be 0.
	dialog_heights = [] //For each dialog height calculated, will be inserted here in order to keep the height of the dialogues and not recalculate them (as it is impossible to recaculate once they are calculated).
	dialog_x_offset = 0 //Offset of the dialog's position depending of the container sprite.
	dialog_y_offset = 0 //If it's not given, these remain on 0, these will contain the top and left sides of the bbox collision of the sprite, which is where the text will be.
	line_jump_height = 0 //Stores the calculation of the height jump that needs to be performed when a text jump is executed in the dialog.
	xscale = _xscale //Can also be scaled being the origin the top left corner of the boundary box of the text, check the user documentation for more information about that.
	yscale = _yscale
	color = [] //This variable is to color the text as it is being displayed, it gets filled in the draw function of this constructor.
	
	//Converts the voices into an array if it was given as a ref directly and also calculates length of the array in a variable.
	if (typeof(_voices) == "ref"){
		voices = []
		voices_length = 1
		
		array_push(voices, _voices)
	}else{
		voices = _voices
		voices_length = array_length(voices)
	}
	
	//Configuration variables for the dialog.
	string_index = -asterisk //booleans are 0 (false) or 1 (true), so if true, this will start at -1.
	skipeable = true
	can_progress = true //This variable sets if the player can progress the dialog by pressing the confirm button, if false, it disables that, so you'll have to manually do it by code.
	reproduce_voice = true
	wait_for_key = undefined //This variable will hold the key the player will have to press to continue the dialog, make sure the player is aware of which one has to be tho, unless you use the confirm option of it.
	wait_for_function = undefined //This variable will hold the function that has to run and return true (or a number above or equal to 1, since thats also true) in order to progress the dialog.
	function_arguments = undefined //This variable holds the arguments of the function that is executed until it returns true.
	display_mode = DISPLAY_TEXT.LETTERS
	display_amount = 1
	action_commands = []
	visual_commands = []
	surface = -1 //The surface is only used for drawing pop ups, and until it is needed it's not created.
	
	//Variables that handle the portrait sprite in the dialog.
	face_sprite = _face_sprite
	face_timer = 0
	face_x_offset = 0
	face_y_offset = 0
	face_subimages_cycle = _face_subimages
	face_subimages_length = 0
	face_index = 0
	face_speed = 10
	face_animation = true
	
	//Variables that handle a sprite binded for talking.
	instance_index = undefined
	instance_timer = 0
	instance_image_index = 0
	instance_image_prev_index = 0
	instance_image_cycle = undefined
	instance_image_length = 0
	
	//Variables used for rendering every letter in the dialog on screen.
	visual_command_index = 0
	visual_command_data = undefined
	shadow_effect = false //Becomes true when the command in the action commands get triggered.
	draw_position_effect = EFFECT_TYPE.NONE
	draw_position_effect_value = 0
	draw_color_effect = EFFECT_TYPE.NONE
	draw_color_effect_offset = 0
	draw_color_effect_value = 0
	draw_text_effect = EFFECT_TYPE.NONE
	draw_text_effect_value = 0
	draw_text_effect_any_letter = false
	draw_text_effect_timers = []
	draw_text_effect_substitutes = []
	draw_shadow_effect = false //Yeah shadow effect is kinda hard coded, unless another similar effect exists I might rename these variables and they can be more general, but since it's the only effect, nope.
	draw_shadow_effect_color = 0
	draw_shadow_effect_font = 0
	draw_effect_x = 0
	draw_effect_y = 0
	draw_shadow_effect_x = 0
	draw_shadow_effect_y = 0
	draw_materializing_effect = EFFECT_TYPE.NONE
	draw_materializing_effect_x = 0
	draw_materializing_effect_y = 0
	draw_materializing_effect_scale = 0
	draw_materializing_effect_alpha = 0
	draw_materializing_effect_intensity = 0
	draw_materializing_effect_extra_effect = false
	draw_materializing_effect_timers = []
	text_align_x = ASTERISK_SPACING
	
	//Variables of the container sprite.
	container_sprite = undefined
	container_right_collision = 0 //The four collisions are kept, up and left sides are kept in the dialog_x_offset and dialog_y_offset variables instead.
	container_bottom_collision = 0
	container_sprite_width = 0
	container_sprite_height = 0
	container_width = 0
	container_height = 0
	container_x_origin = undefined //Instead of having a 0, these contain undefined for the tail sprite to know and not draw until a number gets set on it.
	container_y_origin = undefined
	container_x_offset = 0
	container_y_offset = 0
	container_x = 0
	container_y = 0
	container_original_origins = false //There are no origins set, so it starts as false.
	
	//Variables for handling the tail's container.
	container_tail_sprite = undefined
	container_tail_draw_mode = CONTAINER_TAIL_DRAW_MODE.TOP //By default, the draw mode of the tail is below the container sprite, you can change this with a callable function.
	container_tail_sprite_width = 0
	container_tail_y_origin = 0
	container_tail_angle = 0
	container_tail_width_pixels = 0
	container_tail_height_pixels = 0
	container_tail_width = 0
	container_tail_height = 0
	
	//Variables to handle the mask of the tail so it draws in a more specific way.
	container_tail_mask_sprite = undefined
	container_tail_mask_width = 0
	container_tail_mask_height = 0

	final_face_height = 0
	
	//If the value given as sprite is a sprite, then align the text to the right depending on the size of the sprite.
	if (sprite_exists(face_sprite)){
		final_face_height = sprite_get_height(face_sprite)
		text_align_x += sprite_get_width(face_sprite) + 10
		
		//If no subimages are given, it uses all of the subimages of the sprite for the speaking animation.
		if (!is_undefined(face_subimages_cycle)){
			if (typeof(face_subimages_cycle) == "number"){
				face_index = face_subimages_cycle
				face_subimages_length = 1
			}else{
				face_subimages_length = array_length(face_subimages_cycle)
			}
		}else{
			face_subimages_length = sprite_get_number(face_sprite)
		}
		
		//If there is an animation, make it almost instant.
		if (face_subimages_length > 1){
			face_timer = face_speed - 1
		}
	}
	
	//Final variables for handling all the dialogs changes without applying them directly to the constructor, they keep the last dialog configuration in the dialogs.
	final_asterisk = asterisk
	final_font = font
	final_spacing_width = spacing_width
	final_spacing_height = spacing_height
	final_face_sprite = face_sprite
	final_face_x_offset = face_x_offset
	final_face_y_offset = face_y_offset
	final_text_align_x = text_align_x
	
	//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	//MAIN LOGIC FUNCTIONS
	//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	//These functions are the ones meant to be called in your code so the dialogs can peform the actions.
	
	/*
	The step function handles all the logic, portrait sprites and inputs from the player to have all the information of the current state of the dialog ready to display.
	Prefered place to call this is in any of the 3 step functions, avoid using it on the draw events alongside the draw function, that is not a good practice.
	*/
	step = function(){
		//If there are no dialogs to display, return.
		if (dialogues_amount == 0){
			return
		}
		
		var _length = array_length(draw_text_effect_timers)
		for (var _i = 0; _i < _length; _i++){
			if (draw_text_effect_timers[_i] > 0){
				draw_text_effect_timers[_i]--
			}
		}
		
		_length = array_length(draw_materializing_effect_timers)
		for (var _i = 0; _i < _length; _i++){
			draw_materializing_effect_timers[_i]++
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//DIALOG POP UP UPDATES
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//Please don't put pop ups inside pop ups and so on, it will never end.
		
		for (var _i = 0; _i < dialog_pop_ups_amount; _i++){
			dialog_pop_ups[_i].system.step()
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//PLAYER INPUT CHECKING
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		//Condition to get the confirm button to advance to the next dialog.
		if (string_index == dialog_length and can_progress and (global.confirm_button or global.menu_hold_button)){ //global.confirm_button and global.menu_hold_button only returns 0 or 1, so essencially it's a great boolean thing.
			next_dialog(false)
			animation_step()
			
			return
		}
		
		//Conditions for the special wait commands, waiting for input on keyboard or buttons or until a function returns true.
		if (!is_undefined(wait_for_function)){
			if (method_call(wait_for_function, function_arguments)){ //Until true is returned, it will not reset wait_for_function.
				wait_for_function = undefined
				function_arguments = undefined
			}
		}else if (!is_undefined(wait_for_key)){
			switch (wait_for_key){ //Waits for a specific key press to continue the dialog.
				case "confirm":
					if (global.confirm_button){
						wait_for_key = undefined
					}
				break
				case "cancel":
					if (global.cancel_button){
						wait_for_key = undefined
					}
				break
				case "menu":
					if (global.menu_button){
						wait_for_key = undefined
					}
				break
				case "progress":
					if (global.confirm_button or global.menu_hold_button){
						wait_for_key = undefined
					}
				break
				case "any":
					if (keyboard_check_pressed(vk_anykey)){
						wait_for_key = undefined
					}
				break
				default:
					if (keyboard_check_pressed(ord(wait_for_key))){
						wait_for_key = undefined
					}
				break
			} //If there's not waiting in process, then if the player is pressing the cancel button, dialog may be skipped.
		}else if (string_index < dialog_length and skipeable and ((global.cancel_button and string_index != -asterisk) or global.menu_hold_button)){ //Same property with global.cancel_button from the others.
			skip_dialog()
		}
		//It is important to note that skip condition is checked after the next dialog condition, so text is shown on screen for the current frame and not just emptiness.
		
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//DIALOG PROGRESSION
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//First it is checked if it's not waiting for a key or a function and it's in range to advance the dialog.
		
		if (is_undefined(wait_for_key) and is_undefined(wait_for_function) and (string_index < dialog_length or command_length > 0)){
			text_timer-- //Counts down until 0 is reached so it may advance the dialog.
			var _voice_reproduced = false //In case multiple characters are being displayed, we don't want a sound for each one, right? It gets pretty loud otherwise.
		
			//First execute any commands that may be left over and are yet to be executed (that can happen due to the [wait] command not executing more commands once it's set).
			if (text_timer <= 0){
				execute_action_commands()
			
				//In the execution of the commands maybe any of these paramenters changed, must check again.
				while (text_timer <= 0 and is_undefined(wait_for_key) and is_undefined(wait_for_function) and string_index < dialog_length){
					face_animation = true
				
					//--------------------------------------------------------------------------------------------------------------------------------------------------------
					//DIALOG ADVANCING TYPE
					//--------------------------------------------------------------------------------------------------------------------------------------------------------
				
					var _found_not_space = false //This is a flag that sets to true once any character that is not a jump line or a space is found, this is to make a sound in the dialog.
					switch (display_mode){
						case DISPLAY_TEXT.LETTERS:{ //Dialog may advance by letters, one by one, set by the amount of letters that you want to be displayed on the dialog.
							for (var _i = 0; _i < display_amount; _i++){
								string_index++
							
								if (string_index == 0){
									break //If it's an initial asterisk what must be shown, do that and next frame do the letters (for stylish points).
								}
							
								var _letter = string_char_at(dialog, string_index)
								if (_letter == "\n" or _letter == "\r"){ //If it's a line jump, stop advacing the dialog, for stylish points (doesn't break anything if you don't, but it looks great this way).
									break
								}else if (_letter != " "){
									_found_not_space = true //Set flag since a non jump line or space has been found.
								}
							
								_letter = string_char_at(dialog, string_index + 1)
								if (_letter == "\n" or _letter == "\r"){ //If the character next to the currently being advanced is also a line jump, also stop advancing for even more stylish points.
									break
								}
							}
						break}
						case DISPLAY_TEXT.WORDS:{ //Dialogs may advance by whole words instead, word by word, set by the amount of words that you want to display on the dialog.
							//If it's the beggining of the dialog and asterisk must be displayed, just advance one and stop doing it, next frame do the words.
							if (string_index < 0){
								string_index++
							
								break
							}
						
							//Follows kind of a similar cycle for the auto line jump algorithm.
							var _word_ender_chars_array = [" ", ",", ".", ":", "", "\n", "\r", "-", "/", "\\", "|"]
							var _special_char_length = 11 //11 characters are considered word enders this time.
						
							//Set the search and check indexes.
							var _search_index = max(string_index + 1, 1) //_search_index sets its index to the next char from the current one in string_index.
						
							for (var _i = 0; _i < display_amount; _i++){ //Display X words.
								var _char = string_char_at(dialog, _search_index)
								var _check_index = 0 //Set to 0 every word displayed.
							
								//This while cycle searches starting from the _search_index for any of the word ender characters.
								var _j = 0
								while (_j < _special_char_length){
									if (_char == _word_ender_chars_array[_j]){ //If the next char to the current is one word ender, increase the string_index by 1 and end there.
										string_index++
										_check_index = -1
									
										break
									}
								
									var _char_index = string_pos_ext(_word_ender_chars_array[_j], dialog, _search_index)
								
									if (_char_index == 0){ //If no word ender character has been found, delete from the array since no more are in the dialog.
										_special_char_length--
										array_delete(_word_ender_chars_array, _j, 1)
									
										continue //Go again for the other word ender chars.
									}
								
									if (_check_index == 0){ //If its the very first word ender char found, set it on _check_index.
										_check_index = _char_index
									}else{ //Otherwise, get the minimum index of them.
										_check_index = min(_char_index, _check_index)
									}
								
									_j++
								}
							
								//Set the string_index depending on string_index value.
								if (_check_index == 0){ //_check_index is only 0 when no word ender chars have been found.
									string_index = dialog_length
								
									break
								}else if (_check_index > 0){ //_check_index is above 0 when a word ender has been found.
									string_index = _check_index //It gets set ON the word ender character found.
								
									if (string_char_at(dialog, string_index) != "-"){ //If the word ender is "-" display it as well, otherwise no.
										string_index--
									}
								}else{ //This is a section only executed when _check_index is -1, which only happens when the word ender char is the next one from the current one directly.
									var _letter = string_char_at(dialog, string_index)
								
									if (_letter == "\n" or _letter == "\r"){ //If it's a line jump, stop advacing the dialog.
										break
									}
								}
							
								var _letter = string_char_at(dialog, string_index)
								if (_letter != " " and _letter != "\n" and _letter != "\r"){ //If the char in the current position of the string_index is not a jump line or a space, it's valid to set the flag.
									_found_not_space = true //It always ends on end of word character when displaying a word, so it's guaranteed to find one per word, but not on spaces.
								}
							
								if (string_index + 1 < dialog_length){ //If it's inside the dialog length the index increased by 1.
									_letter = string_char_at(dialog, string_index + 1) //Then check the letter.
								
									if (_letter == "\n" or _letter == "\r"){ //If it's a jump line the next character where it ended, then stop advancing for stylish looks.
										break
									}
								}
							
								//Update the _search_index by setting it one ahead of the current index.
								_search_index = string_index + 1
							}
						break}
					}
				
					//--------------------------------------------------------------------------------------------------------------------------------------------------------
					//COMMAND EXECUTION
					//--------------------------------------------------------------------------------------------------------------------------------------------------------
				
					//After the string_index is in the correct position for the current frame, execute the commands it can do.
					var _execute_commands_code = execute_action_commands() //The function returns always a number of the text_timer that was set by the commands or not.
					if (is_undefined(_execute_commands_code)){ //undefined is returned by the execution of commands only when the [next] command has been performed, that means another dialog is being displayed and this one is no longer valid, hence stop everything and return.
						return
					}else if (_execute_commands_code <= 0){ //Otherwise, if the text_timer returned is below or equal to 0, set it to the text_speed.
						text_timer += text_speed //Keep in mind that if you set it to negative number than the text_speed cannot add up to a positive, it will advance the text until it's greather than 0 either by commands or increasing by text_speed (for more information on that check the user documentation or the programmer documentation).
					}
				
					//--------------------------------------------------------------------------------------------------------------------------------------------------------
					//VOICE REPRODUCTION
					//--------------------------------------------------------------------------------------------------------------------------------------------------------
				
					var _voice = voices[0]
					if (voices_length > 1 and reproduce_voice){ //if there are at least 2 voices, and the voice is not muted, get the random voice.
						_voice = voices[irandom(voices_length - 1)]
					}
				
					//string_index being 0 means it has just displayed the initial asterisk, if there's no asterisk this condition never becomes true.
					if (string_index == 0){
						text_timer += 2*text_speed //For the initial asterisk it takes 2 times the text_speed
				
						if (reproduce_voice){
							audio_play_sound(_voice, 0, false)
							_voice_reproduced = true
						}
				
						continue //Since it is the first asterisk do nothing more.
					}
				
					var _letter = string_char_at(dialog, string_index)
				
					//If asterisks are enabled and the string_index is pointing to a line jump \n and not a \r one, then it takes twice the time to advance the dialog, it also stops the face animation.
					if (_letter == "\n" and asterisk){
						text_timer += 2*text_speed
						face_animation = false
					
						if (!_voice_reproduced and reproduce_voice){
							audio_play_sound(_voice, 0, false)
							_voice_reproduced = true
						} //If no voice has been reproduced yet and something besides a space and line jumps have been found, reproduce the voice.
					}else if (!_voice_reproduced and reproduce_voice and _found_not_space){
						audio_play_sound(_voice, 0, false)
						_voice_reproduced = true
					}
				}
			}
		}
		
		//Lastly just step the portrait animation, it does nothing if there's no sprite assigned to it.
		animation_step()
	}
	
	/*
	This functions is in charge of displaying the dialog and portrait (if set) properly with the information the step function has prepared, such as the proper string_index position and some other configuration things.
	This functions must be called only in draw events of objects that use this constructor function, obviously.
	*/
	draw = function(){
		//Back ups the current depth buffer disable in case some others need it.
		var _surface_prev_target = surface_get_target()
		var _depth_buffer_disabled = surface_get_depth_disable()
		
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//SETTING DRAWING CONFIGURATION
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		draw_set_font(font)
		
		//If there are no dialogs to display, end it there, but do set the properties in case some stuff depends from it.
		if (dialogues_amount == 0){
			return
		}
		
		var _initial_x = x + dialog_x_offset*xscale //Calculate the X and Y position where the text with/without portrait origin is located.
		var _initial_y = y + dialog_y_offset*yscale
		var _reset_point_x = _initial_x + max(text_align_x + face_x_offset, ASTERISK_SPACING*asterisk)*xscale //Set the X point where it resets the X position for every line jump with text_aling_x to make extra space for the portrait and asterisk.
		var _letter_x = _reset_point_x //Start the variables to position each letter.
		var _letter_y = _initial_y
		
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//CONTAINER DRAWING
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		//Draw the tail first if the draw mode is bottom.
		if (sprite_exists(container_tail_sprite) and !is_undefined(container_x_origin) and !is_undefined(container_y_origin) and container_tail_draw_mode == CONTAINER_TAIL_DRAW_MODE.BELOW){
			draw_sprite_ext(container_tail_sprite, 0, x + container_x_origin*xscale, y + container_y_origin*yscale, container_tail_width*xscale, container_tail_height*yscale, container_tail_angle, c_white, 1)
		}
		
		//Draw the container that will hold the text.
		if (sprite_exists(container_sprite)){
			draw_sprite_ext(container_sprite, 0, x + container_x_offset*xscale, y + container_y_offset*yscale, container_width*xscale, container_height*yscale, 0, c_white, 1)
		}
		
		//Draw the tail on top of the container instead of draw mode is not below.
		if (sprite_exists(container_tail_sprite) and !is_undefined(container_x_origin) and !is_undefined(container_y_origin) and container_tail_draw_mode != CONTAINER_TAIL_DRAW_MODE.BELOW){
			//If the draw mode is any of the masking modes, prepare the mask sprite.
			//Only it can be any of the masking modes if a mask sprite is set, any attempt to force without a mask sprite it may result in error.
			if (container_tail_draw_mode == CONTAINER_TAIL_DRAW_MODE.INVERTED_SPRITE_MASK){
				var _offset_x = -get_tail_width()
				var _offset_y = -get_tail_height()
				var _offset_x2 = max(_offset_x, 0)
				var _offset_y2 = max(_offset_y, 0)
				
				if (!surface_exists(surface)){
					surface = surface_create(get_width() + abs(_offset_x), get_height() + abs(_offset_y))
				}
				
				surface_set_target(surface)
				
				draw_sprite_ext(container_tail_sprite, 0, _offset_x2 + container_x_origin*xscale, _offset_y2 + container_y_origin*yscale, container_tail_width*xscale, container_tail_height*yscale, container_tail_angle, c_white, 1)
				
				gpu_set_blendenable(false)
				gpu_set_colorwriteenable(true, true, true, true)
				gpu_set_alphatestenable(true)
				
				shader_set(shd_alpha_masking)
				draw_sprite_ext(container_tail_mask_sprite, 0, _offset_x2, _offset_y2, container_tail_mask_width*xscale, container_tail_mask_height*yscale, 0, c_white, 1)
				shader_reset()
				
				gpu_set_blendenable(true)
				gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
				gpu_set_alphatestenable(false)
				
				surface_reset_target()
				
				draw_surface(surface, x + min(-_offset_x, 0), y + min(-_offset_y, 0))
				
				gpu_set_default_blendmode()
			}else{
				if (container_tail_draw_mode == CONTAINER_TAIL_DRAW_MODE.SPRITE_MASK){
					gpu_set_blendenable(false)
					gpu_set_colorwriteenable(false, false, false, true)
					gpu_set_alphatestenable(true)
					
					//This shader allows for masks with alpha to be used for effects you may want, if by any chance you or your end users cannot run this shader, you will have to use masks with full alpha only, no transparency allowed.
					shader_set(shd_alpha_masking)
					draw_sprite_ext(container_tail_mask_sprite, 0, x, y, container_tail_mask_width*xscale, container_tail_mask_height*yscale, 0, c_white, 1)
					shader_reset()
					
					gpu_set_blendenable(true)
					gpu_set_colorwriteenable(true, true, true, false)
					gpu_set_blendmode_ext(bm_inv_dest_alpha, bm_dest_alpha)
				}
				
				//Draw the tail with its corresponding data.
				draw_sprite_ext(container_tail_sprite, 0, x + container_x_origin*xscale, y + container_y_origin*yscale, container_tail_width*xscale, container_tail_height*yscale, container_tail_angle, c_white, 1)
				
				//Remove all changes made with the masking sprite if it exists.
				if (container_tail_draw_mode == CONTAINER_TAIL_DRAW_MODE.SPRITE_MASK){
					gpu_set_blendenable(false)
					gpu_set_colorwriteenable(false, false, false, true)
					
					draw_sprite_ext(container_tail_mask_sprite, 0, x, y, container_tail_mask_width*xscale, container_tail_mask_height*yscale, 0, c_white, 1)
					
					gpu_set_blendenable(true)
					gpu_set_colorwriteenable(true, true, true, true)
					gpu_set_default_blendmode()
					gpu_set_alphatestenable(false)
				}
			}
		}
		
		//Colors for coloring the letters.
		color[0] = c_white //Resets color, this is to avoid creating another array every frame.
		color[1] = c_white //Yes I know the garbage collector exists, but why must you make it collect every frame the same array?
		color[2] = c_white //Ease some of the job it does.
		color[3] = c_white //Optimize.
		
		var _offset_x = 0 //These offset by X amount the position for something in specific that is needed for, usually for correct positioning inside a surface.
		var _offset_y = 0
		
		//When the shadow effect is active, convert the coordinates into relative ones and create a surface.
		if (shadow_effect){
			if (_depth_buffer_disabled){
				surface_depth_disable(false)
			}
			
			if (!surface_exists(surface)){
				surface = surface_create(dialog_width*xscale, dialog_height*yscale)
			}
			
			_offset_x = -_initial_x //Offset letters to set them in 0,0 on the surface.
			_offset_y = -_initial_y
			
			surface_set_target(surface)
			
			draw_clear_alpha(c_black, 0) //Clean any remainings from it.
		}
		
		//Do stuff only if the sprite for the portrait is set.
		if (sprite_exists(face_sprite)){
			//Portrait variables.
			var _face_y = _letter_y
			var _subimage_index = face_index
			
			//If the face Y offset given is positive, it moves that amount downwards from the top part of the first line of text.
			if (face_y_offset > 0){
				_face_y += face_y_offset*yscale
			}else{ //Otherwise the text moves that amount downwards.
				_letter_y -= face_y_offset*yscale
			}
			
			//If more than 1 subimages has been given, get the current index that has been set by the face_step function in the step function.
			if (face_subimages_length > 1 and !is_undefined(face_subimages_cycle)){
				_subimage_index = face_subimages_cycle[face_index]
			}
			
			//Draw the portrait sprite.
			draw_sprite_ext(face_sprite, _subimage_index, _initial_x + _offset_x + face_x_offset*xscale, _face_y + _offset_y, xscale, yscale, 0, c_white, 1)
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//DIALOG DISPLAYING
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		//Dialogs may start with a string_index of -1, so when it's that, nothing to do.
		if (string_index >= 0){
			effect_timer++ //This is a timer for effects on the dialog.
			
			//Variables for the different effects and the index of the visual commands.
			var _current_commands = visual_commands[0]
			visual_command_index = 0
			visual_command_data = undefined
			draw_position_effect = EFFECT_TYPE.NONE
			draw_position_effect_value = 0
			draw_color_effect = EFFECT_TYPE.NONE
			draw_color_effect_offset = 0
			draw_color_effect_value = 0
			draw_text_effect = EFFECT_TYPE.NONE
			draw_text_effect_value = 0
			draw_shadow_effect = false
			draw_shadow_effect_color = 0
			draw_shadow_effect_font = 0
			draw_effect_x = 0
			draw_effect_y = 0
			draw_shadow_effect_x = 0
			draw_shadow_effect_y = 0
			draw_materializing_effect = EFFECT_TYPE.NONE
			draw_materializing_effect_x = 0
			draw_materializing_effect_y = 0
			draw_materializing_effect_scale = 1
			draw_materializing_effect_alpha = 1
			
			if (visual_command_length > 0){ //If there are any commands, set the visual_command_data already for the first one.
				visual_command_data = _current_commands[0]
			}
			
			var _letter = "*"
			var _length = array_length(draw_text_effect_timers) //Used by the text effect that modify the letters.
			
			if (asterisk){ //If there's an initial asterisk, draw it.
				if (execute_visual_commands(0, _current_commands)){ //If the command [apply_to_asterisk] is at the beginning of the dialog, then display it with all the effects that are loaded at that point.
					if (draw_text_effect == EFFECT_TYPE.MALFUNCTION){
						if (_length > 0 and draw_text_effect_timers[0] > 0){
							_letter = draw_text_effect_substitutes[0]
						}else{
							if (random(9999) < draw_text_effect_value){ //When draw_text_effect_value is 0, it will never be true.
								//Trigger to know what type of charcters to substitute the letters with.
								if (draw_text_effect_any_letter){
									_letter = chr(irandom_range(33,126)) //All printable characters in Unicode/ASCII
								}else{
									_letter = chr(choose(33,35,36,37,38,42,43,45,47,60,61,62,63,64,92,94,95)) //Specific characters chosen that kinda resemble what computer show, signs people don't understand XD.
								}
								
								draw_text_effect_substitutes[0] = _letter
								draw_text_effect_timers[0] = irandom_range(5,60) //It takes between 1/12 to 1 second to reset the letter.
								
								if (_length < 1){
									_length = 1
								}
							}
						}
					}
					
					if (draw_shadow_effect){ //This happens paired to the shadow_effect variable, so a surface must be active when this happens.
						surface_reset_target()
				
						draw_set_font(draw_shadow_effect_font)
						
						draw_text_transformed_color(_letter_x + (draw_shadow_effect_x + draw_materializing_effect_x + draw_effect_x - ASTERISK_SPACING)*xscale, _letter_y + (draw_shadow_effect_y + draw_materializing_effect_y + draw_effect_y)*yscale, _letter, xscale*draw_materializing_effect_scale, yscale*draw_materializing_effect_scale, 0, draw_shadow_effect_color, draw_shadow_effect_color, draw_shadow_effect_color, draw_shadow_effect_color, draw_materializing_effect_alpha)
						
						draw_set_font(font)
						surface_set_target(surface)
					}
					
					draw_text_transformed_color(_letter_x + _offset_x + (draw_effect_x + draw_materializing_effect_x - ASTERISK_SPACING)*xscale, _letter_y + _offset_y + (draw_effect_y + draw_materializing_effect_y)*yscale, _letter, xscale*draw_materializing_effect_scale, yscale*draw_materializing_effect_scale, 0, color[0], color[1], color[2], color[3], draw_materializing_effect_alpha)
				}else{ //Otherwise, display a normal asterisk in normal circumstances.
					draw_text_transformed_color(_letter_x + _offset_x - ASTERISK_SPACING*xscale, _letter_y + _offset_y, _letter, xscale, yscale, 0, c_white, c_white, c_white, c_white, 1)
				}
			}
			
			//------------------------------------------------------------------------------------------------------------------------------------------------------------
			//LETTER RENDERING
			//------------------------------------------------------------------------------------------------------------------------------------------------------------
			//This for cycle runs for every letter it has to draw, applying the effects and color it has to draw the letter with, these are defined by the visual commands.
			
			for (var _i = 1; _i <= string_index; _i++){
				execute_visual_commands(_i, _current_commands) //Execute the visual commands.
				
				_letter = string_char_at(dialog, _i)
				var _original_letter = _letter //Needed since malfunction effect exists and may do it's tricks.
				
				if (draw_text_effect == EFFECT_TYPE.MALFUNCTION and _letter != " "){ //Spaces are ignored yes, only displayed characters.
					if (_length > _i and draw_text_effect_timers[_i] > 0){ //If there's a timer, then the letter must still be a substitute from the effect.
						_letter = draw_text_effect_substitutes[_i]
					}else{
						if (random(9999) < draw_text_effect_value){ //When draw_text_effect_value is 0, it will never be true.
							//Trigger to know what type of charcters to substitute the letters with.
							if (draw_text_effect_any_letter){
								_letter = chr(irandom_range(33,126)) //All printable characters in Unicode/ASCII
							}else{
								_letter = chr(choose(33,35,36,37,38,42,43,45,47,60,61,62,63,64,92,94,95)) //Specific characters chosen that kinda resemble what computer show, signs people don't understand XD.
							}
							
							draw_text_effect_substitutes[_i] = _letter
							draw_text_effect_timers[_i] = irandom_range(5,60) //It takes between 1/12 to 1 second to reset the letter.
						
							if (_length < _i + 1){
								_length = _i + 1
							}
						}
					}
				}
				
				if (_original_letter == "\n" or _original_letter == "\r"){ //If it's a line jump do other stuff.
					if (draw_text_effect != EFFECT_TYPE.MALFUNCTION or _length <= _i or draw_text_effect_timers[_i] == 0){
						_letter = "*" //If something is gonna be displayed, is gonna be an asterisk in this point.
					}
					
					_letter_x = _reset_point_x
					_letter_y += line_jump_height*yscale
					
					if (_original_letter == "\n" and asterisk){ //If the line jump is \n, print an asterisk, conserving the properties of the effects.
						if (draw_shadow_effect){ //This happens paired to the shadow_effect variable, so a surface must be active when this happens.
							surface_reset_target()
							
							draw_set_font(draw_shadow_effect_font)
							
							if (draw_color_effect == EFFECT_TYPE.RAINBOW){ //If you want a different interaction with the rainbow effect and shadows, modify it here.
								draw_color_effect_value = make_color_hsv(color_get_hue(draw_color_effect_value), 255, 64)
								
								draw_text_transformed_color(_letter_x + (draw_shadow_effect_x + draw_materializing_effect_x + draw_effect_x - ASTERISK_SPACING)*xscale, _letter_y + (draw_shadow_effect_y + draw_materializing_effect_y + draw_effect_y)*yscale, _letter, xscale*draw_materializing_effect_scale, yscale*draw_materializing_effect_scale, 0, draw_color_effect_value, draw_color_effect_value, draw_color_effect_value, draw_color_effect_value, draw_materializing_effect_alpha)
							}else{
								draw_text_transformed_color(_letter_x + (draw_shadow_effect_x + draw_materializing_effect_x + draw_effect_x - ASTERISK_SPACING)*xscale, _letter_y + (draw_shadow_effect_y + draw_materializing_effect_y + draw_effect_y)*yscale, _letter, xscale*draw_materializing_effect_scale, yscale*draw_materializing_effect_scale, 0, draw_shadow_effect_color, draw_shadow_effect_color, draw_shadow_effect_color, draw_shadow_effect_color, draw_materializing_effect_alpha)
							}
							
							draw_set_font(font)
							surface_set_target(surface)
						}
						
						if (draw_color_effect == EFFECT_TYPE.RAINBOW){ //If the effect currently on is a rainbow, do a different color rendering.
							draw_text_transformed_color(_letter_x + _offset_x + (draw_effect_x + draw_materializing_effect_x - ASTERISK_SPACING)*xscale, _letter_y + _offset_y + (draw_effect_y + draw_materializing_effect_y)*yscale, _letter, xscale*draw_materializing_effect_scale, yscale*draw_materializing_effect_scale, 0, draw_color_effect_value, draw_color_effect_value, draw_color_effect_value, draw_color_effect_value, draw_materializing_effect_alpha)
						}else{
							draw_text_transformed_color(_letter_x + _offset_x + (draw_effect_x + draw_materializing_effect_x - ASTERISK_SPACING)*xscale, _letter_y + _offset_y + (draw_effect_y + draw_materializing_effect_y)*yscale, _letter, xscale*draw_materializing_effect_scale, yscale*draw_materializing_effect_scale, 0, color[0], color[1], color[2], color[3], draw_materializing_effect_alpha)
						}
					}
				}else{ //Otherwise, render the letter.
					if (_original_letter != " "){ //If the letter is not a space, draw it, otherwise well don't, why would you draw a space XD.
						if (draw_shadow_effect){ //This happens paired to the shadow_effect variable, so a surface must be active when this happens.
							surface_reset_target()
							
							draw_set_font(draw_shadow_effect_font)
						
							if (draw_color_effect == EFFECT_TYPE.RAINBOW){ //If you want a different interaction with the rainbow effect and shadows, modify it here.
								draw_color_effect_value = make_color_hsv(color_get_hue(draw_color_effect_value), 255, 64)
							
								draw_text_transformed_color(_letter_x + (draw_shadow_effect_x + draw_materializing_effect_x + draw_effect_x)*xscale, _letter_y + (draw_shadow_effect_y + draw_materializing_effect_y + draw_effect_y)*yscale, _letter, xscale*draw_materializing_effect_scale, yscale*draw_materializing_effect_scale, 0, draw_color_effect_value, draw_color_effect_value, draw_color_effect_value, draw_color_effect_value, draw_materializing_effect_alpha)
							}else{
								draw_text_transformed_color(_letter_x + (draw_shadow_effect_x + draw_materializing_effect_x + draw_effect_x)*xscale, _letter_y + (draw_shadow_effect_y + draw_materializing_effect_y + draw_effect_y)*yscale, _letter, xscale*draw_materializing_effect_scale, yscale*draw_materializing_effect_scale, 0, draw_shadow_effect_color, draw_shadow_effect_color, draw_shadow_effect_color, draw_shadow_effect_color, draw_materializing_effect_alpha)
							}
						
							draw_set_font(font)
							surface_set_target(surface)
						}
					
						if (draw_color_effect == EFFECT_TYPE.RAINBOW){ //If the effect currently on is a rainbow, do a different color rendering.
							draw_text_transformed_color(_letter_x + _offset_x + (draw_effect_x + draw_materializing_effect_x)*xscale, _letter_y + _offset_y + (draw_effect_y + draw_materializing_effect_y)*yscale, _letter, xscale*draw_materializing_effect_scale, yscale*draw_materializing_effect_scale, 0, draw_color_effect_value, draw_color_effect_value, draw_color_effect_value, draw_color_effect_value, draw_materializing_effect_alpha)
						}else{
							draw_text_transformed_color(_letter_x + _offset_x + (draw_effect_x + draw_materializing_effect_x)*xscale, _letter_y + _offset_y + (draw_effect_y + draw_materializing_effect_y)*yscale, _letter, xscale*draw_materializing_effect_scale, yscale*draw_materializing_effect_scale, 0, color[0], color[1], color[2], color[3], draw_materializing_effect_alpha)
						}
						
						_letter_x += (string_width(_original_letter) + spacing_width)*xscale //Incremented the X position by the width of the letter plus additional space given by the user.
					}else{
						_letter_x += (((use_font_space) ? string_width(" ") : string_width("O")) + spacing_width)*xscale //Incremented the X position by the size of letter O, special case for space character.
					}
				}
			}
		}
		
		//If the shadow effect is enabled then draw the whole surface in the right place and reset the target, surface will be deleted later.
		if (shadow_effect){
			surface_reset_target()
			
			draw_surface(surface, _initial_x, _initial_y)
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//POP UP DISPLAYING
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//If there are any pop ups, they will be displayed above their parent dialog.
		
		surface_depth_disable(true) //Doesn't need depth buffer for this.
		
		for (var _i = 0; _i < dialog_pop_ups_amount; _i++){
			var _dialog = dialog_pop_ups[_i]
			
			if (_dialog.mode != POP_UP_MODE.NONE){ //Literally all modes do make a fade animation except the first one which is NONE.
				var _width = _dialog.system.get_width()
				var _height = _dialog.system.get_height()
				
				//If surface doesn't exists or it's too small for the pop up, create or resize it with the correct size.
				if (!surface_exists(surface)){
					surface = surface_create(_width, _height)
				}else if (surface_get_width(surface) < _width or surface_get_height(surface) < _height){
					surface_resize(surface, _width, _height)
				}
				surface_set_target(surface)
				
				draw_clear_alpha(c_black, 0) //In case the surface is not recreated by the resize function or created at all, it may contain previous pop_ups, clean them.
				
				_dialog.system.draw() //Draw the pop up.
				
				surface_reset_target()
				
				var _x_offset = 0
				var _y_offset = 0
				var _alpha = 1
				
				if (_dialog.timer < 15){ //15 frames or 1/4 a second takes for the animation to take place.
					_dialog.timer++
					
					_alpha = _dialog.timer/15
					
					switch (_dialog.mode){
						case POP_UP_MODE.LEFT: case POP_UP_MODE.LEFT_INSTANT:
							_x_offset = -2*(15 - _dialog.timer)
						break
						case POP_UP_MODE.RIGHT: case POP_UP_MODE.RIGHT_INSTANT:
							_x_offset = 2*(15 - _dialog.timer)
						break
						case POP_UP_MODE.UP: case POP_UP_MODE.UP_INSTANT:
							_y_offset = -2*(15 - _dialog.timer)
						break
						case POP_UP_MODE.DOWN: case POP_UP_MODE.DOWN_INSTANT:
							_y_offset = 2*(15 - _dialog.timer)
						break
					}
				}
				
				//Draw the pop up on the proper place.
				draw_surface_ext(surface, x + (_dialog.x + _x_offset)*xscale, y + (_dialog.y + _y_offset)*yscale, 1, 1, 0, c_white, _alpha)
			}else{ //If the mode is NONE, just draw the pop up as is, and it's like a tiny dialog functioning inside a dialog basically.
				_dialog.system.move_to(x + _dialog.x*xscale, y + _dialog.y*yscale)
				_dialog.system.draw()
			}
		}
		
		//Surface is no longer needed, delete it.
		if (dialog_pop_ups_amount == 0 and !shadow_effect and surface_exists(surface)){
			surface_free(surface)
			surface = -1
		}
		
		if (!_depth_buffer_disabled){
			surface_depth_disable(false)
		}
	}
	
	//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	//CALLABLE FUNCTIONS
	//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	//These can be called anytime with its corresponding parameters to make certain stuff happen with the dialog.
	//Be aware that modifying any of these may affect the dialog system as these functions are as well used withing the code of this system, be cautious of what you modify or remove as commands in the dialog uses these as well too (including the dialog pop ups).
	
	/*
	This function when called skips the dialog, something the player can do by pressing the cancel button, but there are commands that disable it, so you can call this so you can manually in code do it.
	It can be called any moment, of course calling it once the text is done or the user has skipped it won't do anything.
	Be aware that if you call this function before the step function and the user does a perfect frame confirm press (if it can progress the dialog) as you call this function in your code, it may jump the dialog immediatelly, if you want to avoid that, call it after the step event has been called.
	
	BOOLEAN _reproduce_sound -> Option to make a voice sound when it skips to the end of the dialog, it is true by default to reproduce the sound.
	
	RETURNS -> INTEGER/UNDEFINED --The integer is the text_timer used by the system to know if the skip was stopped by some command and has set a text_timer to delay the text (like a combination of [stop_skip][wait]), it only returns UNDEFINED if it has executed the command [next] in the process, which is used by the system to know nothing else needs to be done as the dialog has advanced and the current info is outdated.
	*/
	skip_dialog = function(_reproduce_sound=true){
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//COMMAND EXECUTION
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		text_timer = 0 //Set the text_timer to 0 so it if it stops skipping by some commands, it executes any command that may be still in the position.
		string_index = dialog_length //Set the string_index to the final of the dialog so it executes all commands properly.
		
		if (is_undefined(execute_action_commands(true))){ //If executing the action commands ends up with a undefined being returned, it means the dialog is different now and this context is no longer needed.
			return undefined //Since the skip_dialog may be called by a command as well, return the undefined received as it stops any execution in the step or next_dialog functions.
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//VOICE REPRODUCTION
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//Reproduce a voice if the skip happens however and no other thing interrupts it.
		
		if (reproduce_voice and _reproduce_sound){
			var _voice = voices[0]
		
			if (voices_length > 1){
				_voice = voices[irandom(voices_length - 1)]
			}
			audio_play_sound(_voice, 0, false)
		}
		
		return text_timer //Return the text_timer that may have been changed by the execution of the commands.
	}
	
	/*
	This function when called goes directly to the next dialog, regardless of the state the dialog may be in, if there's no more dialogs, it show nothing then.
	If it's called when there's no dialog on screen (that only happens when the dialogs have been depleted), it does nothing.
	
	BOOLEAN _do_commands -> Option to execute the commands that are still yet to be executed if the dialog has not finished yet, it will do nothing if the dialog is finished, if false you might encounter some inconsistencies when advacing to other dialogs, unless you know what you're doing I recommend leaving it as true by default (for more information on this, check the user or programmer documentation)
	*/
	next_dialog = function(_do_commands=true){
		//If no more dialogs are there, just do nothing.
		if (dialogues_amount == 0){
			return
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//COMMAND EXECUTION
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//To execute the commands it is used skip_dialog function instead of doing it itself, repeating some code, so just make skip_dialog do it.
		
		if (_do_commands){ //Execute all commands yet to be executed
			do{
				//Sometimes in the commands, these variables may be set by the commands and they stop the skip_dialog from continuing, so in case it fails to finish the skip for any reason, set them to undefined.
				wait_for_key = undefined
				wait_for_function = undefined
				function_arguments = undefined
				
				if (is_undefined(skip_dialog(false))){ //If undefined is returned, it means it has found a [next] command that skips the dialog and advances to the next, since that one will do the job already, then stop this execution.
					return
				}
			}until (string_index == dialog_length) //Since the skip_dialog function is being used for executing all commands remaining in the dialog, sometimes it may find commands that stop the skip, in this case that is not what it is wanted as it is advancing the dialog to the next one.
		} //So instead the do-until cycle, makes sure the dialog always executes all the commands in it, if it stops the skips, well, do it again.
		
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//DIALOG ADVACING
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//After commands have been executed to set or change portrait sprites or other persistent configuration, the variables are reset and from the arrays of commands and dialog, it is removed the one that it holds currently, it is no longer needed.
		
		array_delete(action_commands, 0, 1)
		array_delete(visual_commands, 0, 1)
		array_delete(dialog_heights, 0, 1)
		array_delete(dialogues, 0, 1)
		dialogues_amount--
		
		//Delete all pop up information as well, since those only belong to the current dialog displaying.
		if (dialog_pop_ups_amount){ //It's never negative, 0 is false.
			array_delete(dialog_pop_ups, 0, dialog_pop_ups_amount)
		}
		dialog_pop_ups_amount = 0
		
		//Set the timers of the portrait animation to trigger almost immediatelly as the dialog starts.
		if (sprite_exists(face_sprite) and face_subimages_length > 1){
			face_timer = face_speed - 1
		}
		
		//Same for the instance binded if there's any.
		if (!is_undefined(instance_index) and instance_image_length > 1){
			instance_timer = face_speed - 1
		}
		
		//If no more dialogs are there after deleting it, just finish there.
		if (dialogues_amount == 0){
			//If an instance is binded at this point, unbinds it.
			if (!is_undefined(instance_index)){
				instance_index.image_index = instance_image_prev_index
				instance_index = undefined
			}
		
			return
		}
		
		//If there are no stopping points, reset the variables.
		variable_reset()
	}
	
	/*
	This function is used by the command [pop_up], which makes a tiny dialog appear overlapped with the current dialog, this one doesn't have a container in its arguments, but it doesn't prevent it from having one, it's your choice.
	You can use this function in your code to display pop_up whenever you want, as long as there's a dialog.
	
	INTEGER _mode ---------------------> Mode the dialog pop up will be displayed and handled, please use only the constants of POP_UP_MODE.
	REAL _x ---------------------------> Relative X position inside the dialog where the pop up will be displayed.
	REAL _y ---------------------------> Relative Y position inside the dialog where the pop up will be displayed.
	STRING _dialog --------------------> Dialog the pop up will display.
	INTEGER _width --------------------> Width of the dialog pop up, it will be multiplied by 2 as the pop up will be scaled down by half so you only give the width directly as how you would see it if it was its normal scale size.
	INTEGER _face_sprite --------------> Portrait sprite to be used on the dialog.
	ARRAY OF INTEGERS _face_subimages -> ID or IDs of subimages of the portrait sprite to animate the pop up when it's talking, in instant modes this is kinda useless, so just give 1 integer.
	*/
	make_tiny_dialog_pop_up = function(_mode, _x, _y, _dialog, _width, _face_sprite, _face_subimages){
		if (dialogues_amount == 0){
			return
		}
		
		array_push(dialog_pop_ups, {timer: 0, mode: _mode, x: _x, y: _y, system: new DialogSystem(0, 0, _dialog, 2*_width,, xscale/2, yscale/2,, _face_sprite, _face_subimages)})
		dialog_pop_ups_amount++
		
		var _system = dialog_pop_ups[dialog_pop_ups_amount - 1].system
		_system.can_progress = false //Prevent the player from advancing these pop up dialogs, they will be remove when the system is done with its current dialog.
		
		if (_mode >= POP_UP_MODE.INSTANT){ //enums are numerated in order, so after INSTANT, all other constants are variants of instant, so this takes place on all of those.
			do{
				if (is_undefined(_system.skip_dialog(false))){ //If undefined is returned, it means it has found a [next] command that skips the dialog and advances to the next, that means this pop up is no longer needed actually, so remove it immediatelly and return, just don't put [next] in the pop ups if they are instant, please.
					array_pop(dialog_pop_ups)
					dialog_pop_ups_amount--
					
					return
				}
			}until (_system.string_index == _system.dialog_length)
		}
	}
	
	/*
	With this functions you can change the container sprite whenever, this can be done as well with the command [container], in fact, that command calls this function.
	Unless you need to run this function outside the dialog itself, here you can use it.
	Be aware that by setting the sprite while a tail sprite is displaying will override the tail's position to the one assigned to the container with its origin in the sprite itself.
	
	INTEGER _sprite -> Sprite index to set the container to, if you submit a index that contains no sprite (which can be achieved easily by passing -1 since you cannot pass undefined through a string) you will remove it, good for having nothing assigned to it.
	*/
	set_container_sprite = function(_sprite){
		container_sprite = _sprite
		dialog_x_offset = 0
		dialog_y_offset = 0
		
		if (!sprite_exists(container_sprite)){
			return
		}
		
		//Set variables to load the information to display the container properly.
		//If a container is set, then the container's top left corner becomes the origin.
		dialog_x_offset = sprite_get_bbox_left(container_sprite)
		dialog_y_offset = sprite_get_bbox_top(container_sprite)
		container_right_collision = sprite_get_bbox_right(container_sprite) + 1 //Right and bottom collisions are off by 1 for some reason in game maker.
		container_bottom_collision = sprite_get_bbox_bottom(container_sprite) + 1
		container_sprite_width = sprite_get_width(container_sprite)
		container_sprite_height = sprite_get_height(container_sprite)
		container_x_origin = sprite_get_xoffset(container_sprite)
		container_y_origin = sprite_get_yoffset(container_sprite)
		container_original_origins = true
		
		//Call the function to update parameters of the container sprite once the variables have been set.
		update_container_sprite()
		
		//In case a tail exists, send the container's new origin to set the tail's position and if a mask also exists, update the information.
		set_container_tail_position(container_x_origin, container_y_origin)
	}
	
	/*
	With this funcion you can change the container's tail sprite for a change of design or remove it, this can be done as well with the command [tail] that calls this function too.
	If no container sprite is set, until you call the set_container_tail_position() function or do it with the command [tail_position], the tail won't be displayed even if a sprite is assigned (see the programmer documentation to know more about it).
	
	INTEGER _sprite -> Sprite index to set the container's tail to, if you submit a index that contains no sprite (which can be achieved easily by passing -1 since you cannot pass undefined through a string) you will remove it, good for having nothing assigned to it.
	*/
	set_container_tail_sprite = function(_sprite){
		container_tail_sprite = _sprite
		
		if (!sprite_exists(container_tail_sprite)){
			return
		}
		
		//Set the variables to display the container's tail.
		container_tail_sprite_width = sprite_get_width(container_tail_sprite)
		container_tail_y_origin = sprite_get_yoffset(container_tail_sprite)
		container_tail_width_pixels = sprite_get_xoffset(container_tail_sprite)
		container_tail_height_pixels = sprite_get_height(container_tail_sprite)
		
		//Call the function to update parameters of the tail sprite once they have been set.
		update_container_tail_sprite()
		
		//If these origins are set, which can only happen either by setting it manually with the set_container_tail_position() or by loading a container sprite, then continue past this condition.
		if (is_undefined(container_x_origin) or is_undefined(container_y_origin)){
			return
		}
		
		//Set the tail's position and update the mask if they exists with the container too.
		set_container_tail_position(container_x_origin, container_y_origin)
		update_container_tail_mask_sprite()
	}
	
	/*
	With this function you can change the container's tail mask sprite, this mask delimits the section where the tail is being draw or it should not be drawn into.
	Can be used as well with the command [tail_mask] as it uses this function directly, just like the previous ones.
	If no container sprite AND tail sprite as well are set, this mask won't take effect, however you can assign it to use later when the requirements are met.
	
	INTEGER _sprite -> Sprite index to set the container's tail mask sprite to, if you submit a index that contains no sprite (which can be achieved easily by passing -1 since you cannot pass undefined through a string) you will remove it, good for having nothing assigned to it.
	*/
	set_container_tail_mask_sprite = function(_sprite){
		container_tail_mask_sprite = _sprite
		
		if (!sprite_exists(container_tail_mask_sprite)){
			//If the container mask is removed, set the draw mode back to below.
			container_tail_draw_mode = CONTAINER_TAIL_DRAW_MODE.BELOW
			
			return
		}
		
		//Update the mask settings to see if it meets the requirements to apply its effects.
		update_container_tail_mask_sprite()
	}
	
	/*
	This function sets the draw mode of the tail which can only be four modes delimited by the constants of CONTAINER_TAIL_DRAW_MODE, please only use those constants for this function.
	If you know the numbers assigned to the constant you may use them directly, however it is not adviced as you may forget what those numbers really mean, that's why the constants exist.
	
	INTEGER _mode -> Set the drawing mode of the tail sprite, so you deactivate the masking taking place or change it apply a different masking mode, please only use the constants of CONTAINER_TAIL_DRAW_MODE preferibly.
	*/
	set_container_tail_draw_mode = function(_mode){
		switch (_mode){
			case CONTAINER_TAIL_DRAW_MODE.SPRITE_MASK: case CONTAINER_TAIL_DRAW_MODE.INVERTED_SPRITE_MASK: //These mode can be placed only if a sprite_mask was set.
				if (!sprite_exists(container_tail_sprite_mask)){
					break //If no sprite mask was given, do not set any value.
				}
			default:
				container_tail_draw_mode = _mode
			break
		}
	}
	
	/*
	This functions sets the position of the container's tail to make the dialog look like it points to that direction, to make a dialog bubble point to a character.
	set_container_sprite() function sets the _x and _y data to make the tail point in the proper direction, you may give your own coordinates to make the tail appear without the need of the container.
	Be aware that the coordinates passed to this function are local based on the origin of the dialog itself, where 0,0 is the very top left corner of the dialog.
	
	REAL _x -> Relative X coordinate of the tail sprite to make it point to.
	REAL _y -> Relative Y coordinate of the tail sprite to make it point to.
	*/
	set_container_tail_position = function(_x, _y){
		//If the tail sprite exists, continue.
		if (!sprite_exists(container_tail_sprite)){
			return
		}
		
		//Set the position.
		container_x_origin = _x
		container_y_origin = _y
		container_original_origins = false
		
		//All these variables are not meant to be preserved as it is just temporary information used to get the correct position and angle of the tail, after that it is useless.
		var _container_x_origin_offset = container_x_origin - dialog_x_offset //The coordinates are made into local coordinates where the origin is the top left corner of the dialog bounding box itself and not the container's top left corner anymore so it calculates the position and angle of the tail.
		var _container_y_origin_offset = container_y_origin - dialog_y_offset
		var _tail_top_size = container_tail_y_origin*container_tail_height //These 2 variables determinate the size above and below the tail sprite using its original, it basically divides the sprite in 2, needed for the correct rotation of the tail.
		var _tail_bottom_size = (container_tail_height_pixels - container_tail_y_origin)*container_tail_height
		var _tail_alignment_top_left_x = _tail_top_size //These corner variables determinate the points where the tail should start rotating as its in a corner, but it takes the origin of the tail in account for that, to know the point the sprite is at the limit of exiting the dialog's bounding box.
		var _tail_alignment_top_left_y = _tail_bottom_size
		var _tail_alignment_top_right_x = dialog_width - _tail_bottom_size
		var _tail_alignment_top_right_y = _tail_top_size
		var _tail_alignment_bottom_right_x = dialog_width - _tail_top_size
		var _tail_alignment_bottom_right_y = dialog_height - _tail_bottom_size
		var _tail_alignment_bottom_left_x = _tail_bottom_size
		var _tail_alignment_bottom_left_y = dialog_height - _tail_top_size
		
		//The calculation of the angle and length of the tail is determined by its 9 possible sections it can be in the dialog container.
		//It's kind of a nine-slices but made to determinate what to do in each of the 9 sections of the sprite, the corners hold the most complex forms of calculating the rotation and size of the tail.
		if (_container_x_origin_offset < _tail_alignment_top_left_x and _container_y_origin_offset < _tail_alignment_top_left_y){
			//Top-left corner.
			var _dialog_corner_distance = point_distance(0, 0, _container_x_origin_offset, _container_y_origin_offset)
			var _dialog_corner_angle = point_direction(0, 0, _container_x_origin_offset, _container_y_origin_offset)
			container_tail_angle = get_container_tail_angle(_dialog_corner_distance, _dialog_corner_angle, 135) //They use a function to determinate the angle it should be the tail, it's a complicated formulate that took me and a friend of mine to determinate, you can replace it if you find a better one, it's not heavy in performance as you only call this function once to set the stuff and done.
			container_tail_width = point_distance(_tail_top_size*dsin(container_tail_angle), -_tail_bottom_size*dcos(container_tail_angle), _container_x_origin_offset, _container_y_origin_offset)/container_tail_width_pixels //With the angle known, get the size by making point_distance() calculation.
		}else if (_container_x_origin_offset > _tail_alignment_top_right_x and _container_y_origin_offset < _tail_alignment_top_right_y){
			//Top-right corner.
			var _dialog_corner_distance = point_distance(dialog_width, 0, _container_x_origin_offset, _container_y_origin_offset)
			var _dialog_corner_angle = point_direction(dialog_width, 0, _container_x_origin_offset, _container_y_origin_offset)
			container_tail_angle = get_container_tail_angle(_dialog_corner_distance, _dialog_corner_angle, 45)
			container_tail_width = point_distance(dialog_width - _tail_bottom_size*dsin(container_tail_angle), _tail_top_size*dcos(container_tail_angle), _container_x_origin_offset, _container_y_origin_offset)/container_tail_width_pixels
		}else if (_container_x_origin_offset > _tail_alignment_bottom_right_x and _container_y_origin_offset > _tail_alignment_bottom_right_y){
			//Bottom-right corner.
			var _dialog_corner_distance = point_distance(dialog_width, dialog_height, _container_x_origin_offset, _container_y_origin_offset)
			var _dialog_corner_angle = point_direction(dialog_width, dialog_height, _container_x_origin_offset, _container_y_origin_offset)
			container_tail_angle = get_container_tail_angle(_dialog_corner_distance, _dialog_corner_angle, 315)
			container_tail_width = point_distance(dialog_width + _tail_top_size*dsin(container_tail_angle), dialog_height - _tail_bottom_size*dcos(container_tail_angle), _container_x_origin_offset, _container_y_origin_offset)/container_tail_width_pixels
		}else if (_container_x_origin_offset < _tail_alignment_bottom_left_x and _container_y_origin_offset > _tail_alignment_bottom_left_y){
			//Bottom-left corner.
			var _dialog_corner_distance = point_distance(0, dialog_height, _container_x_origin_offset, _container_y_origin_offset)
			var _dialog_corner_angle = point_direction(0, dialog_height, _container_x_origin_offset, _container_y_origin_offset)
			container_tail_angle = get_container_tail_angle(_dialog_corner_distance, _dialog_corner_angle, 225)
			container_tail_width = point_distance(-_tail_bottom_size*dsin(container_tail_angle), dialog_height + _tail_top_size*dcos(container_tail_angle), _container_x_origin_offset, _container_y_origin_offset)/container_tail_width_pixels
		}else if (_container_y_origin_offset < 0){
			//Top side.
			container_tail_angle = 90 //For the sides is very simple, there's not much math involved in here, pretty straight forward.
			container_tail_width = -_container_y_origin_offset/container_tail_width_pixels
		}else if (_container_x_origin_offset > dialog_width){
			//Right side.
			container_tail_angle = 0
			container_tail_width = (_container_x_origin_offset - dialog_width)/container_tail_width_pixels
		}else if (_container_y_origin_offset > dialog_height){
			//Bottom side.
			container_tail_angle = 270
			container_tail_width = (_container_y_origin_offset - dialog_height)/container_tail_width_pixels
		}else if (_container_x_origin_offset < 0){
			//Left side.
			container_tail_angle = 180
			container_tail_width = -_container_x_origin_offset/container_tail_width_pixels
		}else{
			//Middle or center
			container_tail_width = 0 //For the center nothing is displayed, so set the size to 0.
		}
	}
	
	/*
	This functions lets you add dialogues to the dialogues already being displayed, adding them manually yourself is a bit of a long process, so use this function instead please or you may end up with errors.
	This function is also used for the dialog system to work, so be cautious when adding or modifying stuff in it, as this formats all the dialogues and gets all the needed information to make everything functional.
	
	ARRAY OF STRINGS / STRING _dialogues -> Dialogues that will be added to the list of dialogues to be displayed on screen, using the proper format for dialogues.
	*/
	add_dialogues = function(_dialogues){
		//Set the font that will be once all the dialogues have passed, even if the dialogues are not yet in that point, this variables holds the one that should be the last state of the font.
		draw_set_font(final_font)
		
		dialog_height = dialog_minimum_height //When dialogues are being added, this gets recalculated using dialog_heights stored previously, but it must at least be the minimum size of height.
		
		var _dialogues_amount = 1
		var _execute_initial_configuration = (dialogues_amount == 0) //If no dialogs are in currently, then it must execute the initial configuration.
		
		//Adds everything to the list depending of the type passed.
		if (typeof(_dialogues) == "string"){
			dialogues_amount++
			array_push(dialogues, _dialogues)
		}else{
			_dialogues_amount = array_length(_dialogues)
			dialogues_amount += _dialogues_amount
			
			for (var _i = 0; _i < _dialogues_amount; _i++){
				array_push(dialogues, _dialogues[_i])
			}
		}
		
		_execute_initial_configuration = (_execute_initial_configuration and dialogues_amount > 0)
		
		//This for cycle iterates all the new dialogues to fetch its command information and insert the line jumps in it.
		for (var _i = dialogues_amount - _dialogues_amount; _i < dialogues_amount; _i++){
			//Set variables for easier access to some information and containers too.
			var _dialog = dialogues[_i]
			var _dialog_length = string_length(_dialog) //Get the lenght of the dialog, it gets substracted as stuff is being removed.
			var _array_visual = [] //Saves only commands classified as visual for text rendering.
			var _array_action = [] //Saves only commands classified as action that change the way text is being displayed.
			var _current_dialog_lines = 1 //Counts the lines of text there are in the dialog, each line jump adds another line to the dialog which is counted.
			
			//----------------------------------------------------------------------------------------------------------------------------------------------------------------
			//COMMAND AND ESCAPE SEQUENCE PARSER
			//----------------------------------------------------------------------------------------------------------------------------------------------------------------
			//This for cycle removes any escape sequence on the string and all the commands from the dialog as well by sorting the commands in the action and visual arrays.
			
			for (var _j = 1; _j <= _dialog_length; _j++){
				//Here is the command handling, finds a [ then starts doing it, it will error if no ] is found, make sure to always close your commands and use the proper format.
				while (string_char_at(_dialog, _j) == "["){
					var _command_end_index = 0
					var _escape_sequence_indexes = []
					var _escape_sequence_amount = 0
					
					//This for cycle here, looks for a ] to close the command, however this also applies the escape sequence to the characters so it can skip potential ] that want to be used in a command instead of marking the end of the command.
					//It also saves the indexes where the escape sequence happened so those characters won't get treated normally by some commands, that way you can use commas in command without marking it as other arguments.
					for (var _k = _j + 1; _k <= _dialog_length; _k++){
						var _letter = string_char_at(_dialog, _k)
						
						if (_letter == "]"){
							_command_end_index = _k
							
							break
						//The escape sequence character is a / instead of \ because to get that on strings is \\.
						//This is mostly because if you want to put a \ in your commands you would have to double escape it \\\\ once for the actual string that contains it and another for the system here, so instead we use /, so that way you just do // to put the actual / in the command.
						}else if (_letter == "/"){
							_dialog = string_delete(_dialog, _k, 1)
							_dialog_length--
							
							array_push(_escape_sequence_indexes, _k - _j)
							_escape_sequence_amount++
						}
					}
					
					var _command_length = _command_end_index - _j + 1 //Get the command length, since the first character is not counted in the substraction, 1 is added always.
					_dialog_length -= _command_length
					
					//Start the information of the commands.
					var _command_content = string_split(string_copy(_dialog, _j + 1, _command_length - 2), ":", false, 1) //If no : is found, it gives an array of size 1, good to handle commands with no arguments.
					var _command_action = true //Flag for command being an action.
					var _command_data = {index: _j}
					
					//Delete the command from the dialog itself, as it won't be displayed on the game.
					_dialog = string_delete(_dialog, _j, _command_length)
					
					//Sort the type of command, fill the data of it and flag it properly as visual or action.
					switch (string_lower(_command_content[0])){
						case "wait": case "w":{
							_command_data.type = COMMAND_TYPE.WAIT
							_command_data.value = real(_command_content[1])
						break}
						case "text_speed": case "talk_speed":{
							_command_data.type = COMMAND_TYPE.SET_TEXT_SPEED
							_command_data.value = real(_command_content[1])
						break}
						case "sprite":{
							var _arguments = string_split(_command_content[1], ",")
							
							if (_arguments[0] == "none" or _arguments[0] == "undefined"){
								_arguments[0] = -1
							}else{
								var _spr = asset_get_index(_arguments[0])
								if (_spr != -1){
									_arguments[0] = _spr
								}else{
									_arguments[0] = int64(_arguments[0])
								}
							}
							
							if (_j > 1 and (!sprite_exists(final_face_sprite) or sprite_exists(_arguments[0]))){
								continue
							}
							
							_command_data.type = COMMAND_TYPE.SET_SPRITE
							_command_data.value = _arguments
							
							var _command_arguments_length = array_length(_arguments)
							for (var _k = 1; _k < _command_arguments_length; _k++){
								_arguments[_k] = int64(_arguments[_k])
							}
							
							if (_j == 1){
								final_face_x_offset = 0
								final_face_y_offset = 0
								final_face_height = 0
								
								if (sprite_exists(_arguments[0])){
									final_face_sprite = _arguments[0]
									final_text_align_x = ASTERISK_SPACING*final_asterisk
								
									if (sprite_exists(final_face_sprite)){
										final_face_height = sprite_get_height(final_face_sprite)
										final_text_align_x += sprite_get_width(final_face_sprite) + 10
									}
								}else{
									final_face_sprite = undefined
									final_text_align_x = ASTERISK_SPACING*final_asterisk
								}
							}
						break}
						case "sprite_subimages": case "subimages":{
							_command_data.type = COMMAND_TYPE.SET_SUBIMAGES
							_command_data.value = string_split(_command_content[1], ",")
							var _command_arguments_length = array_length(_command_data.value)
							
							for (var _k = 0; _k < _command_arguments_length; _k++){
								_command_data.value[_k] = int64(_command_data.value[_k])
							}
						break}
						case "bind_instance":{
							_command_data.type = COMMAND_TYPE.BIND_INSTANCE
							_command_data.value = string_split(_command_content[1], ",")
							var _inst = get_instance_reference(_command_data.value[0])
							if (is_undefined(_inst)){
								_inst = handle_parse(_command_data.value[0])
								if (!is_undefined(_inst) and _inst != -1 and _inst != noone){
									_command_data.inst = _inst
								}else{
									_command_data.inst = int64(_command_data.value[0])
								}
							}else{
								_command_data.inst = _inst
							}
							
							array_delete(_command_data.value, 0, 1)
							var _command_arguments_length = array_length(_command_data.value)
							
							if (_command_arguments_length > 0){
								for (var _k = 0; _k < _command_arguments_length; _k++){
									_command_data.value[_k] = int64(_command_data.value[_k])
								}
							}else{
								_command_data.value = undefined
							}
						break}
						case "pop_up":{ //The format is _mode, _x, _y, _dialog, _width, _face_sprite, _face_subimages
							var _arguments = string_split(_command_content[1], ",", false, 3)
							
							var _start_pos = 0
							var _end_pos = 0
							var _index = 0
							
							var _found_start = false
							var _found_end = false
							do{
								_start_pos = string_pos_ext("\"", _arguments[3], _index)
								if (_start_pos >= 2 and string_char_at(_arguments[3], _start_pos - 2) == "/"){
									_index = _start_pos + 1
								}else if (_start_pos == 0){
									break
								}else{
									_found_start = true
								}
							}until (_found_start)
							
							if (_found_start){
								_index = _start_pos + 1
								do{
									_end_pos = string_pos_ext("\"", _arguments[3], _index)
									if (_end_pos >= 2 and string_char_at(_arguments[3], _end_pos - 2) == "/"){
										_index = _end_pos + 1
									}else if (_end_pos == 0){
										break
									}else{
										_found_end = true
									}
								}until (_found_end)
							}
							
							if (!_found_end or !_found_start){
								show_error("There's an error in the following dialog:\n\"" + dialogues[_i] + "\"\n\nA [pop_up:mode,x,y,dialog,width,face_sprite,face_subimages] command has a syntax error.\nThe dialog parameter is not properly enclosed between \", check your syntax properly, it must be between \".\n\nExample:\n[pop_up:left,0,0,\"Dialog here\",160] (Extra parameters omitted)\n[pop_up:left,0,0,\"Dialog here\",160,spr_face,0,1]", true)
							}
							
							var _length = string_length(_arguments[3])
							var _arguments_copy = string_delete(_arguments[3], 1, _end_pos)
							_arguments[3] = string_copy(_arguments[3], _start_pos + 1, _end_pos - 2)
							
							var _cut_arguments = string_split(_arguments_copy, ",")
							array_delete(_cut_arguments, 0, 1)
							_length = array_length(_cut_arguments)
							
							for (var _k = 0; _k < _length; _k++){
								if (_k == 1){
									var _spr = asset_get_index(_cut_arguments[_k])
									if (_spr != -1){
										_cut_arguments[_k] = _spr
									}
								}
								
								array_push(_arguments, _cut_arguments[_k])
							}
							
							//After all _arguments are parsed correctly, it is time to get the constant for the mode.
							switch (string_lower(_arguments[0])){
								case "fade":{
									_arguments[0] = POP_UP_MODE.FADE
								break}
								case "fade_instant": case "fade instant":{
									_arguments[0] = POP_UP_MODE.INSTANT
								break}
								case "left":{
									_arguments[0] = POP_UP_MODE.LEFT
								break}
								case "right":{
									_arguments[0] = POP_UP_MODE.RIGHT
								break}
								case "up":{
									_arguments[0] = POP_UP_MODE.UP
								break}
								case "down":{
									_arguments[0] = POP_UP_MODE.DOWN
								break}
								case "left_instant": case "left instant":{
									_arguments[0] = POP_UP_MODE.LEFT_INSTANT
								break}
								case "right_instant": case "right instant":{
									_arguments[0] = POP_UP_MODE.RIGHT_INSTANT
								break}
								case "up_instant": case "up instant":{
									_arguments[0] = POP_UP_MODE.UP_INSTANT
								break}
								case "down_instant": case "down instant":{
									_arguments[0] = POP_UP_MODE.DOWN_INSTANT
								break}
								default:{
									_arguments[0] = POP_UP_MODE.NONE
								break}
							}
							
							_length = array_length(_arguments)
							_command_data.type = COMMAND_TYPE.SHOW_DIALOG_POP_UP
							_command_data.value = _arguments
							
							for (var _k = 1; _k < _length; _k++){
								if (_k == 3){
									continue
								}
								
								_arguments[_k] = int64(_arguments[_k])
							}
						break}
						case "animation_speed": case "anim_speed": case "sprite_speed":{
							_command_data.type = COMMAND_TYPE.SET_SPRITE_SPEED
							_command_data.value = real(_command_content[1])
						break}
						case "voice": case "voices":{ //Notice this command has a condition break.
							if (array_length(_command_content) > 1){ //If no arguments is provided to the voice command, it becomes an unmute command instead.
								_command_data.type = COMMAND_TYPE.SET_VOICE
								_command_data.value = string_split(_command_content[1], ",")
								var _command_arguments_length = array_length(_command_data.value)
							
								for (var _k = 0; _k < _command_arguments_length; _k++){
									var _snd = asset_get_index(_command_data.value[_k])
									if (_snd != -1){
										_command_data.value[_k] = _snd
									}else{
										_command_data.value[_k] = int64(_command_data.value[_k])
									}
								}
							
								break
							}
						}
						case "unmute":{
							_command_data.type = COMMAND_TYPE.VOICE_MUTING
							_command_data.value = true
						break}
						case "no_voice": case "no_voices": case "mute":{
							_command_data.type = COMMAND_TYPE.VOICE_MUTING
							_command_data.value = false
						break}
						case "play_sound":{
							_command_data.type = COMMAND_TYPE.PLAY_SOUND
							_command_data.value = int64(_command_content[1])
						break}
						case "color_rgb":{
							_command_data.type = COMMAND_TYPE.COLOR_RGB
							_command_data.value = string_split(_command_content[1], ",")
						
							for (var _k = 0; _k < 3; _k++){ //If 3 arguments at minimum are not given, this will error.
								_command_data.value[_k] = clamp(int64(_command_data.value[_k]), 0, 255)
							}
						
							_command_action = false //Flag command as visual
						break}
						case "color_hsv":{
							_command_data.type = COMMAND_TYPE.COLOR_HSV
							_command_data.value = string_split(_command_content[1], ",")
						
							for (var _k = 0; _k < 3; _k++){ //Same as rgb variant.
								_command_data.value[_k] = clamp(int64(_command_data.value[_k]), 0, 255)
							}
						
							_command_action = false //Flag command as visual
						break}
						case "effect":{
							_command_data.type = COMMAND_TYPE.TEXT_EFFECT
							var _command_arguments = string_split(_command_content[1], ",")
							
							switch (string_lower(_command_arguments[0])){
								case "zoom":{
									_command_data.subtype = EFFECT_TYPE.ZOOM
								break}
								case "slide":{
									_command_data.subtype = EFFECT_TYPE.SLIDE
									
									if (array_length(_command_arguments) > 1 and _command_arguments[1] != ""){
										_command_data.value = abs(real(_command_arguments[1]))
									}else{
										_command_data.value = 3
									}
									
									if (array_length(_command_arguments) > 2 and _command_arguments[2] != ""){
										_command_data.alpha = abs(real(_command_arguments[2]))
									}else{
										_command_data.alpha = 1
									}
								break}
								case "twitch":{
									_command_data.subtype = EFFECT_TYPE.TWITCH
									
									if (array_length(_command_arguments) > 1 and _command_arguments[1] != ""){
										_command_data.value = abs(real(_command_arguments[1]))
									}else{
										_command_data.value = 2
									}
								break}
								case "shake":{
									_command_data.subtype = EFFECT_TYPE.SHAKE
									
									if (array_length(_command_arguments) > 1 and _command_arguments[1] != ""){
										_command_data.value = abs(real(_command_arguments[1]))
									}else{
										_command_data.value = 1
									}
								break}
								case "oscillate":{
									_command_data.subtype = EFFECT_TYPE.OSCILLATE
									
									if (array_length(_command_arguments) > 1 and _command_arguments[1] != ""){
										_command_data.value = abs(real(_command_arguments[1]))
									}else{
										_command_data.value = 2
									}
								break}
								case "rainbow":{
									_command_data.subtype = EFFECT_TYPE.RAINBOW
									
									if (array_length(_command_arguments) > 1 and _command_arguments[1] != ""){
										_command_data.value = abs(real(_command_arguments[1]))
									}else{
										_command_data.value = 0
									}
								break}
								case "shadow":{
									var _length = array_length(_command_arguments)
									_command_data.subtype = EFFECT_TYPE.SHADOW
									
									_command_data.x = real(_command_arguments[1])
									_command_data.y = real(_command_arguments[2])
									
									//Color
									if (_length > 3 and _command_arguments[3] != ""){
										_command_data.value = int64(_command_arguments[3])
									}else{
										_command_data.value = c_dkgray
									}
									
									//Font
									if (_length > 4 and _command_arguments[4] != ""){
										_command_data.font = int64(_command_arguments[4])
									}else{
										_command_data.font = font
									}
									
									array_push(_array_action, _command_data) //This is the only command variant that goes in both the visual and action commands, insert in visual only and the action gets inserted below.
								break}
								case "malfunction":{
									var _length = array_length(_command_arguments)
									_command_data.subtype = EFFECT_TYPE.MALFUNCTION
									
									//Probability where 10000 is 100%, 100 is 1 %, 1 is 0.01%
									if (_length > 1 and _command_arguments[1] != ""){
										_command_data.value = 100*abs(real(_command_arguments[1])) //Argument is given from 0 to 100 decimals included.
									}else{
										_command_data.value = 5
									}
									
									//Variant of any letter.
									if (_length > 2 and _command_arguments[2] != ""){
										_command_data.any_letter = bool(_command_arguments[2])
									}else{
										_command_data.any_letter = false
									}
								break}
								default:{
									_command_data.subtype = EFFECT_TYPE.NONE
								break}
							}
							
							_command_action = false //Flag command as visual
						break}
						case "no_effect":{
							_command_data.type = COMMAND_TYPE.DISABLE_TEXT_EFFECT
							var _command_arguments = string_split(_command_content[1], ",")
							
							switch (string_lower(_command_arguments[0])){
								case "zoom":{
									_command_data.subtype = EFFECT_TYPE.ZOOM
								break}
								case "slide":{
									_command_data.subtype = EFFECT_TYPE.SLIDE
								break}
								case "twitch":{
									_command_data.subtype = EFFECT_TYPE.TWITCH
								break}
								case "shake":{
									_command_data.subtype = EFFECT_TYPE.SHAKE
								break}
								case "oscillate":{
									_command_data.subtype = EFFECT_TYPE.OSCILLATE
								break}
								case "rainbow":{
									_command_data.subtype = EFFECT_TYPE.RAINBOW
								break}
								case "shadow":{
									_command_data.subtype = EFFECT_TYPE.SHADOW
								break}
								case "malfunction":{
									_command_data.subtype = EFFECT_TYPE.MALFUNCTION
								break}
								default:{ //If none is specified or valid, just ignore the command
									continue
								}
							}
							
							_command_action = false //Flag command as visual
						break}
						case "next": case "continue": case "finish":{
							_command_data.type = COMMAND_TYPE.NEXT_DIALOG
						break}
						case "skip":{
							_command_data.type = COMMAND_TYPE.SKIP_DIALOG
							
							if (array_length(_command_content) > 1){
								_command_data.value = bool(_command_content[1])
							}else{
								_command_data.value = true
							}
						break}
						case "stop_skip":{
							_command_data.type = COMMAND_TYPE.STOP_SKIP
						break}
						case "wait_key_press": case "wait_key":{
							_command_data.type = COMMAND_TYPE.WAIT_KEY_PRESS
							_command_data.value = _command_content[1]
						break}
						case "wait_for": case "wait_function": case "wait_func":{
							_command_data.type = COMMAND_TYPE.WAIT_FOR
							var _arguments = string_split(_command_content[1], ",", false, 1)
							
							//If no function is given, do nothing.
							if (_arguments[0] == ""){
								continue
							}
							
							//Arguments of the function parsing.
							if (array_length(_arguments) > 1){
								var _temp_argument_1 = ""
								var _first = true
								var _new_arguments = []
								var _start_argument = 1
								var _argument_length = string_length(_arguments[1])
								var _index = 0
								var _escape_sequence_offset = string_length(_command_content[0]) + string_length(_arguments[0]) + 2
								
								//This for cycle along side the _escape_sequence_offset and _index variables check if the "," character must be counted as an end of argument or not inside the arguments via escape sequences.
								for (var _k = 1; _k <= _argument_length; _k++){
									//Moves the index in case the character being checked is now ahead of it.
									if (_index < _escape_sequence_amount and _escape_sequence_indexes[_index] < _k + _escape_sequence_offset){
										_index++
									}
									
									if (string_char_at(_arguments[1], _k) == ","){
										//Checks if it is a escape sequence character (if it had a / behind it before).
										if (_index < _escape_sequence_amount and _escape_sequence_indexes[_index] == _k + _escape_sequence_offset){
											continue
										}
										
										//If it's the first "," it finds, then save it temporally in a variable as it will be replaced in the first one later.
										if (_first){
											_temp_argument_1 = string_copy(_arguments[1], _start_argument, _k - 1)
											
											if (_temp_argument_1 == ""){
												_temp_argument_1 = undefined
											}
											
											_start_argument = _k + 1
											_first = false
										}else{
											//Otherwise, get it from the argument and add it into the arguments.
											var _cut_argument = string_copy(_arguments[1], _start_argument, _k - _start_argument)
											
											if (_cut_argument == ""){
												_cut_argument = undefined
											}
											
											_start_argument = _k + 1
											
											array_push(_arguments, _cut_argument)
										}
									}
								}
								
								//If at least one argument was found, then grab the rest and put it in the arguments as another one and replace the first argument with the one saved.
								if (!_first){
									var _cut_argument = string_copy(_arguments[1], _start_argument, _argument_length)
									
									if (_cut_argument == ""){
										_cut_argument = undefined
									}
									
									array_push(_arguments, _cut_argument)
									
									_arguments[1] = _temp_argument_1
								}
							}
							
							var _inst = get_instance_reference(_arguments[0])
							if (is_undefined(_inst)){
								var _parsed = handle_parse(_arguments[0])
								if (!is_undefined(_parsed) and _parsed != -1 and _parsed != noone and string_pos("instance", _arguments[0]) == 5){
									_command_data.value = variable_instance_get(_parsed, _arguments[1])
									array_delete(_arguments, 0, 2)
								}else{
									_command_data.value = _parsed
									array_delete(_arguments, 0, 1)
								}
							}else{
								_command_data.value = variable_instance_get(_inst, _arguments[1])
								array_delete(_arguments, 0, 2)
							}
							
							_command_data.arguments = _arguments
						break}
						case "skipless": case "no_skip":{
							_command_data.type = COMMAND_TYPE.SKIP_ENABLING
							_command_data.value = false
						break}
						case "skipeable": case "skippable":{
							_command_data.type = COMMAND_TYPE.SKIP_ENABLING
							_command_data.value = true
						break}
						case "progress_mode":{
							_command_data.type = COMMAND_TYPE.PROGRESS_MODE
						
							if (_command_content[1] == "input"){
								_command_data.value = true
							}else{
								_command_data.value = false
							}
						break}
						case "display_text":{
							_command_data.type = COMMAND_TYPE.DISPLAY_TEXT
							var _command_arguments = string_split(_command_content[1], ",")
							
							switch (string_lower(_command_arguments[0])){
								case "letters":{
									_command_data.subtype = DISPLAY_TEXT.LETTERS
								
									if (array_length(_command_arguments) > 1){
										_command_data.value = int64(_command_arguments[1])
									}else{
										_command_data.value = 1
									}
								break}
								case "words":{
									_command_data.subtype = DISPLAY_TEXT.WORDS
								
									if (array_length(_command_arguments) > 1){
										_command_data.value = int64(_command_arguments[1])
									}else{
										_command_data.value = 1
									}
								break}
								default:{ //If none match, do not insert the command.
									continue
								}
							}
						break}
						case "apply_to_asterisk":{ //Only save this command if it's in the beginning of the dialog.
							if (_command_data.index == 1){
								_command_data.type = COMMAND_TYPE.APPLY_TO_ASTERISK
							
								_command_action = false //Flag command as visual.
							}else{
								continue
							}
						break}
						case "func": case "function": case "method":{
							_command_data.type = COMMAND_TYPE.FUNCTION
							var _arguments = string_split(_command_content[1], ",", false, 1)
							
							//If no function is given, do nothing.
							if (_arguments[0] == ""){
								continue
							}
							
							//Arguments of the function parsing.
							if (array_length(_arguments) > 1){
								var _temp_argument_1 = ""
								var _first = true
								var _new_arguments = []
								var _start_argument = 1
								var _argument_length = string_length(_arguments[1])
								var _index = 0
								var _escape_sequence_offset = string_length(_command_content[0]) + string_length(_arguments[0]) + 2
								
								//This for cycle along side the _escape_sequence_offset and _index variables check if the "," character must be counted as an end of argument or not inside the arguments via escape sequences.
								for (var _k = 1; _k <= _argument_length; _k++){
									//Moves the index in case the character being checked is now ahead of it.
									if (_index < _escape_sequence_amount and _escape_sequence_indexes[_index] < _k + _escape_sequence_offset){
										_index++
									}
									
									if (string_char_at(_arguments[1], _k) == ","){
										//Checks if it is a escape sequence character (if it had a / behind it before).
										if (_index < _escape_sequence_amount and _escape_sequence_indexes[_index] == _k + _escape_sequence_offset){
											continue
										}
										
										//If it's the first "," it finds, then save it temporally in a variable as it will be replaced in the first one later.
										if (_first){
											_temp_argument_1 = string_copy(_arguments[1], _start_argument, _k - 1)
											
											if (_temp_argument_1 == ""){
												_temp_argument_1 = undefined
											}
											
											_start_argument = _k + 1
											_first = false
										}else{
											//Otherwise, get it from the argument and add it into the arguments.
											var _cut_argument = string_copy(_arguments[1], _start_argument, _k - _start_argument)
											
											if (_cut_argument == ""){
												_cut_argument = undefined
											}
											
											_start_argument = _k + 1
											
											array_push(_arguments, _cut_argument)
										}
									}
								}
								
								//If at least one argument was found, then grab the rest and put it in the arguments as another one and replace the first argument with the one saved.
								if (!_first){
									var _cut_argument = string_copy(_arguments[1], _start_argument, _argument_length)
									
									if (_cut_argument == ""){
										_cut_argument = undefined
									}
									
									array_push(_arguments, _cut_argument)
									
									_arguments[1] = _temp_argument_1
								}
							}
							
							var _inst = get_instance_reference(_arguments[0])
							if (is_undefined(_inst)){
								var _parsed = handle_parse(_arguments[0])
								if (!is_undefined(_parsed) and _parsed != -1 and _parsed != -4 and string_pos("instance", _arguments[0]) == 5){
									_command_data.value = variable_instance_get(_parsed, _arguments[1])
									array_delete(_arguments, 0, 2)
								}else{
									_command_data.value = _parsed
									array_delete(_arguments, 0, 1)
								}
							}else{
								_command_data.value = variable_instance_get(_inst, _arguments[1])
								array_delete(_arguments, 0, 2)
							}
							
							_command_data.arguments = _arguments
						break}
						case "asterisk":{
							var _command_value = bool(_command_content[1])
						
							if (_j == 1 and _command_value != final_asterisk){
								final_asterisk = _command_value
							
								_command_data.type = COMMAND_TYPE.SET_ASTERISK
								_command_data.value = _command_value
							
								final_text_align_x += ASTERISK_SPACING*(2*_command_value - 1)
							}else{
								continue
							}
						break}
						case "font":{
							var _command_arguments = string_split(_command_content[1], ",")
							var _fnt = asset_get_index(_command_arguments[0])
							if (_fnt != -1){
								_command_arguments[0] = _fnt
							}else{
								_command_arguments[0] = int64(_command_arguments[0])
							}
						
							if (_j == 1 and _command_arguments[0] != final_font){
								final_font = _command_arguments[0]
							
								_command_data.type = COMMAND_TYPE.SET_FONT
								_command_data.value = final_font
								
								if (array_length(_command_arguments) > 1){
									_command_data.bool = bool(_command_arguments[1])
								}else{
									_command_data.bool = true
								}
							
								draw_set_font(final_font)
							}else{
								continue
							}
						break}
						case "spacing_width": case "width_spacing":{
							if (_j == 1){
								final_spacing_width = real(_command_content[1])
							
								_command_data.type = COMMAND_TYPE.SET_WIDTH_SPACING
								_command_data.value = final_spacing_width
							}else{
								continue
							}
						break}
						case "spacing_height": case "height_spacing":{
							if (_j == 1){
								final_spacing_height = real(_command_content[1])
							
								_command_data.type = COMMAND_TYPE.SET_HEIGHT_SPACING
								_command_data.value = final_spacing_height
							}else{
								continue
							}
						break}
						case "sprite_x_offset": case "sprite_width_offset":{
							if (_j == 1 and sprite_exists(final_face_sprite)){
								_command_data.type = COMMAND_TYPE.SET_SPRITE_X_OFFSET
								_command_data.value = real(_command_content[1])
								
								final_face_x_offset = _command_data.value
							}else{
								continue
							}
						break}
						case "sprite_y_offset": case "sprite_height_offset":{
							if (_j == 1 and sprite_exists(final_face_sprite)){
								_command_data.type = COMMAND_TYPE.SET_SPRITE_Y_OFFSET
								_command_data.value = real(_command_content[1])
							
								final_face_y_offset = _command_data.value
							}else{
								continue
							}
						break}
						case "container":{
							_command_data.type = COMMAND_TYPE.SET_CONTAINER
							_command_data.value = int64(_command_content[1])
						break}
						case "tail":{
							var _arguments = string_split(_command_content[1], ",")
							var _length = array_length(_arguments)
						
							_arguments[0] = int64(_arguments[0])
							_command_data.type = COMMAND_TYPE.SET_CONTAINER_TAIL
							_command_data.value = _arguments
						
							for (var _k = 1; _k < _length; _k++){
								_arguments[_k] = real(_arguments[_k])
							}
						break}
						case "tail_mask":{
							_command_data.type = COMMAND_TYPE.SET_CONTAINER_TAIL_MASK
							_command_data.value = int64(_command_content[1])
						break}
						case "tail_draw_mode":{
							_command_data.type = COMMAND_TYPE.SET_CONTAINER_TAIL_DRAW_MODE
							_command_data.value = int64(_command_content[1])
						break}
						case "tail_position":{
							_command_data.type = COMMAND_TYPE.SET_CONTAINER_TAIL_POSITION
							_command_data.value = string_split(_command_content[1], ",")
						
							_command_data.value[0] = int64(_command_data.value[0])
							_command_data.value[1] = int64(_command_data.value[1])
						break}
						default:{
							continue
						}
					}
					
					//Puts the command in the proper array according to its type which has been flaged by the variable _command_action.
					if (_command_action){
						array_push(_array_action, _command_data)
					}else{
						array_push(_array_visual, _command_data)
					}
				}
				
				//Once all commands have been cleared out in an index, it checks the character that left.
				//Looks for any / in the string and deletes it, ignoring the character that is next to it, useful for marking "[" as not a command so it prints it.
				if (string_char_at(_dialog, _j) == "/"){
					_dialog = string_delete(_dialog, _j, 1)
					_dialog_length--
				}
			}
			
			//Once all commands have been removed from the dialog and stored their information on the arrays, put them in the variables of commands in order so they match the dialog position on its array as well.
			array_push(action_commands, _array_action)
			array_push(visual_commands, _array_visual)
			
			//----------------------------------------------------------------------------------------------------------------------------------------------------------------
			//AUTO LINE JUMP ALGORITHM
			//----------------------------------------------------------------------------------------------------------------------------------------------------------------
			//From here starts the auto line jump algorithm for the dialog, that is why the width of the dialog is asked.
			
			var _word_ender_chars_array = [" ", "\n", "\r", "-", "/", "\\", "|"] //Characters that are marked as word enders, usually all words end in one of these at least.
			var _length = 7 //length of the _word_ender_chars_array, always is 7.
			var _current_action_commands_array = action_commands[_i] //During the process of the automatic line jump, some line jumps are inserted, making it increase by 1 and offsetting the commands's indexes.
			var _current_action_commands_length = array_length(_current_action_commands_array)
			var _current_visual_commands_array = visual_commands[_i] //These variables are to keep a short reference to the commands of the current dialog and their length, if needed when inserting line jumps.
			var _current_visual_commands_length = array_length(_current_visual_commands_array)
			
			//Indexes for searching and checking the word ender characters in the dialog.
			var _search_index = 0 //This one stores the index from where it starts searching in the dialog, it changes all the time so it doesn't repeteadly find the same character.
			var _last_newline_index = 0 //This one stores the most recent index where a line jump has been performed so it avoids unnecesarry calculation.
			var _check_index = 0 //This one stores the index it found a word ender character and is checked to determinate if it exceeds the width limit by the size of the letters at that point and perform a line jump in the dialog.
			var _last_check_index = 0 //This one stores the last index _check_index had before calculating the new one, whatever index this one holds is where the line jump is placed if it has to perform a line jump in the dialog.
			
			//While cycle that goes through all the dialog seeing if all words fit in the width provided and performs line jumps if needed to fit the text horizontally, but not vertically (have that in mind, your dialogs may end up with multiple lines if it's too long for the width limit given, read the user documentation for more information).
			while (_length > 0){
				var _j = 0
				
				_last_check_index = _check_index //Saves the last value _check_index had.
				while (_j < _length){ //While there are still word enders characters in the array, keep searching, once it doesn't find any, they get removed and eventually decrease _length.
					var _char_index = string_pos_ext(_word_ender_chars_array[_j], _dialog, _search_index)
					
					if (_char_index == 0){ //If character not found.
						array_delete(_word_ender_chars_array, _j, 1)
						_length -= 1 //Remove from the array and go again.
						
						if (_length == 0){ //If no more word enders are found, it checks now the very end of the string starting from the last line jump to measure its width.
							_check_index = _dialog_length + 1 //It may not be a word ender that last position, but it doesn't matter as _check_index is not the index where the line jump is being done, but the previous one it had.
						}
						
						continue
					}
					
					if (_j == 0){ //If it's the first iteration, which is the very first value the _word_ender_chars_array has, then set the _check_index.
						_check_index = _char_index
					}else{ //Otherwise, just get the minimum index of any other found.
						_check_index = min(_char_index, _check_index)
					}
					
					_j++
				}
				
				//In this part the _last_check_index must hold a previous index found by _check_index (which is a number above 0).
				//This means, the first time a word ender is found by _check_index, nothing is done other than keep the index so it gets set on _last_check_index (you can't jump a line with just 1 word, yes you can "wo\nrd", but that's 2 words not 1).
				if (_last_check_index > 0){
					var _last_char = string_char_at(_dialog, _last_check_index)
					
					//If the char the index in _last_check_index is a line jump, set the _last_newline_index on that index + 1, a manual line jump has been done, so start calculating the width from there instead.
					if (_last_char == "\n" or _last_char == "\r"){
						_last_newline_index = _last_check_index + 1
						_current_dialog_lines++
					}else{ //Otherwise, check if it exceeds the width limit.
						var _char_amount = _check_index - _last_newline_index //Calculates how many chars are between the last line jump and the index where a word ender char has been found.
						var _is_a_space = (string_char_at(_dialog, _last_check_index) == " ")
						
						//If the last index where a word ender is found it's a space, it replaces that space for a line jump, doesn't add it in between.
						if (!_is_a_space){
							_char_amount++ //If the character is not a space (and also cannot be a line jump \n or \r due to the previous condition of course), take it into account for the width size calculation.
						}
						
						var _string = string_replace_all(string_copy(_dialog, _last_newline_index, _char_amount), " ", "O") //Get the string that represents the current line.
						if (dialog_width - max(final_text_align_x + final_face_x_offset, ASTERISK_SPACING*final_asterisk) < string_width(_string) + final_spacing_width*(string_length(_string) - 1)){ //For each character in the string - 1, add the width spacing of all of them that was given as _spacing_width between the letters besides the width size of the whole line for the calculation of width limit.
							//This section is only entered when a line jump is needed to be performed.
							var _insert_index = _last_check_index + 1 //This index is 1 ahead of the index where a line jump would be placed if it's a space, and it's where it would be placed if it wasn't a space instead, take it as an auxiliar to same a simple addition calculation.
							
							if (_is_a_space){ //If the word ender found previously with _last_check_index is a space, replace it with a line jump.
								_dialog = string_copy(_dialog, 0, _last_check_index - 1) + "\r" + string_copy(_dialog, _insert_index, string_length(_dialog))
							}else{ //Otherwise add it in between the letters.
								_dialog = string_insert("\r", _dialog, _insert_index)
								_dialog_length++
								_check_index++ //Since a line jump is being added in the previous check index, and the current check index is ahead of it, it will be off by 1, so fix it by adding 1.
								
								//Adding something in between makes all indexes of the commands ahead of it off by 1 as well, these two for cycle fix that.
								for (_j = 0; _j < _current_action_commands_length; _j++){
									var _current_action_command = _current_action_commands_array[_j]
								
									//Any command index that is ahead of the point a line jump was inserted, will increase its index by 1, otherwise stay the same.
									if (_current_action_command.index > _insert_index){
										_current_action_command.index++
									}
								}
								
								for (_j = 0; _j < _current_visual_commands_length; _j++){
									var _current_visual_command = _current_visual_commands_array[_j]
								
									//Any command index that is ahead of the point a line jump was inserted, will increase its index by 1, otherwise stay the same.
									if (_current_visual_command.index > _insert_index){
										_current_visual_command.index++
									}
								}
							}
							
							//Set the start of the new line by setting the index of start of the new line.
							_last_newline_index = _last_check_index + 1
							_current_dialog_lines++
						}
					}
				} //After a line jump as been performed or not, set the index position to look ahead for more word ender characters.
				_search_index = _check_index + 1
			}
			
			//After all the commands have been removed from the dialog and inserted on arrays for their easy management.
			//And automatic line jumps have been inserted or replaced in the dialog, replace the dialog in the array of dialogs and repeat for the other dialogs.
			dialogues[_i] = _dialog
			
			var _current_dialog_height = 0
			
			if (sprite_exists(final_face_sprite)){
				_current_dialog_height = max((string_height("Ag'") + final_spacing_height)*_current_dialog_lines - final_spacing_height - min(final_face_y_offset, 0), final_face_height + max(final_face_y_offset, 0))
			}else{
				_current_dialog_height = (string_height("Ag'") + final_spacing_height)*_current_dialog_lines - final_spacing_height
			}
			
			array_push(dialog_heights, _current_dialog_height)
		}
		
		//Get the maximum height of the dialog to display and set it to the dialog_height, new dialogues may be longer, so it is needed to recalculate indeed.
		for (var _i = 0; _i < dialogues_amount; _i++){
			dialog_height = max(dialog_heights[_i], dialog_height)
		}
		
		//Since the dialog_height is recalculated, maybe it's different size, so the container sprite's size must be updated and the tail sprite too alongside its position too.
		update_container_sprite()
		update_container_tail_sprite()
		update_container_tail_mask_sprite()
		set_container_tail_position(container_x_origin, container_y_origin)
		
		if (_execute_initial_configuration){
			//------------------------------------------------------------------------------------------------------------------------------------------------------------
			//CURRENT DATA VARIABLES
			//------------------------------------------------------------------------------------------------------------------------------------------------------------
			//Variables that get the current information of the current dialog to display it on screen properly.
			
			draw_set_font(font)
			variable_reset()
			line_jump_height = string_height("Ag'") + spacing_height
			
			if (execute_action_commands() == 0){
				text_timer = 1
			}
		}
	}
	
	/*
	This functions calls the add_dialogues(), the difference is that this one deletes all the current dialogues that are loaded and sets the new ones you load in it, making a good reset with new dialogues.
	This functions is not used by the main code or any commands, so you can modify it as you want, be sure to know what you're doing when modifying the dialog system information, it is meant for you the programmer to be used in code in case you need it.
	
	The original code in this makes it so all information of the old dialogues is cleared and handles the new dialogues with the settings the dialog was in the moment this function was called, except the asterisk, that one gets reset again to true.
	This means that if you set a [font] through a dialogue and this function is being called before that font is being set in the dialogue, it will keep the previous font instead of the new one, and that info is used to shape the new dialogues.
	So be careful of when you call this function if you depend on the previous configuration of the dialogues, one way to avoid this is to set your new dialogues with that in mind and reset the settings to not depend on that.
	The only exception to this is the portrait sprite in the dialog, as that one will be reset/removed when calling this function, you can set the starting one by passing the arguments of it of course.
	In short, nothing is being reset or removed with this function, except the portrait sprite, the asterisk configuration and the instance that may be binded is unbinded, have that in mind when using it.
	
	ARRAY OF STRINGS / STRING _dialogues --------> Dialogues that will be added to the list of dialogues to be displayed on screen, using the proper format for dialogues.
	INTEGER _width ------------------------------> Sets a new width for the dialog itself, since all dialogs are cleared, this is helpful to resize the box and new dialog will be affected by the new value.
	INTEGER _face_sprite ------------------------> ID of the new sprite to use as portrait sprite, if it's not a valid sprite, then the new dialog won't contain a portrait sprite.
	ARRAY OF INTEGERS / INTEGER _face_subimages -> ID or IDS of the subimages of the portrait sprite to use for the animation of the sprite, if none are given, it will use all the subimages of the sprite for it.
	*/
	set_dialogues = function(_dialogues, _width=undefined, _height=undefined, _face_sprite=undefined, _face_subimages=undefined){
		//Delete all dialogs and dialog heights.
		if (dialogues_amount){ //It's never negative, 0 is False
			array_delete(dialogues, 0, dialogues_amount)
			array_delete(dialog_heights, 0, dialogues_amount)
			array_delete(action_commands, 0, dialogues_amount)
			array_delete(visual_commands, 0, dialogues_amount)
		}
		dialogues_amount = 0
		
		//If an instance is binded, unbinds it.
		if (!is_undefined(instance_index)){
			if (instance_exists(instance_index)){
				instance_index.image_index = instance_image_prev_index
			}
			instance_index = undefined
		}
		
		//Set the new width if it's defined and it's a positive number.
		if (!is_undefined(_width)){
			dialog_width = max(_width, 1)
		}
		
		//Set the new minimum height as well, which can only be a positive number.
		if (!is_undefined(_height)){
			dialog_minimum_height = max(_height, 0)
		}else{
			dialog_minimum_height = 0
		}
		
		//Reset the text_align_x and the final_face_height to recalculate them again with the new assigned face_sprite from this function, which gets reset of course and reset other stuff too.
		asterisk = true
		font = fnt_determination_mono
		use_font_space = true
		spacing_width = 0
		spacing_height = 2
		text_align_x = ASTERISK_SPACING
		final_face_height = 0
		face_sprite = _face_sprite
		face_subimages_cycle = _face_subimages
		face_subimages_length = 0
		face_x_offset = 0
		face_y_offset = 0
		
		//Set the info of the new face sprite properly.
		if (sprite_exists(face_sprite)){
			final_face_height = sprite_get_height(face_sprite)
			text_align_x += sprite_get_width(face_sprite) + 10
			
			//If no subimages are given, it uses all of the subimages of the sprite for the speaking animation.
			if (!is_undefined(face_subimages_cycle)){
				if (typeof(face_subimages_cycle) == "number"){
					face_index = face_subimages_cycle
					face_subimages_length = 1
				}else{
					face_subimages_length = array_length(face_subimages_cycle)
				}
			}else{
				face_subimages_length = sprite_get_number(face_sprite)
			}
		}
		
		//Load the final variables data with the current state of the dialogues.
		final_asterisk = asterisk
		final_font = font
		final_spacing_width = spacing_width
		final_spacing_height = spacing_height
		final_face_sprite = face_sprite
		final_face_x_offset = face_x_offset
		final_face_y_offset = face_y_offset
		final_text_align_x = text_align_x
		
		//add the dialogues in the empty dialogues.
		add_dialogues(_dialogues)
	}
	
	/*
	This functions changes the scale of the dialog itself as a whole, you could do this yourself putting it on a surface which also lets you control its alpha (something this system cannot do, check the programmer documentation for more information on that).
	If you only need scaling the whole dialog, you can with this function to avoid you the trouble of surfaces, if you need alpha with this, then you will have to rely on surfaces, sorry.
	
	If there are dialog pop-ups displaying the moment this function gets called, those ones will also be scaled by half of the new scales to be in the correct size, have that in mind.
	
	REAL _x -> Proportion to scale the dialog horizontally.
	REAL _y -> Proportion to scale the dialog vertically.
	*/
	set_scale = function(_x, _y){
		xscale = _x
		yscale = _y
		
		for (var _i = 0; _i < dialog_pop_ups_amount; _i++){
			dialog_pop_ups[_i].scale(xscale/2, yscale/2)
		}
	}
	
	/*
	These 2 functions set the position of the dialog itself.
	
	REAL _x -> Position X to move the dialog to.
	REAL _y -> Position Y to move the dialog to.
	*/
	move_to = function(_x, _y){
		x = _x
		y = _y
	}
	set_position = move_to
	
	/*
	This function moves the dialog X and Y pixels from its current position.
	
	REAL _x -> Amount in X to move the dialog to.
	REAL _y -> Amount in Y to move the dialog to.
	*/
	move = function(_x, _y){
		x += _x
		y += _y
	}
	
	/*
	This function returns the width in pixels the current dialog takes with the dialog portrait if it's available, not taking into account containers, dialog_width variable, just what the text takes in space alongside the portrait sprite.
	Takes into account the xscale factor of the dialog and the asterisk width if it's active.
	
	BOOLEAN _currently_displaying -> If set to true, it will return the current width of the text being displayed with the dialog portrait width included, by default is false, which returns the width of the whole text even if it hasn't shown all of it yet with the dialog portrait width included.
	
	RETURN -> REAL -- Width in pixels of the current dialog either by the amount currently displaying or all of it even if it's not displayed yet fully, with the dialog portrait width and the asterisk width included.
	*/
	get_current_text_width = function(_currently_displaying=false){
		draw_set_font(font)
		
		var _dialog = dialog
		
		if (_currently_displaying and string_index < dialog_length){
			_dialog = string_copy(dialog, 0, max(string_index, 0))
		}
		
		_dialog = string_replace_all(_dialog, "\r", "\n")
		var _dialog_array = string_split(_dialog, "\n")
		var _dialogues_amount = array_length(_dialog_array)
		var _maximum_dialog_width = 0
		var _space_width = ((use_font_space) ? string_width(" ") : string_width("O"))
		
		for (var _i = 0; _i < _dialogues_amount; _i++){
			var _dialog_width = -_space_width + max(text_align_x + face_x_offset, ASTERISK_SPACING*asterisk)
			var _dialog_without_spaces = string_split(_dialog_array[_i], " ")
			var _dialog_without_spaces_amount = array_length(_dialog_without_spaces)
			
			for (var _j = 0; _j < _dialog_without_spaces_amount; _j++){
				_dialog_width += string_width(_dialog_without_spaces[_j]) + _space_width
			}
			
			_dialog_width += spacing_width*string_length(_dialog_array[_i])
			_dialog_width *= xscale
			
			_maximum_dialog_width = max(_dialog_width, _maximum_dialog_width)
		}
		
		return _maximum_dialog_width
	}
	
	/*
	This function returns the height in pixels the current dialog takes with the dialog portrait if it's available, not taking into account containers, dialog_height variable, just what the text takes in space alongside the portrait sprite.
	Takes into account the yscale factor of the dialog.
	
	BOOLEAN _currently_displaying -> If set to true, it will return the current height of the text being displayed with the dialog portrait height included, by default is false, which returns the height of the whole text even if it hasn't shown all of it yet with the dialog portrait height included.
	
	RETURN -> REAL -- Height in pixels of the current dialog either by the amount currently displaying or all of it even if it's not displayed yet fully, with the dialog portrait height included.
	*/
	get_current_text_height = function(_currently_displaying=false){
		draw_set_font(font)
		
		var _dialog = dialog
		
		if (_currently_displaying and string_index < dialog_length){
			_dialog = string_copy(dialog, 0, max(string_index, 0))
		}
		
		_dialog = string_replace_all(_dialog, "\r", "\n")
		var _dialog_array = string_split(_dialog, "\n")
		var _dialogues_amount = array_length(_dialog_array)
		var _maximum_dialog_height = string_height(_dialog_array[_dialogues_amount - 1]) + (line_jump_height + spacing_height)*string_count(_dialog, "\n")
		
		return _maximum_dialog_height
	}
	
	/*
	This function returns the number of line jumps that the current dialog has in it.
	This includes line jumps that have been performed manually and that the dialog system has automatically placed in the dialog.
	
	BOOLEAN _currently_displaying -> If set to true, it will return the current number of line jumps of the text being displayed, by default is false, which returns the number of line jumps of the whole text even if it hasn't shown all of it yet.
	
	RETURN -> INTEGER -- Number of line jumps the current dialog has either by the amount currently displaying or all of it even if it's not displayed yet fully.
	*/
	get_current_text_line_jumps = function(_currently_displaying=false){
		var _dialog = dialog
		if (_currently_displaying){
			_dialog = string_copy(dialog, 0, max(string_index, 0))
		}
		
		return string_count("\n", string_replace_all(_dialog, "\r", "\n"))
	}
	
	/*
	With this function you can get the width of the whole dialog itself taking into account if it has a container sprite assigned.
	However this doesn't account for the tail size and rotation, get_tail_width() and get_tail_height() does that for you to use in case you need it for getting the whole dialog inside a surface.
	
	RETURNS -> REAL --Width in pixels of the whole dialog (container included if it's assigned, container's tail excluded).
	*/
	get_width = function(){
		if (sprite_exists(container_sprite)){
			return container_width*container_sprite_width*xscale
		}else{
			return dialog_width*xscale
		}
	}
	
	/*
	With this function you can get the height of the whole dialog itself taking into account if it has a container sprite assigned.
	However this doesn't account for the tail size and rotation, get_tail_width() and get_tail_height() does that for you to use in case you need it for getting the whole dialog inside a surface.
	
	RETURNS -> REAL --Height in pixels of the whole dialog (container included if it's assigned, container's tail excluded).
	*/
	get_height = function(){
		if (sprite_exists(container_sprite)){
			return container_height*container_sprite_height*yscale
		}else{
			return dialog_height*yscale
		}
	}
	
	/*
	With this function you can get the extra width the dialog extends to with the tail.
	This function only returns the extra width the tail ocuppies and not included with the whole dialog so you can offset the dialog inside the surface properly.
	It returns a negative number if the extra width it's from the left side and a positive if it's from the right side, taking also into account the container sprite's size as it not always extends a part when that's present.
	
	RETURNS -> REAL --Positive if it's from the right side, Negative if it's from the left side.
	*/
	get_tail_width = function(){
		if (sprite_exists(container_tail_sprite) and !is_undefined(container_x_offset) and !is_undefined(container_y_offset)){
			var _size = container_tail_width*container_tail_sprite_width*dcos(container_tail_angle)
			
			if (sprite_exists(container_tail_sprite)){
				//If the container is set, substract the side it's the tail in, once it overpasses that it does gives numbers different from 0.
				if (container_tail_angle < 90 or container_tail_angle > 270){
					return max(_size*xscale - container_sprite_width + container_right_collision, 0)
				}else{
					return min(_size*xscale + dialog_x_offset, 0)
				}
			}else{
				return _size*xscale
			}
		}else{
			return 0
		}
	}
	
	/*
	With this function you can get the extra height the dialog extends to with the tail.
	This function only returns the extra height the tail ocuppies and not included with the whole dialog so you can offset the dialog inside the surface properly.
	It returns a negative number if the extra width it's from the up side and a positive if it's from the down side, taking also into account the container sprite's size as it not always extends a part when that's present.
	
	RETURNS -> REAL --Positive if it's from the down side, Negative if it's from the up side.
	*/
	get_tail_height = function(){
		if (sprite_exists(container_tail_sprite) and !is_undefined(container_x_offset) and !is_undefined(container_y_offset)){
			var _size = container_tail_width*container_tail_sprite_width*dsin(-container_tail_angle)
			
			if (sprite_exists(container_tail_sprite)){
				//If the container is set, substract the side it's the tail in, once it overpasses that it does gives numbers different from 0.
				if (container_tail_angle > 180){
					return max(_size*yscale - container_sprite_height + container_bottom_collision, 0)
				}else{
					return min(_size*yscale + dialog_y_offset, 0)
				}
			}else{
				return _size*yscale
			}
		}else{
			return 0
		}
	}
	
	/*
	As the name implies, is a check for the user to know if the dialog has finished.
	
	RETURNS -> BOOLEAN --True if no more dialogues are loaded, false otherwise, the dialog system doesn't destroy itself once the dialog is done, you can reuse it to load more dialogs into it.
	*/
	is_finished = function(){
		return (dialogues_amount == 0)
	}
	
	/*
	This function can be used for you to make your characters in overworld move and perform a talking animation, make specific animations when the dialog is "talking", etc.
	The posibilities are endless, it's up to you if you want to use it, there's already a way to bind just 1 single sprite and make it talk as the dialog progresses until it's done printing more letters using the [bind_instance], doesn't work for layer_sprites sadly.
	It's affected by the wait commands, will return false when a [w] has run and is waiting for its time to run out to continue "talking".
	
	RETURNS -> BOOLEAN --True if the text is advacing normally, which means it is talking, false if a stop is made, either by any of the [wait] commands and its variants or other commands that can do that.
	*/
	is_talking = function(){
		return (face_animation and !is_done_displaying())
	}
	
	/*
	This function can be used for checking if the dialog is done displaying the current text.
	
	RETURNS -> BOOLEAN --True if the text has been displayed fully, which means there's no more text to display on the current dialog, false if the current dialog has not been displayed fully yet.
	*/
	is_done_displaying = function(){
		return (string_index >= dialog_length)
	}
	
	//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	//NOT CALLABLE FUNCTIONS
	//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	//These functions are NOT mean to be called withing your code, only by the system I shaped, check the programmer documentation for details on all this functions in case you're planning to modify or remove any of them, as you can end up breaking the entire system if you do something incorrectly.
	//Unless you know what you're doing, do not call these functions in your code or attempt to modify them in any way as you may end up messing the system leading to unexpected results or with errors.
	
	/*
	This is a function that is used to bind an instance to the dialog so it animates the sprite as the dialog bubble is speaking.
	Have in mind that if you change the sprite_index of the instance while binded to the dialog, if it's not the same subimages size, it might result in undesirable results.
	Once the instance gets unbinded, it will reset to the previous image_index it had when this function was called with the instance provided.
	
	INTEGER / INSTANCE REF / OBJECT REF _inst -> ID or REF of the instance or object to bind the dialog with for the animation of it, have in mind that if you bind an object, you will end up animating all instances of the object, good for group animating.
	ARRAY OF INTEGERS _indexes ----------------> ID or IDS of the subimages to use for the animating of the instance or object.
	*/
	bind_instance = function(_inst, _indexes=undefined){
		//Keep the binding of the instance in a variable.
		if (!is_undefined(instance_index)){
			instance_index.image_index = instance_image_prev_index
		}
		
		instance_index = _inst
		
		if (!is_undefined(instance_index)){
			instance_image_prev_index = _inst.image_index //Save the previous index of it, to go back to it once the dialog is done.
		
			//If indexes are not defined, it takes all subimages from its current assigned sprite_index.
			if (is_undefined(_indexes)){
				instance_image_index = 0
				instance_image_cycle = undefined
				instance_image_length = sprite_get_number(_inst.sprite_index)
				_inst.image_index = 0
			}else if (array_length(_indexes) == 1){ //If only one index is given, then change to that index and the animation will never change from that one, once the dialog is done it will return to the previous one it had before this functions was executed, a nice temporal index change.
				instance_image_index = _indexes[0]
				instance_image_length = 1
				_inst.image_index = instance_image_index
			}else{ //This space is only if multiple indexes have been given, save all of them and will do an iteration for them.
				instance_image_index = 0
				instance_image_cycle = _indexes
				instance_image_length = array_length(_indexes)
				_inst.image_index = instance_image_cycle[instance_image_index]
			}
		}
	}
	
	/*
	This is a special step function that controls only the portrait sprite and instance binded sprite animation of the dialog if there's any of those, since there are more than 1 place that needs to execute the same logic, it is a separate function (only 2 places in the step function XD).
	*/
	animation_step = function(){
		//First it checks for the sprite, if the sprite exists and has more than 1 subimage assigned for use, then continue.
		if (sprite_exists(face_sprite) and face_subimages_length > 1){
			//This condition prevents the animation from running when a [wait] command has been executed, so it looks like it's actually talking.
			if (((string_index < dialog_length and is_undefined(wait_for_key) and is_undefined(wait_for_function)) and face_animation or face_index > 0) and string_index > 0){ //Once again, abusing the fact, booleans are 0 (false) and 1 (true).
				face_timer++ //Counter for the portrait animations
				
				if (face_timer >= face_speed){ //When it's time to change the subimage for the animation do the following.
					face_timer -= face_speed
					face_index++ //Just change the index of the portrait sprite.
					
					if (face_index >= face_subimages_length){ //If it goes over the length of the array, set it back to 0.
						face_index = 0
					}
				}
			}else{ //When it's not talking, just set the first index for the sprite.
				face_index = 0
				face_timer = face_speed - 1
			}
		}
		
		//This next condition does the same as the one above but for the instance it may be binded in the dialog, it uses some of the face variables.
		if (!is_undefined(instance_index) and instance_image_length > 1){
			//This condition prevents the animation from running when a [wait] command has been executed, so it looks like it's actually talking.
			if (((string_index < dialog_length and is_undefined(wait_for_key) and is_undefined(wait_for_function)) and face_animation or instance_image_index > 0) and string_index > 0){ //Once again, abusing the fact, booleans are 0 (false) and 1 (true).
				instance_timer++ //Counter for the portrait animations
			
				if (instance_timer >= face_speed){ //When it's time to change the subimage for the animation do the following.
					instance_timer -= face_speed
					instance_image_index++ //Just change the index of the portrait sprite.
					
					if (instance_image_index >= instance_image_length){ //If it goes over the length of the array, set it back to 0.
						instance_image_index = 0
					}
				}
			}else{ //When it's not talking, just set the first index for the sprite.
				instance_image_index = 0
				instance_timer = face_speed - 1
			}
			
			//Here it the image_index altered depending if the image cycle is defined.
			if (is_undefined(instance_image_cycle)){
				instance_index.image_index = instance_image_index
			}else{
				instance_index.image_index = instance_image_cycle[instance_image_index]
			}
		}
	}
	
	/*
	This function is in charge of executing all the action commands of the dialog, this function is being called in several parts of the step function and on initialization.
	
	RETURNS -> INTEGER/UNDEFINED --It returns the current text_timer everytime it's called, except when it executes the command [next] where it returns undefined, there's only one point in the step function where that matters.
	*/
	execute_action_commands = function(_is_skipping=false){
		//If no dialogs then just do nothing.
		if (dialogues_amount == 0){
			return
		}
		
		if (command_length > 0){ //If there are any commands to execute, do enter.
			//------------------------------------------------------------------------------------------------------------------------------------------------------------
			//VARIABLE DEFINITION
			//------------------------------------------------------------------------------------------------------------------------------------------------------------
			//Set the variables for action command execution.
			
			var _current_commands = action_commands[0]
			var _command_data = _current_commands[0]
			var _index = max(string_index, 0) + 1
			var _has_skipped = _is_skipping
			var _has_set_face_timer = false
			var _has_set_instance_timer = false
			
			//While commands exist and not wait events happen and the index of the command is in bounds of the current position of the dialog and text_timer is under or equal 0 or _is_skipping is set, do execute commands.
			while (command_length > 0 and is_undefined(wait_for_key) and is_undefined(wait_for_function) and (_is_skipping or (text_timer <= 0 and _command_data.index <= _index))){
				//--------------------------------------------------------------------------------------------------------------------------------------------------------
				//COMMAND TYPE EXECUTION
				//--------------------------------------------------------------------------------------------------------------------------------------------------------
				//Depeding of the type of command which has been set by the parser of commands, do different stuff.
				
				switch (_command_data.type){
					case COMMAND_TYPE.WAIT:{
						//When the text is skipping, it ignores specific commands, such as wait.
						if (_is_skipping){
							break
						}else{
							string_index = min(_command_data.index - 1, string_index)
						}
						
						text_timer = _command_data.value
						face_animation = false
					break}
					case COMMAND_TYPE.WAIT_KEY_PRESS:{
						//Some commands, may stop the skipping, like wait press key or stop skip.
						string_index = min(_command_data.index - 1, string_index)
						
						if (_is_skipping){
							_index = max(string_index, 0) + 1
							
							_is_skipping = false
						}
						
						wait_for_key = _command_data.value
						face_animation = false
					break}
					case COMMAND_TYPE.WAIT_FOR:{
						string_index = min(_command_data.index - 1, string_index)
						
						if (_is_skipping){
							_index = max(string_index, 0) + 1
							
							_is_skipping = false
						}
						
						wait_for_function = _command_data.value
						function_arguments = _command_data.arguments
						face_animation = false
					break}
					case COMMAND_TYPE.SKIP_ENABLING:{
						skipeable = _command_data.value
						
						if (_is_skipping and !skipeable){
							string_index = min(_command_data.index - 1, string_index)
							_index = max(string_index, 0) + 1
							
							_is_skipping = false
						}
					break}
					case COMMAND_TYPE.SKIP_DIALOG:{
						//No need to skip when it is already skipping.
						if (_is_skipping){
							break
						}
						
						//Since a skip is comming, and it returns, it is needed to remove the command from here.
						command_length--
						array_delete(_current_commands, 0, 1)
						
						return skip_dialog(_command_data.value) //When skipping dialog it will call this function again with _is_skipping being true, so just do a return with any value the skip_dialog() returns.
					}
					case COMMAND_TYPE.STOP_SKIP:{
						//Yeah, this prevents the skip to continue.
						if (_is_skipping){
							string_index = min(_command_data.index - 1, string_index)
							_index = max(string_index, 0) + 1
							
							_is_skipping = false
						}
					break}
					case COMMAND_TYPE.DISPLAY_TEXT:{
						//Set the string_index if the dialog is not skipping.
						if (!_is_skipping){
							string_index = min(_command_data.index - 1, string_index)
							_index = max(string_index, 0) + 1
						}
						
						display_mode = _command_data.subtype
						display_amount = _command_data.value
					break}
					case COMMAND_TYPE.PROGRESS_MODE:{
						can_progress = _command_data.value
					break}
					case COMMAND_TYPE.NEXT_DIALOG:{
						next_dialog(false)
						
						return undefined //When next dialog, stop executing commands.
					}
					case COMMAND_TYPE.FUNCTION:{
						method_call(_command_data.value, _command_data.arguments)
					break}
					case COMMAND_TYPE.TEXT_EFFECT:{ //The only visual command that is here, activates the flag to start the surface to make shadows.
						if (_command_data.subtype == EFFECT_TYPE.SHADOW){
							shadow_effect = true
						}
					break}
					case COMMAND_TYPE.SET_TEXT_SPEED:{
						text_speed = _command_data.value
					break}
					case COMMAND_TYPE.SET_SPRITE:{
						var _sprite = _command_data.value[0]
						var _sprite_exists = sprite_exists(_sprite)
						
						if (_command_data.index == 1){
							text_align_x = ASTERISK_SPACING*asterisk
							
							if (_sprite_exists){
								text_align_x += sprite_get_width(_sprite) + 10
							}
						}
						
						face_sprite = _sprite
						face_x_offset = 0
						face_y_offset = 0
						
						if (!_sprite_exists){
							_has_set_face_timer = false
							
							break
						}
						
						array_delete(_command_data.value, 0, 1)
					} //No break
					case COMMAND_TYPE.SET_SUBIMAGES:{ //Yeah, what this does, the set_sprite command also uses.
						face_index = 0
						var _subimages = _command_data.value
						var _subimages_length = array_length(_subimages)
						
						if (_subimages_length > 0){
							face_subimages_length = _subimages_length
							if (face_subimages_length == 1){
								face_index = _subimages[0]
								face_subimages_cycle = face_index
							}else{
								face_subimages_cycle = _subimages
							}
						}else{
							face_subimages_cycle = undefined
							face_subimages_length = sprite_get_number(face_sprite)
						}
						
						if (face_subimages_length > 1){
							_has_set_face_timer = true
							face_timer = face_speed - 1
						}else{
							_has_set_face_timer = false
						}
					break}
					case COMMAND_TYPE.SET_SPRITE_SPEED:{
						face_speed = _command_data.value
						
						if (_has_set_face_timer){
							face_timer = face_speed - 1
						}
						
						if (_has_set_instance_timer){
							instance_timer = face_speed - 1
						}
					break}
					case COMMAND_TYPE.PLAY_SOUND:{
						audio_play_sound(_command_data.value, 100, false)
					break}
					case COMMAND_TYPE.SET_VOICE:{
						reproduce_voice = true
						voices = _command_data.value
						voices_length = array_length(voices)
					break}
					case COMMAND_TYPE.VOICE_MUTING:{
						reproduce_voice = _command_data.value
					break}
					case COMMAND_TYPE.SET_ASTERISK:{
						var _asterisk = _command_data.value
						
						if (asterisk == _asterisk){
							return
						}
		
						asterisk = _asterisk
						text_align_x += ASTERISK_SPACING*(2*asterisk - 1)
						
						if (!_is_skipping){
							string_index = -asterisk
						}
					break}
					case COMMAND_TYPE.SET_FONT:{
						font = _command_data.value
						use_font_space = _command_data.bool
						draw_set_font(font)
						
						line_jump_height = string_height("Ag'") + spacing_height
					break}
					case COMMAND_TYPE.SET_WIDTH_SPACING:{
						spacing_width = _command_data.value
					break}
					case COMMAND_TYPE.SET_HEIGHT_SPACING:{
						line_jump_height -= spacing_height
						spacing_height = _command_data.value
						line_jump_height += spacing_height
					break}
					case COMMAND_TYPE.SET_SPRITE_X_OFFSET:{
						face_x_offset = _command_data.value
					break}
					case COMMAND_TYPE.SET_SPRITE_Y_OFFSET:{
						face_y_offset = _command_data.value
					break}
					case COMMAND_TYPE.SET_CONTAINER:{
						set_container_sprite(_command_data.value)
					break}
					case COMMAND_TYPE.SET_CONTAINER_TAIL:{
						set_container_tail_sprite(_command_data.value[0])
						
						if (array_length(_command_data.value) > 1){
							set_container_tail_position(_command_data.value[1], _command_data.value[2])
						}
					break}
					case COMMAND_TYPE.SET_CONTAINER_TAIL_MASK:{
						set_container_tail_mask_sprite(_command_data.value)
					break}
					case COMMAND_TYPE.SET_CONTAINER_TAIL_DRAW_MODE:{
						set_container_tail_draw_mode(_command_data.value)
					break}
					case COMMAND_TYPE.SET_CONTAINER_TAIL_POSITION:{
						var _arguments = _command_data.value
						set_container_tail_position(_arguments[0], _arguments[1])
					break}
					case COMMAND_TYPE.SHOW_DIALOG_POP_UP:{
						var _arguments = _command_data.value
						
						var _mode = _arguments[0]
						var _x = _arguments[1]
						var _y = _arguments[2]
						var _dialog = _arguments[3]
						var _width = _arguments[4]
						var _face_sprite = undefined
						var _face_subimages = undefined
						
						var _length = array_length(_arguments)
						
						if (_length > 5){
							_face_sprite = _arguments[5]
							
							//Handling of _face_subimages.
							if (_length == 7){
								_face_subimages = _arguments[6]
							}else if (_length > 7){
								_face_subimages = []
								
								for (var _i = 6; _i < _length; _i++){
									array_push(_face_subimages, _arguments[_i])
								}
							}
						}
						
						make_tiny_dialog_pop_up(_mode, _x, _y, _dialog, _width, _face_sprite, _face_subimages)
					break}
					case COMMAND_TYPE.BIND_INSTANCE:{
						bind_instance(_command_data.inst, _command_data.value)
						
						if (!is_undefined(instance_index)){
							if (instance_image_length > 1){
								_has_set_instance_timer = true
								instance_timer = face_speed - 1
							}else{
								_has_set_instance_timer = false
							}
						}else{
							_has_set_instance_timer = false
						}
					break}
				}
				
				//Remove the command from the list once it has been executed, it is no longer needed and free some memory.
				command_length--
				array_delete(_current_commands, 0, 1)
				
				//If commands are still available, keep doing it.
				if (command_length > 0){
					_command_data = _current_commands[0]
				}
			}
			
			//If the commands were skipping but a command stopped the skip, then set the text_timer to the text_speed.
			if (_has_skipped and !_is_skipping){
				text_timer = text_speed
			}
		}
		
		return text_timer //Return the current text_timer for stuff to be done in the dialogs.
	}
	
	/*
	This function is in charge of executing all the visual commands of the dialog, this function only gets called 2 times in the draw function.
	
	RETURNS -> BOOLEAN --It returns wheter if the command [apply_to_asterisk] has been executed, which can only happen at the very start of displaying the dialog, so if the first call in the draw step doesn't return true, it will always return false.
	*/
	execute_visual_commands = function(_i, _current_commands){
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//VARIABLE DEFINITION
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//Set the variables for executing visual commands and its configuration.
		
		var _is_initial_asterisk = false
		var _aux_i = max(_i, 1) //For checking the initial asterisk properties, _i gives a 0, but since the index on strings start at 1, this has to be done.
		
		while (visual_command_index < visual_command_length and visual_command_data.index <= _aux_i){
			//These are for color specific commands.
			var _color_direction = ""
			var _color = 0
			
			//------------------------------------------------------------------------------------------------------------------------------------------------------------
			//COMMAND TYPE EXECUTION
			//------------------------------------------------------------------------------------------------------------------------------------------------------------
			//There are color commands, effect commands and the special command to apply the effects and colors to the initial asterisk of the dialog.
			
			switch (visual_command_data.type){
				case COMMAND_TYPE.APPLY_TO_ASTERISK:
					_is_initial_asterisk = true //Flag to set the application of the effects and colors currently configured to the asterisk, can be used more than 1 time at the beginning and will override the previous one, please avoid that.
				break
				case COMMAND_TYPE.COLOR_RGB:
					var _values = visual_command_data.value
					_color = make_color_rgb(_values[0], _values[1], _values[2])
					draw_color_effect = EFFECT_TYPE.NONE //Overrides any color effect.
					
					//Type of coloring
					if (array_length(_values) >= 4){
						_color_direction = _values[3]
					}else{
						_color_direction = "all"
					}
				break
				case COMMAND_TYPE.COLOR_HSV:
					_values = visual_command_data.value
					_color = make_color_hsv(_values[0], _values[1], _values[2])
					draw_color_effect = EFFECT_TYPE.NONE //Overrides any color effect.
					
					//Type of coloring.
					if (array_length(_values) >= 4){
						_color_direction = _values[3]
					}else{
						_color_direction = "all"
					}
				break
				case COMMAND_TYPE.TEXT_EFFECT:
					var _subtype = visual_command_data.subtype
					
					//Effects subtyping.
					switch (_subtype){
						case EFFECT_TYPE.ZOOM: case EFFECT_TYPE.SLIDE:
							draw_materializing_effect = _subtype
						break
						case EFFECT_TYPE.RAINBOW:
							draw_color_effect = _subtype
							draw_color_effect_offset = visual_command_data.value
						break
						case EFFECT_TYPE.SHADOW: //Shadow is kinda hardcoded, if there are another type of effect similar, I will change it to a more general form.
							draw_shadow_effect = true
							draw_shadow_effect_x = visual_command_data.x
							draw_shadow_effect_y = visual_command_data.y
							draw_shadow_effect_color = visual_command_data.value
							draw_shadow_effect_font = visual_command_data.font
						break
						case EFFECT_TYPE.MALFUNCTION:
							draw_text_effect = _subtype
							draw_text_effect_any_letter = visual_command_data.any_letter
							draw_text_effect_value = visual_command_data.value
						break
						case EFFECT_TYPE.NONE: //When none type is used (usually by just [effect] with no arguments or not valid effect arguments), remove all effects.
							draw_position_effect = EFFECT_TYPE.NONE
							draw_color_effect = EFFECT_TYPE.NONE
							draw_shadow_effect = false
							draw_materializing_effect = EFFECT_TYPE.NONE
						break
						default: //These are the effects for position of the text.
							draw_position_effect_value = visual_command_data.value
							
							if (draw_position_effect_value == 0){
								draw_position_effect = EFFECT_TYPE.NONE
							}else{
								draw_position_effect = _subtype
							}
						break
					}
				break
				case COMMAND_TYPE.DISABLE_TEXT_EFFECT:
					_subtype = visual_command_data.subtype
					
					//Effect to cancel.
					switch (_subtype){
						case EFFECT_TYPE.ZOOM: case EFFECT_TYPE.SLIDE:
							draw_materializing_effect = EFFECT_TYPE.NONE
						break
						case EFFECT_TYPE.RAINBOW:
							draw_color_effect = EFFECT_TYPE.NONE
						break
						case EFFECT_TYPE.SHADOW:
							draw_shadow_effect = false //Shadow is kinda hardcoded, if there are another type of effect similar, I will change it to a more general form.
						break
						case EFFECT_TYPE.MALFUNCTION:
							draw_text_effect = EFFECT_TYPE.NONE
						break
						case EFFECT_TYPE.NONE: //When none type wants to be disabled, well we do nothing, cause to begin with, nothing is being done XD.
							break
						default: //These are the effects for position of the text.
							if (draw_position_effect == _subtype){
								draw_position_effect = EFFECT_TYPE.NONE
							}
						break
					}
				break
			}
			
			//------------------------------------------------------------------------------------------------------------------------------------------------------------
			//COLORING TYPE
			//------------------------------------------------------------------------------------------------------------------------------------------------------------
			//When the text is being colored, it can be set what corners to apply the color, if no valid one is given, it does nothing.
			
			switch (_color_direction){
				case "up":
					color[0] = _color
					color[1] = _color
				break
				case "down":
					color[2] = _color
					color[3] = _color
				break
				case "left":
					color[0] = _color
					color[3] = _color
				break
				case "right":
					color[1] = _color
					color[2] = _color
				break
				case "up_left":
					color[0] = _color
				break
				case "up_right":
					color[1] = _color
				break
				case "down_right":
					color[2] = _color
				break
				case "down_left":
					color[3] = _color
				break
				case "all":
					color[0] = _color
					color[1] = _color
					color[2] = _color
					color[3] = _color
				break
			}
			
			//Advance to the next visual command, these are not deleted, as they are needed to render the text properly evert frame.
			visual_command_index++
			if (visual_command_index < visual_command_length){
				visual_command_data = _current_commands[visual_command_index]
			}
			
			//If configuration has to be set to the initial asterisk, do not run more commands to apply the current ones, the rest will be executed when the text needs to be drawn in their given time.
			if (_is_initial_asterisk){
				break
			}
		}
		
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//SETTING EFFECT CONFIGURATION
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//This is the part effects being set by the command take place and are being calculated to display the text with various effects.
		
		draw_effect_x = 0
		draw_effect_y = 0
		draw_materializing_effect_x = 0
		draw_materializing_effect_y = 0
		draw_materializing_effect_scale = 1
		draw_materializing_effect_alpha = 1
		
		//Materializing effects, they offset, scale and set the alpha of the letters in different ways while the text is appearing.
		switch (draw_materializing_effect){
			case EFFECT_TYPE.ZOOM:{
				if (array_length(draw_materializing_effect_timers) <= _i){
					draw_materializing_effect_timers[_i] = 0
				}
				
				var _timer = min(draw_materializing_effect_timers[_i], 10)
				var _size_x = string_width("A")
				var _size_y = string_height("A")
				
				draw_materializing_effect_scale = 3 - _timer/5
				draw_materializing_effect_x = -_size_x*(draw_materializing_effect_scale - 1)/2
				draw_materializing_effect_y = -_size_y*(draw_materializing_effect_scale - 1)/3
				draw_materializing_effect_alpha = _timer/10
			break}
			case EFFECT_TYPE.SLIDE:{
				if (array_length(draw_materializing_effect_timers) <= _i){
					draw_materializing_effect_timers[_i] = 0
				}
				
				var _timer = min(draw_materializing_effect_timers[_i], 40)
				var _size_x = string_width("A")
				var _size_y = string_height("A")
				
				draw_materializing_effect_x = 3*_size_x*max(20 - _timer, 0)/20
				draw_materializing_effect_y = 2*_size_y*ceil((40 - _timer)/40)/10
				draw_materializing_effect_scale = 0.6 + 4*floor(_timer/40)/10
				draw_materializing_effect_alpha = min(_timer, 20)/20
			break}
		}
		
		//Positional effects, they offset the letters in different ways to give style to the dialog.
		switch (draw_position_effect){
			case EFFECT_TYPE.OSCILLATE:
				var _timer = 6*(effect_timer + _i)
				
				draw_effect_x = draw_position_effect_value*dcos(_timer)
				draw_effect_y = draw_position_effect_value*dsin(_timer)
			break
			case EFFECT_TYPE.TWITCH: //Twitch effect is like a shake effect but for just 1 frame, with a chance of 1/1000 to happen.
				if (irandom(1000) != 500){
					break
				}
			case EFFECT_TYPE.SHAKE:
				draw_effect_x = random_range(-draw_position_effect_value, draw_position_effect_value)
				draw_effect_y = random_range(-draw_position_effect_value, draw_position_effect_value)
			break
		}
		
		//Color effects, they give special colors to the text that changes, it overrides any flat color that has been set, but it doesn't reset the color once removed, it keeps the last set color.
		switch (draw_color_effect){
			case EFFECT_TYPE.RAINBOW:
				draw_color_effect_value = make_color_hsv((effect_timer + _i*draw_color_effect_offset)%256, 255, 255)
			break
		}
		
		return _is_initial_asterisk //Return if the initial asterisk needs to be displayed with the coloring and effects.
	}
	
	/*
	As the name implies, it resets the variables of the dialog system, however it is not a reset to its initial values as you would expect as not all variables gets reset.
	It's just variables that need its data reset so the next dialog can be performed correctly, this is used in some places that revolve around advacing to the next dialog and resetting new dialogues scrapping the current ones.
	*/
	variable_reset = function(){
		command_length = array_length(action_commands[0])
		visual_command_length = array_length(visual_commands[0])
		dialog = dialogues[0]
		text_timer = 0 //Starts at 0 so initial commands execute.
		effect_timer = 0
		string_index = -asterisk
		dialog_length = string_length(dialog)
		skipeable = true //Player input checking is restored.
		can_progress = true
		wait_for_key = undefined
		wait_for_function = undefined
		function_arguments = undefined
		display_mode = DISPLAY_TEXT.LETTERS //Display mode also gets reset.
		display_amount = 1
		face_animation = true
		shadow_effect = false
		
		var _length = array_length(draw_text_effect_timers)
		if (_length > 0){
			array_delete(draw_text_effect_timers, 0, _length)
		}
		_length = array_length(draw_materializing_effect_timers)
		if (_length){
			array_delete(draw_materializing_effect_timers, 0, _length)
		}
		
		if (execute_action_commands() == 0){ //Execute any initial commands and if no text_timer is set, strart it on 1.
			text_timer = 1
		}
	}
	
	/*
	This function determinates the angle the container's tail must rotate so its base stays withing the dialog bounding box itself, used by the set_tail_position() function.
	The formula used for this took 3 days to determinate alone, quite the heavy task, with that determianted the implementation was quick in less than 1 hour (not counting bug fixing hours due to the method and formula implementations XD, but less than a day, I swear).
	
	This formula has always one solution for a distance and angle set, but it cannot be calculated in a closed form (getting the solution by making the calculations with the formula just once).
	This uses an aproximation method, meaning the solution is not even 100% accurate, but is 99% accurate, good enough.
	Using newton raphson aproximation alone, the root is aproximated to determinate the correct angle the tail should be rotated to fit in place.
	With the angle gotten, everything lands smoothly, in case you ask by the way, no _angle is not the angle the tail should be rotated.
	For more information on this formula and method see the programmer documentation, maybe you can find a better way to do this, it doesn't take much to calculate surprisingly, no lag experienced during testing (unless you show text in the debug while inside the cycle, if you have a potato PC you maye experience a lag spike with that, for your safety avoid calling the set_tail_position() function every frame with debug text showing).
	
	REAL _d -----> Distance between the position the tail must be and the closest corner of the bounding box of the dialog itself, this may always be positive, giving a negative distance may result in infinite loops or incorrect angle results.
	REAL _angle -> Angle between the position the tail must be and the closest corner of the bounding box of the dialog itself.
	REAL _xn ----> Initial angle to iterate as the newthon raphson method needs it, depending on the corner, it could be 45 (for the corner top right as the tail can only be in angle 0°-90°), 135, 225 and 315, follow this set with the corresponding corner with its corresponding _angle, settings other initial angle values may result in infinite loops or incorrect angle results that not even newthon raphson with bisection variant can get right, reasons are unknown as it has not been studied yet.
	
	RETURNS -> INTEGER --Angle the tail must be rotated to make sure its base is within the dialog bounding box itself.
	*/
	get_container_tail_angle = function(_d, _angle, _xn){
		var _mult = (1 - (_xn div 90)%2) //Two formulas are being used for the angle aproximation, this "switch" here toggles between each other, as one formula works only between 0°-90° and 180°-270°, the other formula works on the rest of the angles, check programmer documentation for more information on that.
		var _const = -2 + 4*_mult //Part of the two formula toggle.
		var _angle_offset = 90*_mult //Part of the two formula toggle as well.
		var _y_origin_scale = container_tail_y_origin/container_tail_height_pixels //The tail variables hold the pixels and absolute positions of the origin and height, the proportion of these is needed instead.
		
		while (true){
			var _f = power(dcos(_xn - _angle_offset), 2) - dsin(_angle - _xn)*_d/(container_tail_height_pixels*container_tail_height) - _y_origin_scale
			
			if (abs(_f) <= 0.01){ //99% preccise solutions are accepted only.
				break
			}
			
			_xn -= _f/(_const*dcos(_xn)*dsin(_xn) + _d*dcos(_angle - _xn)/(container_tail_height_pixels*container_tail_height))
		}
		
		//At this point the correct angle must have been achieved if done correctly.
		return _xn
	}
	
	/*
	This simple function updates the width and height values of the container so it's scaled correctly with the current size of the dialog itself and the container data.
	*/
	update_container_sprite = function(){
		if (!sprite_exists(container_sprite)){
			return
		}
		
		container_width = (dialog_x_offset + dialog_width + container_sprite_width - container_right_collision)/container_sprite_width
		container_height = (dialog_y_offset + dialog_height + container_sprite_height - container_bottom_collision)/container_sprite_height
		
		container_x_offset = sprite_get_xoffset(container_sprite)*container_width
		container_y_offset = sprite_get_yoffset(container_sprite)*container_height
		
		//In case the container has been scaled, to keep the relation of the origin set originally in the sprite, a multiplication is done.
		//This does not affect the container in any way, as this variable is not used to display it, only to position the tail if it has any.
		if (container_original_origins){
			if (container_x_origin > 0){
				container_x_origin *= container_width
			}
			if (container_y_origin > 0){
				container_y_origin *= container_height
			}
		}
		
		//In case the mask exists with a tail, update the data of it since the width and height are being changed.
		update_container_tail_mask_sprite()
	}
	
	/*
	This simple function updates the height value of the container tail so it's correctly scaled with the current size of the dialog itself and the container tail data.
	*/
	update_container_tail_sprite = function(){
		if (!sprite_exists(container_tail_sprite)){
			return
		}
		
		container_tail_height = min(dialog_height/container_tail_height_pixels, 1)
	}
	
	/*
	This simple function updates the variable data of the mask sprite, it only updates when all three sprites of the container are set.
	*/
	update_container_tail_mask_sprite = function(){
		if (!sprite_exists(container_sprite) or !sprite_exists(container_tail_sprite) or !sprite_exists(container_tail_mask_sprite)){
			return
		}
		
		container_tail_draw_mode = CONTAINER_TAIL_DRAW_MODE.INVERTED_SPRITE_MASK
		container_tail_mask_width = container_width*container_sprite_width/sprite_get_width(container_tail_mask_sprite) //The mask sprite cannot be outside the container sprite, it fills always the entire sprite, have that in mind.
		container_tail_mask_height = container_height*container_sprite_height/sprite_get_height(container_tail_mask_sprite)
	}
	
	//Add the dialogues.
	add_dialogues(_dialogues)
	
	//Set the containers sprites if they exist.
	set_container_sprite(_container_sprite)
	set_container_tail_sprite(_container_tail_sprite)
	set_container_tail_mask_sprite(_container_tail_mask_sprite)
}