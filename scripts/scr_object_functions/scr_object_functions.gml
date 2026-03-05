/*

*/

function calculate_object_sprite_size_offset(){
	var _player_sprite = sprite_index
	var _player_angle = image_angle
	var _player_xscale = image_xscale
	var _player_yscale = image_yscale
	var _player_sprite_xoffset = sprite_get_xoffset(_player_sprite)
	var _player_sprite_yoffset = sprite_get_yoffset(_player_sprite)
	
	var _sprite_left = _player_xscale*_player_sprite_xoffset - 0.5
	var _sprite_top = _player_yscale*_player_sprite_yoffset - 0.5
	var _sprite_right = _player_xscale*(sprite_get_width(_player_sprite) - _player_sprite_xoffset) - 0.5
	var _sprite_bottom = _player_yscale*(sprite_get_height(_player_sprite) - _player_sprite_yoffset) - 0.5
	
	var _horizontal_axis = ((dcos(_player_angle) >= 0) ? _sprite_left : _sprite_right)
	var _vertical_axis = ((dsin(_player_angle) >= 0) ? _sprite_top : _sprite_bottom)
	sprite_left_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_player_angle), 2) + power(_horizontal_axis*dsin(_player_angle), 2))
	
	_horizontal_axis = ((dsin(_player_angle) >= 0) ? _sprite_right : _sprite_left)
	_vertical_axis = ((dcos(_player_angle) >= 0) ? _sprite_top : _sprite_bottom)
	sprite_top_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_player_angle), 2) + power(_horizontal_axis*dsin(_player_angle), 2))
	
	_horizontal_axis = ((dcos(_player_angle) >= 0) ? _sprite_right : _sprite_left)
	_vertical_axis = ((dsin(_player_angle) >= 0) ? _sprite_bottom : _sprite_top)
	sprite_right_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_player_angle), 2) + power(_horizontal_axis*dsin(_player_angle), 2))
	
	_horizontal_axis = ((dsin(_player_angle) >= 0) ? _sprite_left : _sprite_right)
	_vertical_axis = ((dcos(_player_angle) >= 0) ? _sprite_bottom : _sprite_top)
	sprite_bottom_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_player_angle), 2) + power(_horizontal_axis*dsin(_player_angle), 2))
}

function calculate_object_collision_offset(){
	var _player_sprite = sprite_index
	var _player_angle = image_angle
	var _player_xscale = image_xscale
	var _player_yscale = image_yscale
	var _player_sprite_half_width = sprite_get_width(_player_sprite)/2
	var _player_sprite_half_height = sprite_get_height(_player_sprite)/2
	
	var _sprite_bbox_left = _player_xscale*(_player_sprite_half_width - sprite_get_bbox_left(_player_sprite)) - 0.5
	var _sprite_bbox_top = _player_yscale*(_player_sprite_half_height - sprite_get_bbox_top(_player_sprite)) - 0.5
	var _sprite_bbox_right = _player_xscale*(sprite_get_bbox_right(_player_sprite) - _player_sprite_half_width + 1) - 0.5
	var _sprite_bbox_bottom = _player_yscale*(sprite_get_bbox_bottom(_player_sprite) - _player_sprite_half_height + 1) - 0.5
	
	var _horizontal_axis = ((dcos(_player_angle) >= 0) ? _sprite_bbox_left : _sprite_bbox_right)
	var _vertical_axis = ((dsin(_player_angle) >= 0) ? _sprite_bbox_top : _sprite_bbox_bottom)
	sprite_left_collision_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_player_angle), 2) + power(_horizontal_axis*dsin(_player_angle), 2))
	
	_horizontal_axis = ((dsin(_player_angle) >= 0) ? _sprite_bbox_right : _sprite_bbox_left)
	_vertical_axis = ((dcos(_player_angle) >= 0) ? _sprite_bbox_top : _sprite_bbox_bottom)
	sprite_top_collision_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_player_angle), 2) + power(_horizontal_axis*dsin(_player_angle), 2))
	
	_horizontal_axis = ((dcos(_player_angle) >= 0) ? _sprite_bbox_right : _sprite_bbox_left)
	_vertical_axis = ((dsin(_player_angle) >= 0) ? _sprite_bbox_bottom : _sprite_bbox_top)
	sprite_right_collision_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_player_angle), 2) + power(_horizontal_axis*dsin(_player_angle), 2))
	
	_horizontal_axis = ((dsin(_player_angle) >= 0) ? _sprite_bbox_left : _sprite_bbox_right)
	_vertical_axis = ((dcos(_player_angle) >= 0) ? _sprite_bbox_bottom : _sprite_bbox_top)
	sprite_bottom_collision_offset = _horizontal_axis*_vertical_axis/sqrt(power(_vertical_axis*dcos(_player_angle), 2) + power(_horizontal_axis*dsin(_player_angle), 2))
}
