-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Text.lua
--
-- An abstract layer over the Corona text fields, used to simplify how it is handled by
-- Corona.
-- It features:
--  A cleaner way to handle the text objects
--
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")
local EcussonDisplayObject = require("lib.ecusson.internal.EcussonDisplayObject")

-----------------------------------------------------------------------------------------

local Super = EcussonDisplayObject
local Class = utils.extend(Super)
local Text = Class

-----------------------------------------------------------------------------------------
-- Local attributes
-----------------------------------------------------------------------------------------

local _255 = 1 / 255

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the text field
--
-- Parameters:
--  group: The display group to add the text to (optional)
--  text: The text to display
--  anchor: The anchor point, either a string (tl, tc, tr, cl, c, cr, bl, bc, br)
--    or a vec2 between vec2(0, 0) and vec2(1, 1) (default is centered, vec2(0.5, 0.5))
--  width: The text width for multiline purpose (default is 0, i.e. not used)
--  height: The text height for multiline purpose (default is 0, i.e. not used)
--  position: The position (default is vec2(0, 0))
--  rotation: The text rotation (default is 0)
--  font: The font (default is native.systemFont)
--  size: The font size (default is 8)
--  align: The text alignment (left, center or right) (default is left)
--  color: The text color, as an array of color components (r, g, b, a (optional)) (default is 255, 255, 255, 255)
--  opacity: The opacity value, in [0 ; 1] (default is 1)
--  numeric: If true, then displays the text as a formatted numeric value
--  visible: If false, the object will not appear on screen (default is true)
--  shadows: Text shadows to apply behind the text (optional), as an array of:
--   offset: The shadow offset, as a vec2
--   color: The shadow color, as color components (r, g, b, a (optional)) (default is 0, 0, 0, 255)
--  toBack: If true, creates the object on back of the group (behind other objects already in this group)
--  hitTestable: If true, forces the display object to be hitTestable (cf Corona documentation) (default is false)
function Class.create(options)
	local self = utils.extend(Class)

	-- Initialize attributes
	self.width = options.width or 0
	self.height = options.height or 0
	self.font = options.font or native.systemFont
	self.size = options.size or 8
	self.color = options.color or { 0, 0, 0, 255 }
	self.color[4] = self.color[4] or 255
	self.numeric = options.numeric
	self.shadows = {}

	-- Create group
	if options.shadows then
		self.group = display.newGroup()

		-- Insert group
		if options.group then
			options.group:insert(self.group)
		end
	end

	-- Create shadows
	if options.shadows then
		for _, shadow in pairs(options.shadows) do
			self.shadows[#self.shadows + 1] = Text.create{
				group = self.group,
				anchor = options.anchor,
				width = options.width,
				height = options.height,
				position = shadow.offset,
				rotation = options.rotation,
				font = shadow.font or options.font,
				size = options.size,
				color = shadow.color,
				align = options.align
			}
		end
	end

	-- Create Corona text
	self._displayObject = display.newText{
		text = options.text or "",
		width = self.width > 0 and self.width or nil,
		height = self.width > 0 and self.height or nil,
		font = self.font,
		fontSize = self.size,
		align = options.align
	}

	self:setColor(self.color)

	if options.text then
		self:setText(options.text)
	end

	-- Prevent Ecusson display object to add the text to the parent group
	Super.super(self, options)

	-- Insert text into group and position it
	if self.group then
		self._displayObject.x = 0
		self._displayObject.y = 0
	end

	return self
end

-- Destroy the text
function Class:destroy()
	for _, shadow in pairs(self.shadows) do
		shadow:destroy()
	end

	self._displayObject:removeSelf()

	if self.group then
		self.group:removeSelf()
	end

	Super.destroy(self)

	utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Format a number to add spaces between each group of 3 digits
--
-- Parameters:
--  number: The raw number (e.g. 42500)
--
-- Returns the formatted number (e.g. "42 500")
function Class:formatNumber(number)
	if number == "" then
		return ""
	else
		local left, num, right = string.match(number, '^([^%d]*%d)(%d*)(.-)$')
		return left..(num:reverse():gsub('(%d%d%d)', '%1 '):reverse())..right
	end
end

-- Move the display object to a given position
--
-- Parameters:
--  position: The position
function Class:setPosition(position)
	self.position = position

	local target = self:getDisplayGroup()
	target.x = position.x
	target.y = position.y
end

-- Set the text rotation
--
-- Parameters:
--  rotation: the rotation
function Class:setRotation(rotation)
	Super.setRotation(self, rotation)

	for _, shadow in pairs(self.shadows) do
		shadow:setRotation(rotation)
	end
end

-- Set the scale of the display object
--
-- Parameters:
--  scale: The new scale
function Class:setScale(scale)
	Super.setScale(self, scale)

	for _, shadow in pairs(self.shadows) do
		shadow:setScale(scale)
	end
end

-- Set the text content
--
-- Parameters:
--  text: The new text content
--  alreadyFormated: [Internal] If true, do not format the text again (for shadows)
function Class:setText(text, alreadyFormated)
	if not alreadyFormated and self.numeric then
		text = self:formatNumber(text)
	end

	self._displayObject.text = text

	for _, shadow in pairs(self.shadows) do
		shadow:setText(text, true)
	end
end

-- Set the text size
--
-- Parameters:
--  size: The new text size
function Class:setSize(size)
	self.size = size
	self._displayObject.size = size

	for _, shadow in pairs(self.shadows) do
		shadow:setSize(size)
	end
end

-----------------------------------------------------------------------------------------

return Class
