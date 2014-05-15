-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Sounds configuration
--
-- Parameters:
--  sound: The sound name
--  stream: If true, streams the sound instead of loading everything in memory
--  media: If true, uses the media library instead of audio tu play this sound on
--    Android devices (may be more reactive but cannot change the volume, pause it, etc.)
--  loops: The number of times you want the audio to loop (Default is 0).
--    Notice that 0 means the audio will loop 0 times which means that the sound
--    will play once and not loop. Continuing that thought, 1 means the audio will
--    play once and loop once which means you will hear the sound a total of
--    2 times. Passing -1 will tell the system to infinitely loop the sample.
--  volume: The volume of this sound, in [0 ; 1] (Default is 1).
--    It can be an interval to pick a random value from (e.g. { 0.5, 0.6 }).
--  duration: The sound duration in seconds (Default is nil, until the sound is finished).
--    It can be an interval to pick a random value from (e.g. { 0.5, 0.6 }).
--  fadeIn: The fade in time in seconds, this will cause the system to start playing
--    a sound muted and linearly ramp up to the maximum volume over the specified
--    number of seconds (Default is nil, no fade in).
--    It can be an interval to pick a random value from (e.g. { 0.5, 0.6 }).
--  fadeOut: The fade out time in seconds, this will cause the system to stop a
--    sound linearly from its level to no volume over the specified
--    number of seconds (Default is nil, no fade out).
--    It can be an interval to pick a random value from (e.g. { 0.5, 0.6 }).
--  pitch: The pitch to apply to the sound (Default is 1).
--    It can be an interval to pick a random value from (e.g. { 0.9, 1.2 }).
--  pan: The position of the sounds from 0 (left) to 1 (right).
--  autoDestroy: Automatically destroys the sound as soon as it has finished playing
--    (Default is false for stream sounds and true for others).
--  autoUnload: Automatically unloads the sound as soon as it has finishes playing
--    (Default is false).
--  
-----------------------------------------------------------------------------------------

return {
	music = {
		music_game = {
			stream = true,
			volume = 0.3,
			fadeOut = 1.5
		}
	},
	sfx={
		hammer_hit = {
			variations = { "_01", "_02" },
			volume = 0.6,
			pitch = { 0.9, 1.15 }
		},

		hammer_miss = {
			volume = 0.8,
			pitch = { 0.75, 1 }
		},

		dog_spawn = {
			variations = { "_01", "_02" },
			volume = 0.5,
			pitch = { 0.8, 1.1 }
		},

		dog_death = {
			variations = { "_01", "_02" },
			volume = 1,
			pitch = { 0.8, 1.1 }
		}
	}
}
