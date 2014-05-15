-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- main.lua
--
-----------------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)
system.activate("multitouch")

math.randomseed(os.time())

-----------------------------------------------------------------------------------------
-- Start Logger
-----------------------------------------------------------------------------------------

local Logger = require("lib.ecusson.Logger")
Logger.create{
	bugReportMail = "ecusson@yopmail.com",
	bugReportName = "log.txt",
	screenshotName = "screenshot.jpeg"
}

local utils = require("lib.ecusson.utils")
local vec2 = require("lib.ecusson.math.vec2")
local Lang = require("lib.ecusson.Lang")
local Rectangle = require("lib.ecusson.Rectangle")
local Sound = require("lib.ecusson.Sound")
local Sprite = require("lib.ecusson.Sprite")
local PerformanceWidget = require("lib.ecusson.PerformanceWidget")

local storyboard = require("storyboard")

-----------------------------------------------------------------------------------------
-- Debug
-----------------------------------------------------------------------------------------

-- Version
print("App version "..system.getInfo("appVersionString"))
print("Corona build "..system.getInfo("build"))
print(" ")

-- Date
local date = os.date("*t")
print("Current date: "..date.year.."/"..date.month.."/"..date.day)
print(" ")

-- Device
print("Device: "..system.getInfo("deviceID").." ("..system.getInfo("name")..")")
print("Model: "..system.getInfo("model").." ("..system.getInfo("architectureInfo")..")")
print("Platform: "..system.getInfo("platformName").." "..system.getInfo("platformVersion"))
print("Store: "..system.getInfo("targetAppStore"))
print(" ")

-- Screen size
print("Screen resolution: "..display.pixelWidth.."x"..display.pixelHeight)
print("Screen density: "..utils.getDpi().." dpi ("..math.cut(utils.getCdpi(), 2).." cdpi)")
print("Screen size: "..math.cut(utils.getScreenSize(), 2))
print(" ")

-- Useful info
print("Max texture size: "..(system.getInfo("maxTextureSize") / 1024).."k")
print(" ")

-----------------------------------------------------------------------------------------
-- System
-----------------------------------------------------------------------------------------

-- Prevent device from dimming / sleeping
system.setIdleTimer(false)

-----------------------------------------------------------------------------------------
-- Globals (beh)
-----------------------------------------------------------------------------------------

-- Create groups
groups = {
	background     	= display.newGroup(),
	ennemies        = display.newGroup(),
	bosses     		= display.newGroup(),
	playership      = display.newGroup(),
	weapons      	= display.newGroup(),
	foreground  	= display.newGroup(),
	hud  			= display.newGroup(),
	borders        	= display.newGroup(),
	debug          	= display.newGroup()
}

-- Init lang module
lang = Lang.create{
	path = "runtimedata.lang."
}

-----------------------------------------------------------------------------------------
-- Preload spritesheets
-----------------------------------------------------------------------------------------

Sprite.setup{
	imagePath = "runtimedata/sprites/",
	datapath = "runtimedata.sprites.",
	animationData = require("src.config.Sprites").sheets
}

Sprite.loadSheet("sprites")

-----------------------------------------------------------------------------------------
-- Setup sounds
-----------------------------------------------------------------------------------------

Sound.setup{
	soundsPath = "runtimedata/audio/",
	soundsData = require("src.config.Sounds")
}

-----------------------------------------------------------------------------------------
-- Borders
-----------------------------------------------------------------------------------------

local borders = {
	-- Left border
	Rectangle.create{
		group = groups.borders,
		color = { 0, 0, 0 },
		anchor = "tr",
		width = 30,
		height = 320
	},
	-- Right border
	Rectangle.create{
		group = groups.borders,
		color = { 0, 0, 0 },
		anchor = "tl",
		width = 30,
		height = 320,
		position = vec2(200, 0)
	},
	-- Top border
	Rectangle.create{
		group = groups.borders,
		color = { 0, 0, 0 },
		anchor = "bl",
		width = 200,
		height = 30
	},
	-- Bottom border
	Rectangle.create{
		group = groups.borders,
		color = { 0, 0, 0 },
		anchor = "tl",
		width = 200,
		height = 30,
		position = vec2(0, 320)
	}
}

-----------------------------------------------------------------------------------------
-- FPS
-----------------------------------------------------------------------------------------

local performanceWidget = PerformanceWidget.create{
	position = vec2(0, 320 - 15),
	group = groups.debug
}

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- System event listener
local systemEventListener = function(event)
	print("[System] "..event.type)

	if event.type == "applicationStart" then
		-- Seed randomizer
		math.randomseed(os.time())

		-- Start the multiplayer game
		storyboard.gotoScene("src.scenes.Main")
	elseif event.type == "applicationExit" then
		-- Unload sounds
		Sound.tearDown()

		-- Delete performance widget
		if performanceWidget then
			performanceWidget:destroy()
		end

		-- Delete borders
		for i = 1, #borders do
			borders[i]:destroy()
		end

		-- Delete groups
		for i = 1, #groups do
			groups[i]:removeSelf()
		end

		return true
	elseif event.type == "applicationSuspend" then
		return true
	elseif event.type == "applicationResume" then
		return true
	end

	return false
end

-- Setup a system event listener
Runtime:addEventListener("system", systemEventListener)
