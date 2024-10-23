/**
* @name         : IssueVoucherEventTriggerHandler
* @description  : This class is used to Handle the event for "Issue Voucher Event" Platform Event.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-05-03    Siddharth Singh          Created
*/

public class IssueVoucherEventTriggerHandler extends TriggerHandler{
	public override void afterInsert() {
        subscribeEvents(Trigger.new);
    }
    
    private static void subscribeEvents(List<Issue_Voucher_Event__e> newEvents){
        Set<String> voucherCodes = new Set<String>();
        Set<String> memberIds = new Set<String>();
        List<Voucher> vouchersToUpdate = new List<Voucher>();
        try{
            for (Issue_Voucher_Event__e event : newEvents) {
            if (String.isNotBlank(event.Voucher_Code__c)) {
                voucherCodes.add(event.Voucher_Code__c);
                memberIds.add(event.MemberId__c);
            }
        }

        system.debug('IssueVoucherEventTriggerHandler:voucherCodes ' + voucherCodes);
        for(Voucher vchr:[SELECT Order_Id_Issue__c , Order_Id_Issue_Channel__c , VoucherCode FROM Voucher where VoucherCode IN:voucherCodes AND LoyaltyProgramMemberId IN:memberIds]){
            for (Issue_Voucher_Event__e event : newEvents) {
                if (event.Voucher_Code__c == vchr.VoucherCode) {
                    vchr.Order_Id_Issue__c = event.Order_Id_Issued__c;
                    vchr.Order_Id_Issue_Channel__c = event.Order_Id_Issued_Channel__c;
                    vouchersToUpdate.add(vchr);
                }
    		}
		}
        system.debug('IssueVoucherEventTriggerHandler:vouchersToUptdate ' + vouchersToUpdate);
        update vouchersToUpdate;
        }
        catch(Exception ex) {
            System.debug('An error occured: ' + ex.getMessage());
        }
        
    }
}