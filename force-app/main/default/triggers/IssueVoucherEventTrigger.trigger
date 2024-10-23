/**
* @name         : IssueVoucherEventTrigger
* @description  : This trigger is used to Handle the event for "Issue Voucher Event" Platform Event.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-05-03    Siddharth Singh          Created
*/

trigger IssueVoucherEventTrigger on Issue_Voucher_Event__e (after insert) {
    //Run trigger handler
    new IssueVoucherEventTriggerHandler().run();

}