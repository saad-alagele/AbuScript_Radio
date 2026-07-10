ESX = exports["es_extended"]:getSharedObject()

local ChannelMembers = {}

local function hasRadioItem(source)
    if not Config.NeedItemToUseRadio then
        return true
    end

    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:GetItemCount(source, Config.ItemName) > 0
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local item = xPlayer.getInventoryItem(Config.ItemName)
    if item and item.count > 0 then
        return true
    end
    return false
end

local function getFreqGroup(freq)
    freq = tonumber(freq)
    if not freq then return nil end

    for k, group in pairs(Config.vaildFrequency) do
        for _, freqList in ipairs(group.Frequencys) do
            for _, f in ipairs(freqList) do
                if tonumber(f) == freq then
                    return group
                end
            end
        end
    end
    return nil
end

local function getFreqLabel(freq)
    local group = getFreqGroup(freq)
    if group then
        return group.label
    end
    return Config.UnprotectedLabel
end

local function getMembersList(channel)
    local list = {}
    if not ChannelMembers[channel] then return list end

    for _, info in pairs(ChannelMembers[channel]) do
        table.insert(list, { id = info.id, name = info.name })
    end

    table.sort(list, function(a, b)
        return a.id < b.id
    end)

    return list
end

local function sendUpdateToChannel(channel)
    if not ChannelMembers[channel] then return end

    local members = getMembersList(channel)
    local label = getFreqLabel(channel)

    for src, _ in pairs(ChannelMembers[channel]) do
        TriggerClientEvent("AbuScript_Radio:UpdateMembers", src, {
            frequency = channel,
            frequencyLabel = label,
            members = members
        })
    end
end

local function removeFromAllChannels(source)
    for channel, members in pairs(ChannelMembers) do
        if members[source] then
            members[source] = nil

            local empty = true
            for _ in pairs(members) do
                empty = false
                break
            end

            if empty then
                ChannelMembers[channel] = nil
            else
                sendUpdateToChannel(channel)
            end
        end
    end
end

local function addToChannel(source, channel)
    removeFromAllChannels(source)

    if not ChannelMembers[channel] then
        ChannelMembers[channel] = {}
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local name = xPlayer.getName and xPlayer.getName() or GetPlayerName(source)

    ChannelMembers[channel][source] = {
        id = source,
        name = name
    }

    sendUpdateToChannel(channel)
end

local function canJoinFreq(xPlayer, freq)
    local group = getFreqGroup(freq)
    if not group then return true end

    local job = xPlayer.job and xPlayer.job.name
    if not job then return false end

    for _, j in ipairs(group.jobCanJoin) do
        if job == j then
            return true
        end
    end
    return false
end

ESX.RegisterServerCallback("AbuScript_Radio:HasRadioItem", function(source, cb)
    cb(hasRadioItem(source))
end)

ESX.RegisterServerCallback("AbuScript_Radio:JoinChannel", function(source, cb, frequency)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(false, "You are not logged in")
        return
    end

    if not hasRadioItem(source) then
        cb(false, "يجب أن يكون لديك راديو في حقيبتك")
        return
    end

    local freq = math.floor(tonumber(frequency) or 0)
    if freq < 1 or freq > Config.MaxFrequency then
        cb(false, "Invalid frequency")
        return
    end

    if not canJoinFreq(xPlayer, freq) then
        cb(false, "لا تملك صلاحية الدخول لهذه الموجة")
        return
    end

    addToChannel(source, freq)

    cb(true, {
        channel = freq,
        frequencyLabel = getFreqLabel(freq),
        members = getMembersList(freq)
    })
end)

RegisterNetEvent("AbuScript_Radio:LeaveChannel", function()
    removeFromAllChannels(source)
end)

AddEventHandler("playerDropped", function()
    removeFromAllChannels(source)
end)

RegisterNetEvent("esx:onPlayerDeath", function()
    removeFromAllChannels(source)
end)
