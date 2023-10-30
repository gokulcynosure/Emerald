public class EM_Constants {

    public static final String EmailTemplate = 'QuoteQuotationTemplate';
    public static final String QuoteContact = '{!Quote.Contact}';
    public static final String QuoteNumber = '{!Quote.QuoteNumber}';
    
    public static  final String EM_SAP_RECORD = 'CreateAccountEndpoint';
    public static  final String SAP_CREDENTIAL = 'callout:EM_SAP';
    public static  final String SAP_URL_ENDPOINT = 'endpoint';
    public static  final String HEADER_CONTENT_TYPE = 'Content-Type';
    public static  final String HEADER_ACCEPT_TYPE = 'Accept';
    public static  final String FIELD_SET = 'EM_SAPCallout';
    
    public static final String OrderEmailTemplate = 'Sales_Order_Email_Template';
   	public static final String OrderContact = '{!Order.Contact}';
    public static final String OrderNumber = '{!Order.OrderNumber}';
}