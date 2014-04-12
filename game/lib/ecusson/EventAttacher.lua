-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- EventAttacher.lua
--
-- Class to be extended to add listeners as if the object was a display object
--
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")
local ProxyListener = require("lib.ecusson.internal.ProxyListener")

-----------------------------------------------------------------------------------------

local Class = {}

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Install the addEventListener and removeEventListener methods.
-- These methods will create the proxies and forward event correctly.
-- This is the only method a class should use to get the proxy running.
--
-- Parameters:
--  target: The target display object to proxy (e.g. a Corona sprite, optional)
function Class:installListeners(target)
	self._proxyHasInternalTarget = (target ~= nil)
	self._proxyListeners = {}
	self._proxyTarget = target
	self._proxyListenersInstalled = true

	-- Create target if not exist
	if not target then
		self._proxyTarget = display.newGroup()
	end
end

-- Add an event listener, by creating a proxy listener
--
-- Parameters:
--  eventName: The event name
--  listener: The listener
function Class:addEventListener(eventName, listener)
	if not self._proxyListenersInstalled then
		self:installListeners()
	end

	local listeners = self._proxyListeners[eventName]

	if not listeners then
		listeners = {}
		self._proxyListeners[eventName] = listeners
	end

	-- Create proxy listener
	-- A proxy is created in order to set the event.target point to the custom Rectangle object (self) and not
	-- the Corona Rectangle object (self.rectangle)
	local proxy = ProxyListener.create{
		listener = listener,
		target = self
	}

	-- Save proxy and attach the real listener to the proxy
	-- The proxy will receive the rectangle events and will directly call the real listener
	listeners[listener] = proxy
	self._proxyTarget:addEventListener(eventName, proxy)
end

local json = require("json")

-- Remove the event listener
--
-- Parameters:
--  eventName: The event name
--  listener: The listener
function Class:removeEventListener(eventName, listener)
	if not self._proxyListenersInstalled then
		self:installListeners()
	end

	local proxy = self._proxyListeners[eventName][listener]
	self._proxyTarget:removeEventListener(eventName, proxy)

	proxy:destroy()
	self._proxyListeners[eventName][listener] = nil
end

-- Dispatch an event
--
-- Parameters:
--  event: The event to throw
function Class:dispatchEvent(event)
	if not self._proxyListenersInstalled then
		self:installListeners()
	end

	local instance

	if self._proxyListeners then
		-- Intance itself is the origin of the dispatch
		instance = self
	else
		-- Target is the origin of the dispatch
		instance = self._source
	end

	-- Find proxy listener
	local listeners = instance._proxyListeners[event.name]

	-- If proxy exists, dispatch event
	if listeners then
		-- Dispatch event until someone returns true
		for _, listener in pairs(listeners) do
			local returnValue = listener:dispatch(event)

			-- Stop sending events if listener returned true
			if returnValue then
				return true
			end
		end
	else
		-- Do nothing
		return false
	end
end

-----------------------------------------------------------------------------------------

return Class
