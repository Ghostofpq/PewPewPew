-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- EcussonDisplayObject.lua
--
-- The parent of all Ecusson display object classes.
--
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")
local vec2 = require("lib.ecusson.math.vec2")
local aabb = require("lib.ecusson.math.aabb")
local EventAttacher = require("lib.ecusson.EventAttacher")

-----------------------------------------------------------------------------------------

local Super = EventAttacher
local Class = utils.extend(Super)

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

local min = math.min
local max = math.max
local _255 = 1 / 255
local minScale = 0.01

local anchors = {
	tl = vec2(0.0, 0.0),
	tc = vec2(0.5, 0.0),
	tr = vec2(1.0, 0.0),
	cl = vec2(0.0, 0.5),
	c  = vec2(0.5, 0.5),
	cr = vec2(1.0, 0.5),
	bl = vec2(0.0, 1.0),
	bc = vec2(0.5, 1.0),
	br = vec2(1.0, 1.0)
}

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the display object
--
-- Parameters:
--  group: The display group to add the object to (optional)
--  anchor: The anchor point, either a string (tl, tc, tr, cl, c, cr, bl, bc, br)
--    or a vec2 between vec2(0, 0) and vec2(1, 1) (default is centered, vec2(0.5, 0.5))
--  position: The position (default is vec2(0, 0))
--  rotation: The display object rotation (default is 0)
--  scale: The uniform scale on both x and y axis (default is 1)
--  opacity: The opacity value, in [0 ; 1] (default is 1)
--  visible: If false, the object will not appear on screen (default is true)
--  toBack: If true, creates the object on back of the group (behind other objects already in this group)
--  color: The color, as an array of color components (r, g, b, a (optional)) (default is 255, 255, 255, 255)
--  hitTestable: If true, forces the display object to be hitTestable (cf Corona documentation) (default is false)
function Class:super(options)
	-- Add display object to group
	if self.group then
		self.group:insert(self._displayObject)
	elseif options.group then
		options.group:insert(self._displayObject)
	end

	if options.toBack then
		self._displayObject:toBack()
	end

	-- Set reference point
	if options.anchor then
		self:setAnchor(options.anchor)
	end

	-- Prepare display object
	self:setPosition(options.position or vec2(0, 0))
	self:setScale(options.scale or 1)
	self:setRotation(options.rotation or 0)
	self:setOpacity(options.opacity or 1)

	if options.visible == false then
		self:hide()
	else
		self:show()
	end

	if options.hitTestable then
		self._displayObject.isHitTestable = options.hitTestable
	end

	if options.color then
		self:setColor(options.color)
	end

	-- Install proxy listeners to receive addEventListener and removeEventListener calls
	self:installListeners(self._displayObject)

	return self
end

-- Destroy the display object
function Class:destroy()
	-- Do nothing
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Get the display group
--
-- Returns:
--  The Corona display object shadowed by Ecusson
function Class:getDisplayGroup()
	return self.group or self._displayObject
end

-- Get the display object
--
-- Returns:
--  The Corona display object shadowed by Ecusson
function Class:getDisplayObject()
	return self._displayObject
end

-- Get the object world coordinates
--
-- Returns the object coordinates relative to the world, as a vec2
function Class:getWorldCoordinates()
	return vec2(self._displayObject:localToContent(0, 0))
end

-- Find the display object bounds
--
-- Returns:
--  An AABB representing the display object boundaries
function Class:getBounds()
	local center = self:getWorldCoordinates()
	local extent = vec2(self._displayObject.width * 0.5, self._displayObject.height * 0.5)
	return aabb(center - extent, center + extent)
end

-- Set the anchor point
--
-- Parameters:
--  anchor: The anchor point, either a string (tl, tc, tr, cl, c, cr, bl, bc, br)
--    or a vec2 between vec2(0, 0) and vec2(1, 1)
function Class:setAnchor(anchor)
	self.anchor = anchors[anchor] or anchor
	self._displayObject.anchorX = self.anchor.x
	self._displayObject.anchorY = self.anchor.y
end

-- Move the display object to a given position
--
-- Parameters:
--  position: The position
function Class:setPosition(position)
	self.position = position

	local target = self:getDisplayObject()
	target.x = position.x
	target.y = position.y
end

-- Move the display object by a certain delta
--
-- Parameters:
--  delta: The delta to move the object of
function Class:move(delta)
	self:setPosition(self.position + delta)
end

-- Set the rotation of the display object
--
-- Parameters:
--  rotation: the rotation in degrees
function Class:setRotation(rotation)
	self.rotation = rotation
	self:getDisplayObject().rotation = rotation
end

-- Rotate the display object
--
-- Parameters:
--  delta: The number of degrees to move the object from (in degrees)
function Class:rotate(delta)
	self:setRotation(self.rotation + delta)
end

-- Set the opacity of the display object
--
-- Parameters:
--  opacity: The new opacity, between 0 and 1
function Class:setOpacity(opacity)
	self.opacity = max(0, min(opacity, 1))
	self:getDisplayGroup().alpha = self.opacity
	self:getDisplayObject().alpha = self.opacity
end

-- Set the visibility of the display object
--
-- Parameters:
--  visible: if true, the object will be visible
function Class:setVisible(visible)
	self.isVisible = visible
	self:getDisplayGroup().isVisible = visible
end

-- Show the display object
function Class:show()
	self:setVisible(true)
end

-- Hide the display object
function Class:hide()
	self:setVisible(false)
end

-- Set the scale of the display object
--
-- Parameters:
--  scale: The new scale
function Class:setScale(scale)
	if type(scale) == "number" then
		local boundedScale = scale == 0 and minScale or scale
		self.scale = vec2(boundedScale, boundedScale)
	else
		self.scale = scale:clone()

		if self.scale.x == 0 then
			self.scale.x = minScale
		end

		if self.scale.y == 0 then
			self.scale.y = minScale
		end
	end
	
	self._displayObject.xScale = self.scale.x
	self._displayObject.yScale = self.scale.y
end

-- Set the color of the display object
--
-- Parameters:
--  color: The four components of a color, in this order: R, G, B, Alpha (optional)
function Class:setColor(color)
	color[4] = color[4] ~= nil and color[4] or 255
	self.color = color
	self._displayObject:setFillColor(color[1] * _255, color[2] * _255, color[3] * _255, color[4] * _255)
end

-----------------------------------------------------------------------------------------

return Class
