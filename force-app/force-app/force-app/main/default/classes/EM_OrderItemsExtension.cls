public with sharing class EM_OrderItemsExtension {
    public Order currentOrder { get; set; }
    public Decimal totalPrice { get; set; }
    public Integer totalQuantity { get; set; }
    public Integer serialNo { get; set; }
    public Decimal totalPriceWithoutTax { get; set; }
    public Decimal totalUnitPrice { get; set; }
    public Decimal totalIGSTAmount { get; set; }
    public Decimal totalIGSTRate { get; set; }
    public List<OrderItem> orderItems { get; set; }
    public List<CustomerReviewForm__c> reviewForm {get;set;}
    
    public EM_OrderItemsExtension() {
        //Id currentPageId = '8011e0000004eqxAAA';
        Id currentPageId = ApexPages.currentPage().getParameters().get('id');
        List<Order> orderList = [SELECT Id,Account.Name,PO_Date__c,OrderNumber,Account.Market__c,UNLOADING_CHARGES__c,FREIGHT_AND_INSURANCE__c,Freight__c,Tax_Code_For_Merchant__c,Merchant_Tax__c,Tax_Code_For_Merchant__r.Name,Tax_Code_For_Merchant__r.Rate__c,Account.Overseas_Group_Company__c,Shipping_Country__c,Account.Category__c,Total_Tax_Amount__c,Total_Price_With_Tax__c FROM Order WHERE Id = :currentPageId];
        this.currentOrder = orderList[0];
        totalPrice = 0.00;
        totalQuantity = 0;
        serialNo = 1;
        totalPriceWithoutTax = 0;
        totalUnitPrice = 0;
        totalIGSTAmount = 0;
        totalIGSTRate = 0;
        orderItems = [SELECT UnitPrice,Product2.Size__c,Basic_Unit_Rate__c,OrderId,Product2.Product_Brand__c,Product2.Type__c,Product_Description__c,Weight__c,CBM__c,Total_Weight__c,Total_CBM__c,Sales_Price_after_Discount__c,Taxable_Value__c, Total_Price_With_Tax__c,Product2.HSN_SAC_Code__c,Order.Account.Name,Total_Unit_Price__c,Tax_Code__r.Name, Discount__c, Tax_Code__r.Rate__c,Tax_Amount__c, UoM__c, Product2.Name, Product2.ProductCode,Quantity,Description, ListPrice, Price_Book__c, Order.Account.Billing_GST_No__c, Order.Account.Shipping_GST_No__c, TotalPrice, Order_Subtotal__c, Order_Product_Total_Amount__c FROM OrderItem
                      WHERE OrderId = :currentOrder.Id];
        
        reviewForm = [SELECT Id,Any_Changes_in_the_Customer_Master__c,Any_implied_requirement__c,Any_special_instructions_remarks_to_note__c,
                      Any_specific_Statutory_Legal_requirement__c,Any_stated_requirement_for_this_specific__c,Order__c FROM CustomerReviewForm__c WHERE Order__c =:currentOrder.Id];
    }
    
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
        if(this.orderItems[0].Tax_Code__c != NULL){
            if(this.orderItems[0].Tax_Code__r.Name.startsWith('CS')){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
        
    }
    public decimal getRounding(){
        Decimal total = this.currentOrder.Total_Price_With_Tax__c;
        String s = String.valueOf(total); 
        String afterDecimal = '0.'+s.substringAfter('.');
        Decimal fractionalPoints = decimal.valueOf(afterDecimal);
        if(fractionalPoints == 00){
            return 0;
        }else if(fractionalPoints < 0.5) {
            return fractionalPoints * -1;
        }else if(fractionalPoints > 0.5) {
            return 1 - fractionalPoints;
        }
        return null;
    }
    
    public string getTotalTaxAmountInWords(){
        Decimal d = this.currentOrder.Total_Tax_Amount__c;
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
        Decimal d = this.currentOrder.Total_Price_With_Tax__c + roundVal;
        NumberTOWordConvertion nwcObj = new NumberTOWordConvertion();
        String numInWords = nwcObj.getNumberTOWordConvertion(d);
        return numInWords;
    }
    public Boolean getIsDomesticAccount(){
        if( this.currentOrder.Account.Market__c == 'DOMESTIC'){
            return true;
        }else{
            return false;
        }
    }
    
    public Boolean getIsCP(){
        if(this.currentOrder.Account.Category__c == 'CP'){
            return true;
        }else{
            return false;
        }
        
    }
    
    public Boolean getIsUSCustomer(){
        if( this.currentOrder.Shipping_Country__c == 'United States of America'){
            return true;
        }else{
            return false;
        }
    }
    
    public Boolean getIsMerchant(){
        if( this.currentOrder.Account.Overseas_Group_Company__c == 'EXPORT MERCHANT'){
            return true;
        }else{
            return false;
        }
        
    }
    
    public decimal getRoundingForMerchant(){
        if(this.currentOrder.Tax_Code_For_Merchant__c != Null){
            Decimal totalVal = this.currentOrder.Total_Price_With_Tax__c;
            // Decimal rate = this.currentOrder.Tax_Code_For_Merchant__r.Rate__c;
            // Decimal totalVal = (total*rate)/100;
            //Decimal total = this.currentOrder.Total__c + this.currentOrder.Total__c/this.currentOrder.Tax_For_Merchant__r.Rate__c;
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
        if(this.currentOrder.Tax_Code_For_Merchant__c != Null){
            Decimal total = this.currentOrder.Total_Price_With_Tax__c - this.currentOrder.Merchant_Tax__c - this.currentOrder.FREIGHT_AND_INSURANCE__c - this.currentOrder.UNLOADING_CHARGES__c;
            system.debug('total'+total);
            
            Decimal rate = this.currentOrder.Tax_Code_For_Merchant__r.Rate__c;
            system.debug('rate'+rate);
            Decimal totalVal = (total*rate)/100;
            return totalVal.setScale(2);
        }else{
            return null;
        }
    }
    
    public String getTaxCodeForMerchant(){
        if(this.currentOrder.Tax_Code_For_Merchant__c != Null){
            String inputText = this.currentOrder.Tax_Code_For_Merchant__r.Name;
            
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
            
            return nameBeforeNumeric + ' '+ this.currentOrder.Tax_Code_For_Merchant__r.Rate__c+'%' ;
        }else{
            return null;
        }
        
    }
    
    public Boolean getIsFrightRequired(){
        if( this.currentOrder.Account.Overseas_Group_Company__c != 'EXPORT MERCHANT'){
            if(this.currentOrder.Account.Overseas_Group_Company__c == 'EXPORT MERCHANT' && this.currentOrder.Freight__c != Null && this.currentOrder.Freight__c == 'CIF' || this.currentOrder.Freight__c == 'DAP' || this.currentOrder.Freight__c == 'CIF' || this.currentOrder.Freight__c == 'DDP' ){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
}