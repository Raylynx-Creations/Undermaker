force = 2

sprite_index = spr_rock

step = function(){ //Important the order of creation or events, the ball must update first and then the 2 entities that play with it, or it will push them.
	x += force
}