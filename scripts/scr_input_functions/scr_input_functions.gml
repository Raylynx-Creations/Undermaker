function any_direction_button(_hold=true){
	if (_hold){
		return (global.up_hold_button or global.down_hold_button or global.left_hold_button or global.right_hold_button)
	}else{
		return (global.up_button or global.down_button or global.left_button or global.right_button)
	}
}

function any_horizontal_button(_hold=true){
	if (_hold){
		return (global.left_hold_button or global.right_hold_button)
	}else{
		return (global.left_button or global.right_button)
	}
}

function any_vertical_button(_hold=true){
	if (_hold){
		return (global.up_hold_button or global.down_hold_button)
	}else{
		return (global.up_button or global.down_button)
	}
}

function get_left_button(_hold=true){
	if (_hold){
		return global.left_hold_button
	}else{
		return global.left_button
	}
}

function get_right_button(_hold=true){
	if (_hold){
		return global.right_hold_button
	}else{
		return global.right_button
	}
}

function get_up_button(_hold=true){
	if (_hold){
		return global.up_hold_button
	}else{
		return global.up_button
	}
}

function get_down_button(_hold=true){
	if (_hold){
		return global.down_hold_button
	}else{
		return global.down_button
	}
}

function get_confirm_button(_hold=true){
	if (_hold){
		return global.confirm_hold_button
	}else{
		return global.confirm_button
	}
}

function get_cancel_button(_hold=true){
	if (_hold){
		return global.cancel_hold_button
	}else{
		return global.cancel_button
	}
}

function get_menu_button(_hold=true){
	if (_hold){
		return global.menu_hold_button
	}else{
		return global.menu_button
	}
}

function get_horizontal_button_force(_hold=true){
	if (_hold){
		return (global.right_hold_button - global.left_hold_button)
	}else{
		return (global.right_button - global.left_button)
	}
}

function get_vertical_button_force(_hold=true){
	if (_hold){
		return (global.down_hold_button - global.up_hold_button)
	}else{
		return (global.down_button - global.up_button)
	}
}
