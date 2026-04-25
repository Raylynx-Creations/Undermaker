enum DAMAGE_UI_ANIMATION_TYPE{
	NO_ANIMATION,
	NORMAL
}

function DamageUIAnimation(_type, _text, _text_color, _x, _y, _depth=0, _draw_bar=true, _hp=100, _max_hp=100, _damage=100, _bar_width=100, _bar_color=c_lime){
	var _renderer = instance_create_depth(_x, _y, _depth, obj_renderer)
	with (_renderer){
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
	
		step = function(){
			timer++
			if (timer >= 90){
				instance_destroy()
			}
		}
		
		draw = function(){
			var _timer = min(timer/60, 1)
			
			draw_set_halign(fa_center)
			draw_set_valign(fa_bottom)
			draw_set_font(get_language_font("fnt_hachiko"))
			
			draw_text_color(x, y - 10 - 20*dsin(180*_timer), text, text_color, text_color, text_color, text_color, 1)
			if (draw_bar){
				draw_healthbar(x - bar_width/2, y + 5, x + bar_width/2, y - 13, 100*(hp - damage*_timer)/max_hp, c_red, bar_color, bar_color, 0, true, true)
			}
		}
		
		switch (_type){
			case DAMAGE_UI_ANIMATION_TYPE.NO_ANIMATION:
				timer = 60
				draw_bar = false
			break
			//You can add more behaviors of damage if you want, be sure to define the enum for it.
		}
	}
	
	return _renderer
}