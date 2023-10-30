@IsTest
public class EM_OrderItemsExtensionTest {

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
        Tax_Code__c testTaxCode = new Tax_Code__c(Name = 'CS Test Tax Code', Rate__c = 10);
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
        
        Order testOrder = new Order(
            Pricebook2Id = standardPricebook.Id,
            Tax_Code_For_Merchant__c = testTaxCode.Id,
            OpportunityId = testOpportunity.Id,
            AccountId = testAccount.Id,
            QuoteId = testQuote.Id,
            EffectiveDate = System.Today(),
            Status ='Draft'
            
        );
        insert testOrder;
        system.debug('testOrder' + testOrder);
        
        OrderItem testOT = new OrderItem(
            OrderId = testOrder.Id,
       		Product2Id = testProduct.Id,
            Sales_Price_after_Discount__c = 50,
            Tax_Code__c = testTaxCode.Id,
            //Taxable_Value__c = 40,
            //QLI_Total_Price__c = 200,
            Quantity = 4,
            Tax_Amount__c = 20,
            PriceBookEntryId = standardPriceEntry.Id,
            UnitPrice = 50.00,
            Product_Description__c = 'Test');
        insert testOT;

        

        Test.startTest();

        PageReference pageRef = Page.EM_OrderTemplatePage; 
        pageRef.getParameters().put('id', String.valueOf(testOrder.Id));
        Test.setCurrentPage(pageRef);
        EM_OrderItemsExtension controller = new EM_OrderItemsExtension();
        
        System.assertEquals(0.00, controller.getTotalPrice());
		System.assertEquals(0, controller.getTotalQuantity());
        System.assertEquals(1, controller.getNextSerialNumber());
        System.assertEquals(0.00, controller.getTotalPriceWithoutTax());
        System.assertEquals(0.00, controller.gettotalUnitPrice());
        System.assertEquals(0.00, controller.getTotalIGSTAmount());
        System.assertEquals(0.00, controller.getTotalIGSTRate());
        System.assertEquals(true, controller.getIsCGST());
       	System.assertEquals(0.00, controller.getRounding());
        System.assertEquals(' Twenty Rupees Only', controller.getTotalTaxAmountInWords());
        System.assertEquals(' Two Hundred and Forty Two Rupees Only', controller.getTotalAmountInWords());
        System.assertEquals(true, controller.getIsDomesticAccount(),'Is Domestic');
        System.assertEquals(true, controller.getIsCP(),'Is Domesti');
        System.assertEquals(false, controller.getIsUSCustomer(),'Is Domest');
        System.assertEquals(false, controller.getIsMerchant(),'Is Domes');
        System.assertEquals(0.00, controller.getRoundingForMerchant(),'hi');
        System.assertEquals(22.00, controller.getIGSTForMerchant(),'hhi');
        System.assertEquals('CS Test Tax Code 10.0%', controller.getTaxCodeForMerchant(),'hhh');

        Test.stopTest();
    }
    

}