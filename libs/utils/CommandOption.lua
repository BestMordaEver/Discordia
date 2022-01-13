local optionType = require('enums').applicationCommandOptionType
local CommandOption, get = require('class')('CommandOption')

local types = {['string'] = true, ['number'] = true, ['boolean'] = true}

function CommandOption:__init(data, parent)
	parent._loadOptions(self, data.options, parent)
	for k, v in pairs(data) do
		if types[type(v)] then
			self['_' .. k] = v
		end
	end

    if data.type == optionType.user then
        self._value = parent._users[self._value]
    elseif data.type == optionType.channel then
        self._value = parent._channels[self._value]
    elseif data.type == optionType.role then
        self._value = parent._roles[self._value]
    end
end

--[=[@p name string The name of the parameter.]=]
function get.name(self)
	return self._name
end

--[=[@p type number The option type. See the `applicationCommandOptionType` enumeration for a human-readable representation.]=]
function get.type(self)
	return self._type
end

--[=[@p value string/number/nil The value of the option resulting from user input.]=]
function get.value(self)
	return self._value
end

--[=[@p options table/nil Suboptions if this option is a group or subcommand.]=]
function get.options(self)
	return self._options
end

--[=[@p option CommandOption/nil Suboption if this option is a group or subcommand. Only exists when there's one suboption.]=]
function get.option(self)
	return self._option
end

--[=[@p focused boolean Whether this option is the currently focused option for autocomplete.]=]
function get.focused(self)
	return self._focused
end

return CommandOption