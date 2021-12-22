--[=[
@c Interaction x Snowflake
@d Represents a message that your application receives when a user uses
an application command or a message component. Messages can contain
simple content strings, rich embeds, attachments, or reactions.
]=]

local json = require('json')
local enums = require('enums')
local constants = require('constants')
local Cache = require('iterables/Cache')
local ArrayIterable = require('iterables/ArrayIterable')
local Interaction = require('containers/abstract/Interaction')
local Reaction = require('containers/Reaction')
local Resolver = require('client/Resolver')
local insert = table.insert
local null = json.null
local format = string.format
local messageFlag, callbackType = enums.messageFlag, enums.callbackType
local band, bor, bnot = bit.band, bit.bor, bit.bnot

local MessagingInteraction, get = require('class')('MessagingInteraction', Interaction)

function MessagingInteraction:__init(data, parent)
    Interaction.__init(self, data, parent)
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
	return self._parent:_callback(self, callbackType.reply, payload)
end

function MessagingInteraction:defer()
	return self._parent:_callback(self, callbackType.defer)
end

function MessagingInteraction:followup(content)
	return self._parent:_followup(self, content)
end

function MessagingInteraction:getCallbackMessage()
	local data, err = self.client._api:getOriginalInteractionResponse(self._application_id, self._token)
	if data then
		return self._parent._messages:_insert(data)
	else
		return nil, err
	end
end

function MessagingInteraction:editCallbackMessage(content)
	local data, err = self.client._api:editCallbackMessage(self._application_id, self._token, content)
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

return MessagingInteraction