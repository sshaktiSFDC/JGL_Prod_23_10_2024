/**
* @name         : ProcessRewardsEventTrigger
* @description  : This trigger is used to subscribe to PE to handle Reward redemption process.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-04-10    Vince Vuong         Created
*/
trigger ProcessRewardsEventTrigger on Process_Rewards_Event__e (After Insert) {
    //Run trigger handler
    system.debug('testsidd');
    new ProcessRewardsEventTriggerHandler().run();
}