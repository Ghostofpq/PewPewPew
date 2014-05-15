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
-----------------------------------------------------------------------------------------
-- Local configuration
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function Class.create(options)
	local self = utils.extend(Class)
	self.id = utils.getUuid()
	-- Initialize attributes
	self.sprite = Sprite.create {
		spriteSet = "generated",
		animation = "laser",
		group = groups.weapons,
		position = options.position
	}

	self.velocity = options.velocity
	self.position = options.position
	return self
end

function Class:destroy()
	self.sprite:destroy()
	utils.deleteObject(self)
end

function Class:enterFrame(options)
	self.position = self.position + self.velocity * options.dt
	self.sprite:setPosition(self.position)
end
-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------

return Class