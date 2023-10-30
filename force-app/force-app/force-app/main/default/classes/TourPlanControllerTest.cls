@isTest
public class TourPlanControllerTest {
  @isTest
  public static void testGetCustomers() {
      BankAccount__c bank = new BankAccount__c(
          Name = 'Test Bank'
      );
      insert bank;
        Account acc = new Account(
            Name = 'Test Account',
            BankAccount__c = bank.Id,
            Billing_District__c = 'Coimbatore'
        );
        insert acc;
      
        // Create a Tour_Plan__c record
        Tour_Plan__c tourPlan = new Tour_Plan__c(
            
            Customer__c = acc.Id,
            Continent__c = 'Asia',
            Country__c = 'India',
            State__c = 'Tamil Nadu',
            District__c = 'Coimbatore'
        );
        insert tourPlan;

        // Call the method
        List<String> customerNames = TourPlanController.getCustomers(tourPlan.Id);

        // Verify the results
        System.assertEquals(1, customerNames.size(), 'Expected one customer name');
        system.assertEquals('TEST ACCOUNT', customerNames[0], 'Customer name should match');
    }

     @isTest
    public static void testGetTourPlanRecord(){
      BankAccount__c bank = new BankAccount__c(
          Name = 'Test Bank'
      );
      insert bank;
        Account acc = new Account(
            Name = 'Test Account',
            BankAccount__c = bank.Id,
            Billing_District__c = 'Coimbatore'
        );
        insert acc;
      
        // Create a Tour_Plan__c record
        Tour_Plan__c tourPlan = new Tour_Plan__c(
            
            Customer__c = acc.Id,
            Continent__c = 'Asia',
            Country__c = 'India',
            State__c = 'Tamil Nadu',
            District__c = 'Coimbatore'
        );
        insert tourPlan;

        // Call the method
        Tour_Plan__c tourPlanRec=TourPlanController.getTourPlan(tourPlan.Id);

        // Verify the results
        System.assertEquals('Coimbatore', tourPlanRec.District__c, 'Expected one customer name');
           
    }
    
    @isTest
    public static void testinsertPlannedCustomers(){
        BankAccount__c bank = new BankAccount__c(
          Name = 'Test Bank'
      );
        insert bank;
        Account acc = new Account(
            Name = 'Test Account',
            BankAccount__c = bank.Id,
            Billing_District__c = 'Coimbatore'
        );
        insert acc;
        
        acc = new Account(
            Name = 'Test Account 1',
            BankAccount__c = bank.Id,
            Billing_District__c = 'Coimbatore'
        );
        insert acc;

        
        
        // Create a Tour_Plan__c record
        List<String> accountNames = new List<String>{'Test Account', 'Test Account 1'};
        Tour_Plan__c tourPlan = new Tour_Plan__c(
           
            Customer__c = acc.Id,
            Continent__c = 'Asia',
            Country__c = 'India',
            State__c = 'Tamil Nadu',
            District__c = 'Coimbatore'
        );        
        
        String recordId = tourPlan.Id;
        insert tourPlan;
        
        // Call the method
       TourPlanController.insertPlannedCustomers(accountNames,tourPlan.Id);
       
        // Verify the expected results
        List<Customers_Planned__c> cpList = [SELECT Id, Customer__c, Place__c, Tour_Plan__c FROM Customers_Planned__c];
        System.assertEquals(2, cpList.size(), 'Incorrect number of Customers_Planned__c records inserted');

        for (Customers_Planned__c cp : cpList) {
            System.debug('Customer__c: ' + cp.Customer__c);
            System.assertEquals('Coimbatore', cp.Place__c, 'Incorrect Place__c on Customers_Planned__c');
            //System.assert(accountNames.contains(cp.Customer__c), 'Invalid Customer__c on Customers_Planned__c');
        }
  
        
    }
    
    
    @isTest
    public static void testSearchAllCustomers() {
         BankAccount__c bank = new BankAccount__c(
          Name = 'Test Bank'
      );
      insert bank;
        Account acc = new Account(
            Name = 'Test Account',
            BankAccount__c = bank.Id,
            Billing_District__c = 'Coimbatore'
        );
        insert acc;
        
         acc = new Account(
            Name = 'Test Account 1',
            BankAccount__c = bank.Id,
            Billing_District__c = 'Coimbatore'
        );
        insert acc;
      
        // Create a Tour_Plan__c record
        Tour_Plan__c tourPlan = new Tour_Plan__c(
            
            Customer__c = acc.Id,
            Continent__c = 'Asia',
            Country__c = 'India',
            State__c = 'Tamil Nadu',
            District__c = 'Coimbatore'
        );
        insert tourPlan;
        String recordId = tourPlan.Id;
        
        
        Test.startTest();
        // Call the method
        List<String> result = TourPlanController.searchAllCustomers('Test', recordId);
        Test.stopTest();

        // Verify the expected results
        System.assertEquals(2, result.size(), 'Incorrect number of matching objects');

        Set<String> expectedCustomerNames = new Set<String>{'TEST ACCOUNT', 'TEST ACCOUNT 1'};
        Set<String> actualCustomerNames = new Set<String>(result);

        System.assertEquals(expectedCustomerNames, actualCustomerNames, 'Mismatched customer names');
    }


}