/*
List of the constants for the items the player can have at all in its inventory.
The order of these matters just like it does with the CELL constants and the ACT_COMMAND constants of battle.
In the Item pool file you have to define the items in a list in the exact same order for their corresponding text and data to match.
See user manual for more information.
*/
enum ITEM{
	EDIBLE_DIRT,
	INSTANT_NOODLES,
	WILTED_VINE,
	STICK,
	OLD_BRICK,
	BANDAGE,
	CHOCOLATE
}

/*
Function that executes whenever the player uses an item in game, the dialog that it returns will be different depending on certaing factors.
Like if you're or not in battle (rm_battle check) and if you're on battle_serious_mode or not that modifies a bit the dialogues and stuff like Undertale.

INTEGER _inventory_index -> Index of the item in the player's inventory that it's being used.

RETURNS -> ARRAY[STRING/ARRAY OF STRINGS, INTEGER] --First data is the dialog the item will display for the item being used and the second is the constant ITEM integer of the item you just used for use on other areas of the engine, IT IS RECOMMENDED YOU DO NOT MODIFY THE RETURN STATEMENT BUT THE DIALOG VARIABLE ON IT.
*/
function use_item(_inventory_index){
	var _item_index = global.player.inventory[_inventory_index] //Gets ITEM constant
	var _item_data = variable_clone(global.item_pool[_item_index]) //Clone the data on the variable from the Item pool, this is why order matters on the constant ITEMs and the Item pool file.
	var _player_hp = global.player.hp //Auxiliar for player HP differentiator.
	
	var _overheal_amount = 0 //This variable can be replaced in some items with some of the arguments you use to allow for some overheal in the system.
	var _item_use_dialog = _item_data[$"use dialog"] //Dialog of the item, can be managed in the switch below in case it's a struct, at the end this must be a string or array.
	
	//Extra stuff to do on the items
	switch (_item_index){
		case ITEM.INSTANT_NOODLES: //Noddles is the best example of many dialogues in it.
			if (room == rm_battle){
				if (global.battle_serious_mode){
					_item_use_dialog = _item_use_dialog.serious
					_item_data.amount = _item_data.amount.serious
				}else{
					_item_use_dialog = _item_use_dialog.battle
					_item_data.amount = _item_data.amount.battle
				}
			}else{
				_item_use_dialog = _item_use_dialog.overworld
				_item_data.amount = _item_data.amount.overworld
			}
		break
		case ITEM.CHOCOLATE: //This is an example on overheal.
			_overheal_amount = 10
		break
	}
	
	/*
	From this point forward, if you haven't handled the item yourself in the switch instruction, then the default method will be attempted.
	You can still handle some specific behavior in the next switch for like for example overheal items, reciclying the healing code from below from the Consumable type items.
	
	For Healing items it will try to add the Amount to the HP expecting it to be an integer, regardless if it's in battle or not.
	For Armor and Weapon items it will be swapped from the position of the item and armor/weapon slot if there's one, otherwise it will be just removed and put in the armor/weapon slot.
	*/
	
	//Any type not handled in this switch will simply do nothing, doesn't even get removed from the inventory on use.
	switch (_item_data.type){
		case "Consumable":{
			var _heal_message = string_replace(global.UI_texts[$"item heal"].heal, "[HealAmount]", _item_data.amount)
			
			global.player.hp = min(global.player.hp + _item_data.amount, global.player.max_hp + _overheal_amount)
			
			if (room == rm_battle){
				if (struct_exists(_item_data, "atk")){
					global.player.battle_atk += _item_data.atk
				}
				if (struct_exists(_item_data, "def")){
					global.player.battle_def += _item_data.def
				}
			}
			
			if (global.player.hp == _player_hp){
				_heal_message = global.UI_texts[$"item heal"].unchanged
				
				audio_play_sound(snd_player_eat, 100, false)
			}else if (global.player.hp < _player_hp){
				_heal_message = string_replace(global.UI_texts[$"item heal"].lost, "[HurtAmount]", -_item_data.amount)
				
				audio_play_sound(snd_player_hurt, 100, false)
			}else if (global.player.hp == global.player.max_hp){
				_heal_message = global.UI_texts[$"item heal"].maxheal
				
				audio_play_sound(snd_player_heal, 100, false)
			}else if (global.player.hp > global.player.max_hp){
				_heal_message = global.UI_texts[$"item heal"].overheal
				
				audio_play_sound(snd_player_overheal, 100, false)
			}else{
				audio_play_sound(snd_player_heal, 100, false)
			}
			
			if (typeof(_item_use_dialog) == "string"){ //You can avoid this check if all your item's dialogues are lists, in that case remove this if statement and its contents.
				_item_use_dialog = string_replace(_item_use_dialog, "[HealMessage]", _heal_message)
			}else{ //It is expected to be an array if it's not a string the _item_use_dialog, otherwise it will fail, make sure to handle any other format of the dialog in the previous switch.
				var _dialog_length = array_length(_item_use_dialog)
				
				for (var _i = 0; _i < _dialog_length; _i++){
					if (string_pos("[HealMessage]", _item_use_dialog[_i])){
						_item_use_dialog[_i] = string_replace(_item_use_dialog[_i], "[HealMessage]", _heal_message)
						
						break
					}
				}
			}
			
			array_delete(global.player.inventory, _inventory_index, 1)
		break}
		case "Weapon":{
			if (is_undefined(global.player.weapon) or global.player.weapon < 0){
				global.player.weapon = _item_index
				
				array_delete(global.player.inventory, _inventory_index, 1)
			}else{
				global.player.inventory[_inventory_index] = global.player.weapon
				global.player.weapon = _item_index
			}
			
			audio_play_sound(snd_player_equip, 100, false)
		break}
		case "Armor":{
			if (is_undefined(global.player.armor) or global.player.armor < 0){
				global.player.armor = _item_index
				
				array_delete(global.player.inventory, _inventory_index, 1)
			}else{
				global.player.inventory[_inventory_index] = global.player.armor
				global.player.armor = _item_index
			}
			
			audio_play_sound(snd_player_equip, 100, false)
		break}
	}
	
	return [_item_use_dialog, _item_index]
}

/*
Function that executes whenever the player selects INFO on an item in the overworld.

INTEGER _inventory_index -> Index of the item in the player's inventory that it's being selected.

RETURNS -> STRING/ARRAY OF STRINGS --Dialog to display that represents the information of the item.
*/
function item_info(_inventory_index){
	var _item_index = global.player.inventory[_inventory_index]
	var _item_data = variable_clone(global.item_pool[_item_index])
	
	return _item_data[$"info dialog"]
}

/*
Function that executes whenever the player selects DROP on an item in the overworld.

INTEGER _inventory_index -> Index of the item in the player's inventory that it's being dropped.

RETURNS -> STRING/ARRAY OF STRINGS --Dialog to display that represents the information of the item.
*/
function drop_item(_inventory_index){
	var _item_index = global.player.inventory[_inventory_index]
	var _item_data = variable_clone(global.item_pool[_item_index])
	
	var _item_drop_dialog = _item_data[$"drop dialog"]
	if (is_undefined(_item_drop_dialog)){
		_item_drop_dialog = string_replace(global.UI_texts[$"item dropped default dialog"], "[ITEM]", _item_data[$"inventory name"])
	}
	
	/*
	//Outdated, you can put the reference to functions in the dialog directly.
	//See scr_custom_dialog_functions's commented documentation or user manual.
	switch (_item_index){
		case ITEM.WILTED_VINE:
			//Do stuff before passing the dialog out.
		break
	}
	*/
	
	//Some items are not to be dropped, in which case you can make conditions or statements to avoid the deletion of the ITEM.
	array_delete(global.player.inventory, _inventory_index, 1)
	
	return _item_drop_dialog
}
