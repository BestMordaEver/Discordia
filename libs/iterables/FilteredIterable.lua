--[=[
@c FilteredIterable x Iterable
@mt mem
@d Iterable class that wraps another iterable and serves a subset of the objects
that the original iterable contains.
]=]

local Iterable = require('iterables/Iterable')

--[=[Iterable class that wraps another iterable and serves a subset of the objects
that the original iterable contains.]=]
---@class FilteredIterable : Iterable
---@overload fun(base : Iterable, predicate : function)
---@field private _base Iterable
---@field private _predicate function
---@field protected __init fun(self : self, base : Iterable, predicate : function)
local FilteredIterable = require('class')('FilteredIterable', Iterable)

function FilteredIterable:__init(base, predicate)
	self._base = base
	self._predicate = predicate
end

--[=[
@m iter
@r function
@d Returns an iterator that returns all contained objects. The order of the objects
is not guaranteed.
]=]
--[=[Returns an iterator that returns all contained objects. The order of the objects
is not guaranteed.]=]
function FilteredIterable:iter()
	return self._base:findAll(self._predicate)
end

return FilteredIterable
