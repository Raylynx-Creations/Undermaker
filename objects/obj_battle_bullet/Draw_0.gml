/// @description Variable method runs if set

if (mask_to_box){
	shader_set(shd_sprite_masking)
	
	var _mask_texture = surface_get_texture(box_for_mask.box_fill_surface)
	var sampler = shader_get_sampler_index(shd_sprite_masking, "mask_texture");
	texture_set_stage(sampler, _mask_texture);

	var _resolution = shader_get_uniform(shd_sprite_masking, "resolution");
	shader_set_uniform_f(_resolution, GAME_WIDTH, GAME_HEIGHT);
}

if (!is_undefined(draw)){
	draw()
}

if (mask_to_box){
	shader_reset()
}