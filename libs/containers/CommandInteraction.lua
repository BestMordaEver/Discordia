--[=[
@c CommandInteraction x MessagingInteraction
@d Represents an interaction that your application receives when a user uses
an application command.
]=]

local channelType = require('enums').channelType
local MessagingInteraction = require('containers/abstract/MessagingInteraction')
local Cache = require('iterables/Cache')
local User = require('containers/User')
local Member = require('containers/Member')
local Role = require('containers/Role')
local Channel = require('containers/abstract/Channel')
local Message = require('containers/Message')
local Resolver = require('client/Resolver')
local CommandOption = require('containers/CommandOption')

local CommandInteraction, get = require('class')('CommandInteraction', MessagingInteraction)

function CommandInteraction:__init(data, parent)
	MessagingInteraction.__init(self, data, parent)

	if data.resolved then
		local guild = self._guild
		local client = self._parent._parent._parent or self._parent._parent

		self._users = Cache({}, User, self)
		for snowflake, obj in pairs(data.resolved.users) do
			local user = Resolver.userId(snowflake)
			if not user then
				user = client._users:_insert(obj)
			end
			self._users:_insert(user)
		end

		self._members = Cache({}, Member, self)
		for snowflake, obj in pairs(data.resolved.members) do
			local member = Resolver.memberId(snowflake)
			if not member then
				member.user = data.resolved[snowflake]
				member = guild._members:_insert(obj)
			end
			self._members:_insert(member)
		end

		self._roles = Cache(data.resolved.roles, Role, self)
		for snowflake, obj in pairs(data.resolved.roles) do
			local role = Resolver.roleId(snowflake)
			if not role then
				role = guild._roles:_insert(obj)
			end
			self._roles:_insert(role)
		end

		self._channels = Cache(data.resolved.channels, Channel, self)
		for snowflake, obj in pairs(data.resolved.channels) do
			local channel = Resolver.channelId(snowflake)
			if not channel then
				if obj.type == channelType.text then
					channel = guild._text_channels:_insert(obj)
				elseif obj.type == channelType.voice then
					channel = guild._voice_channels:_insert(obj)
				elseif obj.type == channelType.category then
					channel = guild._categories:_insert(obj)
				end
			end
			self._channels:_insert(channel)
		end

		self._messages = Cache(data.resolved.messages, Message, self)
		for snowflake, obj in pairs(data.resolved.messages) do
			local message = Resolver.messageId(snowflake)
			if not message then
				message = self._parent._messages:_insert(obj)
			end
			self._messages:_insert(message)
		end
	end

	if data.target_id then
		self._target = self._messages:get(data.target_id) or self._members:get(data.target_id)
	end

	if data.data.options then
		self._options = Cache(data.data.options, CommandOption, self)
		if #self._options == 1 then
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

--[=[@p options Cache/nil Cache of command options received from the user.]=]
function get.options(self)
	return self._options
end

--[=[@p option CommandOption/nil Suboption if this option is a group or subcommand. Only exists when there's one suboption.]=]
function get.option(self)
	return self._option
end

return CommandInteraction