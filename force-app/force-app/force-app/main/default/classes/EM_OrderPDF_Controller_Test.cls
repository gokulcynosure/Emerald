@IsTest
public class EM_OrderPDF_Controller_Test {
    
    @isTest
    static Order orderCreation(){
        String accName = 'Test Account';
        String conFirstName = 'Test Contact FirstName';
        String conLastName = 'Test Contact LastName';
        String email = 'Test@gmail.com';
        String oppName = 'Test Opportunity';
        Date oppCloseDate = System.Today() + 5;
        String oppStageName = 'Prospecting';
        String quoteName = 'Test Quote 1';
        
        BankAccount__c bank = EM_UtilOrder.buildBankAccount('Test Bank');
        insert bank;
        
        Account acc = EM_UtilOrder.buildAccountWithBankAccount(accName, bank.Id);
        insert acc;
        
        Contact con = EM_UtilOrder.buildContact(conFirstName,conLastName,email,acc.Id);
        Insert con;
        
        Opportunity opp = EM_UtilOrder.buildOpportunity(oppName,oppCloseDate,acc.Id,oppStageName);
        insert opp;
        
        Quote qu = EM_UtilOrder.buildQuotewithAccount(quoteName,opp.Id,acc.Id, bank.Id, con.Id);
        insert qu;
        
        Order testOrder = EM_UtilOrder.buildOrder(acc.Id,opp.Id,qu.Id,system.Today(), 'Draft');
		insert testOrder;
        
        return testOrder;
    }
    
    @isTest
    static void testSavePDF() {
        
        Order orderDetail = orderCreation();
        Id orderId = orderDetail.Id;

        Test.startTest();
        ContentDocumentLink result = EM_OrderPDF_Controller.savePDF(orderId);
        Test.stopTest();
        
        List<ContentDocumentLink> expectedLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :orderId];
		
        System.assertEquals(expectedLink[0].Id, result.Id, 'ContentDocumentLink ID should match expected ID');
        
    }
    
    // @isTest
    // static void getLatestDocumentForSendingAnEmailTest(){
    //     Order orderDetail = orderCreation();
    //     Id orderId = orderDetail.Id;
        
    //     ContentDocumentLink result = EM_OrderPDF_Controller.savePDF(orderId);
    //     EmailTemplate emailTemp = EM_UtilOrder.queryEmailTemplate();
        
    //     EM_OrderPDF_Controller.EmailDetails em = new EM_OrderPDF_Controller.EmailDetails();
    //     em.contactName = orderDetail.Contact__r.Name;
    //     em.contactEmail = orderDetail.Contact__r.Email;
    //     system.debug('em.contactEmail : ' + em.contactEmail);
    //     em.contentDocumentId = result.ContentDocumentId;
    //     em.subject = emailTemp.Subject;
    //     em.body = emailTemp.Body;
        
    //     Test.startTest();
    //     EM_OrderPDF_Controller.EmailDetails eD = EM_OrderPDF_Controller.getLatestDocumentForSendingAnEmail(orderId);
    //     Test.stopTest();
        
    //     System.assertEquals(eD.contentDocumentId, result.ContentDocumentId, 'ContentDocumentId will be same');
    // }
    
    @isTest
    static void sendingAnEmailTest(){
    	Order orderDetail = orderCreation();
        Id orderId = orderDetail.Id;
        
        ContentDocumentLink result = EM_OrderPDF_Controller.savePDF(orderId);
        EmailTemplate emailTemp = EM_UtilOrder.queryEmailTemplate();
        
        EM_OrderPDF_Controller.EmailDetails em = new EM_OrderPDF_Controller.EmailDetails();
        em.contactName = orderDetail.Contact__r.Name;
        em.contactEmail = orderDetail.Contact__r.Email;
        em.contentDocumentId = result.ContentDocumentId;
        em.subject = emailTemp.Subject;
        em.body = emailTemp.Body;
        
        Test.startTest();
        EM_OrderPDF_Controller.SendingAnEmail(orderId);
        Test.stopTest();
    }
    
    @isTest
    static void saveCRFPDFTest(){
        Order orderDetail = orderCreation();
        Id orderId = orderDetail.Id;

        Test.startTest();
        ContentDocumentLink result = EM_OrderPDF_Controller.saveCRFPDF(orderId);
        Test.stopTest();
        
        List<ContentDocumentLink> expectedLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :orderId];
		
        System.assertEquals(expectedLink[0].Id, result.Id, 'ContentDocumentLink ID should match expected ID');
    }

}