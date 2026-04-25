//-------------ROTATION ORIENTATIONS---------------

enum ROTATION_ORIENTATION{
	CLOCKWISE,
	COUNTER_CLOCKWISE
}

//-----------------BULLET TYPES--------------------

enum BULLET_TYPE{
	WHITE,
	ORANGE,
	CYAN,
	GREEN
}

//-----------------PLAYER SOUL--------------------

/*

*/
enum PLAYER_STATUS_EFFECT{
	NONE,
	KARMIC_RETRIBUTION //Because it's the most used of course you sans freaks!!!
}

/*

*/
enum SOUL_MODE{
	NORMAL, //Red
	GRAVITY //Blue and Orange
}

/*

*/
enum GRAVITY_SOUL{
	DOWN,
	RIGHT,
	UP,
	LEFT
}

//-----------------BATTLE BOX TYPES--------------------

/*
Battle box types for you to select and make attacks more engaging and interesting to play in.
*/
enum BATTLE_BOX_TYPE{
	NORMAL,
	HOLE,
	MERGE
}

//-----------------STATES--------------------

/*

*/
enum BATTLE_START_ANIMATION{
	NORMAL,
	FAST,
	NO_WARNING,
	NO_WARNING_FAST
}

/*

*/
enum BATTLE_STATE{
	START,
	START_DODGE_ATTACK,
	PLAYER_BUTTONS,
	PLAYER_ENEMY_SELECT,
	PLAYER_ATTACK,
	PLAYER_ACT,
	PLAYER_ITEM,
	PLAYER_MERCY,
	PLAYER_FLEE,
	PLAYER_WON,
	END,
	END_DODGE_ATTACK,
	PLAYER_DIALOG_RESULT,
	ENEMY_DIALOG,
	ENEMY_ATTACK,
	TURN_END
}