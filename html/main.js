console.log("AbuScript-Radio V-1");

let $ = (id) => document.querySelector(id)

let radioShell = $("#radio-shell")
let radioContainer = $("#Radio-container")
let memberListContainer = $("#memberList-container")
let memberListItems = $(".memberList-item-container")
let memberCountEl = $(".memberCount")
let frequencyValueEl = $(".frequencyValue")
let frequencyLabelEl = $(".frequencyLabel")
let input_frequency = $("#input-frequency")
let voiceLevelEl = $(".voice-level")

let maxFrequency = 100
let currentVolume = 50
let resourceName = window.GetParentResourceName ? GetParentResourceName() : "AbuScript_Radio"

function clampFreq() {
    let val = parseInt(input_frequency.value)
    if (isNaN(val) || val < 0) val = 0
    if (val > maxFrequency) val = maxFrequency
    input_frequency.value = val
}

function updateVolume(vol) {
    currentVolume = vol
    if (currentVolume < 0) currentVolume = 0
    if (currentVolume > 100) currentVolume = 100
    voiceLevelEl.textContent = currentVolume + "%"
}

function setFreqLabel(label) {
    label = label || ""
    frequencyLabelEl.textContent = label

    if (label.indexOf("غير محمية") != -1) {
        frequencyLabelEl.classList.add("is-unprotected")
        frequencyLabelEl.classList.remove("is-protected")
    } else if (label.length > 0) {
        frequencyLabelEl.classList.add("is-protected")
        frequencyLabelEl.classList.remove("is-unprotected")
    } else {
        frequencyLabelEl.classList.remove("is-unprotected", "is-protected")
    }
}

function updateMembers(members) {
    memberListItems.innerHTML = ""
    if (!members) members = []

    memberCountEl.textContent = members.length

    for (let i = 0; i < members.length; i++) {
        let m = members[i]
        let card = document.createElement("div")
        card.className = "memberCard"
        card.setAttribute("data-member-id", m.id)

        card.innerHTML = `
            <div class="memberInfo">
                <span class="memberName">${m.name || "Unknown"}</span>
                <span class="memberIdRow">
                    <span class="memberIdLabel">ID :</span>
                    <span class="memberIdValue">${m.id}</span>
                </span>
            </div>
            <i class="fa-solid fa-microphone-lines"></i>
        `
        memberListItems.appendChild(card)
    }
}

function setMemberTalking(playerId, talking) {
    let card = memberListItems.querySelector('[data-member-id="' + playerId + '"]')
    if (!card) return
    if (talking) card.classList.add("talking")
    else card.classList.remove("talking")
}

function showMemberList(show) {
    if (show) {
        memberListContainer.classList.remove("hidden")
    } else {
        memberListContainer.classList.add("hidden")
        updateMembers([])
        frequencyValueEl.textContent = "0"
        setFreqLabel("")
    }
}

function openRadio() {
    radioShell.classList.remove("hidden")
    radioContainer.classList.remove("is-closing")
    radioContainer.classList.add("is-open")
}

function closeRadio() {
    if (radioShell.classList.contains("hidden")) return
    if (radioContainer.classList.contains("is-closing")) return
    radioContainer.classList.remove("is-open")
    radioContainer.classList.add("is-closing")
}

function sendNui(event, data) {
    fetch("https://" + resourceName + "/" + event, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data || {})
    })
}

input_frequency.addEventListener("input", function () {
    let maxDigits = String(maxFrequency).length
    if (input_frequency.value.length > maxDigits) {
        input_frequency.value = input_frequency.value.slice(0, maxDigits)
    }
    clampFreq()
})

window.addEventListener("message", function (event) {
    let msg = event.data
    if (!msg || msg.action != "AbuScript_Radio:UI") return

    if (msg.maxFrequency != null) {
        maxFrequency = parseInt(msg.maxFrequency) || 100
        input_frequency.min = 0
        input_frequency.max = maxFrequency
        clampFreq()
    }

    if (msg.volume != null) updateVolume(msg.volume)

    if (msg.frequency != null) {
        input_frequency.value = msg.frequency
        clampFreq()
    }

    if (msg.show === true) openRadio()
    else if (msg.show === false) closeRadio()

    if (msg.showMemberList != null) showMemberList(msg.showMemberList)

    if (msg.members != null) updateMembers(msg.members)

    if (msg.frequencyLabel != null) setFreqLabel(msg.frequencyLabel)

    if (msg.frequency != null && msg.showMemberList !== false) {
        frequencyValueEl.textContent = msg.frequency
        if (msg.frequencyLabel != null) setFreqLabel(msg.frequencyLabel)
    }

    if (msg.talkingPlayerId != null) {
        setMemberTalking(msg.talkingPlayerId, msg.talking)
    }
})

radioContainer.addEventListener("animationend", function (e) {
    if (e.animationName != "radioSlideOut") return
    radioContainer.classList.remove("is-open", "is-closing")
    radioShell.classList.add("hidden")
    sendNui("close")
})

radioShell.classList.add("hidden")
showMemberList(false)

document.addEventListener("mousedown", function (e) {
    if (radioShell.classList.contains("hidden")) return
    if (!radioContainer.classList.contains("is-open")) return
    if (radioContainer.classList.contains("is-closing")) return
    if (radioShell.contains(e.target)) return
    closeRadio()
})

document.addEventListener("keydown", function (e) {
    if (e.key == "Escape") closeRadio()
})

$("#connect-button").addEventListener("click", function () {
    sendNui("connect", { value: parseInt(input_frequency.value) || 0 })
})

$("#disconnect-button").addEventListener("click", function () {
    sendNui("disconnect")
})

$(".voice_mute").addEventListener("click", function () {
    sendNui("setVolume", { value: 0 })
})

$(".voice_max").addEventListener("click", function () {
    sendNui("setVolume", { value: 100 })
})

$("#valueUp-button").addEventListener("click", function () {
    sendNui("valueUp")
})

$("#valueDown-button").addEventListener("click", function () {
    sendNui("valueDown")
})
