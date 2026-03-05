/// @description Default collision_id

//Sometimes you would like to make collisions for objects, like a maze for rocks the player can push but you want the player to be able to go through these barriers but not the rock, well the id collision is for that.
collision_id = 0 //The default is 0 for the player yes, but you can replace it on the create code of the instance when you place it on the room so you use it for checking on another object or instance (see example in the user manual).
previous_angle_of_this_instance = image_angle //The purpose of this is to have a very inconvient name so it's almost impossible people not knowing use the variable name for other purposes in other places.

step = undefined
when_colliding = undefined
has_collided = false
