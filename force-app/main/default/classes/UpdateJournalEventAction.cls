/**
* @name         : UpdateJournalEventAction
* @description  : Invocable Apex action to publish platform event to update Transaction Journal
* @testClass    : UpdateJournalEventActionTest
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-03-21    Siddharth Singh     Created
* 2024-03-25    Vince Vuong         Updated logic
*/
public without sharing class UpdateJournalEventAction {
    
    @InvocableMethod(label='Publish Update Journal Event' description='Update Journal fields with Event' category='TransactionJournal')
    public static void publishJournalEvent (List<UpdateJournalEventInput> inputs){
    
        System.debug('Inputs count = ' + inputs.size());
        System.debug('publishJournalEvent >> ' + inputs);        
        List<Transaction_Journal_Update__e> journalEvents = new List<Transaction_Journal_Update__e>();

        //TODO: Loop through all inputs
        //Please add try/catch and handle exception
        for (UpdateJournalEventInput rec : inputs) {
            Transaction_Journal_Update__e je = new Transaction_Journal_Update__e();
            String pointstype = rec.pointsType;
            String orderNo = rec.orderNo;
            String orderItemNo = rec.orderItemNo;
            Integer runningBalance = rec.runningBalance;

            System.debug('orderno ' + orderNo + ' order item no ' + orderItemNo + ' runningbalance ' + runningBalance + ' PointsType ' + pointstype);
            
            je.Transaction_Type__c = pointstype;           
            je.Order_No__c = orderNo;
            je.Order_Item_No__c = orderItemNo;
            je.Running_Balance__c = runningBalance;
            je.Voucher_Code_Issued__c = rec.voucherCode;
            journalEvents.add(je);
        }

        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(journalEvents);
        System.debug('results >> ' + results);

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
    
    public class UpdateJournalEventInput {
        @InvocableVariable(label='Order No' description='Order Number to match Journal' required=true)
        public String orderNo;
        @InvocableVariable(label='Order Item No' description='Order Item Number to match Journal' required=true)
        public String orderItemNo;
        @InvocableVariable(label='Running Balance' description='Value of Running Balance to Update' required=true)
        public Integer runningBalance;
        @InvocableVariable(label='Points Type' description='Credit or Debit of Points' required=true)
        public String pointsType;
        @InvocableVariable(label='Journal Reference No' description='Transaction Journal Reference Number')
        public String journalReferenceNo;
        @InvocableVariable(label='Voucher Code' description='Voucher Code Issued')
        public String voucherCode;
    }
}