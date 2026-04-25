/// @description After update event

if (!is_undefined(after_step)){
	after_step()
}

general_entity_update() //Update of the entity for colliding.

//Depth ordering
if (depth_ordering){
	depth = -y
}