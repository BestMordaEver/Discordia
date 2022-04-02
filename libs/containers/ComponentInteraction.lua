--[=[
@c ComponentInteraction x MessagingInteraction
@d Represents an interaction that your application receives when a user uses
a message component.
]=]

local enums = require('enums')
local MessagingInteraction = require('containers/abstract/MessagingInteraction')
local Resolver = require('client/Resolver')
local callbackType = enums.callbackType

local ComponentInteraction, get = require('class')('ComponentInteraction', MessagingInteraction)

function ComponentInteraction:__init(data, client)
    MessagingInteraction.__init(self, data, client)

    local id = Resolver.messageId(data.message.id)
	local message = self._parent._messages:get(id)
	if message then
		self._message = message
	else
		self._message = self.parent._messages:_insert(data.message)
	end

	self._custom_id = data.data.custom_id
	self._component_type = data.data.componentType
	self._values = data.data.values
end

--[=[
@m update
@t http
@p content string/table
@r boolean
@d Acknowledge the interaction and update the message that the component is attached to.
If `content` is a string, then it is simply set as the message content. If it is a table,
more advanced formatting is allowed. See [[managing messages]] for more information.
]=]
function ComponentInteraction:update(payload)
	return self:_callbackWithContent(callbackType.update, payload)
end

--[=[
@m deferUpdate
@t http
@r boolean
@d Acknowledge the interaction and update the message that the component
is attached to later. The user won't see a loading state.
]=]
function ComponentInteraction:deferUpdate()
	return self:_callback(callbackType.deferUpdate)
end

--[=[@p message Message The message on which this component exists.]=]
function get.message(self)
    return self._message
end

--[=[@p customId string Developer defined custom ID for this component.]=]
function get.customId(self)
    return self._custom_id
end

--[=[@p componentType number The component type. See the `componentType` enumeration for a human-readable representation.]=]
function get.componentType(self)
    return self._component_type
end

--[=[@p values table/nil Array of (select option)[https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-option-structure] values. This will exist only for select menu components.]=]
function get.values(self)
    return self._values
end

return ComponentInteraction