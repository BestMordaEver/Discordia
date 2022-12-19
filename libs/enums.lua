local function enum(tbl)
	local call = {}
	for k, v in pairs(tbl) do
		if call[v] then
			return error(string.format('enum clash for %q and %q', k, call[v]))
		end
		call[v] = k
	end
	return setmetatable({}, {
		__call = function(_, k)
			if call[k] then
				return call[k]
			else
				return error('invalid enumeration: ' .. tostring(k))
			end
		end,
		__index = function(_, k)
			if tbl[k] then
				return tbl[k]
			else
				return error('invalid enumeration: ' .. tostring(k))
			end
		end,
		__pairs = function()
			return next, tbl
		end,
		__newindex = function()
			return error('cannot overwrite enumeration')
		end,
	})
end

local enums = {enum = enum}

enums.defaultAvatar = enum {
	blurple = 0,
	gray    = 1,
	green   = 2,
	orange  = 3,
	red     = 4,
}

enums.notificationSetting = enum {
	allMessages  = 0,
	onlyMentions = 1,
}

enums.channelType = enum {
	text          = 0,
	private       = 1,
	voice         = 2,
	group         = 3,
	category      = 4,
	news          = 5,
	store         = 6,
	newsThread    = 10,
	publicThread  = 11,
	privateThread = 12,
	stage         = 13,
	directory     = 14,
	forum         = 15,
}

enums.webhookType = enum {
	incoming        = 1,
	channelFollower = 2,
	application     = 3,
}

enums.messageType = enum {
	default                                 = 0,
	recipientAdd                            = 1,
	recipientRemove                         = 2,
	call                                    = 3,
	channelNameChange                       = 4,
	channelIconChange                       = 5,
	pinnedMessage                           = 6,
	memberJoin                              = 7,
	premiumGuildSubscription                = 8,
	premiumGuildSubscriptionTier1           = 9,
	premiumGuildSubscriptionTier2           = 10,
	premiumGuildSubscriptionTier3           = 11,
	channelFollowAdd                        = 12,

	guildDiscoveryDisqualified              = 14,
	guildDiscoveryRequalified               = 15,
	guildDiscoveryGracePeriodInitialWarning = 16,
	guildDiscoveryGracePeriodFinalWarning   = 17,
	threadCreated                           = 18,
	reply                                   = 19,
	chatInputCommand                        = 20,
	threadStarterMessage                    = 21,
	guildInviteReminder                     = 22,
	contextMenuCommand                      = 23,
}

enums.relationshipType = enum {
	none            = 0,
	friend          = 1,
	blocked         = 2,
	pendingIncoming = 3,
	pendingOutgoing = 4,
}

enums.activityType = enum {
	game   = 0,
	streaming = 1,
	listening = 2,
	watching  = 3,
	custom    = 4,
	competing = 5,
}

enums.status = enum {
	online = 'online',
	idle = 'idle',
	doNotDisturb = 'dnd',
	invisible = 'invisible',
}

enums.gameType = enum { -- NOTE: deprecated; use activityType
	default   = 0,
	streaming = 1,
	listening = 2,
	custom    = 4,
}

enums.verificationLevel = enum {
	none     = 0,
	low      = 1,
	medium   = 2,
	high     = 3, -- (╯°□°）╯︵ ┻━┻
	veryHigh = 4, -- ┻━┻ ﾐヽ(ಠ益ಠ)ノ彡┻━┻
}

enums.explicitContentLevel = enum {
	none   = 0,
	medium = 1,
	high   = 2,
}

enums.premiumTier = enum {
	none  = 0,
	tier1 = 1,
	tier2 = 2,
	tier3 = 3,
}

enums.permission = enum {
	createInstantInvite    = 0x0000000000000001,
	kickMembers            = 0x0000000000000002,
	banMembers             = 0x0000000000000004,
	administrator          = 0x0000000000000008,
	manageChannels         = 0x0000000000000010,
	manageGuild            = 0x0000000000000020,
	addReactions           = 0x0000000000000040,
	viewAuditLog           = 0x0000000000000080,
	prioritySpeaker        = 0x0000000000000100,
	stream                 = 0x0000000000000200,
	readMessages           = 0x0000000000000400,
	sendMessages           = 0x0000000000000800,
	sendTextToSpeech       = 0x0000000000001000,
	manageMessages         = 0x0000000000002000,
	embedLinks             = 0x0000000000004000,
	attachFiles            = 0x0000000000008000,
	readMessageHistory     = 0x0000000000010000,
	mentionEveryone        = 0x0000000000020000,
	useExternalEmojis      = 0x0000000000040000,
	viewGuildInsights      = 0x0000000000080000,
	connect                = 0x0000000000100000,
	speak                  = 0x0000000000200000,
	muteMembers            = 0x0000000000400000,
	deafenMembers          = 0x0000000000800000,
	moveMembers            = 0x0000000001000000,
	useVoiceActivity       = 0x0000000002000000,
	changeNickname         = 0x0000000004000000,
	manageNicknames        = 0x0000000008000000,
	manageRoles            = 0x0000000010000000,
	manageWebhooks         = 0x0000000020000000,
	manageEmojis           = 0x0000000040000000,
	useApplicationCommands = 0x0000000080000000,
	requestToSpeak         = 0x0000000100000000,
	manageEvents           = 0x0000000200000000,
	manageThreads          = 0x0000000400000000,
	creaetePublicThreads   = 0x0000000800000000,
	createPrivateThreads   = 0x0000001000000000,
	useExternalStickers    = 0x0000002000000000,
	sendMessagesInThreads  = 0x0000004000000000,
	useEmbeddedActivities  = 0x0000008000000000,
	moderateMembers        = 0x0000010000000000,
}

enums.overwriteType = enum {
	role = 0,
	member = 1,
}

enums.messageFlag = enum {
	crossposted                      = 0x00000001,
	isCrosspost                      = 0x00000002,
	suppressEmbeds                   = 0x00000004,
	sourceMessageDeleted             = 0x00000008,
	urgent                           = 0x00000010,
	hasThread                        = 0x00000020,
	ephemeral                        = 0x00000040,
	loading                          = 0x00000080,
	failedToMentionSomeRolesInThread = 0x00000100,
}

enums.actionType = enum {
	guildUpdate               = 1,
	channelCreate             = 10,
	channelUpdate             = 11,
	channelDelete             = 12,
	channelOverwriteCreate    = 13,
	channelOverwriteUpdate    = 14,
	channelOverwriteDelete    = 15,
	memberKick                = 20,
	memberPrune               = 21,
	memberBanAdd              = 22,
	memberBanRemove           = 23,
	memberUpdate              = 24,
	memberRoleUpdate          = 25,
	memberMove                = 26,
	memberDisconnect          = 27,
	botAdd                    = 28,
	roleCreate                = 30,
	roleUpdate                = 31,
	roleDelete                = 32,
	inviteCreate              = 40,
	inviteUpdate              = 41,
	inviteDelete              = 42,
	webhookCreate             = 50,
	webhookUpdate             = 51,
	webhookDelete             = 52,
	emojiCreate               = 60,
	emojiUpdate               = 61,
	emojiDelete               = 62,
	messageDelete             = 72,
	messageBulkDelete         = 73,
	messagePin                = 74,
	messageUnpin              = 75,
	integrationCreate         = 80,
	integrationUpdate         = 81,
	integrationDelete         = 82,
	stageInstanceCreate       = 83,
	stageInstanceUpdate       = 84,
	stageInstanceDelete       = 85,
	stickerCreate             = 90,
	stickerUpdate             = 91,
	stickerDelete             = 92,
	guildScheduledEventCreate = 100,
	guildScheduledEventUpdate = 101,
	guildScheduledEventDelete = 102,
	threadCreate              = 110,
	threadUpdate              = 111,
	threadDelete              = 112,
}

enums.gatewayIntent = enum {
	guilds                = 0x00000001,
	guildMembers          = 0x00000002,
	guildBans             = 0x00000004,
	guildEmojis           = 0x00000008,
	guildIntegrations     = 0x00000010,
	guildWebhooks         = 0x00000020,
	guildInvites          = 0x00000040,
	guildVoiceStates      = 0x00000080,
	guildPresences        = 0x00000100,
	guildMessages         = 0x00000200,
	guildMessageReactions = 0x00000400,
	guildMessageTyping    = 0x00000800,
	directMessage         = 0x00001000,
	directMessageRections = 0x00002000,
	directMessageTyping   = 0x00004000,
	messageContent        = 0x00008000,
	guildScheduledEvents  = 0x00010000,
}

enums.locale = enum {
	danish      = "da",
	german      = "de",
	englishUK   = "en-GB",
	englishUS   = "en-US",
	spanish     = "es-ES",
	french      = "fr",
	croatian    = "hr",
	italian     = "it",
	lithuanian  = "lt",
	hungarian   = "hu",
	dutch       = "nl",
	norwegian   = "no",
	polish      = "pl",
	portugeseBR = "pt-BR",
	romanian    = "ro",
	finnish     = "fi",
	swedish     = "sv-SE",
	vietnamese  = "vi",
	turkish     = "tr",
	czech       = "cs",
	greek       = "el",
	bulgarian   = "bg",
	russian     = "ru",
	ukrainian   = "uk",
	hindi       = "hi",
	thai        = "th",
	chineseCN   = "zh-CN",
	chineseTW   = "zh-TW",
	japanese    = "ja",
	korean      = "ko",
}

enums.logLevel = enum {
	none    = 0,
	error   = 1,
	warning = 2,
	info    = 3,
	debug   = 4,
}

enums.interactionType = enum {
	ping               = 1,
	applicationCommand = 2,
	messageComponent   = 3,
	autocomplete       = 4,
	modalSubmit        = 5,
}

enums.callbackType = enum {
	pong         = 1,
	reply        = 4,
	deferReply   = 5,
	deferUpdate  = 6,
	update       = 7,
	autocomplete = 8,
	modal        = 9,
}

enums.applicationCommandType = enum {
	chatInput = 1,
	user      = 2,
	message   = 3,
}

enums.applicationCommandOptionType = enum {
	subcommand = 1,
	subcommandGroup = 2,
	string = 3,
	integer = 4,
	boolean = 5,
	user = 6,
	channel = 7,
	role = 8,
	mentionable = 9,
	number = 10,
	attachment = 11,
}

enums.componentType = enum {
	row = 1,
	button = 2,
	stringSelect = 3,
	textInput = 4,
	userSelect = 5,
	roleSelect = 6,
	mentionableSelect = 7,
	channelSelect = 8
}

enums.buttonStyle = enum {
	primary = 1,
	secondary = 2,
	success = 3,
	danger = 4,
	link = 5,
}

enums.inputStyle = enum {
	short = 1,
	paragraph = 2,
}

return enums
