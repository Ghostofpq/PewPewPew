-----------------------------------------------------------------------------------------
--
-- Sound.lua
--
-- An abstract layer over the Corona sound library.
-- It features:
--  A cleaner way to handle the sounds
--  Default options defined on startup for fade in, fade out, volume, etc.
--  Auto-reset volume before playing the sound
--  Duration parameter along with fade out
--  Sound variations
--  Pitch modulation
--  Pan sound
--  Use media library instead of audio for Android devices
--  Lazy loading of sounds
--
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")

-----------------------------------------------------------------------------------------

local Class = {}
local Sound = Class

-----------------------------------------------------------------------------------------
-- Main
-----------------------------------------------------------------------------------------

-- Load libraries
local audio = require("audio")
local media = require("media")

-- 'Touch' the audio class to enable it by getting one of its attributes
local totalChannels = audio.totalChannels
local maxNoChannelsFreeDuration = 1.0

-- For panning: ensure correct distance model is being used.
al.DistanceModel(al.INVERSE_DISTANCE_CLAMPED)
al.Listener(al.POSITION, 0, 0, 0)
al.Listener(al.ORIENTATION, 0, 1, 0, 0, 0, 1)

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

local nativeTimer = timer
local random = math.random
local sin = math.sin
local cos = math.cos
local MATH_PI_180 = math.pi / 180

-- The sound path
local soundsPath

-- The sounds handles
local sounds = {}

-- Use mp3 by default
local defaultExtension = "mp3"

-- Enable the use of the media library only on iAndroid
local platformName = system.getInfo("platformName")
local enableMedia = platformName == "Android"

-- The group volumes
local groupVolumes = {}

-- Current sounds playing by channel id
local channels = {}

-- The last time all the channels were taken
local noChannelsFreeTime

-----------------------------------------------------------------------------------------
-- Class methods
-----------------------------------------------------------------------------------------

-- Setup sounds
--
-- Parameters:
--  soundsPath: The path to the sounds (e.g. "runtimedata/audio/")
--  soundsData: The user-defined sound data (See Sounds.lua for an example)
function Class.setup(options)
	soundsPath = options.soundsPath

	-- Load sounds
	for groupId, groupSounds in pairs(options.soundsData) do
		groupVolumes[groupId] = 1.0

		for soundId, soundOptions in pairs(groupSounds) do
			-- Select the appropriate method to load the sound
			local media = enableMedia and (soundOptions.media or false)
			local loadMethod

			if soundOptions.stream then
				loadMethod = audio.loadStream
			elseif media then
				loadMethod = media.newEventSound
			else
				loadMethod = audio.loadSound
			end

			local autoDestroy = soundOptions.autoDestroy
			if autoDestroy == nil then
				autoDestroy = true
			end

			-- Save sound settings
			sounds[soundId] = {
				name = soundId,
				groupId = groupId,
				loadMethod = loadMethod,
				loaded = false,
				purgeable = soundOptions.purgeable or false,
				settings = {
					variations = soundOptions.variations or { "" },
					loops = soundOptions.loops or 0,
					volume = soundOptions.volume or 1,
					duration = soundOptions.duration or nil,
					fadeIn = soundOptions.fadeIn or nil,
					fadeOut = soundOptions.fadeOut or nil,
					pitch = soundOptions.pitch or 1,
					stream = soundOptions.stream or false,
					media = media,
					extension = soundOptions.extension or defaultExtension,
					autoDestroy = autoDestroy,
					autoUnload = soundOptions.autoUnload or false
				}
			}
		end
	end
end

-- Stop audio and unload all sounds
function Class.tearDown()
	-- Stop all audio
	audio.stop()

	-- Dispose of all sounds
	for soundId, soundDefinition in pairs(sounds) do
		Class.unloadSound(soundId)
	end

	sounds = {}
end

-- Load a single sound (without playing it)
--
-- Parameters:
--  soundId: The sound to load
function Class.loadSound(soundId)
	local soundDefinition = sounds[soundId]
	if not soundDefinition.loaded then
		print("[Sound] load sound   "..soundId)

		-- Load variations
		local variations = {}
		local soundSettings = soundDefinition.settings
		for i, variation in ipairs(soundSettings.variations) do
			-- Local sound settings
			local localSettings = {}
			for key, value in pairs(soundSettings) do
				localSettings[key] = value
			end

			-- Determine suffix
			local suffix
			if type(variation) == "string" then
				suffix = variation
			else
				suffix = variation.suffix

				-- Override settings
				for key, value in pairs(localSettings) do
					localSettings[key] = variation[key] or localSettings[key]
				end
			end

			local filePath = soundsPath..soundId..suffix.."."..localSettings.extension
			localSettings.handle = soundDefinition.loadMethod(filePath)
			assert(localSettings.handle, "Cannot load sound ("..filePath..")")

			variations[i] = localSettings
		end

		soundDefinition.variations = variations
		soundDefinition.loaded = true
	end
end

-- Unload a sound previously loaded with loadSound
--
-- Parameters:
--  soundId: The sound to unload
function Class.unloadSound(soundId)
	local soundDefinition = sounds[soundId]

	if soundDefinition.loaded then
		print("[Sound] unload sound "..soundId)

		for i = 1, #soundDefinition.variations do
			audio.dispose(soundDefinition.variations[i].handle)
		end

		sounds[soundId].loaded = false
		sounds[soundId].variations = nil
	end
end

-- Unload a bunch of sounds previously loaded with loadSound
--
-- Parameters:
--  soundIds: An array with the ids of the sounds to unload
function Class.unloadSounds(soundIds)
	if soundIds then
		for i = 1, #soundIds do
			Sound.unloadSound(soundIds[i])
		end
	end
end

-- Set the global volume of the whole application
--
-- Parameters:
--  volume: The new volume, in [0, 1]
function Class.setGlobalVolume(volume)
	audio.setVolume(volume)
end

-- Set the volume of a whole group of sounds
--
-- Parameters:
--  group: The group id
--  volume: The new volume, in [0, 1]
function Class.setGroupVolume(options)
	groupVolumes[options.groupId] = options.volume

	for i = 1, audio.totalChannels do
		local sound = channels[i]
		if sound and sound.id then
			sound:resetSoundsVolume()
		end
	end
end

function Class.purgeSounds()
	for soundId, soundDefinition in pairs(sounds) do
		if soundDefinition.purgeable then
			Class.unloadSound(soundId)
		end
	end
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the sound
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
--    (Default is true).
--  autoUnload: Automatically unloads the sound as soon as it has finishes playing
--    (Default is false).
--  onSoundComplete: The callback called when the sound has finished playing (optional).
function Class.create(sound, options)
	local self = utils.extend(Class)

	local soundDefinition = sounds[sound]

	self.id = sound
	self.groupId = soundDefinition.groupId
	self.playing = true

	-- Lazy-load sound if not already loaded
	if not soundDefinition.loaded then
		Class.loadSound(sound)
	end

	options = options or {}

	if audio.freeChannels == 0 then
		print("[Ecusson:Sound] Sound "..soundDefinition.name.." could not be played because all channels are in use.")

		if not noChannelsFreeTime then
			-- The time when all channels were taken
			noChannelsFreeTime = utils.getTime()
		elseif utils.getTime() - noChannelsFreeTime > maxNoChannelsFreeDuration then
			print("[Ecusson:Sound] No channels were free for at least "..maxNoChannelsFreeDuration.." second(s), "..
				"stop all sounds and free all channels.")

			-- Free all the sounds!
			audio.stop()
			noChannelsFreeTime = nil
		end
	else
		noChannelsFreeTime = nil

		-- Determine which variation to play
		local variationCount = #soundDefinition.variations
		local variationId = 1
		if options.variation then
			variationId = options.variation
		elseif variationCount > 1 then
			-- Prevent the same variation to be played twice in a row
			repeat
				variationId = random(variationCount)
			until variationId ~= soundDefinition.lastVariationId
		end

		local variation = soundDefinition.variations[variationId]
		soundDefinition.lastVariationId = variationId

		-- Initialize attributes
		self.isMedia = options.media
		if self.isMedia == nil then
			self.isMedia = variation.media
		end

		self.isStream = options.stream
		if self.isStream == nil then
			self.isStream = variation.stream
		end

		self.autoDestroy = options.autoDestroy
		if self.autoDestroy == nil then
			self.autoDestroy = variation.autoDestroy
		end

		self.autoUnload = options.autoUnload
		if self.autoUnload == nil then
			self.autoUnload = variation.autoUnload
		end

		local duration = options.duration or variation.duration
		local fadeIn = options.fadeIn or variation.fadeIn
		local pitch = options.pitch or variation.pitch
		local volume = options.volume or variation.volume
		self.fadeOut = options.fadeOut or variation.fadeOut
		self.onComplete = options.onSoundComplete
		self.handle = variation.handle
		self.playing = true

		-- Play sound
		if self.isMedia then
			media.playEventSound(self.handle, system.ResourceDirectory)

			if self.autoDestroy then
				self:destroy()
			end
		else
			self.channel, self.source = audio.play(self.handle, {
				loops = options.loops or variation.loops,
				fadeIn = fadeIn and utils.extractValue(fadeIn) * 1000 or nil,
				onComplete = function(options)
					if self.id and not audio.isChannelPlaying(self.channel) then
						self:onSoundComplete(options)
					end
				end
			})

			-- Stop previous sound in case Corona freed the channel before sending the onComplete event
			local previousChannelSound = channels[self.channel]
			if previousChannelSound and previousChannelSound.id then
				previousChannelSound:onSoundComplete(options)
			end

			-- Register sound
			channels[self.channel] = self

			-- Initialize sound for panning
			al.Source(self.source, al.ROLLOFF_FACTOR, 1)
			al.Source(self.source, al.REFERENCE_DISTANCE, 2)
			al.Source(self.source, al.MAX_DISTANCE, 4)

			-- Set volume
			if not fadeIn then
				self:setVolume{
					volume = volume and utils.extractValue(volume) or 1.0
				}
			end

			-- Set pan
			if options.pan then
				self:pan(options.pan)
			end

			-- Set pitch
			if pitch then
				self:setPitch(pitch)
			end

			-- Manual duration handling (to have a proper fade out if any)
			if duration then
				if duration == 0 then
					self:stop()
				else
					self.timerId = nativeTimer.performWithDelay(utils.extractValue(duration) * 1000, self)
				end
			end
		end
	end

	return self
end

-- Destroy the sound object
function Class:destroy()
	if self.playing and not self.isMedia then
		self:stop()
	end

	if self.autoUnload then
		Class.unloadSound(self.id)
	end

	utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Check if the sound is playing
--
-- Returns true if the sound is currently playing
function Class:isPlaying()
	return self.playing
end

-- Pause the sound
-- Warning: This does not free the channel
function Class:pause()
	if self.isMedia then
		print("[Ecusson:Sound] Error: Cannot pause a media sound")
	elseif self.channel then
		if self.timerId then
			nativeTimer.pause(self.timerId)
		end

		self.playing = false
		audio.pause(self.channel)
	end
end

-- Resume the sound
function Class:resume()
	if self.isMedia then
		print("[Ecusson:Sound] Error: Cannot resume a media sound")
	elseif self.channel then
		if self.timerId then
			nativeTimer.resume(self.timerId)
		end

		self.playing = true
		audio.resume(self.channel)
	end
end

-- Rewind the sound
function Class:rewind()
	if self.isMedia then
		print("[Ecusson:Sound] Error: Cannot rewind a media sound")
	elseif self.channel then
		if self.isStream then
			audio.rewind(self.handle)
		else
			audio.rewind{
				channel = self.channel
			}
		end
	end
end

-- Seek to a time position
--
-- Parameters:
--  time: The time to seek, in seconds
function Class:seek(time)
	if self.isMedia then
		print("[Ecusson:Sound] Error: Cannot seek a media sound")
	elseif self.channel then
		audio.seek(time * 1000, {
			channel = self.channel
		})
	end
end

-- Change the volume
--
-- Parameters:
--  volume: The new volume to set, in [0 ; 1]
--  time: The time in seconds to fade the volume (default is nil, no fade)
function Class:setVolume(options)
	if self.isMedia then
		print("[Ecusson:Sound] Error: Cannot set the volume of a media sound")
	elseif self.channel then
		self.volume = utils.extractValue(options.volume)

		if options.time and options.time > 0 then
			audio.fade{
				channel = self.channel,
				time = utils.extractValue(options.time) * 1000,
				volume = self.volume * groupVolumes[self.groupId]
			}
		else
			audio.setVolume(self.volume * groupVolumes[self.groupId], {
				channel = self.channel
			})
		end
	end
end

-- Change the pitch
--
-- Parameters:
--  pitch: The new pitch value
function Class:setPitch(pitch)
	if self.isMedia then
		print("[Ecusson:Sound] Error: Cannot change the pitch of a media sound")
	else
		al.Source(self.source, al.PITCH, utils.extractValue(pitch))
	end
end

-- Pan the sound
--
-- Parameters:
--  value: The pan value, in [-1 ; 1]
function Class:pan(value)
	if self.isMedia then
		print("[Ecusson:Sound] Error: Cannot pan a media sound")
	else
		local radi = (-90 + ((1 + value) * -90)) * MATH_PI_180
		al.Source(self.source, al.POSITION, sin(radi), cos(radi), 0)
	end
end

-- Stop the sound
--
-- Parameters:
--  fadeOutTime: The time in seconds to fade out (default is nil, no fade)
function Class:stop(fadeOutTime)
	if self.isMedia then
		print("[Ecusson:Sound] Error: Cannot stop a media sound")
	elseif self.channel then
		if self.timerId then
			nativeTimer.cancel(self.timerId)
		end

		local fadeOut = fadeOutTime or self.fadeOut

		if fadeOut and fadeOut > 0 then
			audio.fadeOut{
				channel = self.channel,
				time = utils.extractValue(fadeOut) * 1000
			}
		else
			self.playing = false
			audio.stop(self.channel)
		end
	end
end

-- Resets the sound volume, taking into account the global volume (called by setGroupVolume)
function Class:resetSoundsVolume()
	self:setVolume{
		volume = self.volume
	}
end

-----------------------------------------------------------------------------------------
-- Event handlers
-----------------------------------------------------------------------------------------

-- Event callback for the finished timer used to handle the duration
function Class:timer(event)
	self:stop()
end

-- Called when the sound has finished playing
function Class:onSoundComplete(options)
	self.playing = false

	-- Auto-rewind
	if self.isStream then
		self:rewind()
	end

	-- Call user callback if any
	utils.resolveCallback(self.onComplete, "onSoundComplete", event)

	-- Unload & destroy if needed
	if self.autoDestroy then
		self:destroy()
	end
end

-----------------------------------------------------------------------------------------

return Class
