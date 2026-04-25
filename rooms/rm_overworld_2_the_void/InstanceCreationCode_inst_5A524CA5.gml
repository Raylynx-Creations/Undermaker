trigger_function = function(){
	var _end_room = undefined
	var _start_room = undefined
	var _after_transition = undefined
	
	if (!global.save_data.cutscene_1){
		_start_room = function(){
			with (inst_trigger_hall_right){
				entity = instance_create_layer(1480, obj_player_overworld.y, "Collisions", obj_kris_dog_group)
				entity.image_xscale = -2
				entity.image_yscale = 2
				add_instance_reference(entity.id, "inst_outlander")
				
				entity.interaction = function(){
					overworld_dialog(global.dialogues.hot_room.outlander.interaction)
				}
				
				camera_set_view_target(view_camera[0], entity)
				camera_set_view_border(view_camera[0], 300, 999)
			}
		}
		
		_after_transition = function(){
			with (obj_game){
				timer = -60
				
				state = GAME_STATE.EVENT
			
				event_update = function(){
					timer++
					
					var _entity = inst_trigger_hall_right.entity
					
					if (timer > 0 and timer <= 60){
						_entity.image_index = 1
						_entity.x++
					}else if (timer == 61){
						_entity.image_index = 0
					}else if (timer == 120){
						//It works as well if you bind the instance itself directly, cause it holds the id directly that.
						overworld_dialog(global.dialogues.hot_room.outlander.dialog_1)
					}else if (timer == 121){
						if (!dialog.is_finished()){
							timer--
						}
					}else if (timer > 180){
						if (timer <= 240){
							_entity.image_index = 1
							_entity.x += 0.5
						}else if (timer == 241){
							_entity.image_index = 0
						}else if (timer > 300){
							if (timer <= 360){
								_entity.image_index = 1
								_entity.x += 0.5
							}else if (timer == 361){
								_entity.image_index = 0
							}else if (timer == 420){
								overworld_dialog(global.dialogues.hot_room.outlander.dialog_2)
								camera_set_view_target(view_camera[0], -1)
							}else if (timer == 421){
								if (!dialog.is_finished()){
									timer--
								}
							}else if (timer > 480 and timer <= 600){
								_entity.x = irandom_range(1598, 1602)
								_entity.y = obj_player_overworld.y + irandom_range(-2, 2)
							}else if (timer == 601){
								audio_play_sound(snd_switch_flip, 100, false)
								
								_entity.sprite_index = spr_rock
								_entity.image_xscale = 2
								_entity.x = 1560
								_entity.y = obj_player_overworld.y
							}else if (timer >= 661){
								camera_set_view_target(view_camera[0], obj_player_overworld)
								camera_set_view_border(view_camera[0], 999, 999)
								camera_set_view_speed(view_camera[0], 0.5, 0.5)
								
								if (camera_get_view_x(view_camera[0]) == 1280){
									camera_set_view_speed(view_camera[0], -1, -1)
									
									obj_player_overworld.player_sprite_reset()
									
									global.save_data.cutscene_1 = true
								}
							}
						}
					}
				}
				
				event_end_condition = function(){
					return (timer >= 661 and camera_get_view_x(view_camera[0]) == 1280)
				}
			}
		}
	}
	
	change_room(rm_overworld_3_hallway, inst_spawn_point_hall_0,,,,, _end_room, _start_room, _after_transition)
}