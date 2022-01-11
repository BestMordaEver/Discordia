local Container = require('containers/abstract/Container')

local optionType = require('enums').applicationCommandOptionType
local CommandOption, get = require('class')('CommandOption', Container)
local Cache = require('iterables/Cache')

local format = string.format

function CommandOption:__init(data, parent)
	Container.__init(self, data, parent)

	if data.options then
		self._options = Cache(data.options, CommandOption, parent)
		if #self._options == 1 then
			local _, val = next(self._options)
			self._option = val
		end
	end

    if data.type == optionType.user then
        self._value = self._parent._users[self._value]
    elseif data.type == optionType.channel then
        self._value = self._parent._channels[self._value]
    elseif data.type == optionType.role then
        self._value = self._parent._roles[self._value]
    end
end

function CommandOption:__hash()
	return format("%s option '%s'", self._parent._id, self._name)
end

--[=[@p type string The name of the parameter.]=]
function get.name(self)
	return self._name
end

--[=[@p type number The option type. See the `applicationCommandOptionType` enumeration for a human-readable representation.]=]
function get.type(self)
	return self._type
end

--[=[@p type string/number/nil The value of the option resulting from user input.]=]
function get.value(self)
	return self._value
end

--[=[@p type Cache/nil Suboptions if this option is a group or subcommand.]=]
function get.options(self)
	return self._options
end

--[=[@p type CommandOption/nil Suboption if this option is a group or subcommand. Only exists when there's one suboption.]=]
function get.option(self)
	return self._option
end

--[=[@p type boolean Whether this option is the currently focused option for autocomplete.]=]
function get.focused(self)
	return self._focused
end

return CommandOption