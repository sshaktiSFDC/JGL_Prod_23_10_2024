/**
* @name         : ProcessRewardsAction
* @description  : This invocable action is used to recreate Redemption transaction journals
* @testClass    : TODO -> ProcessRewardsActionTest
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-10    Vince Vuong         Created
* 2024-04-24    Vince Vuong         Updated logic
* 2024-08-15    Nicholas Then.      Updated logic
*/ 
public without sharing class ProcessRewardsAction {

    @InvocableMethod(label='Publish PE for Redemption Rewards')
    public static List<LoyaltyProcessFlowWrapper.FlowOutput> processRewards(List<LoyaltyProcessFlowWrapper.FlowInput> inputs) {

        System.debug('ProcessRewardsAction count = ' + inputs.size());
        System.debug('inputs = ' +  inputs);
        List<Process_Rewards_Event__e> events = new List<Process_Rewards_Event__e>();
        List<LoyaltyProcessFlowWrapper.FlowOutput> outputs = new List<LoyaltyProcessFlowWrapper.FlowOutput>();

        //Initial code - Publish only the first record to the PE , but removed restriction to allow bulk operations eg bulk manual points @ 15Aug
        // for Each Order of Accrual-Purchase, we limit only a single (1) line item/count to publish this event because it carries the SUM of total vouchers to issue
       
        for (LoyaltyProcessFlowWrapper.FlowInput rec : inputs) {
            LoyaltyProcessFlowWrapper.FlowOutput output = new LoyaltyProcessFlowWrapper.FlowOutput();
            events.add(new Process_Rewards_Event__e(
                Member_ID__c = rec.memberId, // previously input[0].memberId
                Program_ID__c = rec.programId,
                Order_No__c = rec.orderId,
                Order_Item_No__c = rec.orderItemId,
                Total_Rewards__c = rec.totalRewards,
                Total_Debit_Points__c = rec.totalPointsToDebit,
                TotalVouchersToIssue__c = rec.totalVouchersToIssue,
                Event_Type__c = rec.eventType,
                Channel__c = rec.channel
            ));

            outputs.add(output);
        }
            System.debug(events);
        if (!events.isEmpty()) {
            // Call method to publish events
            List<Database.SaveResult> results = EventBus.publish(events);

            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
        }
        return outputs;
    }

   

   

    

}