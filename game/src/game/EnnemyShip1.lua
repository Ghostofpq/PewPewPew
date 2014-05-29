-----------------------------------------------------------------------------------------
--
-- .lua
--
-- 
--
-----------------------------------------------------------------------------------------

local Class = {}

local utils = require("lib.ecusson.utils")
local vec2 = require("lib.ecusson.math.vec2")
local Sprite = require("lib.ecusson.Sprite")
local Sound = require("lib.ecusson.Sound")
local Shot = require("src.game.Shot")
-----------------------------------------------------------------------------------------
-- Local configuration
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------
function Class.create(options)
	local self = utils.extend(Class)

	-- Initialize attributes
	local self = utils.extend(Class)

	self.sprite = Sprite.create {
		spriteSet = "main",
		animation = "vaisseau",
		group = groups.ennemies,
		position = vec2(100, 30)
	}

	self.position = self.sprite.position
	self.velocity = vec2(0,20) 
	self.hourglass = 1,5
	return self
end

function Class:destroy()
	self.sprite:destroy()
	utils.deleteObject(self)
end
-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------
function Class:enterFrame(options)
	self.position.x = self.position.x + velocity.x * options.dt
	
	self.sprite:setPosition(self.position)
end

function Class:pew(options)
	return Shot.create{
		position = self.sprite.position,
		velocity = vec2(0,160),
		ennemy = true
	}
end
-----------------------------------------------------------------------------------------

return Class