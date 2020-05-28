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
        
        Integer position = 1;                                                
        List<ResponseWrapper> responseWrapper = new List<ResponseWrapper>();
        for (ActivityHistory__c h : history) {
            ResponseWrapper rwTemp = new ResponseWrapper(
                position++, 
                h.FieldName__c,
                String.valueOf(h.OldValue__c), 
                String.valueOf(h.NewValue__c), 
                h.Who__c,
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
