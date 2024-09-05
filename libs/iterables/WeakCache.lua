--[=[
@c WeakCache x Cache
@mt mem
@d Extends the functionality of a regular cache by making use of weak references
to the objects that are cached. If all references to an object are weak, as they
are here, then the object will be deleted on the next garbage collection cycle.
]=]

local Cache = require('iterables/Cache')
local Iterable = require('iterables/Iterable')

--[=[Extends the functionality of a regular cache by making use of weak references
to the objects that are cached. If all references to an object are weak, as they
are here, then the object will be deleted on the next garbage collection cycle.]=]
---@class WeakCache : Cache
---@overload fun(array : any[], constructor : function, parent : Container | Client) : WeakCache
---@field protected __init fun(self, array : any[], constructor : function, parent : Container | Client)
---@field protected __len fun(self) : number
local WeakCache = require('class')('WeakCache', Cache)

local meta = {__mode = 'v'}

function WeakCache:__init(array, constructor, parent)
	Cache.__init(self, array, constructor, parent)
	setmetatable(self._objects, meta)
end

function WeakCache:__len() -- NOTE: _count is not accurate for weak caches
	return Iterable.__len(self)
end

return WeakCache
