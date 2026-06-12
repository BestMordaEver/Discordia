--[=[
@c GuildTextChannel x GuildChannel x TextChannel
@d Represents a text channel in a Discord guild, where guild members and webhooks
can send and receive messages.
]=]

local json = require('json')
local enums = require('enums')

local TextChannel = require('containers/abstract/TextChannel')
local ForumChannel = require('containers/ForumChannel')
local FilteredIterable = require('iterables/FilteredIterable')
local Webhook = require('containers/Webhook')
local Cache = require('iterables/Cache')
local Resolver = require('client/Resolver')

local channelType = assert(enums.channelType)

--[=[Represents a text channel in a Discord guild, where guild members and webhooks
can send and receive messages.]=]
---@class GuildTextChannel : TextChannel, ForumChannel
---@field topic? string
---@field nsfw boolean
---@field rateLimit number
---@field isNews boolean
---@field members FilteredIterable
local GuildTextChannel, get = require('class')('GuildTextChannel', TextChannel, ForumChannel)

function GuildTextChannel:__init(data, parent)
	TextChannel.__init(self, data, parent)
	ForumChannel.__init(self, data, parent)
end

function GuildTextChannel:_load(data)
	TextChannel._load(self, data)
	ForumChannel._load(self, data)
end

--[=[
@m startThread
@t http
@p params table
@r Thread
@d Creates a new thread in this channel using the provided parameter table.
]=]
--[=[Creates a new thread in this channel using the provided parameter table.]=]
---@param params table | string
---@return Thread?
---@return string? error
function GuildTextChannel:startThread(params)
	if type(params) == 'string' then
		params = {name = params}
	else
		params = params or {}
	end

	local data, err = self.client._api:startThread(self._id, params)
	if data then
		return self._parent._threads:_insert(data)
	else
		return nil, err
	end
end

--[=[
@m startThreadFromMessage
@t http
@p message Message-ID-Resolvable
@p params table
@r Thread
@d Creates a new thread from an existing message in this channel.
]=]
--[=[Creates a new thread from an existing message in this channel.]=]
---@param message Message-ID-Resolvable
---@param params table | string
---@return Thread?
---@return string? error
function GuildTextChannel:startThreadFromMessage(message, params)
	local message_id = Resolver.messageId(message)
	if not message_id then
		return nil, 'Invalid message: ' .. tostring(message)
	end

	if type(params) == 'string' then
		params = {name = params}
	else
		params = params or {}
	end

	local payload = {}
	for k, v in pairs(params) do
		if k ~= 'type' and k ~= 'invitable' then
			payload[k] = v
		end
	end

	local data, err = self.client._api:startThreadFromMessage(self._id, message_id, payload)
	if data then
		return self._parent._threads:_insert(data)
	else
		return nil, err
	end
end

--[=[
@m startPublicThread
@t http
@p name string
@op message Message-ID-Resolvable
@r Thread
@d Creates a new public thread in this channel. When `message` is provided, the thread is created from that message.
]=]
--[=[Creates a new public thread in this channel. When `message` is provided, the thread is created from that message.]=]
---@param name string
---@param message? Message-ID-Resolvable
---@return Thread?
---@return string? error
function GuildTextChannel:startPublicThread(name, message)
	if message ~= nil then
		return self:startThreadFromMessage(message, {name = name})
	else
		return self:startThread({name = name, type = channelType.publicThread})
	end
end

--[=[
@m startPrivateThread
@t http
@p name string
@r Thread
@d Creates a new private thread in this channel.
]=]
--[=[Creates a new private thread in this channel.]=]
---@param name string
---@return Thread?
---@return string? error
function GuildTextChannel:startPrivateThread(name)
	return self:startThread({name = name, type = channelType.privateThread})
end

--[=[
@m createWebhook
@t http
@p name string
@r Webhook
@d Creates a webhook for this channel. The name must be between 2 and 32 characters
in length.
]=]
--[=[Creates a webhook for this channel. The name must be between 2 and 32 characters
in length.]=]
---@param name string
---@return Webhook?
---@return string? error
function GuildTextChannel:createWebhook(name)
	local data, err = self.client._api:createWebhook(self._id, {name = name})
	if data then
		return Webhook(data, self.client)
	else
		return nil, err
	end
end

--[=[
@m getWebhooks
@t http
@r Cache
@d Returns a newly constructed cache of all webhook objects for the channel. The
cache and its objects are not automatically updated via gateway events. You must
call this method again to get the updated objects.
]=]
--[=[Returns a newly constructed cache of all webhook objects for the channel. The
cache and its objects are not automatically updated via gateway events. You must
call this method again to get the updated objects.]=]
---@return Cache?
---@return string? error
function GuildTextChannel:getWebhooks()
	local data, err = self.client._api:getChannelWebhooks(self._id)
	if data then
		return Cache(data, Webhook, self.client)
	else
		return nil, err
	end
end

--[=[
@m setTopic
@t http
@p topic string
@r boolean
@d Sets the channel's topic. This must be between 1 and 1024 characters. Pass `nil`
to remove the topic.
]=]
--[=[Sets the channel's topic. This must be between 1 and 1024 characters. Pass `nil`
to remove the topic.]=]
---@param topic? string
---@return boolean success
---@return string? error
function GuildTextChannel:setTopic(topic)
	return self:_modify({topic = topic or json.null})
end

--[=[
@m setRateLimit
@t http
@p limit number
@r boolean
@d Sets the channel's slowmode rate limit in seconds. This must be between 0 and 120.
Passing 0 or `nil` will clear the limit.
]=]
--[=[Sets the channel's slowmode rate limit in seconds. This must be between 0 and 120.
Passing 0 or `nil` will clear the limit.]=]
---@param limit? number
---@return boolean success
---@return string? error
function GuildTextChannel:setRateLimit(limit)
	return self:_modify({rate_limit_per_user = limit or json.null})
end

--[=[
@m follow
@t http
@p targetId Channel-ID-Resolvable
@r string
@d Follow this News channel and publish announcements to `targetId`.
Returns a 403 HTTP error if `GuildTextChannel.isNews` is false.
]=]
function GuildTextChannel:follow(targetId)
	targetId = Resolver.channelId(targetId)
	local data, err = self.client._api:followNewsChannel(self._id, {
		webhook_channel_id = targetId,
	})
	if data then
		return data.webhook_id
	else
		return nil, err
	end
end

--[=[
@m enableNSFW
@t http
@r boolean
@d Enables the NSFW setting for the channel. NSFW channels are hidden from users
until the user explicitly requests to view them.
]=]
--[=[Enables the NSFW setting for the channel. NSFW channels are hidden from users
until the user explicitly requests to view them.]=]
---@return boolean success
---@return string? error
function GuildTextChannel:enableNSFW()
	return self:_modify({nsfw = true})
end

--[=[
@m disableNSFW
@t http
@r boolean
@d Disables the NSFW setting for the channel. NSFW channels are hidden from users
until the user explicitly requests to view them.
]=]
--[=[Disables the NSFW setting for the channel. NSFW channels are hidden from users
until the user explicitly requests to view them.]=]
---@return boolean success
---@return string? error
function GuildTextChannel:disableNSFW()
	return self:_modify({nsfw = false})
end

--[=[@p topic string/nil The channel's topic. This should be between 1 and 1024 characters.]=]
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

--[=[@p isNews boolean Whether this channel is a news channel of type 5.]=]
function get.isNews(self)
	return self._type == 5
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

return GuildTextChannel
