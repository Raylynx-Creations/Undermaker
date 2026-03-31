sprite_index = spr_berry

interaction = function(_direction){
	overworld_dialog(global.dialogues.hot_room.berry)
	
	image_index = (2 + _direction/90)%4
}

step = function(){
	if (image_index != 0 and obj_game.dialog.is_finished()){
		image_index = 0
	}
}