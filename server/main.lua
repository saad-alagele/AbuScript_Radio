-- ============================================================
--  AbuScript_Radio – Server Main
--  Manages radio channels and caller lists.
-- ============================================================

local ESX = exports['es_extended']:getSharedObject()

-- channels[channelNum] = { [serverId] = { name = '', talking = false } }
local channels = {}

-- playerChannel[serverId] = channelNum  (current channel per player)
local playerChannel = {}

-- ── Helpers ──────────────────────────────────────────────────
local function getPlayerName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getName()
    end
    return GetPlayerName(source) or ('Player ' .. source)
end

local function broadcastCallerList(channelNum)
    local ch = channels[channelNum]
    if not ch then return end

    local list = {}
    for sid, info in pairs(ch) do
        list[#list + 1] = {
            id      = sid,
            name    = info.name,
            talking = info.talking,
        }
    end

    for sid in pairs(ch) do
        TriggerClientEvent('AbuScript_Radio:updateCallerList', sid, list)
    end
end

local function leaveChannel(source)
    local channel = playerChannel[source]
    if not channel then return end

    if channels[channel] then
        channels[channel][source] = nil
        -- Clean up empty channels
        local empty = true
        for _ in pairs(channels[channel]) do empty = false; break end
        if empty then channels[channel] = nil end
    end

    playerChannel[source] = nil

    -- Notify remaining callers
    if channels[channel] then
        broadcastCallerList(channel)
    end
end

-- ── Server Events ────────────────────────────────────────────
RegisterServerEvent('AbuScript_Radio:joinChannel')
AddEventHandler('AbuScript_Radio:joinChannel', function(channel)
    local source  = source
    channel       = tonumber(channel)
    if not channel or channel < 1 or channel > 100 then return end

    -- Leave old channel first
    leaveChannel(source)

    -- Join new channel
    if not channels[channel] then channels[channel] = {} end
    channels[channel][source] = {
        name    = getPlayerName(source),
        talking = false,
    }
    playerChannel[source] = channel

    -- Build caller list and send to joining player
    local list = {}
    for sid, info in pairs(channels[channel]) do
        list[#list + 1] = {
            id      = sid,
            name    = info.name,
            talking = info.talking,
        }
    end

    TriggerClientEvent('AbuScript_Radio:channelJoined', source, channel, list)

    -- Notify everyone else in the channel
    broadcastCallerList(channel)
end)

RegisterServerEvent('AbuScript_Radio:leaveChannel')
AddEventHandler('AbuScript_Radio:leaveChannel', function()
    local source = source
    leaveChannel(source)
end)

RegisterServerEvent('AbuScript_Radio:startTalking')
AddEventHandler('AbuScript_Radio:startTalking', function(channel)
    local source = source
    channel      = tonumber(channel)
    if not channel then return end

    if channels[channel] and channels[channel][source] then
        channels[channel][source].talking = true
        broadcastCallerList(channel)
    end
end)

RegisterServerEvent('AbuScript_Radio:stopTalking')
AddEventHandler('AbuScript_Radio:stopTalking', function(channel)
    local source = source
    channel      = tonumber(channel)
    if not channel then return end

    if channels[channel] and channels[channel][source] then
        channels[channel][source].talking = false
        broadcastCallerList(channel)
    end
end)

-- ── Player Drop ──────────────────────────────────────────────
AddEventHandler('playerDropped', function()
    local source = source
    leaveChannel(source)
end)
