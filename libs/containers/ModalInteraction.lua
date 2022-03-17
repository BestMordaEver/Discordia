--[=[
@c ModalInteraction x MessagingInteraction
@d Represents an interaction that your application receives when a user uses
a message component.
]=]

local enums = require('enums')
local MessagingInteraction = require('containers/abstract/MessagingInteraction')
local Resolver = require('client/Resolver')
local callbackType = enums.callbackType

local ModalInteraction, get = require('class')('ModalInteraction', MessagingInteraction)

function ModalInteraction:__init(data, parent)
    MessagingInteraction.__init(self, data, parent)

	self._custom_id = data.data.customId
	self._components = data.data.components
end

--[=[@p customId string Developer defined custom ID for this component.]=]
function get.customId(self)
    return self._custom_id
end

--[=[@p components table Array of message components that represent the values submitted by the user.]=]
function get.components(self)
    return self._components
end

return ModalInteraction