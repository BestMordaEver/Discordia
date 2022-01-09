--[=[
@c MessagingInteraction x Interaction
@t abc
@d Defines the base methods and properties for Discord interactions
that can be replied to with messages.
]=]

local enums = require('enums')
local Interaction = require('containers/abstract/Interaction')
local MessageContainer = require('utils/MessageContainer')
local Resolver = require('client/Resolver')
local callbackType = enums.callbackType

local MessagingInteraction = require('class')('MessagingInteraction', Interaction)

function MessagingInteraction:__init(data, parent)
    Interaction.__init(self, data, parent)
end

function MessagingInteraction:_callbackWithContent(callbackType, payload)
	local content, files = MessageContainer.parseContent(payload)
	if not content then
		return nil, files
	end

	return self:_callback(callbackType, content, files)
end

--[=[
@m reply
@t http
@p content string/table
@r boolean
@d Reply to interaction with a message. If `content` is a string,
then this is simply sent as the message content. If it is a table,
more advanced formatting is allowed. See [[managing messages]] for more information.
This method doesn't return sent message.
]=]
function MessagingInteraction:reply(payload)
	return self:_callbackWithContent(callbackType.reply, payload)
end

--[=[
@m deferReply
@t http
@op ephemeral boolean
@r boolean
@d Acknowledge the interaction and edit the response later. The user will
see the loading state. In order to resolve the loading state, use
MessagingInteraction:updateReply(content) method.
]=]
function MessagingInteraction:deferReply(ephemeral)
	return self:_callback(callbackType.deferReply, {flags = ephemeral and 64 or 0})
end

--[=[
@m followup
@t http
@p content string/table
@r Message
@d Send a followup message. If `content` is a string, then this is simply sent as the message content.
If it is a table, more advanced formatting is allowed. See [[managing messages]] for more information.
You must first reply or acknowledge the interaction before following up!
]=]
function MessagingInteraction:followup(content)
	assert(self._is_replied, "interaction must be replied to before following up")
	local data, err = self.client._api:createFollowupMessage(self._application_id, self._token, MessageContainer.parseContent(content))
	if data then
		return self._parent._messages:_insert(data)
	else
		return nil, err
	end
end

--[=[
@m getReply
@t http
@r Message
@d Get the message object that was sent as the initial reply.
]=]
function MessagingInteraction:getReply()
	local data, err = self.client._api:getOriginalInteractionResponse(self._application_id, self._token)
	if data then
		return self._parent._messages:_insert(data)
	else
		return nil, err
	end
end

--[=[
@m updateReply
@t http
@p content string/table
@r Message
@d Set content of the message object that was sent as the initial reply simmilarly to Message:update(data).
]=]
function MessagingInteraction:updateReply(content)
	p(MessageContainer.parseContent(content))
	local data, err = self.client._api:editOriginalInteractionResponse(self._application_id, self._token, MessageContainer.parseContent(content))
	if data then
		return self._parent._messages:_insert(data)
	else
		return nil, err
	end
end

--[=[
@m getFollowupMessage
@t http
@p id Message-ID-Resolvable
@r Message
@d Gets a folloup message object by ID. If the object is already cached, then the cached
object will be returned; otherwise, an HTTP request is made. Does not support ephemeral followups.
]=]
function MessagingInteraction:getFollowupMessage(id)
	id = Resolver.messageId(id)
	local message = self._parent._messages:get(id)
	if message then
		return message
	else
		local data, err = self.client._api:getFollowupMessage(self._application_id, self._token, id)
		if data then
			return self._parent._messages:_insert(data)
		else
			return nil, err
		end
	end
end

--[=[
@m updateFollowup
@t http
@p content string/table
@r Message
@d Set content of the followup message simmilarly to Message:update(data). Does not support ephemeral followups.
]=]
function MessagingInteraction:updateFollowup(id, content)
	id = Resolver.messageId(id)
	if id then
		return self.client._api:editFollowupMessage(self._application_id, self._token, id, MessageContainer.parseContent(content))
	end
end

return MessagingInteraction