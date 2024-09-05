--[=[
@c Thread x TextChannel
@d Represents a thread in a Discord guild, a kind of text
sub-channel inside an existing channel.
]=]

local TextChannel = require('containers/abstract/TextChannel')
local FilteredIterable = require('iterables/FilteredIterable')

--[=[Represents a thread in a Discord guild, a kind of text
sub-channel inside an existing channel.]=]
---@class Thread : TextChannel
local Thread, get = require('class')('Thread', TextChannel)

function Thread:__init(data, parent)
	TextChannel.__init(self, data, parent)
	self.client._channel_map[self._id] = parent
end

--[=[
@m delete
@t http
@r boolean
@d Permanently deletes the thread. This cannot be undone!
]=]
--[=[Permanently deletes the thread. This cannot be undone!]=]
function Thread:delete()
	return self:_delete()
end

--[=[
@m delete
@t http
@r boolean
@d Permanently deletes the thread. This cannot be undone!
]=]
--[=[Permanently deletes the thread. This cannot be undone!]=]
function Thread:join()
	return self:_delete()
end

--[=[@p flags number Channel flags combined as a bitfield.]=]
function get.flags(self)
	return self._flags
end

--[=[@p members FilteredIterable A filtered iterable of guild members that have
permission to read this channel. If you want to check whether a specific member
has permission to read this channel, it would be better to get the member object
elsewhere and use `Member:hasPermission` rather than check whether the member
exists here.]=]
function get.members(self)
	if not self._members then
		self._members = FilteredIterable(self._parent._members, function(m)
			return m:hasPermission(self, 'readMessages')
		end)
	end
	return self._members
end

return Thread
