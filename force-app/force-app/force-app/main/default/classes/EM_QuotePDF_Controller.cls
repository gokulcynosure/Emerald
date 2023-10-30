public  class EM_QuotePDF_Controller {
    
    
    @AuraEnabled
    public static QuoteDocument savePDF(String quoteId){
        try {
            PageReference pdf = Page.EM_QuoteTemplatePage;
            pdf.getParameters().put('Id',quoteId);
            pdf.setRedirect(true);
            Blob body =  Test.isRunningTest() ? blob.valueOf('Test Body') : pdf.getContentAsPDF();
            
            QuoteDocument quoteDoc = new QuoteDocument();
            quoteDoc.Document = body;
            quoteDoc.QuoteId = quoteId;
            insert quoteDoc;
            
            return quoteDoc;
        } catch (Exception ex) {
            system.debug('Exception'+ex);
            return null;
        }
    }
    
    @AuraEnabled  
    public static EmailDetails getLatestDocumentForSendingAnEmail(String quoteId){
        
        try{
            List<Quote> q = [SELECT Id, Name,QuoteNumber,Contact.Name,Contact.Email  FROM Quote WHERE Id = :quoteId];
            List<EmailTemplate> template = [SELECT id,Name,Body,Subject from EmailTemplate where DeveloperName = :EM_Constants.EmailTemplate];
            List<contentdocumentlink> contentdocumentlink =  [Select id,Contentdocumentid from contentdocumentlink where linkedentityid= :quoteId Order By SystemModstamp Desc];
            
            EmailDetails em = new EmailDetails();
            em.contactName = q[0].Contact.Name;
            em.contactEmail = q[0].Contact.Email;
            em.contentDocumentId = contentdocumentlink[0].ContentDocumentId;
            em.subject = template[0].Subject;
            em.body = template[0].Body;
            
            em.body =em.body.contains(EM_Constants.QuoteContact) ? em.body.replace(EM_Constants.QuoteContact,em.contactName ):em.body; 
            em.subject =em.subject.contains(EM_Constants.QuoteNumber) ? em.subject.replace(EM_Constants.QuoteNumber,q[0].QuoteNumber):em.subject ;
            em.subject =em.subject.contains(EM_Constants.QuoteContact) ? em.subject.replace(EM_Constants.QuoteContact,em.contactName):em.subject ;
            
            if (q[0].Contact.Email == null) {
                throw new NullPointerException();
            } else {
                em.contactEmail = q[0].Contact.Email;
            }
            
            return em;
            
        }catch(Exception e){
            system.debug('exception'+e);
            return null;
        }
        
    }

    @AuraEnabled  
    public static void SendingAnEmail(String quoteId){
        try{
            List<Quote> q = [SELECT Id, Name,QuoteNumber,Contact.Name,Contact.Email  FROM Quote WHERE Id = :quoteId];
            List<EmailTemplate> template = [SELECT id,Name,Body,Subject from EmailTemplate where DeveloperName = :EM_Constants.EmailTemplate];
            List<contentdocumentlink> contentdocumentlink =  [Select id,Contentdocumentid from contentdocumentlink where linkedentityid= :quoteId Order By SystemModstamp Desc];
            
            EmailDetails em = new EmailDetails();
            em.contactName = q[0].Contact.Name;
            em.contactEmail = q[0].Contact.Email;
            em.contentDocumentId = contentdocumentlink[0].ContentDocumentId;
            em.subject = template[0].Subject;
            em.body = template[0].Body;
            
            em.body =em.body.contains(EM_Constants.QuoteContact) ? em.body.replace(EM_Constants.QuoteContact,em.contactName ):em.body; 
            em.subject =em.subject.contains(EM_Constants.QuoteNumber) ? em.subject.replace(EM_Constants.QuoteNumber,q[0].QuoteNumber):em.subject ;
            em.subject =em.subject.contains(EM_Constants.QuoteContact) ? em.subject.replace(EM_Constants.QuoteContact,em.contactName):em.subject ;
            // em.subject = em.subject.replaceAll('<br/>', '');
            system.debug('em'+em);
            if (q[0].Contact.Email == null) {
                throw new NullPointerException();
            } else {
                em.contactEmail = q[0].Contact.Email;
            }

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
    public static ContentDocumentLink saveCRFPDF(String quoteId) {
        PageReference pdf = Page.EM_QuoteCRF;
        pdf.getParameters().put('id', quoteId);
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
        	link.LinkedEntityId = quoteId; 
            //link.ShareType = 'V'; 
            insert link;
            system.debug('Link Id: ' + link.Id);
            ContentDocumentLink insertedLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE Id = :link.Id];
            system.debug('ContentDocumentId: ' + insertedLink.ContentDocumentId);

            return link;
    } 
   


    
    public class EmailDetails{
        @AuraEnabled
        public string contactName;
        @AuraEnabled
        public string contactEmail;
        @AuraEnabled
        public string contentDocumentId ;
        @AuraEnabled
        public String subject ;
        @AuraEnabled
        public String body ;
    }
}