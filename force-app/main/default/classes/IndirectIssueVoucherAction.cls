/**
* @name         : IndirectIssueVoucherAction
* @description  : This invocable action is used to Indirect Issue Vouchers
* @testClass    : TODO -> IndirectIssueVoucherActionTest
* <Date>        <Modified By>     	<Brief Description of Change>

* 2024-09-13    Nicholas Then.      Created
*/ 

public without sharing  class IndirectIssueVoucherAction {
    
    
        @InvocableMethod(label='Publish PE for IndirectIssueVoucherEvent')
    public static List<LoyaltyProcessFlowWrapper.FlowOutput> processRewards(List<LoyaltyProcessFlowWrapper.FlowInput> inputs) {

        System.debug('IndirectIssueVoucherAction count = ' + inputs.size());
        System.debug('IndirectIssueVoucherAction inputs = ' +  inputs);
        List<Indirect_Issue_Voucher_Event__e> events = new List<Indirect_Issue_Voucher_Event__e>();
        List<LoyaltyProcessFlowWrapper.FlowOutput> outputs = new List<LoyaltyProcessFlowWrapper.FlowOutput>();

        //Initial code - Publish only the first record to the PE , but removed restriction to allow bulk operations eg bulk manual points @ 15Aug
        // for Each Order of Accrual-Purchase, we limit only a single (1) line item/count to publish this event because it carries the SUM of total vouchers to issue
       
        for (LoyaltyProcessFlowWrapper.FlowInput rec : inputs) {
            LoyaltyProcessFlowWrapper.FlowOutput output = new LoyaltyProcessFlowWrapper.FlowOutput();
            events.add(new Indirect_Issue_Voucher_Event__e(
                Member_ID__c = rec.memberId, // previously input[0].memberId
                Program_ID__c = rec.programId,
                Order_No__c = rec.orderId,
                Event_Type__c = rec.eventType,
                TotalVouchersToIssue__c = rec.totalVouchersToIssue,
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