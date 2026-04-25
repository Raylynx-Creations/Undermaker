/// @description Pushable, collision and event trigger setting

//The rest is the same as the entity creation code, only the interaction and a variable are added
collision_ids = [0] //By default it collides with the same stuff the player can collide with.
can_player_push = false //Sets if the entity can be pushed around by the player or other entities that can push.
can_entities_push = false
can_push_entities = false //Can push other pushable obj_entity?
can_overlap = false
can_player_collide = true //Sets if the player can collide with the obj_entity, if false it can't push the entity even if pushable is true.
round_collision_behavior = false
can_interact = true
depth_ordering = true

interaction_key = "confirm"
box_inventory_id = 0 //Can change the id of the box it opens

//The interaction is defined since it's meant to be a box object of course
interaction = function(){
	start_box_menu(box_inventory_id)
}

before_step = undefined
step = undefined
after_step = undefined
before_draw = undefined
draw = undefined
after_draw = undefined
when_colliding = undefined //Will do nothing until it's defined, it triggers when the player collides with it.
has_collided = false
