global.game_settings = {
	language: "english",
	resolution_active: 0,
	resolution_last_active: -1,
	border_active: false,
	border_id: 0
}

/*
This is a list of all the stats you get when you reach the specific level by reaching the EXP needed for it, these apply when you level up which can only happen when you kill monsters, triggering the battle_apply_rewards() function in the battle functions.
If you need to trigger leveling by other means outside of the battle, copy the battle_apply_rewards() function and edit it to your needs to make sure levels are met up (try to make sure EXP is met and makes sense with the next_exp requirements from before too).
*/
global.stat_levels = [
	{atk: 0, def: 0, max_hp: 20, hp_bar_width: 24, next_exp: 10}, //Level 1 (You start with these)
	{atk: 2, def: 0, max_hp: 24, hp_bar_width: 29, next_exp: 20}, //Level 2
	{atk: 4, def: 0, max_hp: 28, hp_bar_width: 34, next_exp: 40},//Level 3
	{atk: 6, def: 0, max_hp: 32, hp_bar_width: 38, next_exp: 50}, //Level 4
	{atk: 8, def: 1, max_hp: 36, hp_bar_width: 43, next_exp: 80}, //Level 5
	{atk: 10, def: 1, max_hp: 40, hp_bar_width: 48, next_exp: 100}, //Level 6
	{atk: 12, def: 1, max_hp: 44, hp_bar_width: 53, next_exp: 200}, //Level 7
	{atk: 14, def: 1, max_hp: 48, hp_bar_width: 58, next_exp: 300}, //Level 8
	{atk: 16, def: 2, max_hp: 52, hp_bar_width: 62, next_exp: 400}, //Level 9
	{atk: 18, def: 2, max_hp: 56, hp_bar_width: 67, next_exp: 500}, //Level 10
	{atk: 20, def: 2, max_hp: 60, hp_bar_width: 72, next_exp: 800}, //Level 11
	{atk: 22, def: 2, max_hp: 64, hp_bar_width: 77, next_exp: 1000}, //Level 12
	{atk: 24, def: 3, max_hp: 68, hp_bar_width: 82, next_exp: 1500}, //Level 13
	{atk: 26, def: 3, max_hp: 72, hp_bar_width: 86, next_exp: 2000}, //Level 14
	{atk: 28, def: 3, max_hp: 76, hp_bar_width: 91, next_exp: 3000}, //Level 15
	{atk: 30, def: 3, max_hp: 80, hp_bar_width: 96, next_exp: 5000}, //Level 16
	{atk: 32, def: 4, max_hp: 84, hp_bar_width: 101, next_exp: 10000}, //Level 17
	{atk: 34, def: 4, max_hp: 88, hp_bar_width: 106, next_exp: 25000}, //Level 18
	{atk: 36, def: 4, max_hp: 92, hp_bar_width: 110, next_exp: 49999}, //Level 19
	{atk: 38, def: 4, max_hp: 99, hp_bar_width: 119, next_exp: infinity} //Level 20 (Last level, when next_exp is infinity, in the game is actually displayed as "None")
]

global.dialogues = {}

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

global.box = {
	inventory: [[ITEM.CHOCOLATE, ITEM.BANDAGE, ITEM.STICK], []], //For multiple box inventories, like multi-dimensional box B or more.
	inventory_size: [10, 10]
}

global.minutes = 0
global.seconds = 0

global.save_data = {
	wall_1_moved: false,
	puzzle_1: false,
	cutscene_1: false
}

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