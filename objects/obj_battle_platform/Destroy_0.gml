/// @description Variable method runs if set

if (!is_undefined(destroy)){
	destroy()
}

//Clean up the surface.
if (surface_exists(surface)){
	surface_free(surface)
}