--[=[
@c CommandInteraction x MessagingInteraction
@d Represents an interaction that your application receives when a user uses
an application command.
]=]

local MessagingInteraction = require('containers/abstract/MessagingInteraction')
local Cache = require('iterables/Cache')
local User = require('containers/User')
local Role = require('containers/Role')
local Channel = require('containers/abstract/Channel')
local Message = require('containers/Message')
local Resolver = require('client/Resolver')

local CommandInteraction = require('class')('CommandInteraction', MessagingInteraction)

function CommandInteraction:__init(data, parent)
	MessagingInteraction.__init(self, data, parent)

	if data.resolved then
		self._users = Cache({}, User, self)
		for snowflake, _ in pairs(data.resolved.users) do
			self._users:_insert(Resolver.userId(snowflake.id))
		end

		self._roles = Cache(data.resolved.roles, Role, self)
		for snowflake, _ in pairs(data.resolved.roles) do
			self._roles:_insert(Resolver.roleId(snowflake.id))
		end

		self._channels = Cache(data.resolved.channels, Channel, self)
		for snowflake, _ in pairs(data.resolved.channels) do
			self._channels:_insert(Resolver.channelId(snowflake.id))
		end

		self._messages = Cache(data.resolved.messages, Message, self)
		for snowflake, _ in pairs(data.resolved.messages) do
			self._messages:_insert(Resolver.messageId(snowflake.id))
		end
	end
end

return CommandInteraction