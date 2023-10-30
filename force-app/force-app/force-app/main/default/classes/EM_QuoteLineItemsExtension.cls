public with sharing class EM_QuoteLineItemsExtension {
    
    public Quote currentQuote { get;Set; }
    public Decimal totalPrice { get; set; }
    public Integer totalQuantity { get; set; }
    public Integer serialNo {get;set;}
    public Decimal totalPriceWithoutTax {get; set;}
    public Decimal totalUnitPrice {get; set;}
    public Decimal totalIGSTAmount {get; set;}
    public Decimal totalIGSTRate {get; set;}
    public List<QuoteLineItem> quoteLineItems{ get;set;}
    public List<QuoteLineItem> quoteLineItemsWithSpecialDiscounts{ get;set;}
    public List<CustomerReviewForm__c> reviewForm {get;set;}
    
    public EM_QuoteLineItemsExtension(){
        Id currentPageId = apexpages.currentpage().getparameters(). get('id');
        List<Quote> quoteList = [Select id,Account.Name,QuoteNumber,Customer_Enquiry_Date__c,Tax_For_Merchant__r.Name,Merchant_Tax__C,UNLOADING_CHARGES__c,Tax_For_Merchant__r.Rate__c,Total__c,Quote_Tax__c,Shipping_Country__c,Account.Overseas_Group_Company__c,Account.Market__c,Account.Shipping_Country__c,Account.Category__c from Quote Where id =: currentPageId];
        this.CurrentQuote = quoteList[0];
        totalPrice = 0.00;
        totalQuantity = 0;
        serialNo = 1;
        totalPriceWithoutTax= 0;
        totalUnitPrice = 0;
        totalIGSTAmount = 0;
        totalIGSTRate = 0;
        quoteLineItemsWithSpecialDiscounts = new List<QuoteLineItem>();
        QuoteLineItems = [SELECT QuoteId,Product2.HSN_SAC_Code__c,Product2.Size__c,Product2.Product_Brand__c,Product_Description__c,Line_Item_Description__c,Type__c,Weight__c,CBM__c,Total_Weight__c,Total_CBM__c,Sales_Price_after_Discount__c,Taxable_Value__c,Quote.Account.Name,UoM__c,Quote_Discount__c,SPL_DISCOUNT__c,PPD__c,VD__c,Discount,UnitPrice,Total_Price_WithOut_Discount__c,Tax_Code__r.Name,Tax_Code__r.Rate__c, Total_Amount_With_Tax__c, Tax_Amount__c, Product2.Name,TotalPrice,Product2.ProductCode,QLI_Total_Price__c, Quantity, Subtotal, Description, ListPrice,Quote.Account.Billing_GST_No__c,Quote.Account.Shipping_GST_No__c FROM QuoteLineItem
                          WHERE QuoteId = :CurrentQuote.Id ORDER BY LineNumber ASC ];
        
        for (QuoteLineItem ql : QuoteLineItems) {
            if (ql.SPL_DISCOUNT__c != 0 || ql.PPD__c != 0 || ql.VD__c != 0) {
                quoteLineItemsWithSpecialDiscounts.add(ql);
            }
        }

        reviewForm = [SELECT Id,Any_Changes_in_the_Customer_Master__c,Any_implied_requirement__c,Any_special_instructions_remarks_to_note__c,
        Any_specific_Statutory_Legal_requirement__c,Any_stated_requirement_for_this_specific__c,Order__c FROM CustomerReviewForm__c WHERE Quote__c =:currentQuote.Id];
        
    }
    
    
    
    
    /*public EM_QuoteLineItemsExtension(ApexPages.StandardController controller){
this.CurrentQuote = (Quote)controller.getRecord();
totalPrice = 0.00;
totalQuantity = 0;
serialNo = 0;
QuoteLineItems = [SELECT QuoteId,Quote.Account.Name, Product2.Name,TotalPrice,Product2.ProductCode,QLI_Total_Price__c, Quantity, Subtotal, Description, ListPrice FROM QuoteLineItem
WHERE QuoteId = :CurrentQuote.Id ORDER BY LineNumber ASC ];

}*/
    public Decimal getTotalPrice() {
        return totalPrice;
    }
    
    public Integer getTotalQuantity() {
        return totalQuantity;
    }
    public Integer getNextSerialNumber() {
        return serialNo;
    }
    public Decimal getTotalPriceWithoutTax() {
        return totalPriceWithoutTax;
    }
    
    public Decimal gettotalUnitPrice() {
        return totalUnitPrice;
    }
    
    public Decimal getTotalIGSTAmount() {
        return totalIGSTAmount;
    }
    
    public Decimal getTotalIGSTRate() {
        return totalIGSTRate;
    }
    
    public Boolean getIsCGST(){
        if(this.QuoteLineItems[0].Tax_Code__c != NULL){
        if(this.QuoteLineItems[0].Tax_Code__r.Name.startsWith('CS')){
            return true;
        }else{
            return false;
        }
        }else{
            return false;
        }
        
    }
    
    public decimal getRounding(){
        Decimal total = this.CurrentQuote.Total__c;
        String s = String.valueOf(total); 
        String afterDecimal = '0.'+s.substringAfter('.');
        Decimal fractionalPoints = decimal.valueOf(afterDecimal);
        if(fractionalPoints == 00){
            return 0.00;
        }else if(fractionalPoints < 0.5) {
            return fractionalPoints * -1;
        }else if(fractionalPoints > 0.5) {
            return 1 - fractionalPoints;
        }
        return null;
    }

    public string getTotalTaxAmountInWords(){
        Decimal d = this.CurrentQuote.Quote_Tax__c;
        NumberTOWordConvertion nwcObj = new NumberTOWordConvertion();
        String numInWords;
        if(d > 0){
             numInWords = nwcObj.getNumberTOWordConvertion(d);
        }else{
            numInWords = 'Zero Rupees Only';
        }

        return numInWords;
    }

    public string getTotalAmountInWords(){
        Decimal roundVal = getRounding();
        Decimal d = this.CurrentQuote.Total__c + roundVal;
        NumberTOWordConvertion nwcObj = new NumberTOWordConvertion();
        String numInWords = nwcObj.getNumberTOWordConvertion(d);
        return numInWords;
    }

    public Boolean getIsDomesticAccount(){
        if( this.CurrentQuote.Account.Market__c == 'DOMESTIC'){
            return true;
        }else{
            return false;
        }
    }

    public Boolean getIsCP(){
        if(this.CurrentQuote.Account.Category__c == 'CP'){
            return true;
        }else{
            return false;
        }
        
    }

    public string getContacts(){
        List<Contact> conList = [SELECT ID,Name From Contact WHERE AccountId =:this.CurrentQuote.Account.Id];
        String contacts;
        for(Contact con : conList ){
            if(contacts == null){
                contacts = con.Name;
            }else{
                contacts += ','+ con.Name;
            }
        }
        return contacts;
    }

    public Boolean getIsUSCustomer(){
        system.debug('Shipping_Country__c'+this.CurrentQuote.Shipping_Country__c);
        if( this.CurrentQuote.Shipping_Country__c == 'United States of America'){
            system.debug('Shipping_Country__c true'+this.CurrentQuote.Shipping_Country__c);
            return true;
        }else{
            system.debug('Shipping_Country__c false'+this.CurrentQuote.Shipping_Country__c);
            return false;
        }
    }

    public Boolean getIsMerchant(){
        if( this.CurrentQuote.Account.Overseas_Group_Company__c == 'EXPORT MERCHANT'){
            return true;
        }else{
            return false;
        }
        
    }

    public decimal getRoundingForMerchant(){
        if(this.currentQuote.Tax_For_Merchant__c != Null){
        Decimal total = this.CurrentQuote.Total__c;
        Decimal rate = this.currentQuote.Tax_For_Merchant__r.Rate__c;
        Decimal totalVal = this.CurrentQuote.Total__c;
        //Decimal total = this.CurrentQuote.Total__c + this.CurrentQuote.Total__c/this.currentQuote.Tax_For_Merchant__r.Rate__c;
        String s = String.valueOf(totalVal.setScale(2)); 
        String afterDecimal = '0.'+s.substringAfter('.');
        Decimal fractionalPoints = decimal.valueOf(afterDecimal);
        if(fractionalPoints == 00){
            return 0.00;
        }else if(fractionalPoints < 0.5) {
            return fractionalPoints * -1;
        }else if(fractionalPoints > 0.5) {
            return 1 - fractionalPoints;
        }
        return null;
    }else{
        return null;
    }
    }

    public decimal getIGSTForMerchant(){
        if(this.currentQuote.Tax_For_Merchant__c != Null){
        Decimal total = this.CurrentQuote.Total__c- this.CurrentQuote.Merchant_Tax__C - this.currentQuote.UNLOADING_CHARGES__c;
        Decimal rate = this.currentQuote.Tax_For_Merchant__r.Rate__c;
        Decimal totalVal = (total*rate)/100;
        return totalVal.setScale(2);
        }else{
            return null;
        }
    }

    public String getTaxCodeForMerchant(){
        if(this.currentQuote.Tax_For_Merchant__c != Null){
        String inputText = this.currentQuote.Tax_For_Merchant__r.Name;

        String nameBeforeNumeric = '';

for (Integer i = 0; i < inputText.length(); i++) {
    String currentChar = inputText.substring(i, i + 1);
    if (!currentChar.isNumeric()) {
        nameBeforeNumeric += currentChar;
    } else {
        break; // Stop when the first numeric character is encountered
    }
}

System.debug('Formatted text: ' + nameBeforeNumeric);

        return nameBeforeNumeric + ' '+ this.currentQuote.Tax_For_Merchant__r.Rate__c+'%' ;
    }else{
        return null;
    }
        
}
}