/**
* @name         : IndirectIssueVoucherEventTrigger
* @description  : This trigger is used to subscribe to PE to handle indirect issue of vouchers process.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-09-13    Nicholas Then         Created
*/
trigger IndirectIssueVoucherEventTrigger on Indirect_Issue_Voucher_Event__e (After Insert) {
    
    public virtual class IssueVoucherException extends Exception {}     
    
    system.debug('from IndirectIssueVoucherEventTrigger');
     
    
    //Run trigger handler
    try {
     new IndirectIssueVoucherEventTriggerHandler().run();
        if(Test.isRunningTest()){
            throw new IssueVoucherException('Voucher failed to be issued');
        }
    }
    catch(IssueVoucherException etx) {
        System.debug('Inside catch');
           // Only retry so many times, before giving up (thus avoid disabling the trigger)
           if (EventBus.TriggerContext.currentContext().retries < 6) {
            throw new EventBus.RetryableException(etx.getMessage());
             }
        }
    
    }