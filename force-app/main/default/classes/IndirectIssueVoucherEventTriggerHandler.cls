/**
* @name         : IndirectIssueVoucherEventTriggerHandler
* @description  : Handler class for IndirectIssueVoucherEventTrigger
* @testClass    : IndirectIssueVoucherEventTriggerHandlerTest
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-09-13    Nicholas Then         Created
*/


public class IndirectIssueVoucherEventTriggerHandler extends TriggerHandler {
  
   
    public virtual class IssueVoucherException extends Exception {}  
    
    
    public override void afterInsert() {
        //Subscribe to platform events
        subscribeEvents(Trigger.New);    
    }
    
    //Subscribe to PEs - to  Issue Vouchers 
    private static void subscribeEvents(List<Indirect_Issue_Voucher_Event__e> newEvents){
        System.debug('subscribeEvents >> ' + newEvents);

        List<LoyaltyProcessFlowWrapper.FlowInput> issueVoucherInputs = new List<LoyaltyProcessFlowWrapper.FlowInput>();
         
       
        // Iterate through each event.
        for (Indirect_Issue_Voucher_Event__e event : newEvents) {
            
            LoyaltyProcessFlowWrapper.FlowInput input = new LoyaltyProcessFlowWrapper.FlowInput();
            input.memberId = event.Member_ID__c;
            input.programId = event.Program_ID__c;
            input.orderId = event.Order_No__c;
            input.eventType = event.Event_Type__c;
            input.channel = event.Channel__c;
            input.totalVouchersToIssue = Integer.valueOf(event.TotalVouchersToIssue__c);
            //input.PEreplayId = event.ReplayId;
            //input.PEeventUuid = event.EventUuid;

            issueVoucherInputs.add(input);
            
            
              
            
        }
		System.debug('issueVoucherInputs >> ' + issueVoucherInputs);
		
      
        if (!issueVoucherInputs.isEmpty()) {
            issueRewardVouchers(issueVoucherInputs);
        }

	
    }

 

    //Issue reward vouchers
    private static void issueRewardVouchers(List<LoyaltyProcessFlowWrapper.FlowInput> inputs) {
       
       
             //List<Process_Rewards_Event__e> events = new List<Process_Rewards_Event__e>();
        List<LoyaltyProcessFlowWrapper.FlowOutput> outputs = new List<LoyaltyProcessFlowWrapper.FlowOutput>();
        List<LoyaltyManagement.IssueVoucherInput> issueVoucherList = new List<LoyaltyManagement.IssueVoucherInput>();
       
        for (LoyaltyProcessFlowWrapper.FlowInput rec : inputs) {
            LoyaltyProcessFlowWrapper.FlowOutput output = new LoyaltyProcessFlowWrapper.FlowOutput();
                        
            //Loop through # of vouchers to create
            for(Integer count = 1; count <= rec.totalVouchersToIssue; count++) {

                LoyaltyManagement.IssueVoucherInputBuilder voucher = new LoyaltyManagement.IssueVoucherInputBuilder();
                voucher.setLoyaltyProgramMemberId(rec.memberId);
                voucher.setProgramName(GlobalConstants.LOYALTY_PROGRAM_NAME);
                voucher.setVoucherDefinitionName(GlobalConstants.VOUCHER_DEFINITION_REWARD);
                voucher.setAdditionalNotes(rec.orderId+'@channel@'+rec.channel);
                //voucher.setVoucherCode('Test001');
               //voucher.setJournalId('0lV8r0000000Jx7EAE');

                issueVoucherList.add(voucher.build());
              } 

            outputs.add(output);
        }
        System.debug('issueVoucherList = ' + issueVoucherList);
      
        // Insert vouchers outside the loop
        if (!issueVoucherList.isEmpty()) {
        
            // insert vouchersToInsert;
            List<LoyaltyManagement.IssueVoucherOutput> issueVoucherActionResults = LoyaltyManagement.LoyaltyResources.issueVoucher(issueVoucherList); 
          
             
            System.debug(issueVoucherActionResults);
            System.debug('Issue Voucher Successful Operation:'+ issueVoucherActionResults.get(0));
            Boolean InsertResult = issueVoucherActionResults.get(0).isSuccess();
           
            //throw custom exception if insert failed
            if (!InsertResult){
            throw new IssueVoucherException('Voucher failed to be issued');
                              }
            
            //TODO: Stamp Order ID and Order Item ID against vouchers issued
            List<Id> voucherIds = new List<Id>();
            for(LoyaltyManagement.IssueVoucherOutput rec : issueVoucherActionResults) {
                if (rec.isSuccess()) {
                        voucherIds.add(rec.getVoucherId());
                        } 
            }
            System.debug('voucherIds = ' + voucherIds);
            List<Voucher> vouchersCreated = [SELECT id, Reason  FROM Voucher where id IN:voucherIds];
            List<Voucher> vouchersToUpdate = new List<Voucher>();
            System.debug('processRewardTriggerHandler: vouchersToUpdate = ' + vouchersToUpdate);
            for(Voucher voucherCr : vouchersCreated) {
               String vChannel = voucherCr.Reason.substringAfter('@channel@'); 
               if(!string.isblank(vChannel) && vChannel != 'null'){
                vouchersToUpdate.add( new Voucher(
                    Id = voucherCr.Id,
                    Order_Id_Issue__c = voucherCr.Reason.substringBefore('@channel@'),
                    Order_Id_Issue_Channel__c = voucherCr.Reason.substringAfter('@channel@')
                ));
               } else {
                   vouchersToUpdate.add( new Voucher(
                    Id = voucherCr.Id,
                    Order_Id_Issue__c = voucherCr.Reason.substringBefore('@channel@')
                   
                ));
                   
               }
            }
            System.debug('vouchersToUpdate = ' + vouchersToUpdate);

            if (!vouchersToUpdate.isEmpty()){
                update vouchersToUpdate;
            }
        }
            
            
        

       
    }
    
   
    
    
}