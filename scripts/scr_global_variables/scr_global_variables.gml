//PLAYER AND SAVE VARIABLES
set_initial_game_data() //See scr_initial_save_file_data

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