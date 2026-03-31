//PLAYER VARIABLES
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
} //Define its default values on scr_initial_save_file_data, it's here for reference and example.

global.box = {
	inventory: [[ITEM.CHOCOLATE, ITEM.BANDAGE, ITEM.STICK], []], //For multiple box inventories, like multi-dimensional box B or more.
	inventory_size: [10, 10]
}

//SAVE VARIABLES
global.minutes = 0
global.seconds = 0

global.save_data = {} //Define its contents on scr_initial_save_file_data

//GAME VARIABLES
global.instance_references = {}
global.room_borders = {}
global.room_musics = {}
global.dialogues = {}

global.confirm_button = 0
global.cancel_button = 0
global.menu_button = 0
global.up_button = 0
global.down_button = 0
global.left_button = 0
global.right_button = 0
global.escape_button = 0

global.confirm_hold_button = 0
global.cancel_hold_button = 0
global.menu_hold_button = 0
global.up_hold_button = 0
global.down_hold_button = 0
global.left_hold_button = 0
global.right_hold_button = 0
global.escape_hold_button = 0

global.battle_enemies = []
global.battle_serious_mode = false

global.item_pool = []
global.UI_texts = {}
global.last_save = {}