sprite_index = spr_kris_dog

instance = undefined
timer = 0

//This is just so 1 instance talks with this entity, edit it to allow for multiple entities of course, there are many ways to do it alongside the system.
instance_talk = function(_inst){
	inst_kris_dog_3.instance = real(_inst) //Must specify the inst_kris_dog_3 as this function is called in the scope of the dialog structure, which may not be ideal, so it is needed to do point the instance variables that want to be changed.
	inst_kris_dog_3.timer = 2 //Delay it takes for the dialog to begin, defined by its text_speed which is 2.
}

interaction = function(){
	overworld_dialog(["[bind_instance:" + string(real(id)) + "][func:" + string(id) + ",instance_talk," + string(real(inst_kris_dog_cotton.id)) + "]I'm not part of the kris dog group either.","However I use a function to make the rightmost kris group entity talk and me only.","This is a more proper way to animate multiple entities to talk simultaneously.","[func:" + string(id) + ",instance_talk," + string(real(inst_plate_1.id)) + "]Now I switch and make the button flicker alongside with me[w:10], nice."],, false)
	inst_plate_1.can_update = false
}

step = function(){
	if (!is_undefined(instance)){
		if (!obj_game.dialog.is_finished()){
			if (obj_game.dialog.is_talking() or instance.image_index > 0){
				timer++
				
				if (timer >= 10){
					timer -= 10
					instance.image_index++
					
					if (instance.image_index > 1){
						instance.image_index -= 2
					}
				}
			}else{
				instance.image_index = 0
				timer = 2 //Delay it takes for the dialog to begin, defined by its text speed which is 2.
			}
		}else{
			instance.image_index = 0
			instance = undefined
			timer = 0
			inst_plate_1.can_update = true
		}
	}
}