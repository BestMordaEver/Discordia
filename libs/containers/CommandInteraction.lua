--[=[
@c CommandInteraction x MessagingInteraction
@d Represents an interaction that your application receives when a user uses
an application command.
]=]

local channelType = require('enums').channelType
local MessagingInteraction = require('containers/abstract/MessagingInteraction')
local CommandOption = require('containers/CommandOption')
local Cache = require('iterables/Cache')

local CommandInteraction, get = require('class')('CommandInteraction', MessagingInteraction)

function CommandInteraction:__init(data, parent)
	MessagingInteraction.__init(self, data, parent)

	if data.data.resolved then
		local resolved = data.data.resolved
		local guild = self.guild
		local client = self._parent._parent._parent or self._parent._parent

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
				self._messages[snowflake] = self._parent._messages:get(snowflake) or self._parent._messages:_insert(obj)
			end
		end
	end

	if data.target_id then
		self._target = self._messages[data.target_id] or self._members[data.target_id]
	end

	if data.data.options then
		self._options = Cache(data.data.options, CommandOption, self)
		if #self._options == 1 then
			local _, val = next(self._options._objects)
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

--[=[@p options Cache/nil Cache of command options received from the user.]=]
function get.options(self)
	return self._options
end

--[=[@p option CommandOption/nil Suboption if this option is a group or subcommand. Only exists when there's one suboption.]=]
function get.option(self)
	return self._option
end

return CommandInteraction