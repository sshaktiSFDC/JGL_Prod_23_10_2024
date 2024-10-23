/**
* @name         : VoucherTrigger
* @description  : This trigger is used to Handle the event for Loyalty Program member Trigger.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-04-04    Vince Vuong          Created
*/
trigger VoucherTrigger on Voucher (Before Insert, Before Update, After Insert, After Update) {

    //Get hierarchy settings based on the current running user profile
    Bypass_Automation__c settings = Bypass_Automation__c.getInstance(UserInfo.getUserId());
    //By pass this trigger if All triggers = TRUE or object specific = TRUE
    if (settings.All_Triggers__c == TRUE || settings.TR_Voucher__c == TRUE) {
        return;
    }

    //Run trigger handler
    new VoucherTriggerHandler().run();
}