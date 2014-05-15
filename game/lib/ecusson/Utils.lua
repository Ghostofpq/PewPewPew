-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Utils.lua
--
-- Collection of utils functions.
--
-----------------------------------------------------------------------------------------

local Class = {}

-----------------------------------------------------------------------------------------
-- Local attributes
-----------------------------------------------------------------------------------------

local floor = math.floor
local ceil = math.ceil
local random = math.random
local min = math.min
local max = math.max
local abs = math.abs
local sin = math.sin
local PI = math.pi
local PI2 = PI * 0.5

local dtWarning = 0.1
local maxDt = 0.2

local currentId = 0

-- Function replacing the destroy method after an object has been destroyed.
-- If you see this message, it means you destroyed twice the same object.
local function fakeDestroy()
	print("[Warning] *X*X*X*X*X*X*X*X*X*X*X*")
	print("[Warning] *X*                 *X*")
	print("[Warning] *X*  Fake  Destroy  *X*")
	print("[Warning] *X*                 *X*")
	print("[Warning] *X*X*X*X*X*X*X*X*X*X*X*")
	utils.softError("")
end

-----------------------------------------------------------------------------------------
-- Determine DPI and screen ratio
-----------------------------------------------------------------------------------------

-- Determine the DPI for the current device
--
-- Sources:
--  http://en.wikipedia.org/wiki/List_of_iOS_devices
--  http://stackoverflow.com/questions/12505414/whats-the-device-code-platform-string-for-iphone-5-5c-5s-ipod-touch-5
local function determineDpi()
	local platformName = system.getInfo("platformName")

	-- Android device
	if platformName == "Android" then
		return system.getInfo("androidDisplayApproximateDpi")	-- Almost too easy

	-- Any iOS device
	elseif platformName == "iPhone OS" then
		local model = system.getInfo("architectureInfo")
		local modelType = string.sub(model, 1, 4)

		-- iPhones
		if modelType == "iPho" then
			local modelVersion = tonumber(string.sub(model, 7, 7))

			if modelVersion <= 2 then
				return 163	-- iPhone Classic (2G, 3G, 3GS): 163 dpi
			else
				return 326	-- iPhone Retina (4, 4S, 5, 5C, 5S): 326 dpi
			end

		-- iPads
		elseif modelType == "iPad" then
			local modelVersion = tonumber(string.sub(model, 5, 5))
			local modelSubVersion = tonumber(string.sub(model, 7, 7))

			if modelVersion == 1 or modelVersion == 2 and modelSubVersion <= 4 then
				return 132	-- iPad Classic (1, 2): 132 dpi
			elseif modelVersion == 2 then
				return 163	-- iPad Mini (1): 163 dpi
			elseif modelVersion == 3 or modelVersion == 4 and modelSubVersion <= 2 then
				return 264	-- iPad Retina (3, 4, Air): 264 dpi
			else
				return 326	-- Ipad Mini Retina (2): 326 dpi
			end

		-- iPods
		elseif modelType == "iPod" then
			local modelVersion = tonumber(string.sub(model, 5, 5))

			if modelVersion <= 3 then
				return 163	-- iPod (1, 2, 3): 163 dpi
			else
				return 326	-- iPod (4, 5): 326 dpi
			end
		end

	-- Corona simulator
	else
		return 264	-- iPad Retina resolution
	end
end

-- Determine the DPI in Corona coordinate system
local function determineCdpi()
	return Class.getDpi() * display.contentScaleX
end

-- Return the read DPI
function Class.getDpi()
	if not dpi then
		dpi = determineDpi()
	end

	return dpi
end

-- Return the DPI in Corona coordinate system
function Class.getCdpi()
	if not cdpi then
		cdpi = determineCdpi()
	end
	
	return cdpi
end

-- Return the approximate screen size in inches
function Class.getScreenSize()
	return math.sqrt(display.pixelWidth * display.pixelWidth + display.pixelHeight * display.pixelHeight)
		/ Class.getDpi()
end

-----------------------------------------------------------------------------------------
-- Extend math library
-----------------------------------------------------------------------------------------

-- Cap a value between min and max
--
-- Parameters:
--  value: The value to cap
--  minV: The min value
--  maxV: The max value
math.cap = function(value, minV, maxV)
	return max(minV, min(value, maxV))
end

-- Cut a number after idp floating point digits
--
-- Parameters:
--  value: The value to cut
--  idp: The number of digits after the floating point
math.cut = function(value, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", value))
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Extend a class for inheritance or for instanciation
--
-- Parameters:
--  ParentClass: The class to extend from
-- Returns:
--  The extended object
--
-- Inheritance example:
--  NewClass = utils.extend(ParentClass)
--
-- Instanciation example:
--  local self = utils.extend(Class)
function Class.extend(ParentClass, MetaTable)
	local Class = {}

	-- Create Metatable
	MetaTable = MetaTable or {}
	MetaTable.__index = ParentClass

	setmetatable(Class, MetaTable)

	return Class
end

-- Delete an object by resetting its metatable and setting nil to all its members
--
-- Parameters:
--  object: The object to delete
function Class.deleteObject(object)
	setmetatable(object, {})

	-- Reset all attributes
	for key, value in pairs(object) do
		object[key] = nil
	end
	
	-- Apply the fakeDestroy method to prevent the applciation to crash if destroy is called again
	object.destroy = fakeDestroy
end

-- Extract a value from a custom parametrable variable
--
-- Parameters:
--  value, a variable which is either:
--   * A number, in which case this value is returned
--   * An array with two values, in which case a random value in this interval is returned
-- Returns:
--  The value, either the numeric value given or a random value comprised in the interval given
function Class.extractValue(value)
	if type(value) == "number" then
		return value
	else
		return value[1] + random() * (value[2] - value[1])
	end
end

-- Add a 0 if needed before a number so it always uses 2 characters
--
-- Parameters:
--  value: The time value to pan
--
-- Return the panned time
function Class.panTime(value)
	return value < 10 and "0"..value or value
end

function Class.toReadableTime(time, showMilliseconds)
	local minutes = floor(time / 60)
	local seconds = utils.panTime(floor(time - 60 * minutes))

	local milliseconds = showMilliseconds and "."..utils.panTime(floor((time - 60 * minutes - seconds) * 100)) or ""
	return minutes..":"..seconds..milliseconds
end

-- Get an universal unique id
--
-- Returns:
--  An id not any other object which called getUuid can have
function Class.getUuid()
	currentId = currentId + 1
	return currentId
end

-- Prints the table in the debug console
--
-- Parameters:
--  var: The table
--  name: Its name
--  iteration: The current iteration (internal, do not set)
function Class.printTable(var, name, iteration)
	iteration = iteration or 0

	if iteration < 6 then
		if not name then
			name = "anonymous"
		end

		if type(var) ~= "table" then
			print(name .. " = " .. tostring(var))
		else
			-- for tables, recurse through children
			local hasChildren = false
			for k, v in pairs(var) do
				local child

				hasChildren = true

				if type(k) == "string" then
					if string.find(k, "%a[%w_]*") == 1 then
						-- key can be accessed using dot syntax
						child = name .. '.' .. k
					else
						-- key contains special characters
						child = name .. '["' .. k .. '"]'
					end
				else
					child = name .. ".<table>"
				end

				Class.printTable(v, child, iteration + 1)
			end

			if not hasChildren then
				print(name .. " = {}")
			end
		end
	end
end

-- Get the system time in seconds
function Class.getTime()
	return system.getTimer() * .001
end

-- Prevent an event from bubbling up
function Class.stopBubbling()
	return true
end

-- Prints an error in the console or crashes, depending on the configuration
function Class.softError(message)
	if system.getInfo("environment") == "simulator" then
		error(message)
	else
		print(message)
	end
end

-- Make a callback
--
-- Parameters:
--  target: The target object to call back
--  method: The method name to call
--  event: The event attributes (optional, default is {})
function Class.resolveCallback(target, method, event)
	if target then
		event = event or {}

		if type(target) == 'function' then
			return target(event)
		elseif type(target) == 'table' and type(target[method]) == 'function' then
			return target[method](target, event)
		end
	end
end

-- Interpolate a value linearly
--
-- Parameters:
--  from: The value to interpolate from
--  to: The value to interpolate to
--  delta: the progress value in [0, 1]
function Class.interpolateLinear(options)
	return options.from + (options.to - options.from) * options.delta
end

-- Interpolate a value triangularly
--
-- Parameters:
--  from: The value to interpolate from
--  mid: The value to pass to at delta = 0.5
--  to: The value to interpolate to
--  delta: the progress value in [0, 1]
function Class.interpolateTriangle(options)
	if options.delta < 0.5 then
		return Class.interpolateLinear{
			from = options.from,
			to = options.mid,
			delta = options.delta * 2
		}
	else
		return Class.interpolateLinear{
			from = options.mid,
			to = options.to,
			delta = (options.delta - 0.5) * 2
		}
	end
end

-- Interpolate a color linearly
--
-- Parameters:
--  from: The color to interpolate from
--  to: The color to interpolate to
--  delta: the progress value in [0, 1]
function Class.interpolateLinearColor(options)
	return {
		Class.interpolateLinear{
			from = options.from[1],
			to = options.to[1],
			delta = options.delta
		},
		Class.interpolateLinear{
			from = options.from[2],
			to = options.to[2],
			delta = options.delta
		},
		Class.interpolateLinear{
			from = options.from[3],
			to = options.to[3],
			delta = options.delta
		},
		Class.interpolateLinear{
			from = options.from[4] or 255,
			to = options.to[4] or 255,
			delta = options.delta
		}
	}
end

-- Interpolate a value following a sinus
--
-- Parameters:
--  from: The value to interpolate from
--  to: The value to interpolate to
--  delta: the progress value in [0, 1]
function Class.interpolateSin(options)
	return options.from + (options.to - options.from) * sin(options.delta * PI2)
end

function Class.interpolateQuad(options)
	return options.from + (options.to - options.from) * (1 + sin(options.delta * PI - PI2)) * 0.5
end

-- Encode a value to be used in an URL
--
-- Parameters:
--  url: The string to encode
function Class.encodeUrl(url)
	url = string.gsub(url, "\n", "\r\n")
	url = string.gsub(url, "([^%w ])", function (c)
		return string.format("%%%02X", string.byte(c))
	end)
	url = string.gsub(url, " ", "+")

	return url
end

-- Force the angle to be in [ 0 ; 360 ]
--
-- Parameters:
--  The angle to bind
function Class.bindAngle(angle)
	if angle < 0 then
		return angle + 360
	else
		return angle % 360
	end
end

-- Return the difference between 2 angles, in [0, 360]
--
-- Parameters:
--  a, b: The angles
function Class.getAngleDifference(a, b)
	local diff = abs(a - b)
	return min(diff, 360 - diff)
end

-- Return the angular direction
--
-- Parameters:
--  a: The first angle
--  b: The second angle
--
-- Returns:
--  -1 if the angular direction is counter-clockwise
--  1 if the angular direction is clockwise
function Class.getAngularDirection(a, b)
	if a > 90 and b < -90 then
		return -1
	elseif a < -90 and b > 90 or a > b then
		return 1
	else
		return -1
	end
end

-- Return the angular movement between 2 angles
--
-- Parameters:
--  a, b: The angles
--
-- Returns the difference between the angles, positive if clockwise, negative otherwise
function Class.getAngularMovement(a, b)
	return Class.getAngleDifference(a, b) * Class.getAngularDirection(a, b)
end

-- Return a copy of the input array, shuffled
--
-- Parameters:
--  array: The array to shuffle
--
-- Returns:
--  A copy of the array, shuffled
function Class.shuffleArray(array)
	local n = #array
	local order = {}
	local res = {}
	 
	for i = 1, n do
		order[i] = {
			index = i,
			value = random()
		}
	end

	table.sort(order, function(a, b)
		return a.value < b.value end
	)

	for i = 1, n do
		res[i] = array[order[i].index]
	end

	return res
end

-- Print in the console the memory usage
function Class.printMemory()
	print(" ")
	print("------ MEMORY USAGE ------")
	print(" FPS: "..display.fps)
	print(" System memory:  "..string.format("%.00f", collectgarbage("count")).. " KB")
	print(" Texture memory: "..string.format("%.02f", system.getInfo("textureMemoryUsed") / 1024 / 1024).." MB")
	print("--------------------------")
	print(" ")
end

-----------------------------------------------------------------------------------------
-- Enter frame layer
-----------------------------------------------------------------------------------------

-- Enter frame handler
--
-- Parameters:
--  event: The event object
local lastFrameTime = -1
function enterFrameListener(event)
	if lastFrameTime == -1 then
		lastFrameTime = event.time
	else
		local dt = (event.time - lastFrameTime) * .001
		lastFrameTime = event.time

		if dt > dtWarning then
			print("*** FPS Warning *** dt="..dt.." ("..ceil(1 / dt).."FPS)")
		end

		if dt < maxDt then
			Runtime:dispatchEvent{
				name = "ecussonEnterFrame",
				time = event.time * .001,
				dt = dt
			}
		end
	end
end

Runtime:addEventListener("enterFrame", enterFrameListener)

-----------------------------------------------------------------------------------------

return Class
