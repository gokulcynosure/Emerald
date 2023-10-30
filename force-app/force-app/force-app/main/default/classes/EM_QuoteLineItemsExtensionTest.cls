@isTest
public class EM_QuoteLineItemsExtensionTest {

    @IsTest
    static  void testControllerMethod() {
        
        BankAccount__c testBank = new BankAccount__c (Name = 'Test Bank');
        insert testBank;
        
        
        Account testAccount = new Account(Name = 'Test Account', Market__c = 'DOMESTIC', Category__c = 'CP',BankAccount__c = testBank.Id);
        insert testAccount;

        Id pricebookId = Test.getStandardPricebookId();
	Pricebook2 standardPricebook = new Pricebook2(
    	Id = pricebookId,
    	IsActive = true
	);
	update standardPricebook;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            Pricebook2Id = standardPricebook.Id
        );
        insert testOpportunity;

        // Create a test Tax Code
        Tax_Code__c testTaxCode = new Tax_Code__c(Name = 'Test Tax Code', Rate__c = 10);
        insert testTaxCode;
        
        
       
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            HSN_SAC_Code__c = '1234',
            ProductCode = 'PRD123'
        );
        insert testProduct;
        Pricebook2 testPricebook = new Pricebook2(Name = 'Test Pricebook', isActive = true);
        insert testPricebook;

		
        
		PricebookEntry standardPriceEntry = new PricebookEntry(
    		Pricebook2Id = standardPricebook.Id,
    		Product2Id = testProduct.Id,
    		UnitPrice = 50.00,
            IsActive = true
		);
		insert standardPriceEntry;
        
        Quote testQuote = new Quote(
            Name = 'test Quote',
            Tax_For_Merchant__c = testTaxCode.Id,
            UNLOADING_CHARGES__c = 2,
            OpportunityId = testOpportunity.Id,
            Shipping_Country__c = 'United States of America',
            Customer_Price_Book__c = standardPricebook.Id
        );
        insert testQuote;

		system.debug('Good So far2');

        // Create test QuoteLineItems
        QuoteLineItem testQLI1 = new QuoteLineItem(
            QuoteId = testQuote.Id,
            Product2Id = testProduct.Id,
            Sales_Price_after_Discount__c = 50,
            Taxable_Value__c = 40,
            QLI_Total_Price__c = 200,
            Quantity = 4,
            Tax_Amount__c = 20,
            PriceBookEntryId = standardPriceEntry.Id,
            UnitPrice = 50.00,
            Product_Description__c = 'Test'
        );
        insert testQLI1;

        

        Test.startTest();

        PageReference pageRef = Page.EM_QuoteTemplatePage; 
        pageRef.getParameters().put('id', String.valueOf(testQuote.Id));
        Test.setCurrentPage(pageRef);
        EM_QuoteLineItemsExtension controller = new EM_QuoteLineItemsExtension();
        
        System.assertEquals(0.00, controller.getTotalPrice());
		System.assertEquals(0, controller.getTotalQuantity());
        System.assertEquals(1, controller.getNextSerialNumber());
        System.assertEquals(0.00, controller.getTotalPriceWithoutTax());
        System.assertEquals(0.00, controller.gettotalUnitPrice());
        System.assertEquals(0.00, controller.getTotalIGSTAmount());
        System.assertEquals(0.00, controller.getTotalIGSTRate());
        System.assertEquals(false, controller.getIsCGST());
       	System.assertEquals(0.00, controller.getRounding());
        //System.assertEquals(' Zero Rupees Only', controller.getTotalTaxAmountInWords());
        //System.assertEquals(' Sixty Eight Rupees Only', controller.getTotalAmountInWords());
        System.assertEquals(true, controller.getIsDomesticAccount(),'Is Domestic');
        System.assertEquals(true, controller.getIsCP());
        System.assertEquals(true, controller.getIsUSCustomer());
        System.assertEquals(false, controller.getIsMerchant());
        System.assertEquals(0.00, controller.getRoundingForMerchant());
        // System.assertEquals(6.00, controller.getIGSTForMerchant());
        System.assertEquals('Test Tax Code 10.0%', controller.getTaxCodeForMerchant());

        Test.stopTest();
    }
    

}