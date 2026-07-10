ESX = exports["es_extended"]:getSharedObject()

local radioOpen = false
local currentFrequency = 0
local currentVolume = Config.DefaultVolume

local function clampVolume(vol)
    vol = tonumber(vol) or 0
    if vol < 0 then vol = 0 end
    if vol > 100 then vol = 100 end
    return math.floor(vol)
end

local function setRadioVolume(vol)
    currentVolume = clampVolume(vol)
    exports['pma-voice']:setRadioVolume(currentVolume)

    SendNUIMessage({
        action = "AbuScript_Radio:UI",
        volume = currentVolume
    })
end

local function openRadioUI()
    SendNUIMessage({
        action = "AbuScript_Radio:UI",
        show = true,
        maxFrequency = Config.MaxFrequency,
        volume = currentVolume,
        frequency = currentFrequency
    })
    SetNuiFocus(true, true)
end

local function closeRadioUI()
    radioOpen = false
    SendNUIMessage({
        action = "AbuScript_Radio:UI",
        show = false
    })
    SetNuiFocus(false, false)
end

local function leaveChannel()
    exports['pma-voice']:setRadioChannel(0)
    currentFrequency = 0
    TriggerServerEvent("AbuScript_Radio:LeaveChannel")

    SendNUIMessage({
        action = "AbuScript_Radio:UI",
        frequency = 0,
        showMemberList = false,
        members = {}
    })
end

RegisterCommand("radio", function()
    if radioOpen then return end

    if Config.NeedItemToUseRadio then
        ESX.TriggerServerCallback("AbuScript_Radio:HasRadioItem", function(hasItem)
            if not hasItem then
                ESX.ShowNotification("يجب أن يكون لديك راديو في حقيبتك")
                return
            end
            radioOpen = true
            openRadioUI()
        end)
    else
        radioOpen = true
        openRadioUI()
    end
end, false)

RegisterKeyMapping("radio", "Open Radio", "keyboard", Config.radioKey)

RegisterNUICallback("close", function(data, cb)
    closeRadioUI()
    cb("ok")
end)

RegisterNUICallback("connect", function(data, cb)
    local freq = math.floor(tonumber(data.value) or 0)

    if freq < 0 or freq > Config.MaxFrequency then
        cb("error")
        return
    end

    if currentFrequency == freq then
        cb("error")
        return
    end

    ESX.TriggerServerCallback("AbuScript_Radio:JoinChannel", function(success, result)
        if not success then
            ESX.ShowNotification(result)
            cb("error")
            return
        end

        exports['pma-voice']:setRadioChannel(tonumber(result.channel))
        currentFrequency = tonumber(result.channel)

        SendNUIMessage({
            action = "AbuScript_Radio:UI",
            frequency = currentFrequency,
            frequencyLabel = result.frequencyLabel,
            members = result.members,
            showMemberList = true
        })

        cb("ok")
    end, freq)
end)

RegisterNUICallback("disconnect", function(data, cb)
    leaveChannel()
    cb("ok")
end)

RegisterNUICallback("setVolume", function(data, cb)
    setRadioVolume(data.value)
    cb("ok")
end)

RegisterNUICallback("valueUp", function(data, cb)
    setRadioVolume(currentVolume + Config.VolumeStep)
    cb("ok")
end)

RegisterNUICallback("valueDown", function(data, cb)
    setRadioVolume(currentVolume - Config.VolumeStep)
    cb("ok")
end)

CreateThread(function()
    setRadioVolume(Config.DefaultVolume)
end)

AddEventHandler("esx:onPlayerDeath", function()
    leaveChannel()
end)

RegisterNetEvent("AbuScript_Radio:UpdateMembers", function(data)
    if not data then return end
    SendNUIMessage({
        action = "AbuScript_Radio:UI",
        frequency = data.frequency,
        frequencyLabel = data.frequencyLabel,
        members = data.members,
        showMemberList = true
    })
end)

RegisterNetEvent("pma-voice:setTalkingOnRadio", function(plySource, enabled)
    if currentFrequency <= 0 then return end
    SendNUIMessage({
        action = "AbuScript_Radio:UI",
        talkingPlayerId = plySource,
        talking = enabled
    })
end)
