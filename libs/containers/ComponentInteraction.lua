--[=[
@c ComponentInteraction x MessagingInteraction
@d Represents an interaction that your application receives when a user uses
a message component.
]=]

local json = require('json')
local enums = require('enums')
local constants = require('constants')
local Cache = require('iterables/Cache')
local ArrayIterable = require('iterables/ArrayIterable')
local MessagingInteraction = require('containers/abstract/MessagingInteraction')
local Reaction = require('containers/Reaction')
local Resolver = require('client/Resolver')
local insert = table.insert
local null = json.null
local format = string.format
local messageFlag, callbackType = enums.messageFlag, enums.callbackType
local band, bor, bnot = bit.band, bit.bor, bit.bnot

local ComponentInteraction, get = require('class')('ComponentInteraction', MessagingInteraction)

function ComponentInteraction:__init(data, parent)
    MessagingInteraction.__init(self, data, parent)

    local id = Resolver.messageId(data.message.id)
	local message = self._parent._messages:get(id)
	if message then
		self._message = message
	else
		local data = self.client._api:getChannelMessage(self._parent._id, id)
		if data then
			self._message = self.parent._messages:_insert(data)
		end
	end

end


function ComponentInteraction:updateComponentMessage(payload)
	return self._parent:_callback(self, callbackType.update, payload)
end


function ComponentInteraction:acknowledge()
	assert(self._is_deferrable, "interaction is already deferred")
	self._is_deferrable = false
	return self._parent:_callback(self, callbackType.acknowledge)
end


function get.message(self)
    return self._message
end

return ComponentInteraction