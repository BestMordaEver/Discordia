--[=[
@c MessageContainer
@t ui
@mt mem
@p data table
@d Defines the base methods and properties for all Discord messages and message-like objects.
]=]

local class = require('class')
local classes = class.classes
local pathjoin = require('pathjoin')
local Resolver = require('client/Resolver')
local fs = require('fs')

local splitPath = pathjoin.splitPath
local insert, remove, concat = table.insert, table.remove, table.concat
local format = string.format
local readFileSync = fs.readFileSync
local messageFlag = require('enums').messageFlag
local bor = bit.bor

--[=[Defines the base methods and properties for all Discord messages and message-like objects.]=]
---@class MessageContainer
---@overload fun(data : string|messageParams) : MessageContainer
---@field content string
---@field tts boolean
---@field flags integer
---@field nonce integer|string
---@field embeds table
---@field referenceMessage table <string, string>
---@field allowedMentions {parse : string[], replied_user? : boolean}
---@field components table
---@field hasFile boolean
---@field files string[]
---@field protected _message table
---@field protected _files [string|fileContent]|string|nil
---@field protected __init fun(self : self, data : string|messageParams)
local MessageContainer, get = class('MessageContainer')

---@param obj string | fileContent
---@param files? [string | fileContent]
---@return [string | fileContent]?
---@return string?
local function parseFile(obj, files)
	if type(obj) == 'string' then
		local data, err = readFileSync(obj)
		if not data then
			return nil, err
		end
		files = files or {}
		insert(files, {remove(splitPath(obj)), data})
	elseif type(obj) == 'table' and type(obj[1]) == 'string' and type(obj[2]) == 'string' then
		files = files or {}
		insert(files, obj)
	else
		return nil, 'Invalid file object: ' .. tostring(obj)
	end
	return files
end

---@param obj User
---@param mentions? User[]
---@return [string]?
---@return string?
local function parseMention(obj, mentions)
	if type(obj) == 'table' and obj.mentionString then
		mentions = mentions or {}
		insert(mentions, obj.mentionString)
	else
		return nil, 'Unmentionable object: ' .. tostring(obj)
	end
	return mentions
end

---@param obj table
---@param embeds? table[]
---@return table[]?
---@return string?
local function parseEmbed(obj, embeds)
	if type(obj) == 'table' and next(obj) then
		embeds = embeds or {}
		insert(embeds, obj)
	else
		return nil, 'Invalid embed object: ' .. tostring(obj)
	end
	return embeds
end

---@class fileContent
---@field [1] string file name
---@field [2] string file content

---@class messageParams
---@field content? string
---@field nonce? integer|string
---@field tts? boolean
---@field embed? table
---@field embeds? table[]
---@field file? string | fileContent
---@field files? [string | fileContent]
---@field mention? User
---@field mentions? User[]
---@field components table[]
---@field code? string
---@field reference? {message : Message, mention : boolean}
---@field sticker? Sticker
---@field ephemeral? boolean
---@field silent? boolean

---comment
---@param content messageParams
---@return table?
---@return [string|fileContent]|string|nil
function MessageContainer.parseContent(content)
	if type(content) == 'table' then

		---@class messageParams
		local tbl, err = content
		content = tbl.content

		-- check flags

		if type(tbl.code) == 'string' then
			content = format('```%s\n%s\n```', tbl.code, content)
		elseif tbl.code == true then
			content = format('```\n%s\n```', content)
		end

		local mentions
		if tbl.mention then
			mentions, err = parseMention(tbl.mention)
			if err then
				return nil, err
			end
		end
		if type(tbl.mentions) == 'table' then
			for _, mention in ipairs(tbl.mentions) do
				mentions, err = parseMention(mention, mentions)
				if err then
					return nil, err
				end
			end
		end

		if mentions then
			insert(mentions, content)
			content = concat(mentions, ' ')
		end

		local embeds
		if tbl.embed then
			embeds, err = parseEmbed(tbl.embed)
			if err then
				return nil, err
			end
		end
		if type(tbl.embeds) == 'table' then
			for _, embed in ipairs(tbl.embeds) do
				embeds, err = parseEmbed(embed, embeds)
				if err then
					return nil, err
				end
			end
		end

		local files
		if tbl.file then
			files, err = parseFile(tbl.file)
			if err then
				return nil, err
			end
		end
		if type(tbl.files) == 'table' then
			for _, file in ipairs(tbl.files) do
				files, err = parseFile(file, files)
				if err then
					return nil, err
				end
			end
		end

		local refMessage, refMention
		if tbl.reference then
			refMessage = {message_id = Resolver.messageId(tbl.reference.message)}
			refMention = {
				parse = {'users', 'roles', 'everyone'},
				replied_user = not not tbl.reference.mention,
			}
		end

		local sticker
		if tbl.sticker then
			sticker = {Resolver.stickerId(tbl.sticker)}
		end

		if tbl.ephemeral then
			tbl.flags = bor(tbl.flags or 0, messageFlag.ephemeral)
		end

		if tbl.silent then
			tbl.flags = bor(tbl.flags or 0, messageFlag.suppressNotification)
		end

		return {
			content = content,
			tts = tbl.tts,
			flags = tbl.flags ~= 0 and tbl.flags or nil,
			nonce = tbl.nonce,
			embeds = tbl.embeds,
			message_reference = refMessage,
			allowed_mentions = refMention,
			components = tbl.components,
			sticker_ids = sticker,
		}, files

	else
		return {content = content}

	end
end

function MessageContainer:__init(data)
	local message, files = MessageContainer.parseContent(data)
    if message then
        self._message, self._files = message, files
    else
        error(files)
    end
end

--[=[
@m send
@p textChannel TextChannel
@r Message
@d Sends the message in the provided text channel.
]=]
--[=[Sends the message in the provided text channel.]=]
---@param textChannel TextChannel
---@return Message?
---@return string?
function MessageContainer:send(textChannel)
    assert(class.isInstance(textChannel, classes.TextChannel), "provided object is not a text channel")
    return textChannel:send(self)
end

get.content = function (self)
    return self._message.content
end

get.tts = function (self)
    return self._message.tts
end

get.flags = function (self)
    return self._message.flags
end

get.nonce = function (self)
    return self._message.nonce
end

get.embeds = function (self)
    return self._message.embeds
end

get.referencedMessage = function (self)
    return self._message.message_reference
end

get.allowedMentions = function (self)
    return self._message.allowed_mentions
end

get.components = function (self)
    return self._message.components
end

get.hasFiles = function (self)
    return not not self._files
end

get.files = function (self)
    return self._files
end

return MessageContainer