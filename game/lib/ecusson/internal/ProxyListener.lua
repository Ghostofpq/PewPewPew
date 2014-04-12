-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- ProxyListener.lua
--
-- The proxy listener listen for display object events and redispatch them manually to
-- the real listeners, changing in the process the event target.
--
-- A method is given to install the addEventListener and removeEventListener methods and
-- forward them to the proxy so the only thing to do to use this proxy listener is to
-- use the installListeners method.
--
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")

-----------------------------------------------------------------------------------------

local Class = {}

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the proxy listener
--
-- Parameters:
--  listener: The event listener
--  target: The event target (the event.target attribute when the event is dispatched)
function Class.create(options)
	local self = utils.extend(Class)

	-- Initialize attributes
	self.listener = options.listener
	self.target = options.target

	return self
end

-- Destroy the proxy
function Class:destroy()
	utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Proxy methods
-----------------------------------------------------------------------------------------

-- Dispatch the event to the real listener
--
-- Parameters:
--  event: The event to dispatch
function Class:dispatch(event)
	event.target = self.target

	-- Call the function directly or find the associate method if it is a table
	return utils.resolveCallback(self.listener, event.name, event)
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Callback for the sprite event
--
-- Parameters:
--  event: The dispatched event
function Class:sprite(event)
	return self:dispatch(event)
end

-- Callback for the tap event
--
-- Parameters:
--  event: The dispatched event
function Class:tap(event)
	return self:dispatch(event)
end

-- Callback for the touch event
--
-- Parameters:
--  event: The dispatched event
function Class:touch(event)
	return self:dispatch(event)
end

-- Callback for the Ecusson sprite event
--
-- Parameters:
--  event: The dispatched event
function Class:ecussonSprite(event)
	return self:dispatch(event)
end

-----------------------------------------------------------------------------------------

return Class
