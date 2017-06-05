local timer = require('timer')

local wrap, yield = coroutine.wrap, coroutine.yield
local resume, running = coroutine.resume, coroutine.running
local insert, remove = table.insert, table.remove
local setTimeout, clearTimeout = timer.setTimeout, timer.clearTimeout

local mutexMeta = {
	__index = function(self, k)
		self[k] = {}
		return self[k]
	end
}

local Emitter = require('class')('Emitter')

function Emitter:__init()
	self._listeners = setmetatable({}, mutexMeta)
end

function Emitter:on(name, fn)
	insert(self._listeners[name], {fn = fn})
	return fn
end

function Emitter:once(name, fn)
	insert(self._listeners[name], {fn = fn, once = true})
	return fn
end

function Emitter:onWrap(name, fn)
	insert(self._listeners[name], {fn = fn, wrap = true})
	return fn
end

function Emitter:onceWrap(name, fn)
	insert(self._listeners[name], {fn = fn, once = true, wrap = true})
	return fn
end

function Emitter:emit(name, ...)
	local listeners = self._listeners[name]
	for i = 1, #listeners do
		local listener = listeners[i]
		if listener then
			local fn = listener.fn
			if listener.once then
				self:removeListener(name, fn)
			end
			if listener.wrap then
				wrap(fn)(...)
			else
				fn(...)
			end
		end
	end
	for i = #listeners, 1, -1 do
		if not listeners[i] then
			remove(listeners, i)
		end
	end
end

function Emitter:getListeners(name)
	local listeners = self._listeners[name]
	return wrap(function()
		for _, listener in ipairs(listeners) do
			if listener then
				yield(listener.fn)
			end
		end
	end)
end

function Emitter:getListenerCount(name)
	local listeners = self._listeners[name]
	local n = 0
	for _, listener in ipairs(listeners) do
		if listener then
			n = n + 1
		end
	end
	return n
end

function Emitter:removeListener(name, fn)
	local listeners = self._listeners[name]
	for i, listener in ipairs(listeners) do
		if listener and listener.fn == fn then
			listeners[i] = false
		end
	end
end

function Emitter:removeAllListeners(name)
	self._listeners[name] = nil
end

function Emitter:waitFor(name, timeout)
	local thread = running()
	local fn = self:once(name, function(...)
		if timeout then
			clearTimeout(timeout)
		end
		return assert(resume(thread, true, ...))
	end)
	timeout = timeout and setTimeout(timeout, function()
		self:removeListener(name, fn)
		return assert(resume(thread, false))
	end)
	return yield()
end

return Emitter