function BattleSystem() constructor{
	battle_state = BATTLE_STATE.START
	battle_black_alpha = 1
	battle_button_order = []
	battle_selection = [0, 0, 0] //Buttons, enemy/spare/flee selection, act/item selection
	battle_can_flee = true
	battle_item_page = 1 //For the items in battle
	battle_current_box_dialog = ""
	battle_player_stats = {x: 30, y: 415, depth: 300}
	battle_player_attack = undefined
	battle_dialog_x_offset = 0
	battle_flee_chance = 100 //In Undertale Hardmode this is 0, normally it's 50 and increases by winning battles, decreases by fleeing battles.
	battle_flee_event_type = undefined
	battle_options_amount = 0 //Used for the menus
	battle_cleared_enemies = [] //Cleared as if either killed or spared.
	battle_enemies_dialogs = [] //Here all the enemy dialogs are created if they have any.
	battle_enemies_attacks = []
	battle_enemies_parts = []
	battle_selectable_enemies = []
	battle_dust_clouds = []
	battle_damage_text = []
	battle_bullets = [] //An array of all the bullets, that gets cleared after an attack.
	battle_exp = 0
	battle_gold = 0
	battle_fled = false
	anim_timer = 0
	
	battle_dialog = new DialogSystem(0, 0, [], 1)
	
	battle_init_function = undefined
	battle_end_function = undefined
	
	battle_only_attack = undefined
	is_battle_only_attack_undefined = true //Auxiliar of the other variable
	
	menu_attacks = [] //List of all active menu attacks, yeah you can basically put many at the same time if desired.
	menu_bullets = [] //For menu bullets
	
	step = function(){
		obj_game.depth = battle_player_stats.depth
		
		if (battle_state != BATTLE_STATE.START and battle_state != BATTLE_STATE.START_DODGE_ATTACK){
			if (is_battle_only_attack_undefined){
				var _length = array_length(global.battle_enemies)
				for (var _i=0; _i<_length; _i++){
					var _enemy = global.battle_enemies[_i]
				
					if (is_undefined(_enemy)){
						array_delete(global.battle_enemies, _i, 1)
					
						_i--
						_length--
					
						continue
					}
				
					if (!is_undefined(_enemy.step)){
						_enemy.step()
					}
				}
				
				_length = array_length(battle_cleared_enemies)
				for (var _i=0; _i<_length; _i++){
					var _enemy = battle_cleared_enemies[_i]
			
					if (!_enemy.spared and _enemy.last_animation_timer < sprite_get_height(_enemy.sprite_killed)){
						var _dust_pixels = _enemy.last_animation_timer
						var _offset_x = sprite_get_xoffset(_enemy.sprite_killed)
						var _offset_y = sprite_get_yoffset(_enemy.sprite_killed)
						
						array_push(battle_enemies_parts, {sprite: _enemy.sprite_killed, sprite_index: _enemy.sprite_killed_index, part: _enemy.last_animation_timer, x: _enemy.x - _offset_x, y: _enemy.y + (_dust_pixels - _offset_y)*_enemy.sprite_yscale, xscale: _enemy.sprite_xscale, yscale: _enemy.sprite_yscale, direction: irandom_range(60, 120), alpha: 1})
				
						_enemy.last_animation_timer += _enemy.dust_y_pixels_amount_per_frame
					}
				}
		
				_length = array_length(battle_enemies_parts)
				for (var _i=0; _i<_length; _i++){
					var _part = battle_enemies_parts[_i]
			
					_part.alpha -= 0.05
					var _movement = 2 - _part.alpha
					_part.x += _movement*dcos(_part.direction)
					_part.y -= _movement*dsin(_part.direction)
			
					if (_part.alpha <= 0){
						array_delete(battle_enemies_parts, _i, 1)
				
						_i--
						_length--
					}
				}
		
				_length = array_length(battle_dust_clouds)
				for (var _i=0; _i<_length; _i++){
					var _dust = battle_dust_clouds[_i]
			
					_dust.timer++
					_dust.x += 2*_dust.distance*dcos(_dust.direction)
					_dust.y -= 2*_dust.distance*dsin(_dust.direction)
			
					if (_dust.timer >= 15){
						array_delete(battle_dust_clouds, _i, 1)
				
						_i--
						_length--
					}
				}
		
				_length = array_length(battle_damage_text)
				for (var _i=0; _i<_length; _i++){
					var _text = battle_damage_text[_i]
			
					_text.timer++
			
					if (_text.timer >= 90){
						array_delete(battle_damage_text, _i, 1)
				
						_i--
						_length--
					}
				}
				
				_length = array_length(menu_attacks)
				for (var _i=0; _i<_length; _i++){
					var _menu_attack = menu_attacks[_i]
					
					if (!_menu_attack.menu_attack_done and !is_undefined(_menu_attack.step)){
						_menu_attack.step()
					}
				}
			}
			
			var _length = array_length(battle_bullets)
			for (var _i=0; _i<_length; _i++){
				var _bullet = battle_bullets[_i]
				
				if (!instance_exists(_bullet)){
					array_delete(battle_bullets, _i, 1)
					_i--
					_length--
				}
			}
			
			_length = array_length(menu_bullets)
			for (var _i=0; _i<_length; _i++){
				var _bullet = menu_bullets[_i]
				
				if (!instance_exists(_bullet)){
					array_delete(menu_bullets, _i, 1)
					_i--
					_length--
				}
			}
		}
		
		switch (battle_state){
			case BATTLE_STATE.START:{
				battle_exp = 0
				battle_gold = 0
				battle_flee_event_type = FLEE_EVENT.IMPROVED
				battle_fled = false
				battle_button_order = [btn_fight, btn_act, btn_item, btn_mercy]
				
				var _length = array_length(global.battle_enemies)
				var _x = 640/(_length + 1)
				var _to_check = []
				
				for (var _i=0; _i<_length; _i++){
					var _enemy = new Enemy(global.battle_enemies[_i], _x*(_i + 1), 240)
					_enemy.name = string_trim(_enemy.name)
				
					array_push(_to_check, _i)
				
					global.battle_enemies[_i] = _enemy
				}
				
				for (var _i=0; _i<_length - 1; _i++){
					var _count = 0
					var _enemy_1 = global.battle_enemies[_to_check[_i]]
					
					for (var _j=_i + 1; _j<_length; _j++){
						var _enemy_2 = global.battle_enemies[_to_check[_j]]
					
						if (_enemy_1.name == _enemy_2.name){
							_enemy_2.name += string_concat(" ", chr(66 + _count)) //Starts at B the chr()
							_count++
						
							array_delete(_to_check, _j, 1)
							_j--
							_length--
						}
					}
					
					if (_count > 0){
						_enemy_1.name += " A"
					}
				}
			} //No break
			case BATTLE_STATE.START_DODGE_ATTACK:{
				with (obj_player_battle){
					x = obj_game.battle_start_animation_player_heart_x
					y = obj_game.battle_start_animation_player_heart_y
				}
				
				is_battle_only_attack_undefined = is_undefined(battle_only_attack)
				if (!is_undefined(battle_init_function)){
					battle_init_function()
					battle_init_function = undefined
				}
				
				if (battle_state == BATTLE_STATE.START and is_battle_only_attack_undefined){
					battle_go_to_state(BATTLE_STATE.PLAYER_BUTTONS)
				}else if (!is_battle_only_attack_undefined){
					battle_state = BATTLE_STATE.ENEMY_ATTACK
					
					with (obj_battle_button){
						instance_destroy()
					}
					
					//Just in case you decided to populate these, won't allow it
					var _length = array_length(battle_enemies_dialogs)
					if (_length){
						array_delete(battle_enemies_dialogs, 0, _length)
					}
					_length = array_length(battle_enemies_attacks)
					if (_length){
						array_delete(battle_enemies_attacks, 0, _length)
					}
					
					if (typeof(battle_only_attack) == "array"){
						_length = array_length(battle_only_attack)
						for (var _i=0; _i<_length; _i++){
							array_push(battle_enemies_attacks, new EnemyAttack(battle_only_attack[_i], 0, undefined))
						}
					}else{
						array_push(battle_enemies_attacks, new EnemyAttack(battle_only_attack, 0, undefined))
					}
					
					with (obj_player_battle){
						x = obj_battle_box.x
						y = obj_battle_box.y - round(obj_battle_box.height)/2 - 5
					}
					
					with (obj_battle_box){
						width = box_size.x
						height = box_size.y
					}
				}
			break}
			case BATTLE_STATE.PLAYER_BUTTONS:{
				var _length = array_length(battle_enemies_dialogs)
				for (var _i=0; _i<_length; _i++){
					var _dialog = battle_enemies_dialogs[_i]
					_dialog.step()
				}
				
				if (global.left_button){
					audio_play_sound(snd_menu_selecting, 0, false)
					
					battle_selection[0]--
					
					if (battle_selection[0] <= -1){
						battle_selection[0] += battle_options_amount
					}
				}
				
				if (global.right_button){
					audio_play_sound(snd_menu_selecting, 0, false)
					
					battle_selection[0]++
					
					if (battle_selection[0] >= battle_options_amount){
						battle_selection[0] -= battle_options_amount
					}
				}
				
				var _button = battle_button_order[battle_selection[0]]
				
				if (global.confirm_button){
					audio_play_sound(snd_menu_confirm, 0, false)
					
					switch (_button.button_type){
						case BUTTON.MERCY:
							battle_go_to_state(BATTLE_STATE.PLAYER_MERCY)
						break
						case BUTTON.ITEM:
							battle_go_to_state(BATTLE_STATE.PLAYER_ITEM)
						break
						case BUTTON.ACT:
							battle_go_to_state(BATTLE_STATE.PLAYER_ENEMY_SELECT)
						break
						case BUTTON.FIGHT:
							battle_go_to_state(BATTLE_STATE.PLAYER_ENEMY_SELECT)
						break
					}	
				}
				
				with (obj_player_battle){
					image_alpha = 1
					x = _button.x + _button.heart_button_position_x
					y = _button.y + _button.heart_button_position_y
				}
			break}
			case BATTLE_STATE.PLAYER_ENEMY_SELECT:
			case BATTLE_STATE.PLAYER_MERCY:{
				var _length = array_length(battle_enemies_dialogs)
				for (var _i=0; _i<_length; _i++){
					var _dialog = battle_enemies_dialogs[_i]
					_dialog.step()
				}
				
				if (battle_options_amount > 0){
					if (global.up_button){
						audio_play_sound(snd_menu_selecting, 0, false)
					
						battle_selection[1]--
					
						if (battle_selection[1] <= -1){
							battle_selection[1] += battle_options_amount
						}
					}
				
					if (global.down_button){
						audio_play_sound(snd_menu_selecting, 0, false)
					
						battle_selection[1]++
					
						if (battle_selection[1] >= battle_options_amount){
							battle_selection[1] -= battle_options_amount
						}
					}
				
					if (global.confirm_button){
						audio_play_sound(snd_menu_confirm, 0, false)
					
						if (battle_state == BATTLE_STATE.PLAYER_ENEMY_SELECT){
							var _enemy = battle_selectable_enemies[battle_selection[1]]
							switch (battle_button_order[battle_selection[0]].button_type){
								case BUTTON.FIGHT:
									battle_go_to_state(BATTLE_STATE.PLAYER_ATTACK, _enemy)
								break
								case BUTTON.ACT:
									battle_go_to_state(BATTLE_STATE.PLAYER_ACT, _enemy)
								break
							}
						}else{
							switch (battle_selection[1]){
								case 0: //Spare
									battle_go_to_state(BATTLE_STATE.PLAYER_DIALOG_RESULT)
								break
								case 1: //Flee
									battle_go_to_state(BATTLE_STATE.PLAYER_FLEE)
								break
							}
						}
					}
				}
				
				if (global.cancel_button){
					audio_play_sound(snd_menu_selecting, 0, false)
					
					battle_go_to_state(BATTLE_STATE.PLAYER_BUTTONS)
				}
				
				with (obj_player_battle){
					x = 72
					y = 286 + 32*other.battle_selection[1]
				}					
			break}
			case BATTLE_STATE.PLAYER_ITEM:{
				var _amount_items = array_length(global.player.inventory)
				var _page = battle_item_page
				
				if (global.left_button){
					if (battle_selection[2]%2 == 1){
						audio_play_sound(snd_menu_selecting, 0, false)
						
						battle_selection[2]--
					}else if (battle_selection[2]%2 == 0 and battle_item_page > 1){
						audio_play_sound(snd_menu_selecting, 0, false)
						
						battle_selection[2]++
						battle_item_page--
					}
				}
				
				if (global.right_button){
					if (battle_selection[2]%2 == 0 and _amount_items > battle_selection[2] + 4*(battle_item_page - 1) + 1){
						audio_play_sound(snd_menu_selecting, 0, false)
						
						battle_selection[2]++
					}else if (battle_selection[2]%2 == 1 and _amount_items > 4*battle_item_page){
						audio_play_sound(snd_menu_selecting, 0, false)
						
						if (_amount_items > 4*battle_item_page + 2 and battle_selection[2] == 3){
							battle_selection[2] = 2
						}else{
							battle_selection[2] = 0
						}
						
						battle_item_page++
					}
				}
				
				if (global.up_button){
					if (battle_selection[2] < 2 and _amount_items > battle_selection[2] + 2 + 4*(battle_item_page - 1)){
						audio_play_sound(snd_menu_selecting, 0, false)
						
						battle_selection[2] += 2
					}else if (battle_selection[2] > 1){
						audio_play_sound(snd_menu_selecting, 0, false)
						
						battle_selection[2] -= 2
					}
				}
				
				if (global.down_button){
					if (battle_selection[2] < 2 and _amount_items > battle_selection[2] + 2 + 4*(battle_item_page - 1)){
						audio_play_sound(snd_menu_selecting, 0, false)
						
						battle_selection[2] += 2
					}else if (battle_selection[2] > 1){
						audio_play_sound(snd_menu_selecting, 0, false)
						
						battle_selection[2] -= 2
					}
				}
				
				if (_page != battle_item_page){
					var _text = "[skip:false][asterisk:false]"
					var _page_index = battle_item_page - 1
					
					for (var _i=4*_page_index; _i<min(_amount_items, 4*battle_item_page); _i++){
						var _item_name = undefined
						if (global.battle_serious_mode){
							_item_name = global.item_pool[global.player.inventory[_i]][$"serious name"]
							
							if (is_undefined(_item_name)){
								_item_name = global.item_pool[global.player.inventory[_i]][$"short name"]
							}
						}else{
							_item_name = global.item_pool[global.player.inventory[_i]][$"short name"]
						}
						
						if (is_undefined(_item_name)){
							_item_name = global.item_pool[global.player.inventory[_i]][$"inventory name"]
						}
						
						_text += "   * " + _item_name + string_repeat(" ", max(11 - string_length(_item_name), 0))
						
						if ((_i + 1)%2 == 0){
							_text += "\n"
						}
					}
					
					_text += string_repeat("\n", ceil((4 - (min(_amount_items, 4 + 4*_page_index) - 4*_page_index))/2)) + string_repeat(" ", 21) + "PAGE " + string(battle_item_page)
					
					battle_set_box_dialog(_text)
				}
				
				if (global.confirm_button and _amount_items > 0){
					audio_play_sound(snd_menu_confirm, 100, false)
					
					battle_go_to_state(BATTLE_STATE.PLAYER_DIALOG_RESULT)
				}
				
				if (global.cancel_button){
					audio_play_sound(snd_menu_selecting, 100, false)
					
					battle_go_to_state(BATTLE_STATE.PLAYER_BUTTONS)
				}
				
				with (obj_player_battle){
					x = 72 + 256*(other.battle_selection[2]%2)
					y = 286 + 32*floor(other.battle_selection[2]/2)
				}
			break}
			case BATTLE_STATE.PLAYER_ATTACK:{
				var _length = array_length(battle_enemies_dialogs)
				for (var _i=0; _i<_length; _i++){
					var _dialog = battle_enemies_dialogs[_i]
					_dialog.step()
				}
				
				battle_player_attack.step()
			break}
			case BATTLE_STATE.PLAYER_WON:{
				if (global.confirm_button and battle_dialog.is_done_displaying()){
					battle_go_to_state(BATTLE_STATE.END)
				}
			break}
			case BATTLE_STATE.PLAYER_FLEE:{
				var _length = array_length(battle_enemies_dialogs)
				for (var _i=0; _i<_length; _i++){
					var _dialog = battle_enemies_dialogs[_i]
					_dialog.step()
				}
				
				battle_flee_event.step()
				
				if (battle_flee_event.is_finished){
					if (battle_flee_event.success){
						battle_fled = true
						
						battle_go_to_state(BATTLE_STATE.END)
					}else{
						battle_go_to_state(BATTLE_STATE.ENEMY_DIALOG)
					}
				}
			break}
			case BATTLE_STATE.PLAYER_ACT:{
				var _length = array_length(battle_enemies_dialogs)
				for (var _i=0; _i<_length; _i++){
					var _dialog = battle_enemies_dialogs[_i]
					_dialog.step()
				}
				
				if (battle_options_amount > 0){
					if (global.left_button){
						if (battle_selection[2]%2 == 1){
							audio_play_sound(snd_menu_selecting, 0, false)
						
							battle_selection[2]--
						}else if (battle_selection[2]%2 == 0 and battle_options_amount > battle_selection[2] + 1){
							audio_play_sound(snd_menu_selecting, 0, false)
						
							battle_selection[2]++
						}
					}
				
					if (global.right_button){
						if (battle_selection[2]%2 == 0 and battle_options_amount > battle_selection[2] + 1){
							audio_play_sound(snd_menu_selecting, 0, false)
						
							battle_selection[2]++
						}else if (battle_selection[2]%2 == 1){
							audio_play_sound(snd_menu_selecting, 0, false)
						
							battle_selection[2]--
						}
					}
				
					if (global.up_button){
						if (battle_selection[2] > 1){
							audio_play_sound(snd_menu_selecting, 0, false)
						
							battle_selection[2] -= 2
						}else{
							audio_play_sound(snd_menu_selecting, 0, false)
						
							battle_selection[2] = battle_options_amount + battle_options_amount%2 + battle_selection[2]*(1 - 2*(battle_options_amount%2)) - 2
						}
					}
				
					if (global.down_button){
						if (battle_options_amount <= battle_selection[2] + 2){
							audio_play_sound(snd_menu_selecting, 0, false)
						
							battle_selection[2] = battle_selection[2]%2
						}else{
							audio_play_sound(snd_menu_selecting, 0, false)
						
							battle_selection[2] += 2
						}
					}
				
					if (global.confirm_button){
						audio_play_sound(snd_menu_confirm, 0, false)
					
						battle_go_to_state(BATTLE_STATE.PLAYER_DIALOG_RESULT, battle_selectable_enemies[battle_selection[1]])
					}
				}
				
				if (global.cancel_button){
					audio_play_sound(snd_menu_selecting, 0, false)
					
					battle_go_to_state(BATTLE_STATE.PLAYER_ENEMY_SELECT)
				}
				
				with (obj_player_battle){
					x = 72 + 256*(other.battle_selection[2]%2)
					y = 286 + 32*floor(other.battle_selection[2]/2)
				}
			break}
			case BATTLE_STATE.PLAYER_DIALOG_RESULT:{
				var _length = array_length(battle_enemies_dialogs)
				for (var _i=0; _i<_length; _i++){
					var _dialog = battle_enemies_dialogs[_i]
					_dialog.step()
				}
				
				if (battle_dialog.is_finished()){
					battle_go_to_state(BATTLE_STATE.ENEMY_DIALOG)
				}
			break}
			case BATTLE_STATE.ENEMY_DIALOG:{
				var _length = array_length(battle_enemies_dialogs)
				var _dialog_finished = true
				for (var _i=0; _i<_length; _i++){
					var _dialog = battle_enemies_dialogs[_i]
					_dialog.step()
					
					if (!_dialog.is_finished()){
						_dialog_finished = false
					}
				}
				
				if (_dialog_finished){
					battle_go_to_state(BATTLE_STATE.ENEMY_ATTACK)
				}
				
				with (obj_player_battle){
					x = obj_battle_box.x
					y = obj_battle_box.y - round(obj_battle_box.height)/2 - 5
				}
			break}
			case BATTLE_STATE.TURN_END:{
				var _length = array_length(battle_enemies_dialogs)
				var _dialog_finished = true
				for (var _i=0; _i<_length; _i++){
					var _dialog = battle_enemies_dialogs[_i]
					_dialog.step()
					
					if (!_dialog.is_finished()){
						_dialog_finished = false
					}
				}
				
				if (battle_dialog.is_finished() and _dialog_finished){
					battle_go_to_state(BATTLE_STATE.PLAYER_BUTTONS)
				}
			break}
			case BATTLE_STATE.END_DODGE_ATTACK:
			case BATTLE_STATE.ENEMY_ATTACK:{
				var _length = array_length(battle_enemies_attacks)
				var _attacks_done = true
				for (var _i=0; _i<_length; _i++){
					var _attack = battle_enemies_attacks[_i]
					_attack.step()
					
					if (_attacks_done and !_attack.attack_done){
						_attacks_done = false
					}
				}
				
				if (battle_state == BATTLE_STATE.ENEMY_ATTACK){
					if (_attacks_done){
						if (is_battle_only_attack_undefined){
							for (var _i=0; _i<_length; _i++){
								var _attack = battle_enemies_attacks[_i]
								if (!is_undefined(_attack.cleanup)){
									_attack.cleanup()
								}
								
								delete battle_enemies_attacks[_i]
							}
							
							if (_length > 0){
								array_delete(battle_enemies_attacks, 0, _length)
							}
						
							battle_go_to_state(BATTLE_STATE.TURN_END)
						}else{
							battle_state = BATTLE_STATE.END_DODGE_ATTACK
						
							if (!is_undefined(battle_end_function)){
								start_room_function = function(){
									battle_end_function()
									battle_end_function = undefined
								}
							}
						
							anim_timer = 0
						}
					}
					break
				}
			}
			case BATTLE_STATE.END:{
				anim_timer++
				if (anim_timer == 20){
					obj_player_overworld.image_alpha = 1
					
					while (!battle_dialog.is_finished()){
						battle_dialog.next_dialog()
					}
					
					var _length = array_length(battle_enemies_dialogs)
					for (var _i=0; _i<_length; _i++){
						array_pop(battle_enemies_dialogs)
					}
					
					_length = array_length(battle_dust_clouds)
					for (var _i=0; _i<_length; _i++){
						array_pop(battle_dust_clouds)
					}
					
					_length = array_length(battle_bullets) //You never know when some of these bullets was set to persist
					for (var _i=_length - 1; _i>=0; _i--){
						var _bullet = battle_bullets[_i]
					
						if (instance_exists(_bullet)){
							instance_destroy(_bullet)
						}
					
						array_pop(battle_bullets)
					}
					
					_length = array_length(battle_enemies_attacks)
					for (var _i=_length - 1; _i>=0; _i--){
						array_pop(battle_enemies_attacks)
					}
					
					obj_game.anim_timer = 0
					obj_game.state = GAME_STATE.BATTLE_END
					
					room_goto(obj_game.player_prev_room)
				}
			break}
		}
		
		battle_dialog.step()
	}
	
	draw = function(){
		battle_dialog.move_to(obj_battle_box.x - obj_battle_box.width/2 + 14.5 + battle_dialog_x_offset, obj_battle_box.y - obj_battle_box.height + 10)
		
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		draw_set_font(fnt_battle_status)
		
		draw_text(battle_player_stats.x + 214, battle_player_stats.y - 10, global.UI_texts.hp)
		
		var _hp_bar_color = global.player.hp_bar_color
		var _x_offset = 0
		
		draw_healthbar(battle_player_stats.x + 245, battle_player_stats.y + 6, battle_player_stats.x + 245 + global.player.hp_bar_width, battle_player_stats.y - 16, 100*global.player.hp/global.player.max_hp, c_red, _hp_bar_color, _hp_bar_color, 0, true, false)
		
		switch (global.player.status_effect.type){
			case PLAYER_STATUS_EFFECT.KARMIC_RETRIBUTION:{
				var _kr_color = global.player.status_effect.color
				var _kr_amount = global.player.status_effect.value
				_x_offset += 32
				
				draw_healthbar(battle_player_stats.x + 245, battle_player_stats.y + 6, battle_player_stats.x + 245 + global.player.hp_bar_width*global.player.hp/global.player.max_hp, battle_player_stats.y - 16, 100*_kr_amount/global.player.hp, c_red, _kr_color, _kr_color, 1, false, false)
				
				draw_text(battle_player_stats.x + 255 + battle_player_stats.health_size, battle_player_stats.y - 10, global.UI_texts[$"status effects"][$"karmic retribution"])
				
				if (_kr_amount > 0){
					draw_set_color(_kr_color)
				}
			break}
		}
		
		draw_set_font(fnt_mars_needs_cunnilingus)
		
		draw_text(battle_player_stats.x + 260 + _x_offset + global.player.hp_bar_width, battle_player_stats.y - 14, string_concat(global.player.hp, " / ", global.player.max_hp))
		
		draw_set_color(c_white)
		
		draw_text(battle_player_stats.x, battle_player_stats.y - 14, global.player.name)
		draw_text(battle_player_stats.x + 102, battle_player_stats.y - 14, global.UI_texts.lv)
		draw_text(battle_player_stats.x + 146, battle_player_stats.y - 14, global.player.lv)
		
		var _length = array_length(global.battle_enemies)
		for (var _i=0; _i<_length; _i++){
			var _enemy = global.battle_enemies[_i]
			
			if (is_undefined(_enemy)){
				continue
			}
			
			if (!is_undefined(_enemy.draw)){
				_enemy.draw()
			}
		}
		
		_length = array_length(battle_cleared_enemies)
		for (var _i=0; _i<_length; _i++){
			var _enemy = battle_cleared_enemies[_i]
			
			if (_enemy.spared){
				draw_sprite_ext(_enemy.sprite_spared, _enemy.sprite_spared_index, _enemy.x, _enemy.y, _enemy.sprite_xscale, _enemy.sprite_yscale, 0, c_gray, 1)
			}else if (_enemy.last_animation_timer < sprite_get_height(_enemy.sprite_killed)){
				var _dust_pixels = _enemy.last_animation_timer
				var _offset_x = sprite_get_xoffset(_enemy.sprite_killed)
				var _offset_y = sprite_get_yoffset(_enemy.sprite_killed)
				
				draw_sprite_part_ext(_enemy.sprite_killed, _enemy.sprite_killed_index, 0, _dust_pixels, sprite_get_width(_enemy.sprite_killed), sprite_get_height(_enemy.sprite_killed), _enemy.x - _offset_x, _enemy.y + (_dust_pixels - _offset_y)*_enemy.sprite_yscale, _enemy.sprite_xscale, _enemy.sprite_yscale, c_white, 1)
			}
		}
		
		_length = array_length(battle_enemies_parts)
		for (var _i=0; _i<_length; _i++){
			var _part = battle_enemies_parts[_i]
			
			draw_sprite_part_ext(_part.sprite, _part.sprite_index, 0, _part.part, sprite_get_width(_part.sprite), 1, _part.x, _part.y, _part.xscale, _part.yscale, c_white, _part.alpha)
		}
		
		_length = array_length(battle_dust_clouds)
		for (var _i=0; _i<_length; _i++){
			var _dust = battle_dust_clouds[_i]
			var _size = 1 + (1 - _dust.distance)*_dust.timer/10
			
			draw_sprite_ext(spr_dust_cloud, floor(_dust.timer/5), _dust.x, _dust.y, _size, _size, 0, c_white, 1)
		}
		
		_length = array_length(battle_damage_text)
		for (var _i=0; _i<_length; _i++){
			var _text = battle_damage_text[_i]
			var _timer = min(_text.timer/60, 1)
			
			draw_set_halign(fa_center)
			draw_set_valign(fa_bottom)
			draw_set_font(fnt_hachiko)
			
			draw_text_color(_text.x, _text.y - 10 - 20*dsin(180*_timer), _text.text, _text.text_color, _text.text_color, _text.text_color, _text.text_color, 1)
			if (_text.draw_bar){
				draw_healthbar(_text.x - _text.bar_width/2, _text.y + 5, _text.x + _text.bar_width/2, _text.y - 13, 100*(_text.hp - _text.damage*_timer)/_text.max_hp, c_red, _text.bar_color, _text.bar_color, 0, true, true)
			}
		}
		
		_length = array_length(battle_enemies_dialogs)
		for (var _i=0; _i<_length; _i++){
			var _dialog = battle_enemies_dialogs[_i]
			if (is_undefined(_dialog)){
				continue
			}
			
			_dialog.draw()
		}
		
		_length = array_length(battle_enemies_attacks)
		for (var _i=0; _i<_length; _i++){
			var _attack = battle_enemies_attacks[_i]
			
			if (!is_undefined(_attack.draw)){
				_attack.draw()
			}
		}
	}
	
	draw_gui = function(){
		battle_dialog.draw()
		
		//Special effects of the battle can be placed here.
		if (battle_black_alpha > 0){
			draw_sprite_ext(spr_pixel, 0, 0, 0, 640, 480, 0, c_black, battle_black_alpha)
				
			with (obj_player_battle){
				draw_self()
			}
				
			battle_black_alpha -= 0.05
		}
		
		switch (battle_state){
			case BATTLE_STATE.END_DODGE_ATTACK:
			case BATTLE_STATE.END:{
				draw_sprite_ext(spr_pixel, 0, 0, 0, 640, 480, 0, c_black, anim_timer/20)
			break}
		}
	}
	
	draw_in_box = function(){
		switch (battle_state){
			case BATTLE_STATE.PLAYER_ENEMY_SELECT:
				if (battle_button_order[battle_selection[0]].button_type == BUTTON.FIGHT){
					var _length = array_length(battle_selectable_enemies)
					for (var _i=0; _i<_length; _i++){
						var _enemie = battle_selectable_enemies[_i]
				
						if (_enemie.show_hp){
							draw_healthbar(other.x + 46, other.y - 93 + 36*_i, other.x + 46 + _enemie.hp_bar_width, other.y - 111 + 36*_i, 100*_enemie.hp/_enemie.max_hp, c_red, _enemie.hp_bar_color, _enemie.hp_bar_color, 0, true, false)
						}
					}
				}
			break
			case BATTLE_STATE.PLAYER_ATTACK:
				battle_player_attack.draw()
			break
		}
	}

	clear_battle = function(){
		var _length = array_length(global.battle_enemies)
		for (var _i=0; _i<_length; _i++){
			array_pop(global.battle_enemies)
		}
					
		_length = array_length(battle_enemies_dialogs)
		for (var _i=0; _i<_length; _i++){ //This one already got cleared before getting here, but just in case somehow something trigger as you're still in the battle room, clear it again.
			array_pop(battle_enemies_dialogs)
		}
				
		_length = array_length(battle_cleared_enemies)
		for (var _i=0; _i<_length; _i++){
			array_pop(battle_cleared_enemies)
		}
				
		_length = array_length(battle_dust_clouds)
		for (var _i=0; _i<_length; _i++){
			array_pop(battle_dust_clouds)
		}
	}
}