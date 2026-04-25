/// @description Arena rendering

//1 - Merge outline
//2 - Normal fill
//3 - Normal outline
//4 - Merge fill

if (can_draw){
	if (!surface_exists(hole_outline)){
		hole_outline = surface_create(GAME_WIDTH, GAME_HEIGHT)
	}
	if (!surface_exists(hole_fill)){
		hole_fill = surface_create(GAME_WIDTH, GAME_HEIGHT)
	}
	if (!surface_exists(merge_outline)){
		merge_outline = surface_create(GAME_WIDTH, GAME_HEIGHT)
	}
	if (!surface_exists(normal_fill)){
		normal_fill = surface_create(GAME_WIDTH, GAME_HEIGHT)
	}
	if (!surface_exists(normal_outline)){
		normal_outline = surface_create(GAME_WIDTH, GAME_HEIGHT)
	}
	if (!surface_exists(merge_fill)){
		merge_fill = surface_create(GAME_WIDTH, GAME_HEIGHT)
	}
	
	surface_set_target(hole_outline)
	draw_clear_alpha(c_black, 0)
	surface_reset_target()
	
	surface_set_target(hole_fill)
	draw_clear_alpha(c_black, 0)
	surface_reset_target()
	
	surface_set_target(merge_outline)
	draw_clear_alpha(c_black, 0)
	surface_reset_target()
	
	surface_set_target(normal_fill)
	draw_clear_alpha(c_black, 0)
	surface_reset_target()
	
	surface_set_target(normal_outline)
	draw_clear_alpha(c_black, 0)
	surface_reset_target()
	
	surface_set_target(merge_fill)
	draw_clear_alpha(c_black, 0)
	surface_reset_target()
	
	switch (type){
		case BATTLE_BOX_TYPE.MERGE:{
			surface_set_target(merge_fill)
			draw_surface_ext(box_fill_surface, 0, 0, 1, 1, 0, box_fill_color, box_fill_alpha)
			surface_reset_target()
			
			surface_set_target(merge_outline)
			draw_surface(box_outline_surface, 0, 0)
			surface_reset_target()
		break}
		case BATTLE_BOX_TYPE.HOLE:{
			surface_set_target(hole_fill)
			draw_surface_ext(box_fill_surface, 0, 0, 1, 1, 0, box_fill_color, box_fill_alpha)
			surface_reset_target()
			
			surface_set_target(hole_outline)
			draw_surface(box_outline_surface, 0, 0)
			surface_reset_target()
		break}
		default:{ //BATTLE_BOX_TYPE.NORMAL
			surface_set_target(normal_fill)
			draw_surface_ext(box_fill_surface, 0, 0, 1, 1, 0, box_fill_color, box_fill_alpha)
			surface_reset_target()
			
			surface_set_target(normal_outline)
			draw_surface(box_outline_surface, 0, 0)
			surface_reset_target()
		}
	}
	
	with (obj_battle_box){
		if (id == other.id or depth != other.depth){
			continue
		}
		
		switch (type){
			case BATTLE_BOX_TYPE.MERGE:{
				surface_set_target(other.merge_fill)
				draw_surface_ext(box_fill_surface, 0, 0, 1, 1, 0, box_fill_color, box_fill_alpha)
				surface_reset_target()
			
				surface_set_target(other.merge_outline)
				draw_surface(box_outline_surface, 0, 0)
				surface_reset_target()
			break}
			case BATTLE_BOX_TYPE.HOLE:{ //TODO
				surface_set_target(other.hole_fill)
				draw_surface_ext(box_fill_surface, 0, 0, 1, 1, 0, box_fill_color, box_fill_alpha)
				surface_reset_target()
			
				surface_set_target(other.hole_outline)
				draw_surface(box_outline_surface, 0, 0)
				surface_reset_target()
			break}
			default:{ //BATTLE_BOX_TYPE.NORMAL
				surface_set_target(other.normal_fill)
				draw_surface_ext(box_fill_surface, 0, 0, 1, 1, 0, box_fill_color, box_fill_alpha)
				surface_reset_target()
			
				surface_set_target(other.normal_outline)
				draw_surface(box_outline_surface, 0, 0)
				surface_reset_target()
			break}
		}
		
		can_draw = false
	}
	
	if (!surface_exists(result_boxes)){
		result_boxes = surface_create(GAME_WIDTH, GAME_HEIGHT)
	}
	surface_set_target(result_boxes)
	draw_clear_alpha(c_black, 0)
	
	shader_set(shd_sprite_masking)
	
	var _mask_texture = surface_get_texture(hole_fill)
	var _sampler = shader_get_sampler_index(shd_sprite_masking, "mask_texture");
	texture_set_stage(_sampler, _mask_texture);

	var _resolution = shader_get_uniform(shd_sprite_masking, "resolution");
	shader_set_uniform_f(_resolution, GAME_WIDTH, GAME_HEIGHT);
	
	var _inverse = shader_get_uniform(shd_sprite_masking, "inverse");
	shader_set_uniform_i(_inverse, true);

	draw_surface(merge_outline, 0, 0)
	draw_surface(normal_fill, 0, 0)
	draw_surface(normal_outline, 0, 0)
	draw_surface(merge_fill, 0, 0)
	
	surface_reset_target()
	
	draw_surface(result_boxes, 0, 0)
	
	_mask_texture = surface_get_texture(result_boxes)
	texture_set_stage(_sampler, _mask_texture);
	
	shader_set_uniform_i(_inverse, false);
	
	draw_surface(hole_outline, 0, 0)
	
	shader_reset()
}else{
	can_draw = true
}

//This method of the battle_system draws battle related stuff onto the box, like when the player attacks an enemie.
//Do not confuse that with the text shown in the box, that is handled by the battle_system.battle_dialog, not that.
obj_game.battle_system.draw_in_box()