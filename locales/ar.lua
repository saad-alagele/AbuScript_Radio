-- Arabic Locale (اللغة العربية)
Locale = {
    ['radio_title']         = 'الراديو',
    ['channel_label']       = 'القناة',
    ['join_channel']        = 'الانضمام للقناة',
    ['leave_channel']       = 'مغادرة القناة',
    ['callers_label']       = 'المتصلون في القناة',
    ['no_callers']          = 'لا يوجد أحد في هذه القناة',
    ['talking']             = 'يتكلم...',
    ['toggle_prop']         = 'إمساك الراديو',
    ['push_to_talk']        = 'اضغط للتحدث',
    ['channel_joined']      = 'انضممت للقناة %s',
    ['channel_left']        = 'غادرت القناة',
    ['invalid_channel']     = 'رقم القناة غير صحيح',
    ['close']               = 'إغلاق',
}

function _L(str, ...)
    if Locale[str] then
        return string.format(Locale[str], ...)
    end
    return str
end
