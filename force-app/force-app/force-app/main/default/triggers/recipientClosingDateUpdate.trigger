trigger recipientClosingDateUpdate on Service_Request__c (before update) {
   for (Service_Request__c record : Trigger.new){
        Service_Request__c oldRecord = Trigger.oldMap.get(record.Id);
        if (record.Recipient_Status__c  =='Closed' && oldRecord.Recipient_Status__c !='Closed'){
            record.Recipient_Closing_Date__c = Date.today();
        }
    }
}