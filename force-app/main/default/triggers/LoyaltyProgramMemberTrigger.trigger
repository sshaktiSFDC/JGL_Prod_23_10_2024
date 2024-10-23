/**
* @name         : LoyaltyProgramMemberTrigger
* @description  : This trigger is used to Handle the event for Loyalty Program member Trigger.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-02-12    Vince Vuong         Created
* 2024-04-10    Vince Vuong         Fixed logic to get bypass settings based on User ID 
*/
trigger LoyaltyProgramMemberTrigger on LoyaltyProgramMember (Before Insert, After Insert, Before Update, After Update, After Delete, After Undelete) {

    //Get hierarchy settings based on the current running user profile
    Bypass_Automation__c settings = Bypass_Automation__c.getInstance(UserInfo.getUserId());
    //By pass this trigger if All triggers = TRUE or object specific = TRUE
    if (settings.All_Triggers__c == TRUE || settings.TR_Loyalty_Program_Member__c == TRUE) {
        return;
    }

    //Run trigger handler
    new LoyaltyProgramMemberTriggerHandler().run();
}