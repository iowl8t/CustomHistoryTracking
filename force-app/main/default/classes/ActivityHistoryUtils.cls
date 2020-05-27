public with sharing class ActivityHistoryUtils {
    
    public static void trackHistory(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {

        // Get Name of SObject
        String sobjectName = String.valueOf(newMap.values()[0].getSObjectType());

        //Get Related Metadata
        ActivityHistory_Setting__mdt mtdRecord = [SELECT FieldSet_API_Name__c 
                                                  FROM ActivityHistory_Setting__mdt
                                                WHERE Label = :sobjectName];
        //Get FieldSet API Name
        String fieldSetName = mtdRecord.FieldSet_API_Name__c;

        // Get FieldSet fields
        Schema.DescribeSObjectResult DescribeSObjectResultObj = Schema.getGlobalDescribe().get(sobjectName).getDescribe();
        List<Schema.FieldSetMember> fieldSetMemberList =  DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName).getFields();

        //Put fieldSet Fields in List
        Set<String> fieldsNamesToSave = new Set<String>();
        for(Schema.FieldSetMember fsm : fieldSetMemberList) {
        fieldsNamesToSave.add(fsm.getFieldPath());
        }

        Map<String, SObjectField> fieldMap = newMap.values()[0].getSObjectType().getDescribe().fields.getMap();

        // Create ActivityHistory records
        List<ActivityHistory__c> newActivityHistoryList = new List<ActivityHistory__c>();
        for(String keyId : newMap.keySet()) {
            for(Schema.SObjectField keyNameSchema : fieldMap.values()) {
                String keyName = String.valueOf(keyNameSchema);
                if(fieldsNamesToSave.contains(keyName)) {
                    if((newMap.get(keyId).get(keyName) != oldMap.get(keyId).get(keyName))) {
                        newActivityHistoryList.add(new ActivityHistory__c(
                            SObjectId__c = String.valueOf(keyId),
                            SObjectName__c = sobjectName,
                            FieldName__c = keyName,
                            OldValue__c = String.valueOf(oldMap.get(keyId).get(keyName)),
                            NewValue__c = String.valueOf(newMap.get(keyId).get(keyName)),
                            Who__c = UserInfo.getUserId()
                        ));
                    }
                }
            }
        }

        insert newActivityHistoryList;
    }

}
