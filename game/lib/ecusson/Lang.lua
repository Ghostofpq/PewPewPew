-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Lang.lua
--
-- A translation module
--
-----------------------------------------------------------------------------------------

local Class = {}

-----------------------------------------------------------------------------------------
-- Local definition
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")

local defaultLanguage = "en"

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the lang module
--
-- Parameters:
--  path: The path where the lang definition files are stored (e.g. "data.lang.")
--  id: The language file to load immediately (optional)
function Class.create(options)
    local self = utils.extend(Class)

    -- Initialize attributes
    self.path = options.path

	-- Load default language file, used when text in a specific language does not exist
	self.defaultLangTable = require(self.path..defaultLanguage)

	-- Auto-load language
	if options.id then
		self:load(options.id)
	end

	return self
end

-- Destroy the lang module
function Class:destroy()
    utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Load a lang table
--
-- Parameters:
--  langId: The lang to load
function Class:load(langId)
	self.langId = langId
	self.langTable = require(self.path..langId)
end

-- Translate a text into the current language
--
-- Parameters:
--  textId: The text identifier to translate
--  ...: Any parameters, to fill % variables in the text
function Class:translate(textId, ...)
	local text = (self.langTable and self.langTable[textId]) or self.defaultLangTable[textId]

	if text then
		return string.format(text, ...)
	else
		return "["..textId.."]"
	end
end

-- Return the current language id
function Class:getCurrentLanguage()
	return self.langId
end

-----------------------------------------------------------------------------------------

return Class
