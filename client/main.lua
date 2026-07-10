-- ============================================================
--  AbuScript_Radio – Client Main
--  Features:
--    • Toggle radio UI (F2 / command)
--    • Attach / detach radio prop to player hand
--    • Sync channel join/leave with server
--    • Receive and display caller list from server
-- ============================================================

local ESX = exports['es_extended']:getSharedObject()

-- ── Config ──────────────────────────────────────────────────
local Config = {
    PropModel       = 'prop_cs_hand_radio',    -- radio prop hash
    AnimDict        = 'anim@scripted@human@mp_m_shopkeep_01@',
    AnimName        = 'idle_a',
    PropBone        = 28422,                   -- right hand bone
    PropOffset      = vector3(0.12, 0.0, -0.02),
    PropRotation    = vector3(5.0, 0.0, -90.0),
    ToggleKey       = 0x70,                    -- F2  (VK keycode)
    TalkKey         = 'Z',                     -- Push-to-talk UI key (display only)
    MaxChannels     = 100,
    DefaultChannel  = 1,
}

-- ── State ────────────────────────────────────────────────────
local isRadioOpen   = false
local currentChannel= Config.DefaultChannel
local radioProp     = nil
local callerList    = {}
local isTalking     = false

-- ── Helpers ──────────────────────────────────────────────────
local function loadModel(model)
    local hash = GetHashKey(model)
    if not IsModelValid(hash) then return end
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    return hash
end

local function spawnRadioProp()
    if radioProp and DoesEntityExist(radioProp) then return end

    local hash = loadModel(Config.PropModel)
    if not hash then return end

    local ped    = PlayerPedId()
    radioProp    = CreateObjectNoOffset(hash, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(
        radioProp, ped,
        GetPedBoneIndex(ped, Config.PropBone),
        Config.PropOffset.x, Config.PropOffset.y, Config.PropOffset.z,
        Config.PropRotation.x, Config.PropRotation.y, Config.PropRotation.z,
        true, true, false, true, 1, true
    )
    SetModelAsNoLongerNeeded(hash)
end

local function removeRadioProp()
    if radioProp and DoesEntityExist(radioProp) then
        DetachEntity(radioProp, true, true)
        DeleteObject(radioProp)
        radioProp = nil
    end
end

local function openRadioUI()
    isRadioOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action  = 'openRadio',
        channel = currentChannel,
        callers = callerList,
        config  = {
            maxChannels = Config.MaxChannels,
            talkKey     = Config.TalkKey,
        },
    })
end

local function closeRadioUI()
    isRadioOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeRadio' })
end

local function toggleRadio()
    if isRadioOpen then
        closeRadioUI()
    else
        openRadioUI()
    end
end

-- ── NUI Callbacks ────────────────────────────────────────────
RegisterNUICallback('closeRadio', function(_, cb)
    closeRadioUI()
    cb('ok')
end)

RegisterNUICallback('joinChannel', function(data, cb)
    local channel = tonumber(data.channel)
    if not channel or channel < 1 or channel > Config.MaxChannels then
        cb({ success = false, reason = 'Invalid channel' })
        return
    end

    TriggerServerEvent('AbuScript_Radio:joinChannel', channel)
    currentChannel = channel
    cb({ success = true })
end)

RegisterNUICallback('leaveChannel', function(_, cb)
    TriggerServerEvent('AbuScript_Radio:leaveChannel')
    currentChannel = Config.DefaultChannel
    cb({ success = true })
end)

RegisterNUICallback('startTalking', function(_, cb)
    isTalking = true
    TriggerServerEvent('AbuScript_Radio:startTalking', currentChannel)
    cb('ok')
end)

RegisterNUICallback('stopTalking', function(_, cb)
    isTalking = false
    TriggerServerEvent('AbuScript_Radio:stopTalking', currentChannel)
    cb('ok')
end)

RegisterNUICallback('toggleProp', function(data, cb)
    if data.enabled then
        spawnRadioProp()
    else
        removeRadioProp()
    end
    cb('ok')
end)

-- ── Server Events ────────────────────────────────────────────
RegisterNetEvent('AbuScript_Radio:updateCallerList')
AddEventHandler('AbuScript_Radio:updateCallerList', function(list)
    callerList = list
    SendNUIMessage({
        action  = 'updateCallerList',
        callers = callerList,
    })
end)

RegisterNetEvent('AbuScript_Radio:channelJoined')
AddEventHandler('AbuScript_Radio:channelJoined', function(channel, list)
    currentChannel = channel
    callerList     = list
    SendNUIMessage({
        action  = 'channelJoined',
        channel = channel,
        callers = list,
    })
end)

RegisterNetEvent('AbuScript_Radio:notification')
AddEventHandler('AbuScript_Radio:notification', function(msg, msgType)
    SendNUIMessage({
        action  = 'notification',
        message = msg,
        type    = msgType or 'info',
    })
end)

-- ── Key Thread ───────────────────────────────────────────────
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, Config.ToggleKey) then
            toggleRadio()
        end
    end
end)

-- ── Command ──────────────────────────────────────────────────
RegisterCommand('radio', function()
    toggleRadio()
end, false)

TriggerEvent('chat:addSuggestion', '/radio', 'Toggle the radio interface')

-- ── Cleanup on resource stop ─────────────────────────────────
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        removeRadioProp()
        if isRadioOpen then closeRadioUI() end
    end
end)
