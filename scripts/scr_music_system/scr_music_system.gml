function MusicSystem() constructor{
	music_instance = undefined
	music_name = ""
	change_music_to = undefined
	schedule_music_to = undefined
	schedule_music_time_in = 0
	schedule_stop_music = false
	schedule_pause_music = false
	ignore = false
	
	step = function(){
		if (!is_undefined(schedule_music_to)){
			if (get_gain() <= 0){
				if (audio_exists(schedule_music_to)){
					music_instance = audio_play_sound(schedule_music_to, 100, true)
					music_name = audio_get_name(music_instance)
				
					if (schedule_music_time_in > 0){
						set_gain(0, 0)
						set_gain(1, schedule_music_time_in)
					}
				}else{
					audio_stop_sound(music_instance)
			
					music_instance = undefined
					music_name = ""
				}
				
				schedule_music_to = undefined
			}
		}else if (schedule_stop_music){
			if (get_gain() <= 0){
				audio_stop_sound(music_instance)
			
				music_instance = undefined
				music_name = ""
			
				schedule_stop_music = false
			}
		}else if (schedule_pause_music){
			if (get_gain() <= 0){
				audio_pause_sound(music_instance)
			
				schedule_pause_music = false
			}
		}
	}
	
	update_music_change = function(_time_out=0, _time_in=0){
		if (audio_exists(music_instance) and audio_is_paused(music_instance)){
			resume_music(_time_in)
		}
		
		if (ignore){
			ignore = false
			
			return
		}
		
		set_music(change_music_to, _time_out, _time_in)
		
		change_music_to = undefined
	}
	
	set_music = function(_music=undefined, _time_out=0, _time_in=0){
		var _undefined = is_undefined(_music)
		
		if (!_undefined){
			var _is_playing = is_playing()
			if (_is_playing and audio_get_name(_music) == music_name and is_undefined(schedule_music_to) and !schedule_stop_music and !schedule_pause_music){
				return
			}
			
			if (_is_playing){
				if (_time_out <= 0){
					audio_stop_sound(music_instance)
				
					music_instance = undefined
					music_name = ""
					
					if (audio_exists(_music)){
						music_instance = audio_play_sound(_music, 100, true)
						music_name = audio_get_name(music_instance)
				
						if (_time_in > 0){
							set_gain(0, 0)
							set_gain(1, _time_in)
						}
					}
				}else{
					set_gain(0, _time_out)
					
					if (audio_exists(_music)){
						schedule_music_to = _music
						schedule_music_time_in = _time_in
					}else{
						schedule_stop_music = true
					}
				}
			}else if (audio_exists(_music)){
				music_instance = audio_play_sound(_music, 100, true)
				music_name = audio_get_name(music_instance)
				
				if (_time_in > 0){
					set_gain(0, 0)
					set_gain(1, _time_in)
				}
			}
		}
	}
	
	pause_music = function(_time_out=0){
		if (audio_exists(music_instance) and !audio_is_paused(music_instance)){
			if (_time_out <= 0){
				set_gain(0, 0)
				audio_pause_sound(music_instance)
			}else{
				set_gain(0, _time_out)
				
				schedule_pause_music = true
			}
		}
	}
	
	stop_music = function(_time_out=0){
		if (is_playing()){
			if (_time_out <= 0){
				audio_stop_sound(music_instance)
			
				music_instance = undefined
				music_name = ""
			}else{
				set_gain(0, _time_out)
				
				schedule_stop_music = true
			}
		}
	}
	
	set_gain = function(_gain, _time=0){
		if (is_playing()){
			audio_sound_gain(music_instance, clamp(_gain, 0, 1), _time)
		}
	}
	
	get_gain = function(){
		if (is_playing()){
			return audio_sound_get_gain(music_instance)
		}
	}
	
	resume_music = function(_time_in=0){
		if (is_paused()){
			audio_resume_sound(music_instance)
			set_gain(1, _time_in)
		}
	}
	
	schedule_music_change_to = function(_music=undefined){
		change_music_to = _music
	}
	
	is_playing = function(){
		return (audio_exists(music_instance) and audio_is_playing(music_instance))
	}
	
	is_paused = function(){
		return (audio_exists(music_instance) and audio_is_paused(music_instance))
	}
	
	ignore_next_update = function(){
		ignore = true
	}
}
