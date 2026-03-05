//-----------------PLAYER OVERWORLD--------------------

/*

*/
enum PLAYER_STATE{
	NONE,
	STILL, //Like unable to move
	MOVEMENT
}

/*
Player menu states for the overworld player, used in the player_menu_system.
*/
enum PLAYER_MENU_STATE{
	INITIAL,
	INVENTORY,
	ITEM_SELECTED,
	CELL,
	BOX, //From this state it can either go back to the overworld or the cell menu.
	SAVE,
	STATS,
	WAITING_DIALOG_END
}

/*
Player menu options that you can select in run time.
*/
enum PLAYER_MENU_OPTIONS{
	ITEM,
	STAT,
	CELL
}

/*
////TODO
*/
enum PLAYER_MENU_INVENTORY_OPTIONS{
	USE,
	INFO,
	DROP
}

//-----------------DIALOG CHOICE OPTIONS--------------------

/*
Directions of the options the player can choose in a multiple choice option direction dialog, used only in the create_plus_choice_option() function to indicate which key to listen to for the choice option to select it.
*/
enum PLUS_CHOICE_DIRECTION{
	LEFT,
	DOWN,
	RIGHT,
	UP
}