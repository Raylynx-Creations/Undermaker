enum DAMAGE_UI_ANIMATION_TYPE{
	NO_ANIMATION,
	NORMAL
}

function DamageUIAnimation(_type, _text, _text_color, _x, _y, _draw_bar=true, _hp=100, _max_hp=100, _damage=100, _bar_width=100, _bar_color=c_lime) constructor{
	x = _x
	y = _y
	timer = 0
	text = _text
	text_color = _text_color
	hp = _hp
	max_hp = _max_hp
	damage = _damage
	bar_color = _bar_color
	bar_width = _bar_width
	draw_bar = _draw_bar
	
	switch (_type){
		case DAMAGE_UI_ANIMATION_TYPE.NO_ANIMATION:
			timer = 60
			draw_bar = false
		break
		//You can add more behaviors of damage if you want, be sure to define the enum for it.
	}
}