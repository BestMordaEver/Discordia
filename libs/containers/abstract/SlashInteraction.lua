--[=[
@c SlashInteraction x Interaction
@d Defines the base methods and properties for Discord interactions
that are received when a user uses a slash command.
]=]

local enums = require('enums')
local channelType, commandType, optionType = assert(enums.channelType), assert(enums.applicationCommandType), assert(enums.applicationCommandOptionType)
local Interaction = require('containers/abstract/Interaction')

---@class CommandOption
---@field name string
---@field type applicationCommandOptionType
---@field value string|number|boolean|Member|Role|GuildChannel
---@field focused? boolean

--[=[Defines the base methods and properties for Discord interactions
that are received when a user uses a slash command.]=]
---@class SlashInteraction : Interaction
---@field commandId string
---@field commandName string
---@field commandType applicationCommandType
---@field target? Member | Message
---@field options? table<string, CommandOption>
---@field option? CommandOption
---@field protected __init fun(self : SlashInteraction, data : table, client : Client)
local SlashInteraction, get = require('class')('SlashInteraction', Interaction)

local meta = {__len = function (self)
	local a,i = -1
	repeat
		a = a + 1
		i = next(self,i)
	until not i
	return a
end}

function SlashInteraction:__init(data, client)
	Interaction.__init(self, data, client)

	data = data.data
	self._commandId = data.id
	self._commandName = data.name
	self._commandType = data.type

	local resolved = data.resolved
	local guild = self.guild

	if data.target_id then
		if data.type == commandType.message then
			self._target = self._channel._messages:get(data.target_id) or self._channel._messages:_insert(resolved.messages[data.target_id])
		elseif data.type == commandType.user then
			resolved.members[data.target_id].user = resolved.users[data.target_id]
			self._target = guild._members:get(data.target_id) or guild._members:_insert(resolved.members[data.target_id])
		end
	end

	local options = data.options

	if options and options[1] and not options[1].value then
		self._subcommand = options[1].name
		options = options[1].options
	end

	if options and options[1] and not options[1].value then
		self._subcommandOption = options[1].name
		options = options[1].options
	end

	if options then
		self._options = setmetatable({}, meta)
		for i, option in ipairs(options) do
			self._options[option.name] = option

			if resolved then
				if option.type == optionType.user then
					option.value = client._users:get(option.value) or client._users:_insert(resolved.users[option.value])

					if resolved.members and resolved.members[option.value] then
						resolved.members[option.value].user = resolved.users[option.value]
						guild._members:_insert(resolved.members[option.value])
					end
				elseif option.type == optionType.channel then
					local channelCache
					local obj = resolved.channels[option.value]

					if obj.type == channelType.text then
						channelCache = guild._text_channels
					elseif obj.type == channelType.voice then
						channelCache = guild._voice_channels
					elseif obj.type == channelType.category then
						channelCache = guild._categories
					end

					option.value = channelCache:get(option.value) or channelCache:_insert(obj)

				elseif option.type == optionType.role then
					option.value = guild._roles:get(option.value) or guild._roles:_insert(resolved.roles[option.value])
				end
			end
		end

		if #options == 1 then
			local _, val = next(self._options)
---@diagnostic disable-next-line: assign-type-mismatch
			self._option = val
		end
	end
end

--[=[@p commandId string The ID of the invoked command.]=]
function get.commandId(self)
	return self._commandId
end

--[=[@p commandName string The name of the invoked command.]=]
function get.commandName(self)
	return self._commandName
end

--[=[@op subcommand string The name of the invoked subcommand or subcommand group if one is present.]=]
function get.subcommand(self)
	return self._subcommand
end

--[=[@p subcommandOption string The name of the invoked subcommand. Only exists if a subcommand group is invoked.]=]
function get.subcommandOption(self)
	return self._subcommandOption
end

--[=[@p commandType number The type of the invoked command. See the `applicationCommandType` enumeration for a human-readable representation.]=]
function get.commandType(self)
	return self._commandType
end

--[=[@p target Member/Message/nil Member or message targetted by a user or message command.]=]
function get.target(self)
	return self._target
end

--[=[@p options table/nil Table of command options received from the user.]=]
function get.options(self)
	return self._options
end

--[=[@p option CommandOption/nil Suboption if this option is a group or subcommand. Only exists when there's one suboption.]=]
function get.option(self)
	return self._option
end

return SlashInteraction