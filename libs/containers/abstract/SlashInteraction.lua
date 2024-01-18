--[=[
@c SlashInteraction x Interaction
@d Defines the base methods and properties for Discord interactions
that are received when a user uses a slash command.
]=]

local enums = require('enums')
local channelType, applicationCommandType = assert(enums.channelType), assert(enums.applicationCommandType)
local Interaction = require('containers/abstract/Interaction')
local CommandOption = require('utils/CommandOption')

local SlashInteraction, get = require('class')('SlashInteraction', Interaction)

function SlashInteraction:__init(data, client)
	Interaction.__init(self, data, client)

	data = data.data
	if data.resolved then
		local resolved = data.resolved
		local guild = self.guild

		if resolved.users then
			self._users = {}
			for snowflake, obj in pairs(resolved.users) do
				self._users[snowflake] = client._users:get(snowflake) or client._users:_insert(obj)
			end
		end

		if resolved.members then
			self._members = {}
			for snowflake, obj in pairs(resolved.members) do
				obj.user = resolved.users[snowflake]
				self._members[snowflake] = guild._members:get(snowflake) or guild._members:_insert(obj)
			end
		end

		if resolved.roles then
			self._roles = {}
			for snowflake, obj in pairs(resolved.roles) do
				self._roles[snowflake] = guild._roles:get(snowflake) or guild._roles:_insert(obj)
			end
		end

		if resolved.channels then
			self._channels = {}
			for snowflake, obj in pairs(resolved.channels) do
				local channelCache
				if obj.type == channelType.text then
					channelCache = guild._text_channels
				elseif obj.type == channelType.voice then
					channelCache = guild._voice_channels
				elseif obj.type == channelType.category then
					channelCache = guild._categories
				end

				self._channels[snowflake] = channelCache:get(snowflake) or channelCache:_insert(obj)
			end
		end

		if resolved.messages then
			self._messages = {}
			for snowflake, obj in pairs(resolved.messages) do
				self._messages[snowflake] = self._channel._messages:get(snowflake) or self._channel._messages:_insert(obj)
			end
		end
	end

	if data.target_id then
		if data.type == applicationCommandType.message then
			self._target = self._messages[data.target_id]
		elseif data.type == applicationCommandType.user then
			self._target = self._members[data.target_id]
		end
	end

	return self:_loadOptions(data.options, self)
end

local meta = {__len = function (self)
	local a,i = -1
	repeat
		a = a + 1
		i = next(self,i)
	until not i
	return a
end}

function SlashInteraction:_loadOptions(options, parent)
	if options and next(options) then
		self._options = setmetatable({}, meta)
		for i, option in ipairs(options) do
			self._options[option.name] = CommandOption(option, parent)
		end
		if #options == 1 then
			local _, val = next(self._options)
			self._option = val
		end
	end
end

--[=[@p commandId string The ID of the invoked command.]=]
function get.commandId(self)
	return self._data.id
end

--[=[@p commandName string The name of the invoked command.]=]
function get.commandName(self)
	return self._data.name
end

--[=[@p commandType number The type of the invoked command. See the `applicationCommandType` enumeration for a human-readable representation.]=]
function get.commandType(self)
	return self._data.type
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