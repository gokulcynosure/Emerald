@IsTest
private class EM_QuotePDF_Controller_Test {
    
    @isTest
    static Quote quoteCreation(){
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
        
                
        return qu;
    }
    
    @IsTest
    static void testSavePDF(){
        String accName = 'Test Account';
        String conFirstName = 'Test Contact FirstName';
        String conLastName = 'Test Contact LastName';
        String email = 'Test@gmail.com';
        String oppName = 'Test Opportunity';
        Date oppCloseDate = System.Today() + 5;
        String oppStageName = 'Prospecting';
        String quoteName = 'Test Quote';
        
        BankAccount__c bank = EM_UtilQuote.buildBankAccount('Test Bank');
        insert bank;
        
        Account acc = EM_UtilQuote.buildAccountWithBankAccount(accName,bank.Id);
        insert acc;
        
        Contact con = EM_UtilQuote.buildContact(conFirstName,conLastName,email,acc.Id);
        Insert con;
        
        Opportunity opp = EM_UtilQuote.buildOpportunity(oppName,oppCloseDate,acc.Id,oppStageName);
        insert opp;
        
        Quote qu = EM_UtilQuote.buildQuoteWithAccount(quoteName,opp.Id,acc.Id);
        qu.ContactId = con.Id;
        system.debug('qu'+qu);
        insert qu;
        
        
        Test.startTest();
        QuoteDocument quoteDoc = EM_QuotePDF_Controller.savePDF(qu.Id);
        Test.stopTest();
        List<QuoteDocument> doc = [Select id,quoteId From QuoteDocument where quoteId =: qu.Id Order By CreatedDate Desc ];
        Assert.areEqual(quoteDoc.Id,doc.get(0).Id);
        
    }
    
    @IsTest
    static void testSavePDFInsteadOfQuoteIdWillPassOpportunityId(){
        String accName = 'Test Account';
        String conFirstName = 'Test Contact FirstName';
        String conLastName = 'Test Contact LastName';
        String email = 'Test@gmail.com';
        String oppName = 'Test Opportunity';
        Date oppCloseDate = System.Today() + 5;
        String oppStageName = 'Prospecting';
        
        BankAccount__c bank = EM_UtilQuote.buildBankAccount('Test Bank');
        insert bank;
        
        Account acc = EM_UtilQuote.buildAccountWithBankAccount(accName,bank.Id);
        insert acc;
        
        Contact con = EM_UtilQuote.buildContact(conFirstName,conLastName,email,acc.Id);
        Insert con;
        
        Opportunity opp = EM_UtilQuote.buildOpportunity(oppName,oppCloseDate,acc.Id,oppStageName);
        insert opp;
        
        Test.startTest();
        QuoteDocument quoteDoc = EM_QuotePDF_Controller.savePDF(opp.Id);
        Test.stopTest();
        
        List<QuoteDocument> doc = [Select id,quoteId From QuoteDocument  Order By CreatedDate Desc ];
        Assert.areEqual(0,doc.size());
        Assert.areEqual(null,quoteDoc);
        
    }
    
    @IsTest
    static void toPreventMixDmlOperationInsertEmailTemplate(){
        String emailTemplateName = 'QuoteQuotationTemplate';
        String emailBody = 'Dear {!Quote.Contact}, Test Body';
        String emailSubject = 'Test Subject {!Quote.QuoteNumber}';
        String emailTemplateDevName = EM_Constants.EmailTemplate;
        Id FolderId = UserInfo.getUserId();
        String TemplateType = 'text';
        
        EmailTemplate emailTemp = EM_UtilQuote.buildEmailTemplate(emailTemplateName,emailTemplateDevName,emailBody,emailSubject,FolderId, TemplateType);
        insert emailTemp;
        
    }
    @IsTest
    static void testGetLatestDocumentForSendingAnEmail(){
        String accName = 'Test Account';
        String conFirstName = 'Test Contact FirstName';
        String conLastName = 'Test Contact LastName';
        String email = 'test@gmail.com';
        String oppName = 'Test Opportunity';
        Date oppCloseDate = System.Today() + 5;
        String oppStageName = 'Prospecting';
        String quoteName = 'Test Quote';
        String contentVersionTitle = 'Test Content Version';
        String contentVersionPath = 'Test.pdf';
        Blob contentVersionVersionData = blob.valueOf('Test Pdf Quote');
        
        
        BankAccount__c bank = EM_UtilQuote.buildBankAccount('Test Bank');
        insert bank;
        
        Account acc = EM_UtilQuote.buildAccountWithBankAccount(accName,bank.Id);
        insert acc;
        
        Contact con = EM_UtilQuote.buildContact(conFirstName,conLastName,email,acc.Id);
        Insert con;
        
        Opportunity opp = EM_UtilQuote.buildOpportunity(oppName,oppCloseDate,acc.Id,oppStageName);
        insert opp;
        
        system.debug('con'+con.Id);
        Quote qu = EM_UtilQuote.buildQuoteWithAccount(quoteName,opp.Id,acc.Id);
        qu.ContactId = con.Id;
        system.debug('qu'+qu);
        insert qu;
        
        ContentVersion cv =  EM_UtilQuote.buildContentVersion(contentVersionTitle,contentVersionPath,contentVersionVersionData);
        insert cv;
        
        List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion where id =: cv.Id];
        
        ContentDocumentLink cdLink =  EM_UtilQuote.buildContentDocumentLink(qu.id,cvList[0].ContentDocumentId);
        insert cdLink;
        
        
        Test.startTest();
        EM_QuotePDF_Controller.EmailDetails em = EM_QuotePDF_Controller.getLatestDocumentForSendingAnEmail(qu.Id);
        Test.stopTest();
        
        Assert.areNotEqual(em,null);
        Assert.areEqual(con.Email,em.contactEmail);
      }
    
    @IsTest
    static void testGetLatestDocumentForSendingAnEmailWithOutContactEmail(){
        String accName = 'Test Account';
        String conFirstName = 'Test Contact FirstName';
        String conLastName = 'Test Contact LastName';
        String email = 'test@gmail.com';
        String oppName = 'Test Opportunity';
        Date oppCloseDate = System.Today() + 5;
        String oppStageName = 'Prospecting';
        String quoteName = 'Test Quote';
        String contentVersionTitle = 'Test Content Version';
        String contentVersionPath = 'Test.pdf';
        Blob contentVersionVersionData = blob.valueOf('Test Pdf Quote');
        
        
        BankAccount__c bank = EM_UtilQuote.buildBankAccount('Test Bank');
        insert bank;
        
        Account acc = EM_UtilQuote.buildAccountWithBankAccount(accName,bank.Id);
        insert acc;
        
        Contact con = EM_UtilQuote.buildContactWithOutEmail(conFirstName,conLastName,acc.Id);
        Insert con;
        
        Opportunity opp = EM_UtilQuote.buildOpportunity(oppName,oppCloseDate,acc.Id,oppStageName);
        insert opp;
        
        Quote qu = EM_UtilQuote.buildQuoteWithAccount(quoteName,opp.Id,acc.Id);
        qu.ContactId = con.Id;
        system.debug('qu'+qu);
        insert qu;
        
        ContentVersion cv =  EM_UtilQuote.buildContentVersion(contentVersionTitle,contentVersionPath,contentVersionVersionData);
        insert cv;
        
        List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion where id =: cv.Id];
        
        ContentDocumentLink cdLink =  EM_UtilQuote.buildContentDocumentLink(qu.id,cvList[0].ContentDocumentId);
        insert cdLink;
        
        
        Test.startTest();
        EM_QuotePDF_Controller.EmailDetails em = EM_QuotePDF_Controller.getLatestDocumentForSendingAnEmail(qu.Id);
        Test.stopTest();
        
        Assert.areEqual(em,null);
      }
    
    @isTest
    static void saveCRFPDFTest(){
        Quote qu = quoteCreation();
        Id quoteId = qu.Id;

        Test.startTest();
        ContentDocumentLink result = EM_QuotePDF_Controller.saveCRFPDF(quoteId);
        Test.stopTest();
        
        List<ContentDocumentLink> expectedLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :quoteId];
		
        System.assertEquals(expectedLink[0].Id, result.Id, 'ContentDocumentLink ID should match expected ID');
    }
    
    @isTest
    static void sendingAnEmailTest(){
    	Quote qu = quoteCreation();
        Id quoteId = qu.Id;
        
        List<Quote> quoteList = [SELECT Id,Contact.Name,Contact.Email FROM Quote WHERE Id = :quoteId];
        
        QuoteDocument result = EM_QuotePDF_Controller.savePDF(quoteId);
        EmailTemplate emailTemp = EM_UtilOrder.queryEmailTemplate();
        
        EM_OrderPDF_Controller.EmailDetails em = new EM_OrderPDF_Controller.EmailDetails();
        em.contactName = quoteList[0].Contact.Name;
        em.contactEmail = quoteList[0].Contact.Email;
        em.contentDocumentId = result.QuoteId;
        em.subject = emailTemp.Subject;
        em.body = emailTemp.Body;
        
        Test.startTest();
        EM_QuotePDF_Controller.SendingAnEmail(quoteId);
        Test.stopTest();
    }
}