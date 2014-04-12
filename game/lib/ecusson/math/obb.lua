-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- obb.lua
--
-- An Oriented Bounding Box
--
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")
local aabb = require("lib.ecusson.math.aabb")

-----------------------------------------------------------------------------------------

local Class = {}
local MetaClass = {}

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Build the OBB
local function obb(center, width, height, rotation)
	local self = utils.extend(Class, MetaClass)

	-- Initialize attributes
	self.center = center
	self.halfWidth = width * 0.5
	self.halfHeight = height * 0.5
	self.rotation = rotation

	return self
end

-- Destroy the OBB
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
	return "[center="..self.center.." ; extents="..self.extentX.." ("..self.halfWidth..") ; "..self.extentY.." ("..self.halfHeight..")]"
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Return the OBB width
function Class:getWidth()
	return self.halfWidth * 2
end

-- Return the OBB height
function Class:getHeight()
	return self.halfHeight * 2
end

-- Return true if the OBB contains the vector
function Class:containsPoint(vector)
	return self:_getAABB():containsPoint(self:_worldToLocal(vector))
end

-- Return the number of collisions with a line, by rotating the line and then using Cohen-Sutherland algorithm
-- -1: No collisions and the line is outside the box
--  0: No collisions and the line is inside the box
--  1: 1 collision, meaning on end of the line is inside while the other is outside
--  2: 2 collisions, meaning the line goes through the box
function Class:collideLine(a, b)
	return self:_getAABB():collideLine(self:_worldToLocal(a), self:_worldToLocal(b))
end

-- Return a AABB as if the OOB was not oriented
function Class:_getAABB()
	return aabb(
		vec2(self.center.x - self.halfWidth, self.center.y - self.halfHeight),
		vec2(self.center.x + self.halfWidth, self.center.y + self.halfHeight)
	)
end

-- Return the local position of a vector in the OBB coordinate system
function Class:_worldToLocal(vector)
	return vector:rotate(-self.rotation, self.center)
end

-- Draw shape
function Class:draw(options)
	options = options or {}

	if self.shape then
		self.shape.x = self.center.x
		self.shape.y = self.center.y
		self.shape.rotation = self.rotation

		if options.color then
			self.shape:setStrokeColor(unpack(options.color))
		end
	else
		local size = options.size or 2

		self.shape = display.newRect(0, 0, self:getWidth(), self:getHeight())
		self.shape.x = self.center.x
		self.shape.y = self.center.y
		self.shape.rotation = self.rotation
		self.shape:setFillColor(0, 0, 0, 0)
		self.shape:setStrokeColor(unpack(options.color or { 255, 0, 255 }))
		self.shape.strokeWidth = 1
	end
end

-----------------------------------------------------------------------------------------

return obb
