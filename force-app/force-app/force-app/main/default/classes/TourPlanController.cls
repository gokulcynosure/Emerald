public class TourPlanController {
    @AuraEnabled(cacheable=true)
    public static list<String> getCustomers(String recordId){
        system.debug('recordId'+recordId);
        List<Tour_Plan__c> tourPlan = [SELECT Id, Name, Customer__c, District__c from Tour_Plan__c WHERE Id =: recordId];
       List<Account> query = [SELECT Id, Name from Account WHERE Billing_District__c =: tourPlan[0].District__c];
        List<String> customerNames = new List<String>();
        for (Account acc : query){
            customerNames.add(acc.name);
        }
        system.debug('customerNames'+customerNames);
        return customerNames;    
    }
     @AuraEnabled(cacheable=true)
    public static Tour_Plan__c getTourPlan(String recordId){
        List<Tour_Plan__c> tourPlan = [SELECT Name, District__c from Tour_Plan__c WHERE Id =: recordId];
       
        return tourPlan[0];    
    }
    @AuraEnabled
    public static Integer insertPlannedCustomers(List<String> accountNames,String recordId) {
          SYSTEM.DEBUG('recordId'+recordId);
         List<Tour_Plan__c> tourPlan = [SELECT Id, Name,Customer__c,District__c from Tour_Plan__c WHERE Id =: recordId];
        SYSTEM.DEBUG('recordId'+tourPlan);
        List<Account> queriedAccounts = [SELECT Id, Name, Billing_District__c FROM Account WHERE Name IN :accountNames AND Billing_District__c = :tourPlan[0].District__c];
        List<Customers_Planned__c> cpList = new List<Customers_Planned__c>();
        for(Account acc : queriedAccounts){
            Customers_Planned__c cp = new Customers_Planned__c();
            cp.Customer__c = acc.Id;
            cp.Place__c = tourPlan[0].District__c;
            cp.Tour_Plan__c = recordId;
            cpList.add(cp);
        }
        Insert cpList;
        return cpList.size();
        
        
    }
    @AuraEnabled(cacheable=false)
     public static List<String> searchAllCustomers(String searchString,String recordId){
         List<Tour_Plan__c> tourPlan = [SELECT Id, Name, Customer__c, District__c from Tour_Plan__c WHERE Id =: recordId];
       List<Account> query = [SELECT Id, Name from Account WHERE Billing_District__c =: tourPlan[0].District__c];
        List<String> customerNames = new List<String>();
        for (Account acc : query){
            customerNames.add(acc.name);
        }
        List<String> availableObjects = customerNames;
        List<String> matchingObjects = new List<String>();
        String searchStringLower = searchString.toLowerCase();
        
        for (String objectName : availableObjects) {
            if (objectName.toLowerCase().startsWith(searchStringLower)) {
                matchingObjects.add(objectName);
            }
        }
        
        return matchingObjects;
    }
}