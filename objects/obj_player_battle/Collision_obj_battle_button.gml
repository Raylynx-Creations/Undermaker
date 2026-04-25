/// @description Button handling

with (other){
	if (can_select){
		selected = true
	}
	
	if (can_interact and !is_undefined(interaction)){
		var _is_interacting
		
		//Check for the key to interact being pressed.
		switch (interaction_key){
			case "confirm":
				_is_interacting = get_confirm_button(false)
			break
			case "cancel":
				_is_interacting = get_cancel_button(false)
			break
			case "menu":
				_is_interacting = get_menu_button(false)
			break
			default: //Checks the key you have.
				_is_interacting = keyboard_check_pressed(ord(interaction_key))
			break
		}
		
		if (_is_interacting){
			interaction()
		}
	}
}