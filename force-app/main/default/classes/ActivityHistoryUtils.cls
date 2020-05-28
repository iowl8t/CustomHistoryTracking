public with sharing class ActivityHistoryUtils {
    
    public static void trackHistory(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {

        // Get SObject's Name and sObjectType of 
        String sobjectName = String.valueOf(newMap.values()[0].getSObjectType());
        Schema.SObjectType sObjectType = newMap.values()[0].getSObjectType();

        // Get Related Metadata
        ActivityHistory_Setting__mdt mtdRecord = [SELECT FieldSet_API_Name__c 
                                                    FROM ActivityHistory_Setting__mdt  
                                                    WHERE Label = :sobjectName ];
        //Get FieldSet API Name
        String fieldSetName = mtdRecord.FieldSet_API_Name__c;

        // Get FieldSet fields
        List<Schema.FieldSetMember> fieldSetMemberList = sObjectType.getDescribe().fieldsets.getMap().get(fieldSetName).getFields();

        // Put FieldSet fields in Set
        Set<String> fieldsNamesToSave = new Set<String>();
        for(Schema.FieldSetMember fsm : fieldSetMemberList) {
            fieldsNamesToSave.add(fsm.getFieldPath());
        }

        // Create ActivityHistory records
        List<ActivityHistory__c> newActivityHistoryList = new List<ActivityHistory__c>();
        
        for(String recordId : newMap.keySet()) {
            for(String fieldName : fieldsNamesToSave) {
                if((newMap.get(recordId).get(fieldName) != oldMap.get(recordId).get(fieldName))) {
                    newActivityHistoryList.add(new ActivityHistory__c(
                        SObjectId__c = String.valueOf(recordId),
                        SObjectName__c = sobjectName,
                        FieldName__c = fieldName,
                        OldValue__c = String.valueOf(oldMap.get(recordId).get(fieldName)),
                        NewValue__c = String.valueOf(newMap.get(recordId).get(fieldName)),
                        Who__c = UserInfo.getUserId()
                    ));
                }
            }
        }
        try {
            insert newActivityHistoryList;
        } catch (DmlException e) {
            System.debug('ErrorMessage: ' + e.getMessage());
        }
    }
}