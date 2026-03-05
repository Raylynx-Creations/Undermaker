array_pop(collision_ids) //Remove the collision on id 0 so it doesn't collide with that one, but the player does.
array_push(collision_ids, 1) //Add collision to the 1.

become_pushable = function(){
	inst_kris_dog_4.can_player_push = true
	inst_kris_dog_4.can_entities_push = true
	inst_kris_dog_4.image_blend = c_yellow
	inst_kris_dog_4.dialogs = ["[bind_instance:" + string(real(inst_kris_dog_4.id)) + "]Come on![w:10] Push me!"]
}

has_changed_dialogs = false
dialogs = ["[bind_instance:" + string(real(id)) + "]You can also push me around[w:10], I'm an entity after all.","Oh wait[w:10], you can't push me right now.","I will make myself pushable then[w:10][func:" + string(id) + ",become_pushable], give it a try now!"]

sprite_index = spr_kris_dog

interaction = function(){
	overworld_dialog(dialogs,, false)
}

step = function(){
	if (!has_changed_dialogs and (x != 460 or y != 540)){
		has_changed_dialogs = true
		dialogs = ["[bind_instance:" + string(real(id)) + "]WEEEEEEEEEEEEEEEE![w:10] Faster![w:10] Faster!"]
	}
}