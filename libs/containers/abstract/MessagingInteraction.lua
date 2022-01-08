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

local MessagingInteraction, get = require('class')('MessagingInteraction', Interaction)

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
This method doesn't return sent message
]=]
function MessagingInteraction:reply(payload)
	return self:_callbackWithContent(callbackType.reply, payload)
end

function MessagingInteraction:deferReply()
	return self:_callback(callbackType.deferReply)
end

function MessagingInteraction:followup(content)
	local data, err = self.client._api:createFollowupMessage(self._application_id, self._token, MessageContainer.parseContent(content))
	if data then
		return self._parent._messages:_insert(data)
	else
		return nil, err
	end
end

function MessagingInteraction:getCallbackMessage()
	local data, err = self.client._api:getOriginalInteractionResponse(self._application_id, self._token)
	if data then
		return self._parent._messages:_insert(data)
	else
		return nil, err
	end
end

function MessagingInteraction:setCallbackContent(content)
	local data, err = self.client._api:editOriginalInteractionResponse(self._application_id, self._token, MessageContainer.parseContent(content))
	if data then
		return self._parent._messages:_insert(data)
	else
		return nil, err
	end
end

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

function MessagingInteraction:setFollowupContent(id, content)
	id = Resolver.messageId(id)
	if id then
		return self.client._api:editFollowupMessage(self._application_id, self._token, id, MessageContainer.parseContent(content))
	end
end

return MessagingInteraction