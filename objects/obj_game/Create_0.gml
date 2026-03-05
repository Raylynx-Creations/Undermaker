alarm[0] = 1
alarm[1] = 60 //Temporary timer startup, this should be moved to the menu stuff and reset stuff too

state = GAME_STATE.PLAYER_CONTROL ////REPLACE WHEN ALL IS DONE.
battle_start_animation_type = BATTLE_START_ANIMATION.NORMAL

battle_start_animation_player_heart_x = 0
battle_start_animation_player_heart_y = 0

player_heart_sprite = spr_player_heart
player_heart_subimage = 0 //The index of the sprite heart to use for menus, you can have another one for the battle one if you want, just change this variable when accessing the states.
player_heart_color = c_red

anim_timer = 0
selection = -1
ui_surface = -1

grid_options = []
plus_options = [undefined, undefined, undefined, undefined] //left, down, right, up
options_x = 0
options_y = 0
choice_sprite = spr_player_heart
choice_index = 0

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

event_update = undefined
event_end_condition = undefined
start_room_function = undefined
end_room_function = undefined

application_surface_draw_enable(false)
window_enable_borderless_fullscreen(true)

// Arrays of width and height of available resolutions that are integer multiples of GAME_WIDTH x GAME_HEIGHT.
resolutions_width = []
resolutions_height = []

calculate_resolutions()
load_game_data()