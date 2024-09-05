--[=[
@c Mutex
@t ui
@mt mem
@d Mutual exclusion class used to control Lua coroutine execution order.
]=]

local Deque = require('utils/Deque')
local timer = require('timer')

local yield = coroutine.yield
local resume = coroutine.resume
local running = coroutine.running
local setTimeout = timer.setTimeout

--[=[Mutual exclusion class used to control Lua coroutine execution order.]=]
---@class Mutex : Deque
---@overload fun() : Mutex
---@field protected _active boolean
---@field protected __init fun(self)
local Mutex = require('class')('Mutex', Deque)

function Mutex:__init()
	Deque.__init(self)
	self._active = false
end

--[=[
@m lock
@op prepend boolean
@r nil
@d If the mutex is not active (if a coroutine is not queued), this will activate
the mutex; otherwise, this will yield and queue the current coroutine.
]=]
--[=[If the mutex is not active (if a coroutine is not queued), this will activate
the mutex; otherwise, this will yield and queue the current coroutine.]=]
---comment
---@param prepend? boolean
---@return nil
function Mutex:lock(prepend)
	if self._active then
		if prepend then
			return yield(self:pushLeft(running()))
		else
			return yield(self:pushRight(running()))
		end
	else
		self._active = true
	end
end

--[=[
@m unlock
@r nil
@d If the mutex is active (if a coroutine is queued), this will dequeue and
resume the next available coroutine; otherwise, this will deactivate the mutex.
]=]
--[=[If the mutex is active (if a coroutine is queued), this will dequeue and
resume the next available coroutine; otherwise, this will deactivate the mutex.]=]
---@return nil
function Mutex:unlock()
	if self:getCount() > 0 then
		return assert(resume(self:popLeft()))
	else
		self._active = false
	end
end

local unlock = Mutex.unlock
--[=[
@m unlockAfter
@p delay number
@r uv_timer
@d Asynchronously unlocks the mutex after a specified time in milliseconds.
The relevant `uv_timer` object is returned.
]=]
--[=[Asynchronously unlocks the mutex after a specified time in milliseconds.
The relevant `uv_timer` object is returned.]=]
---@param delay number time in milliseconds
---@return userdata
function Mutex:unlockAfter(delay)
	return setTimeout(delay, unlock, self)
end

return Mutex
