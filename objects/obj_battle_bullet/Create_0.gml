/// @description Initial variables

//Functions for the bullets.
//Define them to do stuff with the object.
step = undefined
before_draw = undefined
draw = draw_self
after_draw = undefined
destroy = undefined
clean_up = undefined
before_hit = undefined
after_hit = undefined
when_colliding = undefined

//Bullet specific data.
type = BULLET_TYPE.WHITE
can_damage = true
damage = 1
box_for_mask = inst_battle_box //In case multiple boxes are selected, make sure it's the original box
mask_to_box = false //Wheter to activate or deactivate the mask
karma = 1 //Used only for karmic retribution player status effect, will do nothing if not in that status effect.
persistent = false //This plays with the persistency of the bullet between rooms too yes but the system uses it for deleting the bullets in the proper time.
box_depth = inst_battle_box.depth //Layer bullets cause damage, if player has same depth, it can be damaged by this bullet