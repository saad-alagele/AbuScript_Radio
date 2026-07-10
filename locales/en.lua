-- English Locale
Locale = {
    ['radio_title']         = 'Radio',
    ['channel_label']       = 'Channel',
    ['join_channel']        = 'Join Channel',
    ['leave_channel']       = 'Leave Channel',
    ['callers_label']       = 'Callers on Channel',
    ['no_callers']          = 'No one on this channel',
    ['talking']             = 'Talking...',
    ['toggle_prop']         = 'Hold Radio',
    ['push_to_talk']        = 'Push to Talk',
    ['channel_joined']      = 'Joined channel %s',
    ['channel_left']        = 'Left the channel',
    ['invalid_channel']     = 'Invalid channel number',
    ['close']               = 'Close',
}

function _L(str, ...)
    if Locale[str] then
        return string.format(Locale[str], ...)
    end
    return str
end
