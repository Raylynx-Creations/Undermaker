/*
This is a script of custom functions that you can define to call on your dialogues in the Dialogues text file.
to do so you have to use the [func] or any other command that takes a function reference and do:
[func: ref script <name>, <arg-1>, ..., <arg-n>] where <name> is the name of the function you want to call and <arg>s are the arguments you give to the function, note they will be all strings tho.
That way you can call built in function of the game to do stuff even like start_plus_choice().

In the dialogues you can also do [func:<instance_registered_name>, <method_name>, <arg-1>, ..., <arg-n>] to use a method that is defined inside an instance.
All you have to do is register the instance's id/self (struct representation of it) with add_instance_reference(<id/self>, <name>) and use the name you registered it with.
This is because support to "ref instance <name/id_number>" is no longer supported for handle_parse() built in Game Maker Studio 2 function.
*/

function drop_wilted_vine_item(){
	audio_play_sound(snd_player_hurt, 100, false)
	global.player.hp-- //It can kill you yes, funny x3
}