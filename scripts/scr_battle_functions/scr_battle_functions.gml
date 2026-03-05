function death_reset(){
	perform_game_load()
	
	return 0
}

function battle_apply_rewards(_sound=true){
	global.player.gold += battle_gold
	global.player.exp += battle_exp
	global.player.next_exp -= battle_exp
	global.player.battle_atk = 0
	global.player.battle_def = 0
		
	if (global.player.next_exp <= 0){ //Here is where the stats are applied once the EXP is met.
		if (_sound){
			audio_play_sound(snd_player_love_up, 100, false)	
		}
			
		var _stats = global.stat_levels[global.player.lv]
			
		global.player.lv++
		global.player.atk = _stats.atk
		global.player.def = _stats.def
		global.player.next_exp += _stats.next_exp
		global.player.max_hp = _stats.max_hp
		global.player.hp_bar_width = _stats.hp_bar_width
	}
		
	battle_gold = 0
	battle_exp = 0
}

function battle_set_box_dialog(_dialogues, _x_offset=0, _face_sprite=undefined, _face_subimages=undefined){
	battle_dialog_x_offset = _x_offset
		
	battle_dialog.text_speed = 2
	battle_dialog.set_dialogues(_dialogues, obj_battle_box.box_size.x/2 - 15 - _x_offset/2, 0, _face_sprite, _face_subimages)
	battle_dialog.set_scale(2, 2)
	battle_dialog.set_container_sprite(-1)
	battle_dialog.set_container_tail_sprite(-1)
	battle_dialog.set_container_tail_mask_sprite(-1)
	battle_dialog.move_to(obj_battle_box.x - obj_battle_box.width/2 + 14.5 + battle_dialog_x_offset, obj_battle_box.y - obj_battle_box.height + 10)
		
	//By order of constant definition, BATTLE_STATE.END is the last integer that will keep the dialogs from progressing because it's the player moving in the UI or animations, the other states after that are meant that the player presses a button to advance the dialogs.
	if (battle_state <= BATTLE_STATE.END){
		battle_dialog.can_progress = false
	}
}

function battle_set_enemy_dialog(_enemy){
	if (typeof(_enemy.next_dialog) == "array"){
		_enemy.next_dialog[0] = "[font:" + string(int64(fnt_monster)) + "][color_rgb:0,0,0][asterisk:false]" + _enemy.next_dialog[0]
	}else{
		_enemy.next_dialog = "[font:" + string(int64(fnt_monster)) + "][color_rgb:0,0,0][asterisk:false]" + _enemy.next_dialog
	}
	
	var _dialog = new DialogSystem(_enemy.x + _enemy.bubble_x, _enemy.y + _enemy.bubble_y, _enemy.next_dialog, _enemy.bubble_width, 0, 1, 1,,,, _enemy.bubble_sprite, _enemy.bubble_tail_sprite, _enemy.bubble_tail_mask_sprite)
	
	_enemy.next_dialog = undefined
	
	array_push(battle_enemies_dialogs, _dialog)
}

function damage_player_bullet_instance(_bullet, _player){
	with (_player){
		var _prev_hp = global.player.hp
		global.player.hp = clamp(global.player.hp + ((_bullet.type == BULLET_TYPE.GREEN) ? _bullet.damage : -_bullet.damage), (get_battle_state() != BATTLE_STATE.ENEMY_ATTACK), global.player.max_hp)
		
		if (_prev_hp != global.player.hp){
			if (global.player.status_effect.type == PLAYER_STATUS_EFFECT.KARMIC_RETRIBUTION){
				global.player.status_effect.value = min(global.player.status_effect.value + _bullet.karma, _bullet.player.hp - 1, 40)
				_bullet.karma = min(_bullet.karma, 1) //There are more steps to karmic retribution but I'm doing it the simple way really.
			}
			
			if (_bullet.type == BULLET_TYPE.GREEN){
				audio_play_sound(snd_player_heal, 0, false)
			}else{
				audio_play_sound(snd_player_hurt, 0, false)
			}
			
			invulnerability_frames = global.player.invulnerability_frames
		}
	}
}
