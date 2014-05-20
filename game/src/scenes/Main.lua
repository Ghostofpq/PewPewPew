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
local EnnemyShip = require("src.game.EnnemyShip")
local Text = require("lib.ecusson.Text")
local Sound = require("lib.ecusson.Sound")
local aabb = require("lib.ecusson.math.aabb")

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
	self.hourglass2 = 0

	self.pews = {}
	self.ennemyships = {}

	-- Add the key callback
	Runtime:addEventListener("key", self)
	Runtime:addEventListener("increaseScore", self)
	Runtime:addEventListener("ecussonEnterFrame", self)
	Runtime:addEventListener("touch", self)
	Runtime:addEventListener("playerPew", self)
	Runtime:addEventListener("ennemyPew", self)
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
	Runtime:removeEventListener("touch", self)
	Runtime:removeEventListener("playerPew", self)
	Runtime:removeEventListener("ennemyPew", self)
	for k, v in pairs(self.pews) do
		v:destroy()
	end
	for k, v in pairs(self.ennemyships) do
		v:destroy()
	end
end

-----------------------------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------------------------

function Class:playerPew(event)
	local pew = self.playership:pew()
	self.pews[pew.id]=pew
end

function Class:ennemyPew(event)
	local pew = self.ennemyships[event.value]:pew()
	self.pews[pew.id]=pew
end

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

function Class:ecussonEnterFrame(options)
	-- check pews
	for k, v in pairs(self.pews) do
		v:enterFrame(options)
		if v.position.y <= 0 or v.position.y >320 then
			v:destroy()
			self.pews[k]=nil
		elseif v.ennemy then
			if v:getAabb():collideAABB(self.playership:getAabb()) then
				-- Destroy pew
				v:destroy()
				self.pews[k]=nil	
				-- Destroy ship
				self:increaseScore{value=1}
			end
		else
			for k2, v2 in pairs(self.ennemyships) do
				if v:getAabb():collideAABB(v2:getAabb()) then
					-- Destroy pew
					v:destroy()
					self.pews[k]=nil
					-- Destroy ennemy
					v2:destroy()
					self.ennemyships[k2]=nil
					break
				end
			end
		end
	end

	if self.hourglass2 <= 0 then
		local ennemyship = EnnemyShip.create{
			position = vec2(50,50),
			velocity = vec2(0,15),
			weaponCooldown = 1
		}

		self.ennemyships[ennemyship.id]=ennemyship
		self.hourglass2 = 5
	end

	self.hourglass = self.hourglass - options.dt
	self.hourglass2 = self.hourglass2 - options.dt

	-- Update PlayerShip
	self.playership:enterFrame(options)

	-- Update ennemy Ships
	for k, v in pairs(self.ennemyships) do
		-- Update ennemy Ship
		v:enterFrame(options)
	end
end

function Class:touch(options)
	self.playership:move{target=vec2(options.x,options.y)}
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
