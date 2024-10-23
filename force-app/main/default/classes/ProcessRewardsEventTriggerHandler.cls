/**
* @name         : ProcessRewardsEventTriggerHandler
* @description  : Handler class for Process Rewards Event Platform event trigger
* @testClass    : ProcessRewardsEventTriggerHandlerTest
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-10    Vince Vuong         Created
*/
public with sharing class ProcessRewardsEventTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        //Subscribe to platform events
        subscribeEvents(Trigger.New);    
    }
    
    //Subscribe to PEs -  Split Redemption/Reward Journals
    private static void subscribeEvents(List<Process_Rewards_Event__e> newEvents){
        System.debug('subscribeEvents >> ' + newEvents);

       
        List<LoyaltyProcessFlowWrapper.FlowInput> redemptionInputs = new List<LoyaltyProcessFlowWrapper.FlowInput>();

        // Iterate through each event.
        for (Process_Rewards_Event__e event : newEvents) {

            LoyaltyProcessFlowWrapper.FlowInput input = new LoyaltyProcessFlowWrapper.FlowInput();
            input.memberId = event.Member_ID__c;
            input.programId = event.Program_ID__c;
            input.orderId = event.Order_No__c;
            input.orderItemId = event.Order_Item_No__c;

            input.totalRewards = Integer.valueOf(event.Total_Rewards__c);
            input.totalPointsToDebit = Integer.valueOf(event.Total_Debit_Points__c);
            input.totalVouchersToIssue = Integer.valueOf(event.TotalVouchersToIssue__c);
            input.eventType = event.Event_Type__c;
            input.channel = event.Channel__c;

			//system.debug(event.Event_Type__c );
			//system.debug('LoyaltyProcessFlowWrapper.FlowInput >>' + input);

            if (event.Event_Type__c == 'Redemption') {
                redemptionInputs.add(input);
            }
           
        }
		
		System.debug('redemptionInputs >> ' + redemptionInputs);

        
        if (!redemptionInputs.isEmpty()) {
            splitRedemptionJournals(redemptionInputs);
        }
    }

    //Handle and split Transaction Journals
    private static void splitRedemptionJournals(List<LoyaltyProcessFlowWrapper.FlowInput> inputs) {

        System.debug('splitRedemptionJournals = ' + inputs);
        //Recreate new TJ with Type = Redemption, Sub-Type = Reward, Amount = 200 and debit 200 points from Balance Currency
        //Create Program Ledger

    
            Set<String> orderIds = new Set<String>();
            Set<String> programMemberIds = new Set<String>();
            List<TransactionJournal> tjList = new  List<TransactionJournal>();
            List<TransactionJournal> oldTjList = new  List<TransactionJournal>();
            List<LoyaltyLedger> transactionJournalLedgerList = new  List<LoyaltyLedger>();

            Map<String,String> orderIdVsflow = new Map<String,String>();
            Map<String,String> orderIdVsEventType = new Map<String,String>();
            Map<String,String> orderIdVsCurrency = new Map<String,String>();

            //Store Order IDs to Channel mappings
            Map<String, String> orderIdChannelMappings = new Map<String, String>();

            for(LoyaltyProcessFlowWrapper.FlowInput input: inputs){
                orderIds.add(input.orderId);
                programMemberIds.add(input.memberId);
                orderIdChannelMappings.put(input.orderId, input.channel);
            }
            System.debug('orderIdChannelMappings = ' + orderIdChannelMappings);

            //Retrieve Journals matching Type = Redemption and Sub Type = Reward only!
            for(TransactionJournal tj : [SELECT Id,Order_ID__c,Order_Item_ID__c,Channel,Brand,TransactionAmount,LoyaltyProgramId,JournalSubTypeId,JournalTypeId,MemberId,ActivityDate,JournalDate,
                                            PartnerId,Channel_Name__c,
                                            (SELECT EventType,Points,LoyaltyProgramMemberId,LoyaltyProgramCurrencyId,TransactionJournalId,Flow,ActivityDate FROM TransactionJournalLedger) 
                                        FROM TransactionJournal 
                                        WHERE Order_ID__c IN :orderIds
                                        AND MemberId IN : programMemberIds
                                        AND JournalType.Name =: GlobalConstants.JOURNAL_TYPE_REDEMPTION
                                        AND JournalSubType.Name =: GlobalConstants.JOURNAL_SUBTYPE_REWARD]){

                //Get total points to Debit
                Integer debitedPoints = (Integer)tj.TransactionJournalLedger[0].Points;
                System.debug('debitedPoints = ' + debitedPoints);

                //Make sure it's the right Redemption journals matching Order IDs and Channel!
                if (!orderIdChannelMappings.containsKey(tj.Order_ID__c) ) {
                    continue;
                }

                //Do we need to split journals?
                if(debitedPoints > GlobalConstants.REWARD_VOUCHER_TARGET_POINTS){
                    //Calculate total # of journals to split
                    Integer noOfTJ = Math.round(debitedPoints / GlobalConstants.REWARD_VOUCHER_TARGET_POINTS);

                    orderIdVsflow.put(tj.Order_ID__c, tj.TransactionJournalLedger[0].Flow);
                    orderIdVsCurrency.put(tj.Order_ID__c, tj.TransactionJournalLedger[0].LoyaltyProgramCurrencyId);
                    orderIdVsEventType.put(tj.Order_ID__c, tj.TransactionJournalLedger[0].EventType);

                    //Create new redemption journals
                    for(Integer i=0; i<noOfTJ; i++){
                        TransactionJournal newObj = new TransactionJournal();
                        newObj.LoyaltyProgramId = tj.LoyaltyProgramId;
                        newObj.MemberId = tj.MemberId;

                        newObj.Order_ID__c = tj.Order_ID__c;
                        newObj.Order_Item_ID__c = tj.Order_Item_ID__c;
                        newObj.TransactionAmount = GlobalConstants.REWARD_VOUCHER_TARGET_POINTS;    //Amount should be 200
                        newObj.JournalSubTypeId = tj.JournalSubTypeId;
                        newObj.JournalTypeId = tj.JournalTypeId;

                        //TODO: Convert these dates to UTC
                        newObj.ActivityDate = tj.ActivityDate;
                        newObj.JournalDate = tj.JournalDate;
                        newObj.Brand = tj.Brand;
                        newObj.PartnerId = tj.PartnerId;

                        //Take Channel from custom field if standard channel has no value.
                        newObj.Channel = (tj.Channel != null) ? tj.Channel : tj.Channel_Name__c;

                        //Make sure Status = Processed
                        newObj.Status = GlobalConstants.JOURNAL_STATUS_PROCESSED;

                        //TODO: Copy other fields as required here...

                        tjList.add(newObj);
                    }
                }
                oldTjList.add(tj);
            }

            //TODO: We need to use Atomic transaction - All or Nothing using SavePoints
            if (!tjList.isEmpty()) {
                insert tjList;
                delete oldTjList;   //Only delete old journals if we're splitting into multiple
            }

            //Create new ledgers and associated with the new journals
            for (TransactionJournal insertedTJ : tjList) {
                LoyaltyLedger tjl = new LoyaltyLedger();
                tjl.EventType = orderIdVsEventType.get(insertedTJ.Order_ID__c);
                tjl.Points = GlobalConstants.REWARD_VOUCHER_TARGET_POINTS;
                tjl.LoyaltyProgramMemberId = insertedTJ.MemberId;
                tjl.LoyaltyProgramCurrencyId = orderIdVsCurrency.get(insertedTJ.Order_ID__c);
                tjl.TransactionJournalId = insertedTJ.Id;
                tjl.Flow = orderIdVsflow.get(insertedTJ.Order_ID__c);
                tjl.ActivityDate= insertedTJ.ActivityDate;
                transactionJournalLedgerList.add(tjl);
            }
            
            if (!transactionJournalLedgerList.isEmpty()) {
                insert transactionJournalLedgerList;
            }
        
         
    }

    
}