/*
This just sets the variables for the game to work as if it was a new game.
The player can save to override the previous save file or not save at all.
Note that this does not clear any save file saved in the game, so if you don't save you can recover still your previous progress.
*/
function set_initial_game_data(){
	//This is the player's initial state, all these variables are needed since the engine uses them.
	//Make sure to define them all always with the values you want them to have when a player creates a new save game.
	global.player = {
		max_hp: 20,
		hp: 20,
		hp_bar_width: 24, //Used for the battle HP bar.
		hp_bar_color: c_yellow, //Used for the battle HP bar.
		lv: 1,
		gold: 0,
		name: "Chara",
		battle_atk: 0,
		battle_def: 0,
		atk: 0,
		def: 0,
		equipped_atk: 0,
		equipped_def: 0,
		exp: 9,
		next_exp: 1,
		weapon: ITEM.OLD_BRICK,
		armor: ITEM.BANDAGE,
		prev_weapon: -1, //These variables are only meant to be used by the obj_game's step event that triggers the calculations for the equipped atk, equipped def and the invulnerability frames.
		prev_armor: -1, //They start at -1 to jumpstart the first calculation, no item can have an index of -1 so it starts it.
		invulnerability_frames: PLAYER_BASE_INVULNERABILITY_FRAMES, //Frames the player will be invulnerable when getting hit, this variable is free to change at any point in the game and will take effect immediatelly after getting hit.
		cell: true,
		cell_options: [CELL.CALL_GASTER, CELL.DIMENTIONAL_BOX_B, CELL.DIMENTIONAL_BOX_A, CELL.CALL_GASTER, CELL.LOAD_GAME],
		inventory: [ITEM.EDIBLE_DIRT, ITEM.INSTANT_NOODLES, ITEM.WILTED_VINE, ITEM.OLD_BRICK],
		inventory_size: 8,
		status_effect: {
			type: PLAYER_STATUS_EFFECT.NONE,
			color: make_color_rgb(232, 0, 255),
			value: 0
		}
	}
	
	//Reset box to the initial save state
	global.box = {
		inventory: [[ITEM.CHOCOLATE, ITEM.BANDAGE, ITEM.STICK], []], //For multiple box inventories, like multi-dimensional box B or more.
		inventory_size: [10, 10]
	}
	
	//Reset times
	global.minutes = 0
	global.seconds = 0

	//Reset flags of specific events that you define and use in your game, they are saved
	global.save_data = {
		wall_1_moved: false,
		puzzle_1: false,
		cutscene_1: false
	}
}
