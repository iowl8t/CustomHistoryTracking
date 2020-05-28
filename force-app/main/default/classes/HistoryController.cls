public with sharing class HistoryController {

    @AuraEnabled
    public static String getHistoryForRecord(String recordId) {
        List<ActivityHistory__c> history = [SELECT FieldName__c,
                                                   OldValue__c,
                                                   NewValue__c,
                                                   Who__c,
                                                   CreatedDate
                                                FROM ActivityHistory__c
                                                WHERE SObjectId__c = :recordId
                                                ORDER BY CreatedDate DESC];
        
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
