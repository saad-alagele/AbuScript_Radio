Config = {}


Config.radioKey = "F4"
Config.MaxFrequency = 1000
Config.DefaultVolume = 50
Config.VolumeStep = 5
Config.NeedItemToUseRadio = false
Config.ItemName = "radio"


Config.vaildFrequency = {
    ['admin'] = {
        label = " موجة الرقابة و التفتيش ",
        Frequencys = {
            {"1","2","3"}
        },
        jobCanJoin ={
            'admin',
            'police',
            'agent',
            'ambulance',
            'mechanic',
        }
    },
    ['plice'] = {
        label = " موجة الأمن العام ",
        Frequencys = {
            {"4","5","6"}
        },
        jobCanJoin ={
            'admin',
            'police',
            'agent',
            'ambulance',
            'mechanic',
        }
    }
}

Config.UnprotectedLabel = "موجة غير محمية"