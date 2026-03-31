/*
Similar to scr_room_border_ids.

This global variable contains the relationship between the rooms and the musics that should play when entering them.
The engine uses it so it must be defined.
Use the rooms constants as names and give them their corresponding IDs, the room constant names are converted to strings no problem.
Just set the music it should play, if you use -1 that room will stop the music and play nothing.

Only applies to overworld rooms, not the battle room.
*/
global.room_musics = {
	rm_menu: mus_waterfall,
	rm_overworld_1_grass_land: -1,
	rm_overworld_2_the_void: mus_waterfall,
	//Notice rm_overworld_3 is not here, it is Undefined, so that means it will not change the music nor remove it, will keep the one that currently has playing.
	rm_overworld_4_training_area: mus_snowy
}