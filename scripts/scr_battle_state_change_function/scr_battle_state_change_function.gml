function battle_go_to_state(_state, _enemy=undefined){
	with (obj_game.battle_system){
		if (!is_undefined(battle_only_attack)){
			return
		}
		var _prev_state = battle_state
		battle_state = _state

		switch (_state){
			case BATTLE_STATE.PLAYER_BUTTONS:{
				battle_options_amount = array_length(battle_button_order)
				
				var _length = array_length(global.battle_enemies)
				var _enemies_still_available = false
				var _position = 0
				for (var _i=0; _i<_length; _i++){
					_enemy = global.battle_enemies[_i]
					
					if (is_undefined(_enemy)){
						continue
					}
					
					if (!is_undefined(_enemy.turn_starts)){
						_enemy.turn_starts()
					}
					
					if ((_prev_state == BATTLE_STATE.START or _prev_state == BATTLE_STATE.TURN_END) and !is_undefined(_enemy.next_menu_attack)){
						array_push(menu_attacks, new MenuAttack(_enemy.next_menu_attack, _position, calculate_enemy_damage_amount(_enemy)))
						
						_enemy.next_menu_attack = undefined
						_position++
					}
					
					if (_enemy.hp <= 0){
						battle_kill_enemy(_i)
					}else if (_enemy.spared){
						battle_forgive_enemy(_i)
					}else{
						_enemies_still_available = true
					}
				}
				
				if (_enemies_still_available){
					battle_set_box_dialog(battle_current_box_dialog)
				}else{
					battle_go_to_state(BATTLE_STATE.PLAYER_WON)
				}
			break}
			case BATTLE_STATE.PLAYER_ENEMY_SELECT:{
				if (_prev_state != BATTLE_STATE.PLAYER_ACT){
					battle_selection[1] = 0
				}
				battle_options_amount = 0
				
				var _length = array_length(battle_selectable_enemies)
				for (var _i=0; _i<_length; _i++){
					array_pop(battle_selectable_enemies)
				}
				
				_length = array_length(global.battle_enemies)
				var _to_check = []
				var _extra_letters = []
				
				for (var _i=0; _i<_length; _i++){
					array_push(_to_check, _i)
					array_push(_extra_letters, "")
				}
				
				for (var _i=0; _i<_length - 1; _i++){
					var _count = 0
					var _id = _to_check[_i]
					var _enemy_1 = global.battle_enemies[_id]
					
					for (var _j=_i + 1; _j<_length; _j++){
						var _id2 = _to_check[_j]
						var _enemy_2 = global.battle_enemies[_id2]
					
						if (_enemy_1.name == _enemy_2.name){
							_extra_letters[_id2] = string_concat(" ", chr(66 + _count)) //Starts at B the chr()
							_count++
						
							array_delete(_to_check, _j, 1)
							_j--
							_length--
						}
					}
					
					if (_count > 0){
						_extra_letters[_id] = " A"
					}
				}
				
				var _aux_i = 0
				_length = array_length(global.battle_enemies)
				for (var _i=0; _i<_length; _i++){
					_enemy = global.battle_enemies[_i]
					
					if (_enemy.selectionable){
						battle_options_amount++
						
						array_push(battle_selectable_enemies, _enemy)
					}else{
						array_delete(_extra_letters, _i - _aux_i, 1)
						
						_aux_i++
					}
				}
				
				var _text = "[skip:false][asterisk:false]   "
				
				if (battle_options_amount == 0){
					_text += "[color_rgb:127,127,127]* " + global.UI_texts[$"battle no enemy"]
				}else{
					_length = array_length(battle_selectable_enemies)
					for (var _i=0; _i<_length; _i++){
						_enemy = battle_selectable_enemies[_i]
					
						if (is_undefined(_enemy)){
							continue
						}
					
						if (_enemy.can_spare){
							_text += "[color_rgb:255,255,0]* " + _enemy.name + _extra_letters[_i] + "[color_rgb:255,255,255]"
						}else{
							_text += "* " + _enemy.name + _extra_letters[_i]
						}
					
						if (_i + 1 < _length){
							_text += "\r   "
						}
					}
				}
				
				battle_set_box_dialog(_text)
			break}
			case BATTLE_STATE.PLAYER_ATTACK:{
				battle_dialog.next_dialog(false)
				
				obj_player_battle.image_alpha = 0
				battle_resize_box(565, 130)
				
				battle_player_attack = new PlayerAttack(global.player.weapon, _enemy)
			break}
			case BATTLE_STATE.PLAYER_ACT:{
				battle_selection[2] = 0
				battle_options_amount = array_length(_enemy.act_commands)
				
				var _text = "[skip:false][asterisk:false]"
				if (battle_options_amount == 0){
					_text += "[color_rgb:127,127,127]* " + global.UI_texts[$"battle no acts"]
				}else{
					for (var _i=0; _i<battle_options_amount; _i++){
						var _act_command = global.UI_texts[$"battle acts"][_enemy.act_commands[_i]]
						_text += "   * " + _act_command + string_repeat(" ", max(11 - string_length(_act_command), 0))
					
						if ((_i + 1)%2 == 0){
							_text += "\n"
						}
					}
				}
				
				battle_set_box_dialog(_text)
			break}
			case BATTLE_STATE.PLAYER_ITEM:{
				battle_selection[2] = 0
				
				var _amount_items = array_length(global.player.inventory)
				if (_amount_items > 0){
					var _text = "[skip:false][asterisk:false]"
					battle_item_page = min(battle_item_page, ceil(_amount_items/4))
					
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
					
					_text += string_repeat("\n", ceil((4 - (min(_amount_items, 4*battle_item_page) - 4*_page_index))/2)) + string_repeat(" ", 21) + "PAGE " + string(battle_item_page)
					
					battle_set_box_dialog(_text)
				}else{
					var _randmsg = global.UI_texts[$"no items"]
					if (global.battle_serious_mode){
						_randmsg = _randmsg.serious
					}else{
						_randmsg = _randmsg.normal
					}
					
					var _msg = _randmsg[irandom(array_length(_randmsg) - 1)]
					var _text = "[skip:false][color_rgb:127,127,127][apply_to_asterisk]" + _msg
					
					battle_set_box_dialog(_text, 48)
				}
			break}
			case BATTLE_STATE.PLAYER_MERCY:{
				battle_selection[1] = 0
				battle_options_amount = 1 + battle_can_flee
				
				var _can_spare = false
				var _length = array_length(global.battle_enemies)
				for (var _i=0; _i<_length; _i++){
					_enemy = global.battle_enemies[_i]
					
					if (is_undefined(_enemy)){
						continue
					}
					
					if (_enemy.can_spare){
						_can_spare = true
						
						break
					}
				}
				
				var _text = "[skip:false][asterisk:false]"
				if (_can_spare){
					_text += "   [color_rgb:255,255,0]* " + global.UI_texts[$"battle spare"] + "[color_rgb:255,255,255]"
				}else{
					_text += "   * " + global.UI_texts[$"battle spare"]
				}
				
				if (battle_can_flee){
					_text += "\r   * " + global.UI_texts[$"battle flee"]
				}
				
				battle_set_box_dialog(_text)
			break}
			case BATTLE_STATE.PLAYER_WON:{
				battle_resize_box(565, 130)
				battle_move_box_to(320, 390)
				battle_rotate_box_to(0)
				battle_reset_box_polygon_points()
				battle_set_player_status_effect()
				
				if (obj_game.battle_pause_music){
					obj_game.battle_music_system.stop_music()
				}
				
				obj_player_battle.image_alpha = 0
				
				var _victory_text = string_replace("[no_skip]" + string_replace(global.UI_texts[$"battle won"], "[ExpWon]", battle_exp), "[GoldWon]", battle_gold)
				
				if (global.player.next_exp - battle_exp <= 0){
					_victory_text += "\n" + global.UI_texts[$"battle love up"]
				}
				
				battle_apply_rewards()
				battle_set_box_dialog(_victory_text)
			break}
			case BATTLE_STATE.PLAYER_FLEE:{
				obj_player_battle.sprite_index = spr_player_heart_run_away
				obj_player_battle.image_index = 0
				obj_player_battle.image_alpha = 1
				
				//By default a dialog is given to you and if the flee was successful as well, you can do whatever you want with it on the flee event if you desire a different dialog and outcome.
				var _success = (irandom(99) <= battle_flee_chance)
				var _enemies_allow_flee = true
				battle_do_not_modify_flee_chance = false
				
				var _length = array_length(global.battle_enemies)
				for (var _i=0; _i<_length; _i++){
					_enemy = global.battle_enemies[_i]
					
					if (is_undefined(_enemy)){
						continue
					}
					
					if (!is_undefined(_enemy.flee)){
						_enemy.flee()
					}
					
					if (!_enemy.can_player_flee){
						_enemies_allow_flee = false
					}
				}
				
				if (_enemies_allow_flee){
					_success = true
					battle_do_not_modify_flee_chance = true
				}
				
				var _flee_dialog = global.UI_texts[$"battle flee dialogs"]
				_flee_dialog = _flee_dialog[irandom(array_length(_flee_dialog) - 1)]
				
				if (_success){
					if (battle_exp > 0 or battle_gold > 0){
						_flee_dialog += "\n" + string_replace(string_replace(global.UI_texts[$"battle flee earning"], "[ExpWon]", battle_exp), "[GoldWon]", battle_gold)
						
						if (global.player.next_exp - battle_exp <= 0){
							_flee_dialog += "\n" + global.UI_texts[$"battle love up"]
						}
						
						battle_apply_rewards()
					}
				}
				
				battle_set_box_dialog("[skip:false]" + _flee_dialog)
				
				battle_flee_event = new FleeEvent(battle_flee_event_type, _success)
				
				if (battle_flee_event.is_finished){
					battle_go_to_state(BATTLE_STATE.ENEMY_DIALOG)
				}
			break}
			case BATTLE_STATE.PLAYER_DIALOG_RESULT:{
				obj_player_battle.image_alpha = 0
				
				switch (_prev_state){
					case BATTLE_STATE.PLAYER_ACT:
						var _dialog = _enemy.act(_enemy.act_commands[battle_selection[2]])
						
						if (!is_undefined(_dialog)){
							battle_set_box_dialog(_dialog)
						}else{
							battle_dialog.next_dialog(false)
						}
					break
					case BATTLE_STATE.PLAYER_ITEM:
						_dialog = use_item(battle_selection[2] + 4*(battle_item_page - 1)) //This returns an array of the dialog and the item index that it was, don't get confused by the name of the variable.
						var _item_index = _dialog[1]
						_dialog = _dialog[0] //It eventually holds the dialog only.
						
						var _length = array_length(global.battle_enemies)
						for (var _i=0; _i<_length; _i++){
							_enemy = global.battle_enemies[_i]
							
							if (is_undefined(_enemy)){
								continue
							}
							
							if (!is_undefined(_enemy.item_used)){
								_enemy.item_used(_item_index)
							}
						}
						
						battle_set_box_dialog(_dialog)
					break
					case BATTLE_STATE.PLAYER_MERCY:
						battle_dialog.next_dialog(false)
						
						_length = array_length(global.battle_enemies)
						for (var _i=0; _i<_length; _i++){
							_enemy = global.battle_enemies[_i]
							
							if (is_undefined(_enemy)){
								continue
							}
							
							if (!is_undefined(_enemy.spare)){
								_enemy.spare()
							}
							
							if (_enemy.can_spare){
								_enemy.spared = true
							}
						}
					break
				}
				
				var _length = array_length(battle_enemies_dialogs)
				for (var _i=0; _i<_length; _i++){
					if (battle_enemies_dialogs[_i].is_finished()){
						array_delete(battle_enemies_dialogs, _i, 1)
						
						_i--
						_length--
					}
				}
				
				if (battle_dialog.is_finished()){
					battle_go_to_state(BATTLE_STATE.ENEMY_DIALOG)
				}
			break}
			case BATTLE_STATE.ENEMY_DIALOG:{
				inst_battle_box.depth = 200
				
				var _length = array_length(battle_enemies_dialogs)
				if (_length){
					array_delete(battle_enemies_dialogs, 0, _length)
				}
				
				battle_resize_box(155, 130)
				
				with (obj_player_battle){
					x = obj_battle_box.x
					y = obj_battle_box.y - round(obj_battle_box.height)/2 - 5
				}
				
				battle_dialog.next_dialog(false)
				
				_length = array_length(global.battle_enemies)
				for (var _i=0; _i<_length; _i++){
					_enemy = global.battle_enemies[_i]
					
					if (is_undefined(_enemy)){
						continue
					}
					
					if (!is_undefined(_enemy.dialog_starts)){
						_enemy.dialog_starts()
					}
					
					var _type_dialog = typeof(_enemy.next_dialog)
					
					if (_type_dialog == "array" or _type_dialog == "string"){
						battle_set_enemy_dialog(_enemy)
					}else if (_enemy.hp <= 0){
						battle_kill_enemy(_i)
					}else if (_enemy.spared){
						battle_forgive_enemy(_i)
					}
				}
				
				with (obj_player_battle){
					sprite_index = spr_player_heart
					image_alpha = 1
					image_index = obj_game.player_heart_subimage
					x = inst_battle_box.x
					y = inst_battle_box.y - round(inst_battle_box.height)/2 - 5
				}
				
				if (array_length(battle_enemies_dialogs) == 0){ //No enemie wants to speak, then it just attacks.
					battle_go_to_state(BATTLE_STATE.ENEMY_ATTACK)
				}
			break}
			case BATTLE_STATE.ENEMY_ATTACK:{
				obj_player_battle.box_depth = inst_battle_box.depth
				inst_battle_box.type = BATTLE_BOX_TYPE.NORMAL
				
				battle_attack_count = 0
				
				var _length = array_length(battle_enemies_dialogs)
				if (_length > 0){
					array_delete(battle_enemies_dialogs, 0, _length)
				}
				_length = array_length(battle_enemies_attacks)
				if (_length > 0){
					array_delete(battle_enemies_attacks, 0, _length)
				}
				
				_length = array_length(menu_attacks)
				for (var _i=0; _i<_length; _i++){
					var _menu_attack = menu_attacks[_i]
					
					if (!is_undefined(_menu_attack.force_end)){
						_menu_attack.force_end()
					}
					
					array_delete(menu_attacks, _i, 1)
					_i--
					_length--
				}
				
				_length = array_length(menu_bullets)
				for (var _i=0; _i<_length; _i++){
					var _bullet = menu_bullets[_i]
					
					if (instance_exists(_bullet)){
						instance_destroy(_bullet)
					}
					
					array_delete(menu_bullets, _i, 1)
					_i--
					_length--
				}
				
				var _enemy_attack = false
				var _enemies_count = array_length(global.battle_enemies)
				var _enemies_still_available = false
				var _position = 0
				for (var _i=0; _i<_enemies_count; _i++){
					_enemy = global.battle_enemies[_i]
					
					if (is_undefined(_enemy)){
						continue
					}
					
					if (!is_undefined(_enemy.attack_starts)){
						_enemy.attack_starts()
					}
					
					if (!is_undefined(_enemy.next_attack)){
						_enemies_still_available = true
						_enemy_attack = true
						var _damage = max(calculate_enemy_damage_amount(_enemy), 1)
					
						array_push(battle_enemies_attacks, new EnemyAttack(_enemy.next_attack, _position, _damage))
						
						if (_enemy.next_attack != ENEMY_ATTACK.SPARE){
							battle_attack_count++
						}
						
						_enemy.next_attack = undefined
						_position++
					}else if (_enemy.hp <= 0){
						battle_kill_enemy(_i)
					}else if (_enemy.spared){
						battle_forgive_enemy(_i)
					}else{
						_enemies_still_available = true
					}
				}
				
				if (!_enemies_still_available){
					battle_go_to_state(BATTLE_STATE.PLAYER_WON)
				}else if (!_enemy_attack){
					array_push(battle_enemies_attacks, new EnemyAttack(ENEMY_ATTACK.SPARE, 0, undefined))
				}
			break}
			case BATTLE_STATE.TURN_END:{
				battle_resize_box(565, 130)
				battle_move_box_to(320, 390)
				battle_rotate_box_to(0)
				battle_reset_box_polygon_points()
				inst_battle_box.type = BATTLE_BOX_TYPE.NORMAL
				
				with (obj_battle_box){
					if (inst_battle_box.id != id){
						instance_destroy()
					}else{
						depth = 200
					}
				}
				
				obj_player_battle.image_alpha = 0
				
				var _length = array_length(battle_bullets)
				for (var _i=0; _i<_length; _i++){
					var _bullet = battle_bullets[_i]
					
					if (instance_exists(_bullet) and !_bullet.persistent){
						instance_destroy(_bullet)
					}
					
					array_delete(battle_bullets, _i, 1)
					_i--
					_length--
				}
				
				_length = array_length(battle_enemies_attacks)
				if (_length > 0){
					array_delete(battle_enemies_attacks, 0, _length)
				}
				
				battle_current_box_dialog = global.UI_texts[$"battle default box dialog"]
				var _candidate_dialog = undefined
				
				//Some people may want their enemy spared or dead after an attack, therefor they must set the data before the attack ends, luckily enemies have a function that executes when an attack ends.
				var _enemies_count = array_length(global.battle_enemies)
				var _enemies_still_available = false
				var _enemy_dialog = false
				for (var _i=0; _i<_enemies_count; _i++){
					_enemy = global.battle_enemies[_i]
					
					if (is_undefined(_enemy)){
						continue
					}
					
					if (!is_undefined(_enemy.turn_ends)){
						_candidate_dialog = _enemy.turn_ends(_candidate_dialog)
					}
					
					var _type_dialog = typeof(_enemy.next_dialog)
					
					if (_type_dialog == "array" or _type_dialog == "string"){
						_enemies_still_available = true
						_enemy_dialog = true
						
						battle_set_enemy_dialog(_enemy)
					}else if (_enemy.hp <= 0){
						battle_kill_enemy(_i)
					}else if (_enemy.spared){
						battle_forgive_enemy(_i)
					}else{
						_enemies_still_available = true
					}
				}
				
				if (!_enemies_still_available){
					battle_go_to_state(BATTLE_STATE.PLAYER_WON)
				}else if (!_enemy_dialog){
					if (!is_undefined(_candidate_dialog)){
						battle_current_box_dialog = _candidate_dialog
					}
					
					battle_go_to_state(BATTLE_STATE.PLAYER_BUTTONS)
				}
			break}
			case BATTLE_STATE.END:{
				if (!is_undefined(battle_end_function)){
					obj_game.start_room_function = function(){
						var _killed_enemies = []
						var _spared_enemies = []
					
						var _length = array_length(battle_cleared_enemies)
						for (var _i=0; _i<_length; _i++){
							var _enemy = battle_cleared_enemies[_i]
						
							if (_enemy.hp <= 0){
								array_push(_killed_enemies, _enemy)
							}else{
								array_push(_spared_enemies, _enemy)
							}
						}
					
						battle_end_function(global.battle_enemies, _killed_enemies, _spared_enemies, battle_fled)
						battle_end_function = undefined
						
						_length = array_length(global.battle_enemies)
						for (var _i=_length - 1; _i>=0; _i--){
							var _enemy = global.battle_enemies[_i]
							
							if (!is_undefined(_enemy.destroy)){
								_enemy.destroy()
							}
							
							array_pop(global.battle_enemies)
						}
						
						_length = array_length(battle_cleared_enemies)
						for (var _i=0; _i<_length; _i++){
							array_pop(battle_cleared_enemies)
						}
					}
				}
				
				anim_timer = 0
				battle_set_player_status_effect()
				battle_apply_rewards(false)
				
				if (obj_game.battle_pause_music){
					obj_game.battle_music_system.set_gain(0, 333)
				}
			break}
		}
	}
}
