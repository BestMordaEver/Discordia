--[=[
@c ForumChannel x GuildChannel
@d Represents a guild channel that can only contain threads.
]=]

local GuildChannel = require('containers/abstract/GuildChannel')
local FilteredIterable = require('iterables/FilteredIterable')
local Cache = require('iterables/Cache')
local Resolver = require('client/Resolver')
local channelType = require('enums').channelType
local Thread = require('containers/Thread')
local MessageContainer = require('utils/MessageContainer')

local ForumChannel, get = require('class')('ForumChannel', GuildChannel)

function ForumChannel:__init(data, parent)
	GuildChannel.__init(self, data, parent)
end

function ForumChannel:_load(data)
	GuildChannel._load(self, data)
end

--[=[
@m startThread
@t http
@p params table
@p content 
@r Thread
@d Creates a new thread using the raw table of parameters for initialization.
]=]
function ForumChannel:startThread(params, content)
	local data, files = MessageContainer.parseContent(content)
	if not data then
		return nil, files
	end

	data, files = self.client._api:startThreadInForumChannel(self._id, params, data)	-- TODO: files

	if data then
		return self._messages:_insert(data)
	else
		return nil, files
	end
end

--[=[
@m startThread
@t http
@p name string
@r Thread
@d Creates a new public thread
in length.
]=]
function ForumChannel:startPublicThread(name)
	return self:startThread({name = name, type = channelType.publicThread})
end

--[=[
@m startThread
@t http
@p name string/table
@r Thread
@d Creates a new private thread
in length.
]=]
function ForumChannel:startPrivateThread(name)
	return self:startThread({name = name, type = channelType.privateThread})
end

--[=[@p isNews boolean Whether this channel is a news channel of type 5.]=]
function get.isNews(self)
	return self._type == 5
end


return ForumChannel
