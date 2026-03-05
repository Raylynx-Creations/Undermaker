/// @description Initial variables

step = undefined
draw_begin = undefined
draw = draw_self
draw_end = undefined
on_destroy = undefined

type = BULLET_TYPE.WHITE
can_damage = true
karma = 5 //Used only for karmic retribution player status effect, will do nothing if not in that status effect.
persistent = false //This plays with the persistency of the bullet between rooms too yes but the system uses it for deleting the bullets in the proper time.