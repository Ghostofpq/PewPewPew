-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- circle.lua
--
-- A circle
--
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")

-----------------------------------------------------------------------------------------

local Class = {}
local MetaClass = {}

local random = math.random

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Build the circle
local function circle(center, radius)
	local self = utils.extend(Class, MetaClass)

	-- Initialize attributes
	self.center = center
	self.radius = radius
	self.powRadius = radius * radius

	return self
end

-- Destroy the circle
function Class:destroy()
	if self.shape then
		self.shape:removeSelf()
	end

	utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Override Methods
-----------------------------------------------------------------------------------------

function MetaClass:__tostring()
	return "[center="..self.center..", radius="..self.radius"]"
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Return true if the circle collides with another circle
function Class:collideCircle(circle)
	return self.center:distance(circle.center) < self.radius + circle.radius
end

-- Return true if the circle collides with a point
function Class:containsPoint(vector)
	return self.center:powDistance(vector) < self.powRadius
end

-- Return a random point in the circle
function Class:randomPoint()
	return self.center + vec2(random(self.radius), 0):rotate(random(360))
end

-- Draw shape
function Class:draw(options)
	options = options or {}

	if self.shape then
		self.shape.x = self.center.x
		self.shape.y = self.center.y

		if options.color then
			self.shape:setStrokeColor(unpack(options.color))
		end
	else
		self.shape = display.newCircle(self.center.x, self.center.y, self.radius)
		self.shape:setFillColor(0, 0, 0, 0)
		self.shape:setStrokeColor(255, 0, 255)
		self.shape.strokeWidth = 1
	end
end

-----------------------------------------------------------------------------------------

return circle
