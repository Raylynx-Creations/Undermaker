///@description Variable definition and system creation for multiple system the game uses

alarm[0] = 1
alarm[1] = 60 //Temporary timer startup, this should be moved to the menu stuff and reset stuff too

starting_up = true //Variable to do stuff on start up

state =  -1 //Doesn't matter the initial state, the menu function at the very bottom replaces this value
battle_start_animation_type = BATTLE_START_ANIMATION.NORMAL

//Position where the player heart will move at the battle starting animations
battle_start_animation_player_heart_x = 0
battle_start_animation_player_heart_y = 0

//Menu heart selector
player_heart_sprite = spr_player_heart
player_heart_subimage = 0 //The index of the sprite heart to use for menus, you can have another one for the battle one if you want, just change this variable when accessing the states.
player_heart_color = c_red

quit_timer = 0 //Necessary for the hold ESC quitting.
anim_timer = 0 //Timer for the animation of transition to battle room and going back to overworld
selection = -1 //Selection of the multiple choice dialog events
ui_surface = -1 //UI surface reference variable

//Variables used for the dynamic border.
border_id = 0
border_prev_id = 0
border_alpha = 1

//Variable to store the previous room the player was in
previous_room = undefined

//Variables for the multiple choice dialog event
grid_options = []
plus_options = [undefined, undefined, undefined, undefined] //left, down, right, up
options_x = 0
options_y = 0
choice_sprite = spr_player_heart //The choice heart can be different if desired
choice_index = 0 //As well as the index, but the color is the same as the player_heart_color, bit incosistent yeah... but it works

//The several systems the game manages
random_encounter_system = new RandomEncounterSystem()
battle_system = new BattleSystem()
overworld_music_system = new MusicSystem()
battle_music_system = new MusicSystem()
battle_pause_music = false
game_over_system = new GameOverSystem()
player_menu_system = new PlayerMenuSystem()
dialog = new DialogSystem(0, 0, [], 1)
input_system = new InputSystem()
room_transition_system = new RoomTransitionSystem()

//Functions for events that happen
event_update = undefined
event_end_condition = undefined
start_room_function = undefined
end_room_function = undefined

//We draw the surface in a custom way using Draw GUI event to support borders
application_surface_draw_enable(false)
window_enable_borderless_fullscreen(true)

// Arrays of width and height of available resolutions that are integer multiples of GAME_WIDTH x GAME_HEIGHT.
resolutions_width = []
resolutions_height = []

//Get the resolutions the current PC can support
calculate_resolutions()
//Load all the game data the game needs to functions, these come from files and may be configuration, dialogs, etc.
load_game_data()
load_audio()

//The menu system I manage, needed after the load_game_data()
game_menu_system = undefined

game_ready = function(){
	go_to_game_menu() //Loads the menu, the function can be used in any place of the game and will lead you to the menu.
}

gpu_set_default_blendmode()
