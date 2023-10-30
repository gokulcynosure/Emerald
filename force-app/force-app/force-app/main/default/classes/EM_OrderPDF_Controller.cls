public class EM_OrderPDF_Controller {
    
      
    @AuraEnabled
    public static ContentDocumentLink savePDF(String orderId) {
    try {
        PageReference pdf = Page.EM_OrderTemplatePage;
        pdf.getParameters().put('id', orderId);
        pdf.setRedirect(true);
        Blob body = Test.isRunningTest() ? Blob.valueOf('Test Body') : pdf.getContentAsPDF();

        // Create and insert the ContentVersion
        ContentVersion fileToUpload = new ContentVersion();
        fileToUpload.PathOnClient = 'SalesOrderDocument.pdf';
        fileToUpload.Title = 'Sales Order';
        fileToUpload.VersionData = body;
        insert fileToUpload;

   
             // Create the ContentDocumentLink
            ContentVersion orderContentVersion= [SELECT Id, Title, ContentDocumentId FROM ContentVersion
            WHERE Id = :fileToUpload.Id LIMIT 1];
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = orderContentVersion.ContentDocumentId;
        	link.LinkedEntityId = orderId; 
            //link.ShareType = 'V'; 
            insert link;
            system.debug('Link Id: ' + link.Id);
            ContentDocumentLink insertedLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE Id = :link.Id];
            system.debug('ContentDocumentId: ' + insertedLink.ContentDocumentId);

            return link;
    } 
        
        catch (Exception ex) {
         System.debug('Exception: ' + ex);
         return null;    
    }
}

    
    @AuraEnabled  
    public static EmailDetails getLatestDocumentForSendingAnEmail(String orderId){
       
        system.debug('OrderId:'+ orderId);

        try{
            List<Order> orderList = [
                SELECT Id, OrderNumber, AccountId, Account.Name, Contact__r.Name, Contact__r.Email
                FROM Order
                WHERE Id = :orderId
            ];

            system.debug('OrderList:' + orderList);
                   
            List<EmailTemplate> template = [SELECT Id, Name, Body, Subject FROM EmailTemplate WHERE DeveloperName = :EM_Constants.OrderEmailTemplate];
             
             system.debug('Email Template List:'+ template);
            
            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :orderId
                ORDER BY SystemModstamp DESC
            ];
            
            System.debug('ContentDocumentLink:' +contentDocumentLinks);
                       
            EmailDetails em = new EmailDetails();
 
            em.contactName = orderList[0].Contact__r.Name;
            em.contactEmail = orderList[0].Contact__r.Email;
                       
            if (!contentDocumentLinks.isEmpty()) {
                em.contentDocumentId = contentDocumentLinks[0].ContentDocumentId;
            } else {
                system.debug('No ContentDocumentLinks found for orderId: ' + orderId);
            }

            system.debug('Contact Name:'+ em.contactName);
            system.debug('contactEmail:'+ em.contactEmail);
            
            if (!template.isEmpty()) {
                em.subject = template[0].Subject;
                em.body = template[0].Body;
                
                if (em.body.contains(EM_Constants.OrderContact)) {
                    em.body = em.body.replace(EM_Constants.OrderContact, em.contactName);
                }
                
                if (em.subject.contains(EM_Constants.OrderNumber)) {
                    em.subject = em.subject.replace(EM_Constants.OrderNumber, orderList[0].OrderNumber);
                }
                
                if (em.subject.contains(EM_Constants.OrderContact)) {
                    em.subject = em.subject.replace(EM_Constants.OrderContact, em.contactName);
                }
            }
            
            if (em.contactEmail == null) {
                throw new NullPointerException();
            }
            system.debug('EmailDetails:'+em);
            return em;
        } catch(Exception e){
            System.debug('Exception: ' + e);
            return null;
        }
    }

    @AuraEnabled  
    public static void SendingAnEmail(String orderId){
        try{
            List<Order> orderList = [
                SELECT Id, OrderNumber, AccountId, Account.Name, Contact__r.Name, Contact__r.Email
                FROM Order
                WHERE Id = :orderId
            ];

            system.debug('OrderList:' + orderList);
                   
            List<EmailTemplate> template = [SELECT Id, Name, Body, Subject FROM EmailTemplate WHERE DeveloperName = :EM_Constants.OrderEmailTemplate];
             
             system.debug('Email Template List:'+ template);
            
            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :orderId
                ORDER BY SystemModstamp DESC
            ];
            
            System.debug('ContentDocumentLink:' +contentDocumentLinks);
                       
            EmailDetails em = new EmailDetails();
 
            em.contactName = orderList[0].Contact__r.Name;
            em.contactEmail = orderList[0].Contact__r.Email;
                       
            if (!contentDocumentLinks.isEmpty()) {
                em.contentDocumentId = contentDocumentLinks[0].ContentDocumentId;
            } else {
                system.debug('No ContentDocumentLinks found for orderId: ' + orderId);
            }

            system.debug('Contact Name:'+ em.contactName);
            system.debug('contactEmail:'+ em.contactEmail);
            
            if (!template.isEmpty()) {
                em.subject = template[0].Subject;
                em.body = template[0].Body;
                
                if (em.body.contains(EM_Constants.OrderContact)) {
                    em.body = em.body.replace(EM_Constants.OrderContact, em.contactName);
                }
                
                if (em.subject.contains(EM_Constants.OrderNumber)) {
                    em.subject = em.subject.replace(EM_Constants.OrderNumber, orderList[0].OrderNumber);
                }
                
                if (em.subject.contains(EM_Constants.OrderContact)) {
                    em.subject = em.subject.replace(EM_Constants.OrderContact, em.contactName);
                }
            }
            
            if (em.contactEmail == null) {
                throw new NullPointerException();
            }
            // em.subject = em.subject.replaceAll('<br>', '');
ContentVersion pdfContent = [SELECT Id, VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :em.contentDocumentId];
System.debug('pdfContent'+pdfContent);
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

email.setToAddresses(new List<String>{em.contactEmail});
email.setSubject(em.subject);
email.setPlainTextBody(em.body);
System.debug('email'+email);

Messaging.EmailFileAttachment pdfAttachment = new Messaging.EmailFileAttachment();
pdfAttachment.setFileName('AttachmentName.pdf'); 
pdfAttachment.setBody(pdfContent.VersionData);
email.setFileAttachments(new List<Messaging.EmailFileAttachment>{pdfAttachment});
Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
System.debug('sendResults'+sendResults);
        
        }catch(Exception e){
            system.debug('exception'+e);
        }
        
    }
    @AuraEnabled
    public static ContentDocumentLink saveCRFPDF(String orderId) {
    try {
        PageReference pdf = Page.CustomerReviewForm;
        pdf.getParameters().put('id', orderId);
        pdf.setRedirect(true);
        Blob body = Test.isRunningTest() ? Blob.valueOf('Test Body') : pdf.getContentAsPDF();

        // Create and insert the ContentVersion
        ContentVersion fileToUpload = new ContentVersion();
        fileToUpload.PathOnClient = 'CustomerReviewForm.pdf';
        fileToUpload.Title = 'CRF';
        fileToUpload.VersionData = body;
        insert fileToUpload;

   
             // Create the ContentDocumentLink
            ContentVersion orderContentVersion= [SELECT Id, Title, ContentDocumentId FROM ContentVersion
            WHERE Id = :fileToUpload.Id LIMIT 1];
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = orderContentVersion.ContentDocumentId;
        	link.LinkedEntityId = orderId; 
            //link.ShareType = 'V'; 
            insert link;
            system.debug('Link Id: ' + link.Id);
            ContentDocumentLink insertedLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE Id = :link.Id];
            system.debug('ContentDocumentId: ' + insertedLink.ContentDocumentId);

            return link;
    } 
        
        catch (Exception ex) {
         System.debug('Exception: ' + ex);
         return null;    
    }
}

    
    public class EmailDetails{
        @AuraEnabled
        public String contactName;
        @AuraEnabled
        public String contactEmail;
        @AuraEnabled
        public String contentDocumentId;
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String body;
    }
}