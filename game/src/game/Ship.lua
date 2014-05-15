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

	self.position = self.sprite.position
	self.velocity = vec2(0,0) 
	self.maxSpeed = 400
	self.target = self.position

	return self
end


function Class:enterFrame(options)
	local destination = self.target - self.position
	local velocity = destination:capLength(1) * self.maxSpeed
	self.position.x = math.cap(self.position.x + velocity.x * options.dt , self.sprite.width, 200-self.sprite.width)
	
	self.sprite:setPosition(self.position)
		
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

function Class:move(options)
	self.target = options.target
end

return Class