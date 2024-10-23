/**
* @name         : DirectIssueVoucherEventAction
* @description  : Invocable method to publish Event re Direct Issue of reward vouchers from Loyalty process
* @testClass    : DirectIssueVoucherEventActionTest
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-05-03    Nicholas Then         Created
* 2024-05-03    Vengad Ramalingame  Updated logic
*/ 


public class DirectIssueVoucherEventAction {

   @InvocableMethod(label='Publish Direct Issue Voucher  Event' description='Publish Direct Issue VoucherEvent' category='Voucher')
    public static void publishJournalEvent (List<publishDirectIssueVoucherEventInput> inputs){
    
      
        System.debug('publishDirectIssueVoucherEvent inputs >> ' + inputs);        
        List<Issue_Voucher_Event__e> journalEvents = new List<Issue_Voucher_Event__e>();

        //TODO: Loop through all inputs
        //Please add try/catch and handle exception
        for (publishDirectIssueVoucherEventInput rec : inputs) {
            Issue_Voucher_Event__e je = new Issue_Voucher_Event__e();
            
            je.Order_Id_Issued__c = rec.orderIdIssued;
            je.Voucher_Code__c = rec.voucherCode;
            je.Order_Id_Issued_Channel__c = rec.orderIdIssuedChannel;
            je.MemberId__c = rec.memberId;


            journalEvents.add(je);
        }

        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(journalEvents);
        System.debug('DirectIssueVoucherEventAction results >> ' + results);

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
    
    public class publishDirectIssueVoucherEventInput {
        @InvocableVariable(label='Order Id Issued' description='Order Id Issuing the Voucher' required=true)
        public String orderIdIssued;
        @InvocableVariable(label='Voucher Code' description='Voucher Code Issued')
        public String voucherCode;
        @InvocableVariable(label='Order Id Issued Channel' description='Channel Issued')
        public String orderIdIssuedChannel;
        @InvocableVariable(label='Member Id' description='Loyalty Program Member Id')
        public String memberId;
    }
}