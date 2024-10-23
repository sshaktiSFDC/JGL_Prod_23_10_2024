/**
* @name         : UpdateVoucherEventAction
* @description  : Invocable Apex action to publish platform event to update Voucher
* @testClass    : UpdateVoucherEventAction
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-03-25    
*/
public with sharing class UpdateVoucherEventAction {
    public UpdateVoucherEventAction() {

    }
    
    @InvocableMethod(label='Publish Voucher Update Event' description='Publish Voucher Update Event' category='Voucher')
    public static void publishJournalEvent (List<UpdateVoucherEventInput> inputs){
    
        System.debug('Inputs count = ' + inputs.size());
        System.debug('publishJournalEvent >> ' + inputs);        
        List<RedeemVoucherTransaction__e> journalEvents = new List<RedeemVoucherTransaction__e>();

        //TODO: Loop through all inputs
        //Please add try/catch and handle exception
        for (UpdateVoucherEventInput rec : inputs) {
            RedeemVoucherTransaction__e je = new RedeemVoucherTransaction__e();
            String voucherCode = rec.voucherCode;
            String orderNo = rec.orderNo;
            String channelRedeemed = rec.channelRedeemed;

            System.debug('orderno ' + orderNo + ' Voucher code ' + voucherCode +' channelRedeemed:' + channelRedeemed  );
                       
            je.Order_Id_Redeem__c = orderNo;
            je.Voucher_Code_Issued__c = rec.voucherCode;
            je.Order_Id_Redeem_Channel__c = rec.channelRedeemed;

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
    
    public class UpdateVoucherEventInput {
        @InvocableVariable(label='Order No' description='Order Number to match Journal' required=true)
        public String orderNo;
        @InvocableVariable(label='Voucher Code' description='Voucher Code Issued')
        public String voucherCode;
        @InvocableVariable(label='Channel Redeemed' description='Voucher Code Issued')
        public String channelRedeemed;
    }
}