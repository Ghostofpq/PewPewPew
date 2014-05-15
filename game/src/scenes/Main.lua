-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Main.lua
--
-- Main scene
--
-----------------------------------------------------------------------------------------

local storyboard = require("storyboard")
local Class = storyboard.newScene()

local vec2 = require("lib.ecusson.math.vec2")
local Sprite = require("lib.ecusson.Sprite")
local Ship = require("src.game.Ship")
local Text = require("lib.ecusson.Text")
local Sound = require("lib.ecusson.Sound")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function Class:createScene(event)
	-- Do nothing
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function Class:destroyScene(event)
	-- Do nothing
end

-- Called immediately after scene has moved onscreen:
function Class:enterScene(event)
	self.score = 0

	self.background = Sprite.create{
		spriteSet = "level",
		animation = "background",
		group = groups.background,
		anchor = "tl"
	}

	self.scoreText = Text.create{
		position = vec2(0, -1),
		group = groups.hud,
		anchor = "tl",
		size = 16,
		color = { 254, 228, 158 },
		shadows = {
			{
				offset = vec2(-.5, -.5),
				color = { 128, 93, 80 }
			}, {
				offset = vec2(-.5, .5),
				color = { 128, 93, 80 }
			}, {
				offset = vec2(.5, -.5),
				color = { 128, 93, 80 }
			}, {
				offset = vec2(.5, .5),
				color = { 128, 93, 80 }
			}
		}
	}

	self:increaseScore{
		value = 0
	}

	self.playership = Ship.create()

	self.hourglass = 0

	self.pews = {}
	-- Add the key callback
	Runtime:addEventListener("key", self)
	Runtime:addEventListener("increaseScore", self)
	Runtime:addEventListener("ecussonEnterFrame", self)
end

function Class:ecussonEnterFrame(options)
	if self.hourglass <= 0 then
		local pew = self.playership:pew()
		self.pews[pew.id]=pew
		self.hourglass = 1
	end

	self.hourglass = self.hourglass - options.dt

	for k, v in pairs(self.pews) do
		v:enterFrame(options)
		if v.position.y <= 0 then
			v:destroy()
			self.pews[k]=nil
		end
	end
end

-- Called when scene is about to move offscreen:
function Class:exitScene(event)
	self.scoreText:destroy()
	self.foreground:destroy()
	self.background:destroy()
	self.playership:destroy()
	Runtime:removeEventListener("increaseScore", self)
	Runtime:removeEventListener("key", self)
	Runtime:removeEventListener("ecussonEnterFrame", self)

	for k, v in pairs(self.pews) do
		v:destroy()
	end
end

-----------------------------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------------------------

-- Key listener
function Class:key(event)
	if event.keyName == "back" and event.phase == "up" then
		os.exit()
	end

	return false
end

function Class:increaseScore(options)
	self.score = self.score + options.value
	self.scoreText:setText(lang:translate("score", self.score))
end

-----------------------------------------------------------------------------------------
-- Binding
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
Class:addEventListener("createScene", Class)

-- "enterScene" event is dispatched whenever scene transition has finished
Class:addEventListener("enterScene", Class)

-- "exitScene" event is dispatched whenever before next scene's transition begins
Class:addEventListener("exitScene", Class)

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
Class:addEventListener("destroyScene", Class)

-----------------------------------------------------------------------------------------

return Class
