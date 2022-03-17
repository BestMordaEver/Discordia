--[=[
@c AutocompleteInteraction x SlashInteraction
@d Represents an interaction that your application receives when a user
start typing slash command that has autocomplete option.
]=]

local enums = require('enums')
local SlashInteraction = require('containers/abstract/SlashInteraction')
local callbackType = enums.callbackType

local AutocompleteInteraction = require('class')('AutocompleteInteraction', SlashInteraction)

function AutocompleteInteraction:__init(data, parent)
	SlashInteraction.__init(self, data, parent)
end

--[=[
@m provideChoices
@t http
@p choices table
@r boolean
@d Reply to interaction with an array of choices. A choice
consists of "name" and "value" fields
]=]
function AutocompleteInteraction:provideChoices(choices)
	return self._callback(callbackType.autocomplete, {choices = choices})
end

return AutocompleteInteraction