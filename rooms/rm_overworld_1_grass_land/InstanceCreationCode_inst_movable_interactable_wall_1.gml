if (global.save_data.wall_1_moved){
	y = 240
}

epic_movement = function(){
	move_wall = true
}

interaction = function(){
	if (!global.save_data.wall_1_moved){
		move_wall = false
	
		var _option_1 = function(){
			overworld_dialog(global.dialogues.grass_land.interaction_6.option_1,, false)
		}
	
		var _option_2 = function(){
			overworld_dialog(global.dialogues.grass_land.interaction_6.option_2,, false)
		}
	
		var _option_3 = function(){
			overworld_dialog(global.dialogues.grass_land.interaction_6.option_3,, false)
		}
	
		var _option_4 = function(){
			overworld_dialog(global.dialogues.grass_land.interaction_6.option_4,, false)
		}
		
		var _options = global.dialogues.grass_land.interaction_6.options
		create_plus_choice_option(PLUS_CHOICE_DIRECTION.LEFT, 110, _options[0], _option_1)
		create_plus_choice_option(PLUS_CHOICE_DIRECTION.RIGHT, 110, _options[1], _option_2)
		create_plus_choice_option(PLUS_CHOICE_DIRECTION.UP, 35, _options[2], _option_3)
		create_plus_choice_option(PLUS_CHOICE_DIRECTION.DOWN, 35, _options[3], _option_4)
	
		overworld_dialog(global.dialogues.grass_land.interaction_6.not_moved)
	
		set_event_update(function(){
			if (move_wall){
				if (inst_movable_interactable_wall_1.y < 240){
					inst_movable_interactable_wall_1.y += 2
				}else{
					global.save_data.wall_1_moved = true
				}
			}
		})
		set_event_end_condition(function(){
			return (obj_game.dialog.is_finished() and (!move_wall or global.save_data.wall_1_moved))
		})
	}else{
		overworld_dialog(global.dialogues.grass_land.interaction_6.moved)
	}
}