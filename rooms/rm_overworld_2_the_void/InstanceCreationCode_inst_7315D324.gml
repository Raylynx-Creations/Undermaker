timer = 0

step = function(){
	timer += 2
	
	if (timer >= 360){
		timer -= 360
	}
	
	image_angle += 1
	
	x = 1100 + 40*dcos(image_angle) - 40*dsin(image_angle)
	y = 260 - 40*dcos(image_angle) - 40*dsin(image_angle) - 60*dsin(timer)
}