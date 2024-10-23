/**
* @name         : ChangeStatusOfVoucherForReturnProcess
* @description  : TODO
* @testClass    : TODO
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-04-09    Siddharth Singh     Created
*/
public class ChangeStatusOfVoucherForReturnProcess {
	@InvocableMethod(label='Handle Returns Process3')
    public static Void handleReturnsProcess3(List<HandleReturnsProcessInput> inputs) {
        
        system.debug('ChangeStatusOfVoucherforReturnProcess : ' + inputs.size());
        
        List<String> OriginalorderIds = new List<String>();
        Set<String> originalChannels = new Set<String>();
         Set<String> MemberIds = new Set<String>();
        List<Voucher> vouchersToUpdate = new List<Voucher>();
        for (HandleReturnsProcessInput rec : inputs) {

            originalChannels.add(rec.originalChannel);
            OriginalorderIds.add(rec.originalOrderId);
            MemberIds.add(rec.MemberId);

            }
        System.debug('originalChannels = ' + originalChannels);
        System.debug('OriginalorderIds = ' + OriginalorderIds);
        System.debug('MemberId = ' + MemberIds);
        
        List<Voucher> vouchersRedeemForOrder = [SELECT Id,Order_Id_Redeem__c,Status,TransactionJournal.LoyaltyProgramId , LoyaltyProgramMemberId 
                                                FROM Voucher 
                                                WHERE Status = 'Redeemed' 
                                                AND Order_Id_Redeem__c IN: OriginalorderIds 
                                                AND Order_Id_Redeem_Channel__c IN: originalChannels 
                                                AND LoyaltyProgramMemberId IN: MemberIds ];
        System.debug('List<Voucher> vouchersRedeemForOrder : ' + vouchersRedeemForOrder);
        if(!vouchersRedeemForOrder.isEmpty()){
                for(Voucher voucher : vouchersRedeemForOrder){
                    if(voucher.Status == 'Redeemed'){
                        voucher.Status = 'Issued';
                        voucher.RedeemedValue =0;
                        voucher.UseDate = null;
                        voucher.Order_Id_Redeem_Channel__c = null;
                        voucher.Order_Id_Redeem__c = null;
                        vouchersToUpdate.add(voucher);
                    }
                }
                if (!vouchersToUpdate.isEmpty()) {
                    update vouchersToUpdate;
                }

            }

    }
    
    public class HandleReturnsProcessInput {
        @InvocableVariable public String originalChannel;
        @InvocableVariable public String originalOrderId;
         @InvocableVariable public String MemberId;
        
    }
}