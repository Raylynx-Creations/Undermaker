/*
Constants for the battle backgrounds, define yours here if you want to draw your own.
*/
enum BATTLE_BACKGROUND{
	NO_BG,
	SQUARE_GRID,
	MOVING_SQUARE_GRID
}

/*
The background and everything is automatically setup in the start_battle() and start_attack() functions by giving the constant of the battle background.
All you have to do is just program how your background is going to behave here, by default the depth is 500 on them.
You can change the background by using the function battle_set_background() and set depth and more details there.
This is not a constructor function really but it kinda behaves like one, creating new instances so it's named BattleBackground() instead of battle_background().

INTEGER _name --> The constant BATTLE_BACKGROUND that tells which background to create.
INTEGER _depth -> The depth at which the background is gonna be rendered.

RETURNS -> INSTANCE OF OBJ_RENDERER _renderer --The object that renders the battle background.
*/
function BattleBackground(_name, _depth=500){
	//We use an object to render the background, since that way we can adjust and change the depth.
	var _renderer = instance_create_depth(0, 0, _depth, obj_renderer)
	//The renderer object comes with variables that we can define to draw, step and clean up data when it's removed.
	with (_renderer){
		timer = 0 //By default all backgrounds come with a timer, I recommend not adjusting this, unless you require so.
		
		//Depending on the background, we define stuff differently.
		switch (_name){
			//This is a static background of a square grid, very simply made.
			//If wanted it could be a sprite draw, and you have a predefined set of backgrounds to draw.
			case BATTLE_BACKGROUND.SQUARE_GRID:{
				//Executes on the draw event of the renderere object.
				draw = function(){
					draw_set_color(c_green)
					for (var _i=0; _i<6; _i++){
						for (var _j=0; _j<2; _j++){
							draw_rectangle(50 + 90*_i, 50 + 90*_j, 138 + 90*_i, 138 + 90*_j, true)
						}
					}
					draw_set_color(c_white)
				}
			break}
			//For more complex backgrounds however, we do use step function to count the timer and draw stuff accordingly.
			//You can get as complex as you want, this is a simple moving background that it's similar to the square grid, but notice the timer variable adjusting the Y position on the draw_rectangle().
			case BATTLE_BACKGROUND.MOVING_SQUARE_GRID:{
				//Executes on the step event of the renderer object.
				step = function(){
					timer++
				}
				
				//Draw event
				draw = function(){
					draw_set_color(c_green)
					for (var _i=0; _i<6; _i++){
						for (var _j=0; _j<2; _j++){
							draw_rectangle(50 + 90*_i, 50 + 90*_j - 30*dsin(timer + 45*_i), 138 + 90*_i, 138 + 90*_j - 30*dsin(timer + 45*_i), true)
						}
					}
					draw_set_color(c_white)
				}
				
				//These methods don't need clean_up event for now since we are not using surfaces or other stuff that ocuppies memory that needs to be freed.
				//But if you need to, you just define clean_up variable as a function here and do stuff when the renderer is removed, which happens when you set another background or exit the battle room.
			break}
			//By default if the background is not defined, it just does nothing...
			default:{ //BATTLE_BACKGROUND.NO_BG //No background
				//Nothing
			break}
		}
	}
	
	//Return the renderer as the reference is kept in the battle_system, if you ever want to just call the background yourself you will have to keep the reference to this object just in case.
	//You don't have to use battle_set_background() in that case but this function instead.
	return _renderer
}
