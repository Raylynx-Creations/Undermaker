/*
Constants for the flee event, you can add more and use them
*/
enum FLEE_EVENT{
	NORMAL,
	IMPROVED
}

/*
Function constructor that represents the fleeing of the player when they select Flee, you just have to fill in the code needed for your events, don't have to call this function anywhere else, the engine does.
Usually when you flee normally and it fails, you just don't get an animation or dialog, that's the default flee coded in the game.
There's an improved version I made, you can use that as a default if you wish, but you can modify and adjust the animation and how everything plays once the player selects Flee.
All that matters is the end values of the success variable and the is_finished battle, if you set that to false, it will always fail the flee.
You are given a _success variable as a starting point, but you can adjust it always to the outcome you want.

INTEGER _type ----> Determinates the type of flee event that happens.
BOOLEAN _success -> Tells you if the chance of fleeing is successful or not, doesn't define the final outcome of the flee event in battle tho.

CONSTRUCTS -> STRUCT OF FLEE EVENT DATA --Represents the flee event for the engine to execute its behavior.
*/
function FleeEvent(_type, _success) constructor{
	success = _success //This variable is needed, it defines it the flee was successful or not.
	is_finished = false //This variable is needed too, it defines when the flee event is done and apply the flee result via the success variable.
	
	//step = undefined //This is the only function event that the flee event has, so you gotta define it to do your logic.
	
	//Switch to determinate the type of event.
	switch (_type){
		case FLEE_EVENT.IMPROVED:{
			timer = 0 //Timer for the animation
			
			audio_play_sound(snd_flee, 100, false) //You can play anything at start
			
			//The logic is here
			step = function(){
				with (obj_player_battle){ //This is the player object, we use it to do the animation, you can set it invisible or use an obj_renderer instead if you want, let your creativity flow.
					if (!other.success and x <= 42){ //This is the animation that happens when you fail the flee, when it reaches 42 in X then it tumbles and falls to the ground.
						if (x == 42){ //Point where you trip
							audio_stop_sound(snd_flee)
							audio_play_sound(snd_switch_flip, 100, false)
							
							x--
							image_speed = 0
						}else if (image_angle < 90){ //You start falling
							image_angle += 9
							x--
							
							if (image_angle == 90){
								audio_play_sound(snd_player_hurt, 100, false)
								
								image_index = 1
							}
						}else if (x > 22){ //Fall and move a little
							x -= 0.5
						}else{
							other.timer++ //Little waiter and then finish the flee.
							
							if (other.timer >= 60){
								image_angle = 0
								image_speed = 1
								
								other.is_finished = true
							}
						}
					}else{ //This is the default flee animation, it runs to the left constantly.
						x--
						
						if (x <= -10){
							other.is_finished = true
						}
					}
				}
			}
		break}
		default:{ //FLEE_EVENT.NORMAL
			if (!success){ //Instantly finish the flee if unsuccessful.
				is_finished = true
			}else{ //Otherwise play the flee sound.
				audio_play_sound(snd_flee, 100, false)
			}
			
			step = function(){
				with (obj_player_battle){
					x-- //This only happens if success is true.
				
					if (x <= -10){
						other.is_finished = true
					}
				}
			}
		break}
	}
}