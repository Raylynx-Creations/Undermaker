/// @description Pushable, collision and event trigger setting

collision_ids = [0] //By default it collides with the same stuff the player can collide with.
can_player_push = false //Sets if the entity can be pushed around by the player or other entities that can push.
can_entities_push = false
can_push_entities = false //Can push other pushable obj_entity?
can_overlap = false
can_player_collide = true //Sets if the player can collide with the obj_entity, if false it can't push the entity even if pushable is true.
round_collision_behavior = false
can_interact = true
depth_ordering = true //You can deactivate the depth by the Y position

//Button in which you interact with the entity, usually confirm
interaction_key = "confirm"

//Functions for the entity interaction
before_step = undefined
step = undefined
after_step = undefined
before_draw = undefined
draw = undefined
after_draw = undefined
interaction = undefined
when_colliding = undefined //Will do nothing until it's defined, it triggers when the player collides with it.
has_collided = false
