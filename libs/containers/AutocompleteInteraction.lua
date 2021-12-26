--[=[
@c AutocompleteInteraction x Interaction
@d Represents an interaction that your application receives when a user
start typing slash command that has autocomplete option.
]=]

local enums = require('enums')
local Interaction = require('containers/abstract/Interaction')
local callbackType = enums.callbackType

local AutocompleteInteraction = require('class')('AutocompleteInteraction', Interaction)

function AutocompleteInteraction:__init(data, parent)
	Interaction.__init(self, data, parent)
end

function AutocompleteInteraction:proposeAutocomplete(choices)
	local data, err = self.client._api:createInteractionResponse(self._id, self._token, {type = callbackType.autocomplete, data = {choices = choices}})
	if data then
		return data
	else
		return nil, err
	end
end

return AutocompleteInteraction