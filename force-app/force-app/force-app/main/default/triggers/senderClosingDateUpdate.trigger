trigger senderClosingDateUpdate on Service_Request__c (before update) {
    for (Service_Request__c record : Trigger.new) {
        Service_Request__c oldRecord = Trigger.oldMap.get(record.Id);
        if (record.Status__c == 'Closed' && oldRecord.Status__c  != 'Closed'){
            record.Closing_date__c = Date.today();
        }
    }
}