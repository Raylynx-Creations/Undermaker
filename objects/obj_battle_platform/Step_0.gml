/// @description Variable method runs if set

if (!is_undefined(step)){
	step()
}

if (type == PLATFORM_TYPE.CONVEYOR){
	image_blend = make_color_rgb(191, 76, 0);
}else if (type == PLATFORM_TYPE.TRAMPOLINE){
	image_blend = make_color_rgb(0, 148, 255);
}else if (type == PLATFORM_TYPE.STICKY){
	image_blend = make_color_rgb(127.5, 0, 191);
}else{
	image_blend = make_color_rgb(0, 127.5, 0);
}