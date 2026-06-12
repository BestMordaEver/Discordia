--[=[
@c GuildCategoryChannel x GuildChannel
@d Represents a channel category in a Discord guild, used to organize individual
text or voice channels in that guild.
]=]

local GuildChannel = require('containers/abstract/GuildChannel')
local FilteredIterable = require('iterables/FilteredIterable')
local enums = require('enums')

local channelType = assert(enums.channelType)

--[=[Represents a channel category in a Discord guild, used to organize individual
text or voice channels in that guild.]=]
---@class GuildCategoryChannel : GuildChannel
---@field textChannels FilteredIterable
---@field forumChannels FilteredIterable
---@field mediaChannels FilteredIterable
---@field voiceChannels FilteredIterable
local GuildCategoryChannel, get = require('class')('GuildCategoryChannel', GuildChannel)

function GuildCategoryChannel:__init(data, parent)
	GuildChannel.__init(self, data, parent)
end

--[=[
@m createTextChannel
@t http
@p name string
@r GuildTextChannel
@d Creates a new GuildTextChannel with this category as it's parent. Similar to `Guild:createTextChannel(name)`
]=]
--[=[Creates a new GuildTextChannel with this category as it's parent. Similar to `Guild:createTextChannel(name)`]=]
---@param name string
---@return GuildTextChannel?
---@return string? error
function GuildCategoryChannel:createTextChannel(name)
	local guild = self._parent
	local data, err = guild.client._api:createGuildChannel(guild._id, {
		name = name,
		type = channelType.text,
		parent_id = self._id
	})
	if data then
		return guild._text_channels:_insert(data)
	else
		return nil, err
	end
end

--[=[
@m createVoiceChannel
@t http
@p name string
@r GuildVoiceChannel
@d Creates a new GuildVoiceChannel with this category as it's parent. Similar to `Guild:createVoiceChannel(name)`
]=]
--[=[Creates a new GuildVoiceChannel with this category as it's parent. Similar to `Guild:createVoiceChannel(name)`]=]
---@param name string
---@return GuildVoiceChannel?
---@return string? error
function GuildCategoryChannel:createVoiceChannel(name)
	local guild = self._parent
	local data, err = guild.client._api:createGuildChannel(guild._id, {
		name = name,
		type = channelType.voice,
		parent_id = self._id
	})
	if data then
		return guild._voice_channels:_insert(data)
	else
		return nil, err
	end
end

--[=[
@m createForumChannel
@t http
@p name string
@r ForumChannel
@d Creates a new ForumChannel with this category as its parent. Similar to `Guild:createForumChannel(name)`.
]=]
--[=[Creates a new ForumChannel with this category as its parent. Similar to `Guild:createForumChannel(name)`.]=]
---@param name string
---@return ForumChannel?
---@return string? error
function GuildCategoryChannel:createForumChannel(name)
	local guild = self._parent
	local data, err = guild.client._api:createGuildChannel(guild._id, {
		name = name,
		type = channelType.forum,
		parent_id = self._id
	})
	if data then
		return guild._forum_channels:_insert(data)
	else
		return nil, err
	end
end

--[=[
@m createMediaChannel
@t http
@p name string
@r MediaChannel
@d Creates a new MediaChannel with this category as its parent. Similar to `Guild:createMediaChannel(name)`.
]=]
--[=[Creates a new MediaChannel with this category as its parent. Similar to `Guild:createMediaChannel(name)`.]=]
---@param name string
---@return MediaChannel?
---@return string? error
function GuildCategoryChannel:createMediaChannel(name)
	local guild = self._parent
	local data, err = guild.client._api:createGuildChannel(guild._id, {
		name = name,
		type = channelType.media,
		parent_id = self._id
	})
	if data then
		return guild._media_channels:_insert(data)
	else
		return nil, err
	end
end

--[=[@p textChannels FilteredIterable Iterable of all textChannels in the Category.]=]
function get.textChannels(self)
	if not self._text_channels then
		local id = self._id
		self._text_channels = FilteredIterable(self._parent._text_channels, function(c)
			return c._parent_id == id
		end)
	end
	return self._text_channels
end

--[=[@p forumChannels FilteredIterable Iterable of all forum channels in the Category.]=]
function get.forumChannels(self)
	if not self._forum_channels then
		local id = self._id
		self._forum_channels = FilteredIterable(self._parent._forum_channels, function(c)
			return c._parent_id == id
		end)
	end
	return self._forum_channels
end

--[=[@p mediaChannels FilteredIterable Iterable of all media channels in the Category.]=]
function get.mediaChannels(self)
	if not self._media_channels then
		local id = self._id
		self._media_channels = FilteredIterable(self._parent._media_channels, function(c)
			return c._parent_id == id
		end)
	end
	return self._media_channels
end

--[=[@p voiceChannels FilteredIterable Iterable of all voiceChannels in the Category.]=]
function get.voiceChannels(self)
	if not self._voice_channels then
		local id = self._id
		self._voice_channels = FilteredIterable(self._parent._voice_channels, function(c)
			return c._parent_id == id
		end)
	end
	return self._voice_channels
end

return GuildCategoryChannel
