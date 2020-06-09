public with sharing class HistoryController {

    @AuraEnabled
    public static String getFields(String recordId) {
        Schema.SObjectType sobjectType = ((Id) recordId).getSObjectType();
        String sObjectName = sobjectType.getDescribe().getName();

        ActivityHistory_Setting__mdt mtdRecord = [SELECT FieldSet_API_Name__c 
                                                  FROM ActivityHistory_Setting__mdt  
                                                  WHERE Label = :sObjectName];

        String fieldSetName = mtdRecord.FieldSet_API_Name__c;
        List<Schema.FieldSetMember> fieldSetMemberList = sObjectType.getDescribe().fieldsets.getMap().get(fieldSetName).getFields();

        List<OptionsWrapper> optionsWrapperList = new List<OptionsWrapper>();
        for(Schema.FieldSetMember fsm : fieldSetMemberList) {
            optionsWrapperList.add(new OptionsWrapper(fsm.fieldpath, fsm.fieldpath));
        }

        return JSON.serialize(optionsWrapperList);
    }


    @AuraEnabled
    public static String getHistoryForRecord(String recordId, String fieldName) {
        List<ActivityHistory__c> history;
        if (fieldName != '') {
            history = (List<ActivityHistory__c>) Database.query(
                'SELECT FieldName__c, ' +
                        'OldValue__c, ' +
                        'NewValue__c, ' +
                        'Who__c, ' +
                        'CreatedDate ' + 
                'FROM ActivityHistory__c ' + 
                'WHERE SObjectId__c = :recordId AND ' +  
                       'FieldName__c = :fieldName ' +
                'ORDER BY CreatedDate DESC '
            );
        } else {
            history = [SELECT FieldName__c,
                                OldValue__c,
                                NewValue__c,
                                Who__c,
                                CreatedDate
                            FROM ActivityHistory__c
                            WHERE SObjectId__c = :recordId
                            ORDER BY CreatedDate DESC];
        }
        Set<Id> usersIds = new Set<Id>();
        for (ActivityHistory__c ah : history) {
            usersIds.add(ah.Who__c);
        }

        Map<Id, User> usersMap = new Map<Id, User>([SELECT Name FROM User WHERE Id IN :usersIds]);

        Integer position = 1;
        List<ResponseWrapper> responseWrapper = new List<ResponseWrapper>();
        for (ActivityHistory__c h : history) {

            ResponseWrapper rwTemp = new ResponseWrapper(
                position++, 
                h.FieldName__c,
                String.valueOf(h.OldValue__c), 
                String.valueOf(h.NewValue__c), 
                usersMap.get(h.Who__c).Name,
                String.valueOf(h.CreatedDate)
            );

            responseWrapper.add(rwTemp);
        }
        
        return JSON.serialize(responseWrapper);
    }


    public class OptionsWrapper {
        public String label;
        public String value;

        public OptionsWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }


    public class ResponseWrapper {
        public Integer position;
        public String fieldName;
        public String oldValue;
        public String newValue;
        public String who;
        public String createdDate;

        public ResponseWrapper(Integer position, String fieldName, String oldValue, String newValue, String who, String createdDate) {
            this.position = position;
            this.fieldName = fieldName;
            this.oldValue = oldValue;
            this.newValue = newValue;
            this.who = who;
            this.createdDate = createdDate;
        }
    }
}
