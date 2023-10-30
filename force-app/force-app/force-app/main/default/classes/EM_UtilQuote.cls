@IsTest
public  class EM_UtilQuote {
    
    public static BankAccount__c buildBankAccount(String bankName){
        return new BankAccount__c(Name = bankName);
    }
    
    public static Account buildAccount(String accName){
        return new Account(Name = accName);
    }
    public static Account buildAccountWithBankAccount(String accName, Id bankId){
        return new Account(Name = accName, BankAccount__c = bankId);
    }
    public static Contact buildContact(String conFirstName,String conLastName,String email,Id accId){
        return new Contact (FirstName = conFirstName,LastName = conLastName,Email = email, AccountId = accId);
    }
    
    public static Contact buildContactWithOutEmail(String conFirstName,String conLastName,Id accId){
        return new Contact (FirstName = conFirstName,LastName = conLastName,AccountId = accId);
    }
    public static Opportunity buildOpportunity(String oppName,Date CloseDate,Id accId,String StageName){
        return new Opportunity(Name = oppName,CloseDate = CloseDate,AccountId = accId,StageName = StageName );
    }
    
    public static Quote buildQuote(String quoteName,Id oppId,Id contactId){
        return new Quote(Name = quoteName,OpportunityId = oppId,ContactId = contactId);
    }
    public static Order buildOrder(Id accId,Id OppId, Id quoteId, Date startDate){
        return new Order(AccountId = accId,OpportunityId = OppId,QuoteId = quoteId);        
    }
    public static ContentVersion buildContentVersion(String Title,String PathOnClient,Blob VersionData){
        return new ContentVersion(Title = Title,PathOnClient = PathOnClient,VersionData = VersionData);
    }
    
    public static ContentDocumentLink buildContentDocumentLink(Id LinkedEntityId,Id ContentDocumentId){
        return new ContentDocumentLink(LinkedEntityId = LinkedEntityId,ContentDocumentId = ContentDocumentId);
    }
    
    public static EmailTemplate buildEmailTemplate(String Name,String devName,String Body,String Subject,Id FolderId,String TemplateType){
        return new EmailTemplate(Name = Name,DeveloperName = Name,Body = Body,Subject = Subject,FolderId = FolderId,TemplateType = TemplateType);
    }
    public static Quote buildQuoteWithAccount(String quoteName,Id oppId,Id accountId){
        return new Quote(Name = quoteName,OpportunityId = oppId,Customer__c =accountId);
    }
}