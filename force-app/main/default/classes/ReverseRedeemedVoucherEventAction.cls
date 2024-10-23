/**
* @name         : ReverseRedeemedVoucherEventAction 
* @description  : Invocable method to publish Event Reversing Redeemed reward vouchers from Loyalty process
* @testClass    : ReverseRedeemedVoucherEventActionTest
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-07-24    Nicholas Then         Created
* 
*/



public class ReverseRedeemedVoucherEventAction {

    @InvocableMethod(label='Publish Reverse Redeemed Voucher  Event' description='Publish Reverse Redeemed VoucherEvent' category='Voucher')
    public static void publishJournalEvent (List<publishReverseRedeemedVoucherEventInput> inputs){
    
      
        System.debug('publishReverseRedeemedVoucherEvent inputs >> ' + inputs);        
        List<Reverse_Redeemed_Vouchers__e> journalEvents = new List<Reverse_Redeemed_Vouchers__e>();

        //TODO: Loop through all inputs
        //Please add try/catch and handle exception
        for (publishReverseRedeemedVoucherEventInput rec : inputs) {
            Reverse_Redeemed_Vouchers__e je = new Reverse_Redeemed_Vouchers__e();
            
            je.OriginalOrderId__c = rec.OriginalOrderId;
            je.Channel__c = rec.Channel;
            je.MemberId__c = rec.memberId;


            journalEvents.add(je);
            System.debug('ReverseRedeemedVoucherEvent : ' + je);
        }

        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(journalEvents);
        System.debug('ReverseRedeemedVoucherEventAction results >> ' + results);

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
    
    public class publishReverseRedeemedVoucherEventInput {
        @InvocableVariable(label='Original Order Id inWhich Redeemed' description='Order Id inWhich Redeemed the Voucher' required=true)
        public String OriginalOrderId;
        @InvocableVariable(label='Order Id Redeemed Channel' description='Channel of Order inWhich Redeemed the Voucher')
        public String Channel;
        @InvocableVariable(label='Member Id' description='Loyalty Program Member Id')
        public String memberId;
    }
    
    
}