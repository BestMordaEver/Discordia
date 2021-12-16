--[=[
@c Interaction x Snowflake
@d Represents a message that your application receives when a user uses
an application command or a message component. Messages can contain
simple content strings, rich embeds, attachments, or reactions.
]=]

local json = require('json')
local enums = require('enums')
local Cache = require('iterables/Cache')
local ArrayIterable = require('iterables/ArrayIterable')
local MessagingInteraction = require('containers/abstract/MessagingInteraction')
local User = require('containers/User')
local Role = require('containers/Role')
local Channel = require('containers/abstract/Channel')
local Message = require('containers/Message')
local Member = require('containers/Member')
local Reaction = require('containers/Reaction')
local Resolver = require('client/Resolver')
local insert = table.insert
local null = json.null
local format = string.format
local messageFlag, callbackType = enums.messageFlag, enums.callbackType
local band, bor, bnot = bit.band, bit.bor, bit.bnot

local CommandInteraction, get = require('class')('CommandInteraction', MessagingInteraction)

function CommandInteraction:__init(data, parent)
	MessagingInteraction.__init(self, data, parent)
	self._resolved = {}

	local guild = self._parent._parent
	local resolved = self._resolved
	if data.resolved then
		resolved.members = Cache({}, Member, self)
		for snowlake, partMember in pairs(data.resolved.members) do
			local member = guild:getMember(snowlake.id)

			if not member then
				member = partMember
				member.user = Resolver.userId(snowlake.id)
			end
			resolved.members:_insert(member)
		end

		self._users = Cache({}, User, self)
		for snowflake, _ in pairs(data.resolved.users) do
			resolved.users:_insert(Resolver.userId(snowflake.id))
		end

		self._roles = Cache(data.resolved.roles, Role, self)
		for snowflake, _ in pairs(data.resolved.roles) do
			resolved.roles:_insert(Resolver.roleId(snowflake.id))
		end

		self._channels = Cache(data.resolved.channels, Channel, self)
		self._messages = Cache(data.resolved.messages, Message, self)
	--p(data.resolved)
	end
end

return CommandInteraction