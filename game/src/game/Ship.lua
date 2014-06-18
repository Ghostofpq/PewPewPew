-----------------------------------------------------------------------------------------
--
-- Author: Gop
-- (bisous à) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Ship.lua
--
-- The main Ship
--
-----------------------------------------------------------------------------------------
local Class = {}

local utils = require("lib.ecusson.Utils")
local vec2 = require("lib.ecusson.math.vec2")
local Sprite = require("lib.ecusson.Sprite")
local Sound = require("lib.ecusson.Sound")
local Shot = require("src.game.Shot")
local aabb = require("lib.ecusson.math.aabb")


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
		position = vec2(30, 100),
		rotation = 90
	}

	self.position = self.sprite.position
	self.velocity = vec2(0,0) 
	self.maxSpeed = 400
	self.target = self.position

	self.weaponCooldown = 0.5
	self.weaponTimer = 0
	return self
end
-- Destroy the level
function Class:destroy()
	self.sprite:destroy()
	utils.deleteObject(self)
end
-- Update
function Class:enterFrame(options)
	local destination = self.target - self.position
	local velocity = destination:capLength(1) * self.maxSpeed
	
	--self.position.x = math.cap(self.position.x + velocity.x * options.dt , self.sprite.width, 320-self.sprite.width)
	self.position.y =math.cap(self.position.y + velocity.y * options.dt , self.sprite.height, 200-self.sprite.height)
	-- Stops the movement if the target is passed
	if (velocity.x > 0) then
		self.position.x = math.min(self.position.x, self.target.x)
	elseif (velocity.x < 0) then
		self.position.x = math.max(self.position.x, self.target.x)
	end
	if (velocity.y > 0) then
		self.position.y = math.min(self.position.y, self.target.y)
	elseif (velocity.y < 0) then
		self.position.y = math.max(self.position.y, self.target.y)
	end

	self.sprite:setPosition(self.position)

	self.weaponTimer = self.weaponTimer - options.dt	
	if self.weaponTimer <= 0 then		
		self.weaponTimer = self.weaponCooldown
		Runtime:dispatchEvent{
			name = "playerPew"
		}
	end	
end
-- Generates a Pew
function Class:pew(options)
	return Shot.create{
		position = self.sprite.position,
		velocity = vec2(300,0),
		ennemy = false
	}
end
-- Sets the movement target
function Class:move(options)
	self.target = options.target
end
-- Gets the Ships AABB
function Class:getAabb(options)
	return aabb(
		vec2(self.sprite.position.x - (self.sprite.width / 2), self.sprite.position.y - (self.sprite.height / 2)),
		vec2(self.sprite.position.x + (self.sprite.width / 2), self.sprite.position.y + (self.sprite.height / 2))   
	)
end

return Class