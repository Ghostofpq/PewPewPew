-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- DeferredTaskHandler.lua
--
-- An event handler that piles events for a deferred resolution
--
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")

-----------------------------------------------------------------------------------------

local Class = {}

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the deferred event handler
--
-- Parameters:
--  target: The target object that will receive final events
function Class.create(options)
	local self = utils.extend(Class)

	-- Initialize attributes
	self.target = options.target
	self.listeners = {}
	self.deferreds = {}
	
	return self
end

-- Destroy the handler
function Class:destroy()
	utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Add an event listener that will add a task when triggered
--
-- Parameters:
--  source: The object to bind the event on
--  eventName: The event name to listen to
function Class:addEventListener(source, eventName)
	if self.listeners[eventName] then
		utils.softError("Event listener already attached to this deferred handler "..eventName)
	else
		local function handler(event)
			self:addTask(eventName, event)
		end

		source:addEventListener(eventName, handler)
		self.listeners[eventName] = handler
	end
end

-- Remove an event listener previously bound with addEventListener
--
-- Parameters:
--  source: The bound object
--  eventName: The event name
function Class:removeEventListener(source, eventName)
	source:removeEventListener(eventName, self.listeners[eventName])
	self.listeners[eventName] = nil
end

-- Add a task to the pile
--
-- Parameters:
--  taskName: The name of the task, which will be used to call a method with the same name on the target object
--  options: A userdata array directly passed to the deferred call
function Class:addTask(taskName, options)
	self.deferreds[#self.deferreds + 1] = {
		name = taskName,
		options = options
	}
end

-- Resolve all the tasks in the pile
function Class:resolveTasks()
	-- Immediately create a new deferred stack if some arrive while resolving the current ones
	local currentDeferreds = self.deferreds
	self.deferreds = {}

	-- Call deferred methods
	for _, deferred in pairs(currentDeferreds) do
		self.target[deferred.name](self.target, deferred.options)
	end

	-- Execute new tasks recursively if any
	if #self.deferreds > 0 then
		self:resolveTasks()
	end
end

-----------------------------------------------------------------------------------------

return Class
