--[=[
@c CommandInteraction x MessagingInteraction X SlashInteraction
@d Represents an interaction that your application receives when a user uses
an application command.
]=]

local MessagingInteraction = require('containers/abstract/MessagingInteraction')
local SlashInteraction = require('containers/abstract/SlashInteraction')

local CommandInteraction = require('class')('CommandInteraction', MessagingInteraction, SlashInteraction)

function CommandInteraction:__init(data, client)
	MessagingInteraction.__init(self, data, client)
	SlashInteraction.__init(self, data, client)
end

return CommandInteraction