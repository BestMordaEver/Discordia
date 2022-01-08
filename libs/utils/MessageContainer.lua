--[=[
@c MessageContent
@d Defines the base methods and properties for all Discord text channels.
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

local MessageContent, get = class('MessageContent')

function MessageContent:__init(data)
	local message, files = MessageContent.parseContent(data)
    if message then
        self._message, self._files = message, files
    else
        error(files)
    end
end

function MessageContent.parseFile(obj, files)
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

function MessageContent.parseMention(obj, mentions)
	if type(obj) == 'table' and obj.mentionString then
		mentions = mentions or {}
		insert(mentions, obj.mentionString)
	else
		return nil, 'Unmentionable object: ' .. tostring(obj)
	end
	return mentions
end

function MessageContent.parseContent(content)
	if type(content) == 'table' then

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
			mentions, err = MessageContent.parseMention(tbl.mention)
			if err then
				return nil, err
			end
		end
		if type(tbl.mentions) == 'table' then
			for _, mention in ipairs(tbl.mentions) do
				mentions, err = MessageContent.parseMention(mention, mentions)
				if err then
					return nil, err
				end
			end
		end

		if mentions then
			insert(mentions, content)
			content = concat(mentions, ' ')
		end

		local files
		if tbl.file then
			files, err = MessageContent.parseFile(tbl.file)
			if err then
				return nil, err
			end
		end
		if type(tbl.files) == 'table' then
			for _, file in ipairs(tbl.files) do
				files, err = MessageContent.parseFile(file, files)
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

		return {
			content = content,
			tts = tbl.tts,
			flags = tbl.flags,
			nonce = tbl.nonce,
			embeds = tbl.embeds,
			message_reference = refMessage,
			allowed_mentions = refMention,
			components = tbl.components
		}, files

	else
		return {content = content}

	end
end

function MessageContent:send(textChannel)
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

return MessageContent