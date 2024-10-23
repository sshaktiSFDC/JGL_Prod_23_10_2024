/**
* @name         : WalletServiceLogUtility
* @description  : Utility class for logging details with Wallet Service
* @testClass    : WalletServiceLogUtilityTest
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-22    Vince Vuong         Created
*/
public without sharing class WalletServiceLogUtility {

    private static final String LOG_TYPE_SYNC   = 'sync';
    private static final String LOG_TYPE_ASYNC  = 'async';

    private static List<WalletServiceLogWrapper> logWrapperList = new List<WalletServiceLogWrapper>();

    /**
    @description: Main method logs a record in the Web Service object synchronously or asynchronously
    @inputs:    message - String
                status - String
                memberId - String
    */
    public static void logMessage(String message, String status, String memberId) {

        //Asynchronous loggings and check whether invocation is not from a future method
        // if (!System.isFuture() && Limits.getFutureCalls() < Limits.getLimitFutureCalls() ) {
        //     System.debug('\n\nasynclogService\n\n');
        //     WalletServiceLogUtility.asyncLogMessage(message, status, memberId);
        // } else {
            System.debug('logMessage');
            WalletServiceLogUtility.syncLogMessage(message, status, memberId);
        //}
    }

    /**
    @description: Main method logs a record in the Wallet Service Log object synchronously
    @inputs:    message - String
                status - String
                memberId - String
    */
    private static void syncLogMessage(String message, String status, String memberId) {

        WalletServiceLogWrapper logWrapper = new WalletServiceLogWrapper();
        try {
            logWrapper.message = message;
            logWrapper.status = status;
            logWrapper.memberId = memberId;

            logWrapperList.add(logWrapper);

        } catch (Exception ex){
            // log exception to application log utility
            System.debug('Exception: ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
        }
    }

    /**
    @description: Main method logs a record in the Web Service object asynchronously
    @inputs:    message - String
                requestBody - String
                requestMethod - String
    */
    /*
    @future
    private static void asyncLogMessage(String message,
                                  String status,
                                  String requestMethod) {

        WalletServiceLogWrapper logWrapper = new WalletServiceLogWrapper();
        try {
            logWrapper.message = message;
            logWrapper.status = status;
            logWrapper.memberId = memberId;

            logWrapperList.add(logWrapper);
        } catch (Exception e){
            // log exception to application log utility
            System.debug('Exception: ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
        }
    }
    */

    /**
    @description: This method will attempt to insert the list of WebserviceLogWrapper to Webservice_Log__c sObject
    */
    public static void commitLog() {
        if (!logWrapperList.isEmpty()) {
            List<Wallet_Service_Log__c> logList = new List<Wallet_Service_Log__c>();

            for (WalletServiceLogWrapper log : logWrapperList) {
                logList.add(new Wallet_Service_Log__c(
                    Member__c  = log.memberId,
                    Status__c  = log.status,
                    Message__c = log.message.left(32768))
                );
            }
            insert logList;
        }
    }

    /**
    @description: Method to format XML content into human-readable structure
    @inputs:    xmlString - String in XML format
    @returns:   String formatted in human-readable format
    */
    @testVisible
    private static String logPrettyServiceXML(String xmlString) {
        //TODO
        return xmlString;
    }

    /**
    @description: Method to format JSON content into human-readable structure
    @inputs:    jsonString - String in XML format
    @returns:   String formatted in human-readable format
    */
   
   @TestVisible private static String logPrettyServiceJSON(String jsonString, Boolean isResponseBody) {
        String prettyFormat = '';
        if (!String.isBlank(jsonString)) {
            prettyFormat = jsonString;
            prettyFormat = prettyFormat.replace('{', isResponseBody ? '{' : '{\n');
            prettyFormat = prettyFormat.replace('},', isResponseBody ? '^' : '^');
            prettyFormat = prettyFormat.replace(',', isResponseBody ? ',' : ',\n');
            prettyFormat = prettyFormat.replace('^', isResponseBody ? '},' : '},\n');

            integer lastIndex = prettyFormat.lastIndexOf('}');
            prettyFormat = prettyFormat.left(lastIndex) + '\n' + prettyFormat.right(prettyFormat.length() - lastIndex);
        }
        return prettyFormat;
    }

    /**
    @description: Wrapper class for interface with Wallet Service Log object
    */
    class WalletServiceLogWrapper {
        public String status {get; set;}
        public String message {get; set;}
        public ID memberID {get; set;}

        //public String endpoint {get; set;}
        //public String requestBody {get; set;}
        //public String requestMethod {get; set;}
        //public String responseBody {get; set;}
        //public Integer statusCode {get; set;}
        //public String serviceName {get; set;}
        //public String responseHeader {get; set;}
        //public String requestHeader {get; set;}
        //public Long callTime {get; set;}
    }

    /**
    @description: Method to determine if a string is in JSON format
    @inputs:         response - String
    @returns:        Boolean - true or false
    */
    @testVisible
    private static Boolean isJSON(String response) {
        if (String.isNotBlank(response)) {
            return !response.contains('<') && !response.contains('>');
        }
        return false;
    }
    
}