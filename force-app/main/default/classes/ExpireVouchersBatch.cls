/**
* @name         : ExpireVouchersBatch
* @description  : The batch Apex job to expire vouchers can either be run on demand or per a custom schedule
*                 See more info: https://help.salesforce.com/s/articleView?id=sf.voucher_expiration.htm&type=5
* @testClass    : ExpireVouchersBatchTest
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-03-21    Vince Vuong         Created
*/
global inherited sharing class ExpireVouchersBatch implements Database.Batchable<sObject>, Database.Stateful {

    String expiredVoucherRecordsQuery = '';
    public Integer vouchersToBeExpired = 0;
    public Boolean hasInvalidAccessError = false;
    String ERROR_INVALID_ACCESS = '\nERROR : The user does not have permission to update Voucher object and/or Status field of Voucher object';


    //Invocable Method to be invoked from Flow
    @InvocableMethod(label='Batch Vouchers Expiration')
    global static void executeExpirationBatch() {
        Id jobId = Database.executeBatch(new ExpireVouchersBatch());
    }

    //Start method
    global Database.QueryLocator start(Database.BatchableContext bc) {

        //TODO: Flow scheduled to run daily at 12AM Based on Perth timezone so we need to change query filter to ExpirationDate < TODAY
        return Database.getQueryLocator([
            SELECT Id, Status
            FROM Voucher
            WHERE Status =: GlobalConstants.VOUCHER_STATUS_ISSUED
            AND ExpirationDate <= TODAY
        ]);
    }

    //Execute method
    global void execute(Database.BatchableContext bc, List<Voucher> expiredVoucherRecords) {
        vouchersToBeExpired += expiredVoucherRecords.size();
        System.debug('Scope: ' + expiredVoucherRecords);
        System.debug('Current Date: ' + System.today());

        //Set 'Expired' Status all queried expired Vouchers
        for (Voucher expiredVoucher : expiredVoucherRecords) {
            System.debug(String.valueOf(expiredVoucher));
            expiredVoucher.Status = GlobalConstants.VOUCHER_STATUS_EXPIRED;
        }
        System.debug('expiredVoucherRecords: ' + expiredVoucherRecords);

        //Check for Accessibility && Also check whether object is updatetable or not
        DescribeSObjectResult describeVoucherObject = Voucher.sObjectType.getDescribe();
        DescribeFieldResult describeVoucherStatusField = Schema.SObjectType.Voucher.fields.Status;  
        if(describeVoucherObject.isUpdateable() && describeVoucherStatusField.isUpdateable()) {
            update expiredVoucherRecords;
        } else {
            this.hasInvalidAccessError = true;
            throw new VoucherExpirationBatchApexException(this.ERROR_INVALID_ACCESS);
        } 
    }
 
    //Finish method
    global void finish(Database.BatchableContext bc) {

        //TODO: Perhaps we should consider logging this info in the logs instead.
        /*
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob job = [ SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()
                            WITH SECURITY_ENFORCED];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>{ job.CreatedBy.Email };
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Voucher Expiration Batch Processing Status');
        mail.setSubject('Voucher Expiration Apex Batch Process Completed');
        String mailTextBody = 'Batch Process has completed.' + 
            '\nVouchers to be Expired : ' + vouchersToBeExpired +
            '\nThe batch Apex job processed ' + job.TotalJobItems + ' batches with ' + job.NumberOfErrors + ' batch failures.';
        if ( hasInvalidAccessError) { mailTextBody += this.ERROR_INVALID_ACCESS; }
        mail.setPlainTextBody(mailTextBody);
        
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        */
    }

    //Custom Exception class to show execution errors of Apex Batch Scheduling for Voucher Expiration
    private class VoucherExpirationBatchApexException extends Exception {}
}