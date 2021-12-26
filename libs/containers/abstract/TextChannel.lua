--[=[
@c TextChannel x Channel
@t abc
@d Defines the base methods and properties for all Discord text channels.
]=]

local Channel = require('containers/abstract/Channel')
local Message = require('containers/Message')
local MessageContainer = require('utils/MessageContainer')
local CommandInteraction = require('containers/CommandInteraction')
local ComponentInteraction = require('containers/ComponentInteraction')
local AutocompleteInteraction = require('containers/AutocompleteInteraction')
local WeakCache = require('iterables/WeakCache')
local SecondaryCache = require('iterables/SecondaryCache')
local Resolver = require('client/Resolver')

local format = string.format

local TextChannel, get = require('class')('TextChannel', Channel)

function TextChannel:__init(data, parent)
	Channel.__init(self, data, parent)
	self._messages = WeakCache({}, Message, self)
	self._command_interactions = WeakCache({}, CommandInteraction, self)
	self._component_interactions = WeakCache({}, ComponentInteraction, self)
	self._autocomplete_interactions = WeakCache({}, AutocompleteInteraction, self)
end

--[=[
@m getMessage
@t http
@p id Message-ID-Resolvable
@r Message
@d Gets a message object by ID. If the object is already cached, then the cached
object will be returned; otherwise, an HTTP request is made.
]=]
function TextChannel:getMessage(id)
	id = Resolver.messageId(id)
	local message = self._messages:get(id)
	if message then
		return message
	else
		local data, err = self.client._api:getChannelMessage(self._id, id)
		if data then
			return self._messages:_insert(data)
		else
			return nil, err
		end
	end
end

--[=[
@m getFirstMessage
@t http
@r Message
@d Returns the first message found in the channel, if any exist. This is not a
cache shortcut; an HTTP request is made each time this method is called.
]=]
function TextChannel:getFirstMessage()
	local data, err = self.client._api:getChannelMessages(self._id, {after = self._id, limit = 1})
	if data then
		if data[1] then
			return self._messages:_insert(data[1])
		else
			return nil, 'Channel has no messages'
		end
	else
		return nil, err
	end
end

--[=[
@m getLastMessage
@t http
@r Message
@d Returns the last message found in the channel, if any exist. This is not a
cache shortcut; an HTTP request is made each time this method is called.
]=]
function TextChannel:getLastMessage()
	local data, err = self.client._api:getChannelMessages(self._id, {limit = 1})
	if data then
		if data[1] then
			return self._messages:_insert(data[1])
		else
			return nil, 'Channel has no messages'
		end
	else
		return nil, err
	end
end

local function getMessages(self, query)
	local data, err = self.client._api:getChannelMessages(self._id, query)
	if data then
		return SecondaryCache(data, self._messages)
	else
		return nil, err
	end
end

--[=[
@m getMessages
@t http
@op limit number
@r SecondaryCache
@d Returns a newly constructed cache of between 1 and 100 (default = 50) message
objects found in the channel. While the cache will never automatically gain or
lose objects, the objects that it contains may be updated by gateway events.
]=]
function TextChannel:getMessages(limit)
	return getMessages(self, limit and {limit = limit})
end

--[=[
@m getMessagesAfter
@t http
@p id Message-ID-Resolvable
@op limit number
@r SecondaryCache
@d Returns a newly constructed cache of between 1 and 100 (default = 50) message
objects found in the channel after a specific id. While the cache will never
automatically gain or lose objects, the objects that it contains may be updated
by gateway events.
]=]
function TextChannel:getMessagesAfter(id, limit)
	id = Resolver.messageId(id)
	return getMessages(self, {after = id, limit = limit})
end

--[=[
@m getMessagesBefore
@t http
@p id Message-ID-Resolvable
@op limit number
@r SecondaryCache
@d Returns a newly constructed cache of between 1 and 100 (default = 50) message
objects found in the channel before a specific id. While the cache will never
automatically gain or lose objects, the objects that it contains may be updated
by gateway events.
]=]
function TextChannel:getMessagesBefore(id, limit)
	id = Resolver.messageId(id)
	return getMessages(self, {before = id, limit = limit})
end

--[=[
@m getMessagesAround
@t http
@p id Message-ID-Resolvable
@op limit number
@r SecondaryCache
@d Returns a newly constructed cache of between 1 and 100 (default = 50) message
objects found in the channel around a specific point. While the cache will never
automatically gain or lose objects, the objects that it contains may be updated
by gateway events.
]=]
function TextChannel:getMessagesAround(id, limit)
	id = Resolver.messageId(id)
	return getMessages(self, {around = id, limit = limit})
end

--[=[
@m getPinnedMessages
@t http
@r SecondaryCache
@d Returns a newly constructed cache of up to 50 messages that are pinned in the
channel. While the cache will never automatically gain or lose objects, the
objects that it contains may be updated by gateway events.
]=]
function TextChannel:getPinnedMessages()
	local data, err = self.client._api:getPinnedMessages(self._id)
	if data then
		return SecondaryCache(data, self._messages)
	else
		return nil, err
	end
end

--[=[
@m broadcastTyping
@t http
@r boolean
@d Indicates in the channel that the client's user "is typing".
]=]
function TextChannel:broadcastTyping()
	local data, err = self.client._api:triggerTypingIndicator(self._id)
	if data then
		return true
	else
		return false, err
	end
end

--[=[
@m send
@t http
@p content string/table
@r Message
@d Sends a message to the channel. If `content` is a string, then this is simply
sent as the message content. If it is a table, more advanced formatting is
allowed. See [[managing messages]] for more information.
]=]
function TextChannel:send(content)

	local data, err

	content, err = MessageContainer.parseContent(content)
	if not content then
		return nil, err
	end

	data, err = self.client._api:createMessage(self._id, content, err)

	if data then
		return self._messages:_insert(data)
	else
		return nil, err
	end

end

--[=[
@m sendf
@t http
@p content string
@p ... *
@r Message
@d Sends a message to the channel with content formatted with `...` via `string.format`
]=]
function TextChannel:sendf(content, ...)
	local data, err = self.client._api:createMessage(self._id, {content = format(content, ...)})
	if data then
		return self._messages:_insert(data)
	else
		return nil, err
	end
end

--[=[@p messages WeakCache An iterable weak cache of all messages that are
visible to the client. Messages that are not referenced elsewhere are eventually
garbage collected. To access a message that may exist but is not cached,
use `TextChannel:getMessage`.]=]
function get.messages(self)
	return self._messages
end

return TextChannel
