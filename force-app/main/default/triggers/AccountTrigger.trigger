trigger AccountTrigger on Account (before update) {

    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            ActivityHistoryUtils.trackHistory(Trigger.oldMap, Trigger.newMap);
        }
    }
}