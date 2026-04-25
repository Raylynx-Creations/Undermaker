/// @description Button configuration

button_type = BUTTON.FIGHT //By default buttons not specified become FIGHT buttons.

//Offset of the player with the button.
heart_button_position_x = -39
heart_button_position_y = 0

can_select = true
can_interact = true
interaction_key = "confirm"

interaction = undefined
step = undefined

//---------------Programmer Area---------------------

sprite_index = get_language_sprite("spr_player_buttons")
selected = false