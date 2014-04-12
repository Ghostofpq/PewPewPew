-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- PerformanceWidget.lua
--
-- A box showing the performance of the application
--
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")
local vec2 = require("lib.ecusson.math.vec2")
local Rectangle = require("lib.ecusson.Rectangle")
local Text = require("lib.ecusson.Text")

-----------------------------------------------------------------------------------------

local Class = {}

-----------------------------------------------------------------------------------------
-- Local configuration
-----------------------------------------------------------------------------------------

local min = math.min
local floor = math.floor

local msRefreshFrequency = 4
local fpsRefreshFrequency = 1
local widgetWidth = 50
local widgetHeight = 15
local barPadding = 4
local fpsReference = 70

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the performance widget
--
-- Parameters:
--  group: The display group to add the box to (optional)
--  position: The position
function Class.create(options)
	local self = utils.extend(Class)

	-- Initialize attributes
	self.msTimer = 0
	self.msFrameCount = 0
	self.frameCount = 0
	self.frameTimer = 0

	-- Create group
	self.group = display.newGroup()
	if options.group then
		options.group:insert(self.group)
	end

	-- Position group
	self.group.x = options.position.x
	self.group.y = options.position.y

	-- Create widget
	self.background = Rectangle.create{
		group = self.group,
		anchor = "tl",
		width = widgetWidth,
		height = widgetHeight,
		cornerRadius = 2,
		opacity = 0.5,
		color = { 0, 0, 0 }
	}

	self.fps = Text.create{
		group = self.group,
		anchor = "tr",
		position = vec2(24, 8),
		color = { 255, 255, 255 },
		size = 6
	}

	self.ms = Text.create{
		group = self.group,
		anchor = "tr",
		position = vec2(46, 8),
		color = { 255, 255, 255 },
		size = 6
	}

	self.instantBar = Rectangle.create{
		group = self.group,
		anchor = "tl",
		height = 2,
		position = vec2(barPadding, 2),
		opacity = 0.75
	}

	self.msBar = Rectangle.create{
		group = self.group,
		anchor = "tl",
		height = 2,
		position = vec2(barPadding, 4),
		opacity = 0.75
	}

	self.fpsBar = Rectangle.create{
		group = self.group,
		anchor = "tl",
		height = 2,
		position = vec2(barPadding, 6),
		opacity = 0.75
	}

	-- Bind events
	Runtime:addEventListener("ecussonEnterFrame", self)

	return self
end

-- Destroy the rectangle
function Class:destroy()
	Runtime:removeEventListener("ecussonEnterFrame", self)

	self.fpsBar:destroy()
	self.msBar:destroy()
	self.instantBar:destroy()
	self.ms:destroy()
	self.fps:destroy()
	self.background:destroy()

	self.group:removeSelf()

	utils.deleteObject(self)
end

-- Return the bar color depending on the FPS value
--
-- Parameters:
--  fps: The FPS value
--
-- Return a color:
--  Red if FPS < 10
--  Orange if FPS < 20
--  Yellow if FPS < 30
--  Green otherwise
local getBarColor = function(fps)
	if fps < 10 then
		return { 255, 0, 0 }
	elseif fps < 20 then
		return { 255, 128, 0 }
	elseif fps < 30 then
		return { 255, 255, 0 }
	else
		return { 0, 255, 0 }
	end
end

-- Update the bar color and width depending on the FPS
--
-- Parameters:
--  bar: The bar object
--  fps: The FPS value for this bar
local updatebar = function(bar, fps)
	fps = min(fps, 75)

	bar:resize{
		width = (fps / fpsReference) * (widgetWidth - 2 * barPadding)
	}

	bar:setColor(getBarColor(fps))
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter frame handler
--
-- Parameters:
--  event: The event object
function Class:ecussonEnterFrame(options)
	self.msTimer = self.msTimer + options.dt
	self.msFrameCount = self.msFrameCount + 1
	self.frameTimer = self.frameTimer + options.dt
	self.frameCount = self.frameCount + 1

	-- Update instant bar
	updatebar(self.instantBar, 1 / options.dt)

	-- Update MS text
	if self.msTimer >= 1 / msRefreshFrequency then
		updatebar(self.msBar, self.msFrameCount * msRefreshFrequency)
		self.ms:setText(floor(options.dt * 1000).." ms")
		self.msTimer = 0
		self.msFrameCount = 0
	end

	-- Update FPS text and bar
	if self.frameTimer >= 1 / fpsRefreshFrequency then
		local fps = self.frameCount * fpsRefreshFrequency

		self.fps:setText(fps.." fps")
		updatebar(self.fpsBar, fps)

		self.frameTimer = 0
		self.frameCount = 0
	end
end

-----------------------------------------------------------------------------------------

return Class
