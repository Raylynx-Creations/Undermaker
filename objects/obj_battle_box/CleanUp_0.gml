/// @description Box fill surface clean up

if (surface_exists(box_fill_surface)){
	surface_free(box_fill_surface)
}
if (surface_exists(box_outline_surface)){
	surface_free(box_outline_surface)
}