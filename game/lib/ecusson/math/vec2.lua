-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- vec2.lua
--
-- A 2 dimension vector, with x and y components
--
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")

-----------------------------------------------------------------------------------------

local Class = {}
local MetaClass = {}

-----------------------------------------------------------------------------------------
-- Local attributes
-----------------------------------------------------------------------------------------

local sqrt = math.sqrt
local min = math.min
local max = math.max
local random = math.random
local cos = math.cos
local sin = math.sin
local atan2 = math.atan2
local acos = math.acos
local PI = math.pi
local PI_180 = PI / 180
local PI_180_invert = 180 / PI

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Build the vector
local function vec2(x, y)
	local self = utils.extend(Class, MetaClass)

	-- Initialize attributes
	self.x = x
	self.y = y

	return self
end

-- Destroy the vector
function Class:destroy()
	if self.shape then
		self.shape:removeSelf()
	end

	utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Override Methods
-----------------------------------------------------------------------------------------

-- Override binary operator '+'
function MetaClass:__add(b)
	return vec2(self.x + b.x, self.y + b.y)
end

-- Override binary operator '-'
function MetaClass:__sub(b)
	return vec2(self.x - b.x, self.y - b.y)
end

-- Override binary operator '*'
function MetaClass:__mul(b)
	if type(b) == "number" then
		return vec2(self.x * b, self.y * b)
	else
		return vec2(self.x * b.x, self.y * b.y)
	end
end

-- Override binary operator '/'
function MetaClass:__div(b)
	if type(b) == "number" then
		return vec2(self.x / b, self.y / b)
	else
		return vec2(self.x / b.x, self.y / b.y)
	end
end

-- Override unary operator '-'
function MetaClass:__unm()
	return vec2(-self.x, -self.y)
end

-- Override binary operator '=='
function MetaClass:__eq(b)
	return self.x == b.x and self.y == b.y
end

-- Override binary operator '<'
function MetaClass:__lt(b)
	return self.x < b.x or self.x == b.x and self.y < b.y
end

-- Override tostring method
function MetaClass:__tostring()
	return "[x="..tostring(self.x).." ; y="..tostring(self.y).."]"
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Return a copy of the vector
function Class:clone()
	return vec2(self.x, self.y)
end

-- Make the dot product between two vectors
function Class:dot(v)
	return self.x * v.x + self.y * v.y
end

-- Make the cross product between two vectors
function Class:cross(v)
	return self.x * v.y - self.y * v.x
end

-- Return the perpendicular vector
function Class:perp()
	return vec2(-self.y, self.x)
end

-- Return the length of the vector
function Class:length()
	return sqrt(self.x * self.x + self.y * self.y)
end

-- Return the powered length (length ^ 2) of the vector
function Class:powLength()
	return self.x * self.x + self.y * self.y
end

-- Return the angle of the vector in radians
function Class:radAngle()
	return atan2(self.x, self.y)
end

-- Return the angle of the vector in degrees
function Class:angle()
	return self:radAngle() * PI_180_invert
end

-- Return the angle between this vector and another in radians
function Class:radVectorAngle(vector)
	return acos(self:dot(vector) / (self:length() * vector:length()))
end

-- Return the angle between this vector and another in degrees
function Class:vectorAngle(vector)
	return self:radVectorAngle(vector) * PI_180_invert
end

-- Return a normalized version of the vector
function Class:norm()
	return self / self:length()
end

-- Cap the length to a maximal value
function Class:capLength(maxValue)
	local length = self:length()

	if length <= maxValue then
		return self
	else
		return self * (maxValue / length)
	end
end

function Class:reflect(normal)
	return normal * 2 * self:dot(normal) - self
end

-- Rotate the vector around a point (by default its origin)
function Class:rotate(angle, center)
	if center then
		-- Translate vector and apply the rotation
		return (self - center):rotate(angle) + center
	else
		local radAngle = angle * PI_180
		local cosAngle = cos(radAngle)
		local sinAngle = sin(radAngle)

		-- Apply rotation
		return vec2(
			self.x * cosAngle - self.y * sinAngle,
			self.x * sinAngle + self.y * cosAngle
		)
	end
end

-- Return a new vector with the minimal components of the two vectors
function Class:min(v)
	return vec2(min(self.x, v.x), min(self.y, v.y))
end

-- Return a new vector with the maximal components of the two vectors
function Class:max(v)
	return vec2(max(self.x, v.x), max(self.y, v.y))
end

-- Return the distance between the two vectors
function Class:distance(v)
	return (v - self):length()
end

-- Return the powered distance (distance ^ 2) between the two vectors
function Class:powDistance(v)
	return (v - self):powLength()
end

-- Return a vector with random values for each component that are between the two vectors
function Class:random(v)
	return vec2(random(self.x, v.x), random(self.y, v.y))
end

-- Return the intersection point (if any) between two segments, return nil otherwise
--
-- Parameters:
--  p: The first segment position
--  r: The first segment vector
--  q: The second segment position
--  s: The second segment vector
--
-- Usage: vec2():getIntersection(p, r, q, s)
function Class:getIntersection(p, r, q, s)
	local rxs = r:cross(s)

	-- r x s = 0 means lines are parrallel
	if rxs ~= 0 then
		local o = q - p
		local dr = o:cross(s) / rxs
		local ds = o:cross(r) / rxs

		-- dr outside [ 0 ; 1 ] means segments do not collide (but non-limited lines would collide)
		if dr >= 0 and dr <= 1 and ds >= 0 and ds <= 1 then
			return p + r * dr
		end
	end
end

-- Return true if the vector is in the given circle
function Class:isInCircle(v, radius)
	local dx = self.x - v.x
	local dy = self.y - v.y
	
	return (dx * dx + dy * dy <= radius * radius)
end

-- Return true if the point is in the given triangle
function Class:isInTriangle(a, b, c)
	-- Compute vectors
	local v0 = c - a
	local v1 = b - a
	local v2 = self - a

	-- Compute dot products
	local dot00 = v0:dot(v0)
	local dot01 = v0:dot(v1)
	local dot02 = v0:dot(v2)
	local dot11 = v1:dot(v1)
	local dot12 = v1:dot(v2)

	-- Compute barycentric coordinates
	local invDenom = 1 / (dot00 * dot11 - dot01 * dot01)
	local u = (dot11 * dot02 - dot01 * dot12) * invDenom
	local v = (dot00 * dot12 - dot01 * dot02) * invDenom

	-- Check if point is in triangle
	return (u >= 0 and v >= 0 and u + v < 1)
end

-- Return true if the point in the given rectangle
function Class:isInRectangle(x, y, w, h)
	return self.x >= x and self.y >= y and self.x <= x + w and self.y <= y + h
end

-- Draw the vector as a point on the screen
function Class:draw(options)
	options = options or {}

	if self.shape then
		if options.size then
			self.shape.width = options.size
			self.shape.height = options.size
		end

		local position = self - vec2(self.shape.width, self.shape.height) * 0.5
		self.shape.x = position.x
		self.shape.y = position.y

		if options.color then
			self.shape:setFillColor(unpack(options.color))
		end
	else
		local size = options.size or 2
		local position = self - vec2(size, size) * 0.5

		self.shape = display.newRect(position.x, position.y, size, size)
		self.shape:setFillColor(unpack(options.color or { 255, 255, 255 }))
	end

	return self.shape
end

-----------------------------------------------------------------------------------------

return vec2
