--[=[
@c AutocompleteInteraction x Interaction
@d Represents an interaction that your application receives when a user
start typing slash command that has autocomplete option.
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

local AutocompleteInteraction, get = require('class')('AutocompleteInteraction', Interaction)

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