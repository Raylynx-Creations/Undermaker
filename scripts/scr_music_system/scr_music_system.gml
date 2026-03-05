function MusicSystem() constructor{
	music_instance = undefined
	change_music_to = undefined
	ignore = false
	
	step = function(){
		if (ignore){
			ignore = false
			
			return
		}
		
		if (audio_exists(music_instance) and audio_is_paused(music_instance)){
			resume_music(1000)
		}
		
		set_music(change_music_to)
		
		change_music_to = undefined
	}
	
	set_music = function(_music=undefined){
		if (audio_exists(music_instance) and audio_is_playing(music_instance)){
			audio_stop_sound(music_instance)
		}
		
		if (!is_undefined(_music)){
			music_instance = audio_play_sound(_music, 100, true)
		}
	}
	
	pause_music = function(){
		if (audio_exists(music_instance) and !audio_is_paused(music_instance)){
			set_gain(0, 0)
			audio_pause_sound(music_instance)
		}
	}
	
	stop_music = function(){
		if (audio_exists(music_instance) and audio_is_playing(music_instance)){
			audio_stop_sound(music_instance)
			
			music_instance = undefined
		}
	}
	
	set_gain = function(_gain=0, _time=0){
		if (audio_exists(music_instance) and audio_is_playing(music_instance)){
			audio_sound_gain(music_instance, _gain, _time)
		}
	}
	
	resume_music = function(_time=0){
		if (audio_exists(music_instance) and audio_is_paused(music_instance)){
			audio_resume_sound(music_instance)
			set_gain(100, _time)
		}
	}
	
	schedule_music_change_to = function(_music=undefined){
		change_music_to = _music
	}
	
	ignore_next_update = function(){
		ignore = true
	}
}