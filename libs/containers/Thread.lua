--[=[
@c Thread x TextChannel
@d Represents a thread in a Discord guild, a kind of text
sub-channel inside an existing channel.
]=]

local TextChannel = require('containers/abstract/TextChannel')
local FilteredIterable = require('iterables/FilteredIterable')
local Resolver = require('client/Resolver')
local json = require('json')

local bor, band, bnot = bit.bor, bit.band, bit.bnot
local null = json.null

--[=[Represents a thread in a Discord guild, a kind of text
sub-channel inside an existing channel.]=]
---@class Thread : TextChannel
---@field flags number
---@field guild Guild
---@field parentChannel Channel?
---@field ownerId? string
---@field messageCount number
---@field memberCount number
---@field totalMessageSent number
---@field appliedTags table
---@field archived boolean
---@field autoArchiveDuration? number
---@field archiveTimestamp? string
---@field locked boolean
---@field invitable? boolean
---@field createTimestamp? string
---@field joined boolean
---@field joinTimestamp? string
---@field memberFlags? number
---@field members FilteredIterable
local Thread, get = require('class')('Thread', TextChannel)

function Thread:__init(data, parent)
	TextChannel.__init(self, data, parent)
	self.client._channel_map[self._id] = parent
	Thread._load(self, data)
end

function Thread:_load(data)
	TextChannel._load(self, data)

	local metadata = data.thread_metadata
	if metadata == null then
		self._archived = nil
		self._auto_archive_duration = nil
		self._archive_timestamp = nil
		self._locked = nil
		self._invitable = nil
		self._create_timestamp = nil
	elseif metadata then
		self._archived = metadata.archived
		self._auto_archive_duration = metadata.auto_archive_duration
		self._archive_timestamp = metadata.archive_timestamp
		self._locked = metadata.locked
		self._invitable = metadata.invitable
		self._create_timestamp = metadata.create_timestamp
	end

	if data.applied_tags == null then
		self._applied_tags = nil
	elseif data.applied_tags then
		self._applied_tags = data.applied_tags
	end

	local member = data.member
	if member == null then
		self._join_timestamp = nil
		self._member_flags = nil
	elseif member then
		self._join_timestamp = member.join_timestamp
		self._member_flags = member.flags
		local user_id = member.user_id or (self.client.user and self.client.user.id)
		if user_id then
			self._member_ids = self._member_ids or {}
			self._member_ids[user_id] = true
		end
	end
end

--[=[
@m delete
@t http
@r boolean
@d Permanently deletes the thread. This cannot be undone!
]=]
--[=[Permanently deletes the thread. This cannot be undone!]=]
---@return boolean success
---@return string? error
function Thread:delete()
	return self:_delete()
end

--[=[
@m join
@t http
@r boolean
@d Adds the current user to the thread.
]=]
--[=[Adds the current user to the thread.]=]
---@return boolean success
---@return string? error
function Thread:join()
	return self.client._api:joinThread(self._id)
end

--[=[
@m leave
@t http
@r boolean
@d Removes the current user from the thread.
]=]
--[=[Removes the current user from the thread.]=]
---@return boolean success
---@return string? error
function Thread:leave()
	return self.client._api:leaveThread(self._id)
end

--[=[
@m addMember
@t http
@p id User-ID-Resolvable
@r boolean
@d Adds another member to the thread.
]=]
--[=[Adds another member to the thread.]=]
---@param id User-ID-Resolvable
---@return boolean success
---@return string? error
function Thread:addMember(id)
	id = Resolver.userId(id)
	if not id then
		return false, 'Invalid user ID'
	end
	return self.client._api:addThreadMember(self._id, id)
end

--[=[
@m removeMember
@t http
@p id User-ID-Resolvable
@r boolean
@d Removes another member from the thread.
]=]
--[=[Removes another member from the thread.]=]
---@param id User-ID-Resolvable
---@return boolean success
---@return string? error
function Thread:removeMember(id)
	id = Resolver.userId(id)
	if not id then
		return false, 'Invalid user ID'
	end
	return self.client._api:removeThreadMember(self._id, id)
end

--[=[
@m setName
@t http
@p name string
@r boolean
@d Sets the thread's name.
]=]
--[=[Sets the thread's name.]=]
---@param name string
---@return boolean success
---@return string? error
function Thread:setName(name)
	return self:_modify({name = name or json.null})
end

--[=[
@m setRateLimit
@t http
@p limit number
@r boolean
@d Sets the thread's slowmode rate limit in seconds.
]=]
--[=[Sets the thread's slowmode rate limit in seconds.]=]
---@param limit? number
---@return boolean success
---@return string? error
function Thread:setRateLimit(limit)
	return self:_modify({rate_limit_per_user = limit or json.null})
end

--[=[
@m setAutoArchiveDuration
@t http
@p duration number
@r boolean
@d Sets the thread's auto-archive duration in minutes.
]=]
--[=[Sets the thread's auto-archive duration in minutes.]=]
---@param duration number
---@return boolean success
---@return string? error
function Thread:setAutoArchiveDuration(duration)
	return self:_modify({auto_archive_duration = duration})
end

--[=[
@m setArchived
@t http
@p archived boolean
@r boolean
@d Sets whether the thread is archived.
]=]
--[=[Sets whether the thread is archived.]=]
---@param archived boolean
---@return boolean success
---@return string? error
function Thread:setArchived(archived)
	return self:_modify({archived = not not archived})
end

--[=[
@m archive
@t http
@r boolean
@d Archives the thread.
]=]
--[=[Archives the thread.]=]
---@return boolean success
---@return string? error
function Thread:archive()
	return self:setArchived(true)
end

--[=[
@m unarchive
@t http
@r boolean
@d Unarchives the thread.
]=]
--[=[Unarchives the thread.]=]
---@return boolean success
---@return string? error
function Thread:unarchive()
	return self:setArchived(false)
end

--[=[
@m setLocked
@t http
@p locked boolean
@r boolean
@d Sets whether the thread is locked.
]=]
--[=[Sets whether the thread is locked.]=]
---@param locked boolean
---@return boolean success
---@return string? error
function Thread:setLocked(locked)
	return self:_modify({locked = not not locked})
end

--[=[
@m lock
@t http
@r boolean
@d Locks the thread.
]=]
--[=[Locks the thread.]=]
---@return boolean success
---@return string? error
function Thread:lock()
	return self:setLocked(true)
end

--[=[
@m unlock
@t http
@r boolean
@d Unlocks the thread.
]=]
--[=[Unlocks the thread.]=]
---@return boolean success
---@return string? error
function Thread:unlock()
	return self:setLocked(false)
end

--[=[
@m setInvitable
@t http
@p invitable boolean
@r boolean
@d Sets whether non-moderators can add other non-moderators to this private thread.
]=]
--[=[Sets whether non-moderators can add other non-moderators to this private thread.]=]
---@param invitable boolean
---@return boolean success
---@return string? error
function Thread:setInvitable(invitable)
	return self:_modify({invitable = not not invitable})
end

--[=[
@m pin
@t http
@r boolean
@d Pins the thread when supported by its parent channel.
]=]
--[=[Pins the thread when supported by its parent channel.]=]
---@return boolean success
---@return string? error
function Thread:pin()
	return self:_modify({flags = bor(self._flags or 0, 0x2)})
end

--[=[
@m unpin
@t http
@r boolean
@d Unpins the thread when supported by its parent channel.
]=]
--[=[Unpins the thread when supported by its parent channel.]=]
---@return boolean success
---@return string? error
function Thread:unpin()
	return self:_modify({flags = band(self._flags or 0, bnot(0x2))})
end

--[=[
@m setAppliedTags
@t http
@p tags table
@r boolean
@d Sets the applied tag IDs for this thread.
]=]
--[=[Sets the applied tag IDs for this thread.]=]
---@param tags? table
---@return boolean success
---@return string? error
function Thread:setAppliedTags(tags)
	return self:_modify({applied_tags = tags or json.null})
end

--[=[@p flags number Channel flags combined as a bitfield.]=]
function get.flags(self)
	return self._flags or 0
end

--[=[@p guild Guild The guild in which this thread exists.]=]
function get.guild(self)
	return self._parent
end

--[=[@p parentChannel Channel/nil The parent channel from which this thread was created.]=]
function get.parentChannel(self)
	return self._parent:getChannel(self._parent_id)
end

--[=[@p ownerId string/nil The ID of the user that owns this thread.]=]
function get.ownerId(self)
	return self._owner_id
end

--[=[@p messageCount number Approximate number of messages in this thread.]=]
function get.messageCount(self)
	return self._message_count or 0
end

--[=[@p memberCount number Approximate number of members in this thread.]=]
function get.memberCount(self)
	return self._member_count or 0
end

--[=[@p totalMessageSent number Number of messages ever sent in this thread.]=]
function get.totalMessageSent(self)
	return self._total_message_sent or 0
end

--[=[@p appliedTags table The applied tag IDs for this thread.]=]
function get.appliedTags(self)
	return self._applied_tags or {}
end

--[=[@p archived boolean Whether this thread is archived.]=]
function get.archived(self)
	return self._archived or false
end

--[=[@p autoArchiveDuration number/nil The thread's auto-archive duration in minutes.]=]
function get.autoArchiveDuration(self)
	return self._auto_archive_duration
end

--[=[@p archiveTimestamp string/nil The timestamp at which this thread's archive status last changed.]=]
function get.archiveTimestamp(self)
	return self._archive_timestamp
end

--[=[@p locked boolean Whether this thread is locked.]=]
function get.locked(self)
	return self._locked or false
end

--[=[@p invitable boolean/nil Whether non-moderators can add other non-moderators to this thread.]=]
function get.invitable(self)
	return self._invitable
end

--[=[@p createTimestamp string/nil The timestamp at which this thread was created, if available.]=]
function get.createTimestamp(self)
	return self._create_timestamp
end

--[=[@p joined boolean Whether the current user is joined to this thread.]=]
function get.joined(self)
	return self._join_timestamp ~= nil
end

--[=[@p joinTimestamp string/nil The timestamp at which the current user joined this thread, if available.]=]
function get.joinTimestamp(self)
	return self._join_timestamp
end

--[=[@p memberFlags number/nil The current user's thread-member flags for this thread, if available.]=]
function get.memberFlags(self)
	return self._member_flags
end

--[=[@p members FilteredIterable A filtered iterable of cached guild members that have joined this thread. The cache only contains members that Discord has exposed to the client.]=]
function get.members(self)
	if not self._members then
		self._members = FilteredIterable(self._parent._members, function(m)
			return self._member_ids and self._member_ids[m._user._id] or false
		end)
	end
	return self._members
end

return Thread
