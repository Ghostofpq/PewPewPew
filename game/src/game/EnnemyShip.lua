-----------------------------------------------------------------------------------------
--
-- Author: Gop
-- (bisous à) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Ennmy Ship.lua
--
-- An ugly ennemy ship
--
-----------------------------------------------------------------------------------------
local Class = {}

local utils = require("lib.ecusson.utils")
local vec2 = require("lib.ecusson.math.vec2")
local Sprite = require("lib.ecusson.Sprite")
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
	self.id = utils.getUuid()
	self.sprite = Sprite.create {
		spriteSet = "main",
		animation = "vaisseau",
		group = groups.playership,
		position = options.position
	}

	self.position = self.sprite.position
	self.velocity = options.velocity
	self.weaponCooldown = options.weaponCooldown
	self.weaponTimer = 0

	return self
end


function Class:enterFrame(options)
	self.position = self.position + self.velocity * options.dt
	self.sprite:setPosition(self.position)

	self.weaponTimer = self.weaponTimer - options.dt	
	if self.weaponTimer <= 0 then		
		self.weaponTimer = self.weaponCooldown
		Runtime:dispatchEvent{
			name = "ennemyPew",
			value = self.id
		}
	end	
end

-- Destroy the level
function Class:destroy()
	self.sprite:destroy()
	utils.deleteObject(self)
end

function Class:pew(options)
	return Shot.create{
		position = self.sprite.position,
		velocity = vec2(0,160),
		ennemy = true
	}
end

return Class