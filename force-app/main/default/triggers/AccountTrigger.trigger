trigger AccountTrigger on Account (after update) {

    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            ActivityHistoryUtils.trackHistory(Trigger.oldMap, Trigger.newMap);
        }
    }
}