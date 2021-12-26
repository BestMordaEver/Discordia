--[=[
@c CommandInteraction x MessagingInteraction
@d Represents an interaction that your application receives when a user uses
an application command.
]=]

local MessagingInteraction = require('containers/abstract/MessagingInteraction')

local CommandInteraction = require('class')('CommandInteraction', MessagingInteraction)

function CommandInteraction:__init(data, parent)
	MessagingInteraction.__init(self, data, parent)
end

return CommandInteraction