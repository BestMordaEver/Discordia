--[=[
@c ForumChannel x GuildChannel
@d Represents a guild channel that can only contain threads.
]=]

local GuildChannel = require('containers/abstract/GuildChannel')
local FilteredIterable = require('iterables/FilteredIterable')
local SecondaryCache = require('iterables/SecondaryCache')
local MessageContainer = require('utils/MessageContainer')
local json = require('json')

local bor, band, bnot = bit.bor, bit.band, bit.bnot
local null = json.null

--[=[Represents a guild channel that can only contain threads.]=]
---@class ForumChannel : GuildChannel
---@field topic? string
---@field nsfw boolean
---@field rateLimit number
---@field flags number
---@field defaultAutoArchiveDuration? number
---@field availableTags table
---@field defaultReactionEmoji? table
---@field defaultThreadRateLimit number
---@field defaultSortOrder? number
---@field defaultForumLayout number
---@field threads FilteredIterable
local ForumChannel, get = require('class')('ForumChannel', GuildChannel)

local function mergeThreadMembers(cache, members)
	for _, member in ipairs(members or {}) do
		local thread = cache:get(member.id)
		if thread then
			thread:_load({member = member})
		end
	end
	return cache
end

local function newThreadCache(self, data)
	local cache = SecondaryCache(data.threads or {}, self._parent._threads)
	return mergeThreadMembers(cache, data.members)
end

function ForumChannel:__init(data, parent)
	GuildChannel.__init(self, data, parent)
	ForumChannel._load(self, data)
end

function ForumChannel:_load(data)
	GuildChannel._load(self, data)
	if data.available_tags == null then
		self._available_tags = nil
	elseif data.available_tags then
		self._available_tags = data.available_tags
	end
	if data.default_reaction_emoji == null then
		self._default_reaction_emoji = nil
	elseif data.default_reaction_emoji then
		self._default_reaction_emoji = data.default_reaction_emoji
	end
end

--[=[
@m setTopic
@t http
@p topic string
@r boolean
@d Sets the channel's topic. This must be between 0 and 4096 characters. Pass `nil`
to remove the topic.
]=]
--[=[Sets the channel's topic. Pass `nil` to remove the topic.]=]
---@param topic? string
---@return boolean success
---@return string? error
function ForumChannel:setTopic(topic)
	return self:_modify({topic = topic or json.null})
end

--[=[
@m setRateLimit
@t http
@p limit number
@r boolean
@d Sets the channel's slowmode rate limit in seconds. This must be between 0 and 21600.
Passing 0 or `nil` will clear the limit.
]=]
--[=[Sets the channel's slowmode rate limit in seconds. Passing 0 or `nil` will clear the limit.]=]
---@param limit? number
---@return boolean success
---@return string? error
function ForumChannel:setRateLimit(limit)
	return self:_modify({rate_limit_per_user = limit or json.null})
end

--[=[
@m setDefaultAutoArchiveDuration
@t http
@p duration number
@r boolean
@d Sets the default auto-archive duration for newly created threads in this channel.
]=]
--[=[Sets the default auto-archive duration for newly created threads in this channel.]=]
---@param duration number
---@return boolean success
---@return string? error
function ForumChannel:setDefaultAutoArchiveDuration(duration)
	return self:_modify({default_auto_archive_duration = duration})
end

--[=[
@m setDefaultThreadRateLimit
@t http
@p limit number
@r boolean
@d Sets the default slowmode rate limit for newly created threads in this channel.
]=]
--[=[Sets the default slowmode rate limit for newly created threads in this channel.]=]
---@param limit? number
---@return boolean success
---@return string? error
function ForumChannel:setDefaultThreadRateLimit(limit)
	return self:_modify({default_thread_rate_limit_per_user = limit or json.null})
end

--[=[
@m setDefaultSortOrder
@t http
@p order forumSortOrder
@r boolean
@d Sets the default sort order used to display posts in this channel.
]=]
--[=[Sets the default sort order used to display posts in this channel.]=]
---@param order? number
---@return boolean success
---@return string? error
function ForumChannel:setDefaultSortOrder(order)
	return self:_modify({default_sort_order = order or json.null})
end

--[=[
@m setDefaultForumLayout
@t http
@p layout forumLayout
@r boolean
@d Sets the default forum layout used to display posts in this channel.
]=]
--[=[Sets the default forum layout used to display posts in this channel.]=]
---@param layout? number
---@return boolean success
---@return string? error
function ForumChannel:setDefaultForumLayout(layout)
	return self:_modify({default_forum_layout = layout or json.null})
end

--[=[
@m setAvailableTags
@t http
@p tags table
@r boolean
@d Sets the available tags for this channel.
]=]
--[=[Sets the available tags for this channel.]=]
---@param tags? table
---@return boolean success
---@return string? error
function ForumChannel:setAvailableTags(tags)
	return self:_modify({available_tags = tags or json.null})
end

--[=[
@m setDefaultReactionEmoji
@t http
@p emoji table
@r boolean
@d Sets the default reaction emoji for posts in this channel.
]=]
--[=[Sets the default reaction emoji for posts in this channel.]=]
---@param emoji? table
---@return boolean success
---@return string? error
function ForumChannel:setDefaultReactionEmoji(emoji)
	return self:_modify({default_reaction_emoji = emoji or json.null})
end

--[=[
@m setRequireTag
@t http
@p required boolean
@r boolean
@d Sets whether new posts in this channel must include a tag.
]=]
--[=[Sets whether new posts in this channel must include a tag.]=]
---@param required boolean
---@return boolean success
---@return string? error
function ForumChannel:setRequireTag(required)
	local flags = self._flags or 0
	if required then
		flags = bor(flags, 0x10)
	else
		flags = band(flags, bnot(0x10))
	end
	return self:_modify({flags = flags})
end

--[=[
@m enableNSFW
@t http
@r boolean
@d Enables the NSFW setting for the channel.
]=]
--[=[Enables the NSFW setting for the channel.]=]
---@return boolean success
---@return string? error
function ForumChannel:enableNSFW()
	return self:_modify({nsfw = true})
end

--[=[
@m disableNSFW
@t http
@r boolean
@d Disables the NSFW setting for the channel.
]=]
--[=[Disables the NSFW setting for the channel.]=]
---@return boolean success
---@return string? error
function ForumChannel:disableNSFW()
	return self:_modify({nsfw = false})
end

--[=[
@m startThread
@t http
@p params table
@p content 
@r Thread
@d Creates a new thread using the raw table of parameters for initialization.
]=]
--[=[Creates a new thread using the raw table of parameters for initialization.]=]
---@param params table
---@param content? string | table
---@return Thread?
---@return string? error
function ForumChannel:startThread(params, content)
	if type(params) == 'string' then
		params = {name = params}
	else
		params = params or {}
	end

	if content ~= nil then
		local message, files = MessageContainer.parseContent(content)
		if not message then
			return nil, files --[[ @as string]]
		end
		params.message = message
		local data, err = self.client._api:startThreadInForumChannel(self._id, params, files)
		if data then
			local thread = self._parent._threads:_insert(data)
			if data.message then
				thread._messages:_insert(data.message)
			end
			return thread
		else
			return nil, err
		end
	elseif params.message then
		local data, err = self.client._api:startThreadInForumChannel(self._id, params)
		if data then
			local thread = self._parent._threads:_insert(data)
			if data.message then
				thread._messages:_insert(data.message)
			end
			return thread
		else
			return nil, err
		end
	else
		return nil, 'Forum and media threads require a starter message'
	end
end

--[=[
@m startPublicThread
@t http
@p name string
@p content
@r Thread
@d Creates a new public thread in this channel with an initial message.
]=]
--[=[Creates a new public thread in this channel with an initial message.]=]
---@param name string
---@param content? string | table
---@return Thread?
---@return string? error
function ForumChannel:startPublicThread(name, content)
	return self:startThread({name = name}, content)
end

--[=[
@m getActiveThreads
@t http
@r SecondaryCache
@d Returns a newly constructed secondary cache of active threads in this channel.
]=]
--[=[Returns a newly constructed secondary cache of active threads in this channel.]=]
---@return SecondaryCache?
---@return string? error
function ForumChannel:getActiveThreads()
	local data, err = self.client._api:listActiveThreads(self._id)
	if data then
		return newThreadCache(self, data)
	else
		return nil, err
	end
end

--[=[
@m getPublicArchivedThreads
@t http
@op query table
@r SecondaryCache
@d Returns a newly constructed secondary cache of public archived threads in this channel.
]=]
--[=[Returns a newly constructed secondary cache of public archived threads in this channel.]=]
---@param query? table
---@return SecondaryCache?
---@return string? error
function ForumChannel:getPublicArchivedThreads(query)
	local data, err = self.client._api:listPublicArchivedThreads(self._id, query)
	if data then
		return newThreadCache(self, data)
	else
		return nil, err
	end
end

--[=[
@m getPrivateArchivedThreads
@t http
@op query table
@r SecondaryCache
@d Returns a newly constructed secondary cache of private archived threads in this channel.
]=]
--[=[Returns a newly constructed secondary cache of private archived threads in this channel.]=]
---@param query? table
---@return SecondaryCache?
---@return string? error
function ForumChannel:getPrivateArchivedThreads(query)
	local data, err = self.client._api:listPrivateArchivedThreads(self._id, query)
	if data then
		return newThreadCache(self, data)
	else
		return nil, err
	end
end

--[=[
@m getJoinedPrivateArchivedThreads
@t http
@op query table
@r SecondaryCache
@d Returns a newly constructed secondary cache of joined private archived threads in this channel.
]=]
--[=[Returns a newly constructed secondary cache of joined private archived threads in this channel.]=]
---@param query? table
---@return SecondaryCache?
---@return string? error
function ForumChannel:getJoinedPrivateArchivedThreads(query)
	local data, err = self.client._api:listJoinedPrivateArchivedThreads(self._id, query)
	if data then
		return newThreadCache(self, data)
	else
		return nil, err
	end
end

--[=[
@m startPrivateThread
@t http
@p name string
@r nil
@d Returns an error because forum and media channels can only create public threads.
]=]
--[=[Returns an error because forum and media channels can only create public threads.]=]
---@param name string
---@return nil
---@return string? error
function ForumChannel:startPrivateThread(name)
	return nil, 'Forum and media channels only support public threads'
end

--[=[@p topic string/nil The channel's topic. This should be between 0 and 4096 characters.]=]
function get.topic(self)
	return self._topic
end

--[=[@p nsfw boolean Whether this channel is marked as NSFW (not safe for work).]=]
function get.nsfw(self)
	return self._nsfw or false
end

--[=[@p rateLimit number Slowmode rate limit per guild member.]=]
function get.rateLimit(self)
	return self._rate_limit_per_user or 0
end

--[=[@p flags number Channel flags combined as a bitfield.]=]
function get.flags(self)
	return self._flags or 0
end

--[=[@p defaultAutoArchiveDuration number/nil Default auto-archive duration for newly created threads in this channel.]=]
function get.defaultAutoArchiveDuration(self)
	return self._default_auto_archive_duration
end

--[=[@p availableTags table The available tags that can be applied to threads in this channel.]=]
function get.availableTags(self)
	return self._available_tags or {}
end

--[=[@p defaultReactionEmoji table/nil The default reaction emoji shown for threads in this channel.]=]
function get.defaultReactionEmoji(self)
	return self._default_reaction_emoji
end

--[=[@p defaultThreadRateLimit number Default slowmode rate limit for newly created threads in this channel.]=]
function get.defaultThreadRateLimit(self)
	return self._default_thread_rate_limit_per_user or 0
end

--[=[@p defaultSortOrder number/nil The default sort order for threads in this channel.]=]
function get.defaultSortOrder(self)
	return self._default_sort_order
end

--[=[@p defaultForumLayout number The default forum layout for this channel.]=]
function get.defaultForumLayout(self)
	return self._default_forum_layout or 0
end

--[=[@p threads FilteredIterable An iterable of cached threads that belong to this channel.]=]
function get.threads(self)
	if not self._threads then
		local id = self._id
		self._threads = FilteredIterable(self._parent._threads, function(thread)
			return thread._parent_id == id
		end)
	end
	return self._threads
end


return ForumChannel
