/*
Constants that represent the ID of the subimage of specific border images in the spr_border.
You can define their IDs in them or define them ordered as you have them in the subimages of spr_border.
*/
enum BORDER{
	NONE = 0, //The assignations are not necessary, but they are there to show you can define any number in them.
	BATTLE = 1,
	SNOW_FOREST = 2,
	SNOW_FOREST_2 = 3
}

/*
Similar to scr_room_music_ids.

This global variable contains the relationship between the rooms and the borders it should have when entering them.
The engine uses it so it must be defined.
Use the rooms constants as names and give them their corresponding IDs, the room constant names are converted to strings no problem.
It's prefered to use enum constants in case you change the spr_border's subimages for assigning the ID to rooms.
So it's easier to adjust it and not have to redefine for every single room again editing the number.
*/
global.room_borders = {
	rm_menu: BORDER.BATTLE, //Yes same as battle, for testing, can be any of course.
	rm_battle: BORDER.BATTLE,
	rm_overworld_1_grass_land: BORDER.SNOW_FOREST_2,
	rm_overworld_2_the_void: BORDER.SNOW_FOREST,
	//Notice rm_overworld_3 is not here, it is Undefined, so that means it will not change the border nor remove it, will keep the one that currently has.
	rm_overworld_4_training_area: BORDER.SNOW_FOREST_2
}