-----------------------------------------------------------------------------------------
--
-- Author: Gop
-- (bisous à) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Ship.lua
--
-- An ugly ship
--
-----------------------------------------------------------------------------------------
local Class = {}

local utils = require("lib.ecusson.utils")
local vec2 = require("lib.ecusson.math.vec2")
local Sprite = require("lib.ecusson.Sprite")
local Sound = require("lib.ecusson.Sound")
local Shot = require("src.game.Shot")


-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

local transitionDuration = 1.0

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the environment
function Class.create(options)
	local self = utils.extend(Class)

	self.sprite = Sprite.create {
		spriteSet = "main",
		animation = "vaisseau",
		group = groups.playership,
		position = vec2(100, 280)
	}

	return self
end


-- Destroy the level
function Class:destroy()
	self.sprite:destroy()
	utils.deleteObject(self)
end

function Class:pew(options)
	return Shot.create{
		position = self.sprite.position,
		velocity = vec2(0,-160)
	}
end

return Class