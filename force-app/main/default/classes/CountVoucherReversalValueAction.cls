/**
* @name         : CountVoucherReversalValueAction
* @description  : Invocable action to Calculate Total FaceValue of Redeemed Vouchers Reversal 
* @testClass    : CountVoucherReversalValueActionTest
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-07-24    Nicholas Then     Created
*/

public class CountVoucherReversalValueAction {

     @InvocableMethod(label='CountVoucherReversalValueAction.cls: CalcCountReversedVoucherValue')
     
    public static List<CountVoucherValueReversedOutput> CalcCountReversedVoucherValue(List<CountVoucherValueReversedInput> inputs) {
        system.debug(inputs.size());
       
        List<CountVoucherValueReversedOutput> outputList = new List<CountVoucherValueReversedOutput>();
       
        List<String> OriginalorderIds = new List<String>();
        Set<String> originalChannels = new Set<String>();
        Set<String> MemberIds = new Set<String>();
        List<Voucher> vouchersToUpdate = new List<Voucher>();
      
        for (CountVoucherValueReversedInput rec : inputs) {

            originalChannels.add(rec.originalChannel);
            OriginalorderIds.add(rec.originalOrderId);
            MemberIds.add(rec.MemberId);

            }
        System.debug('originalChannels = ' + originalChannels);
        System.debug('OriginalorderIds = ' + OriginalorderIds);
        System.debug('MemberIds = ' + MemberIds);
        
        Map<String, Decimal> faceValueTotalsMap = new Map<String, Decimal>();
        for (AggregateResult agg : [SELECT Order_Id_Redeem__c,Status,SUM(FaceValue)TotalFaceValue, TransactionJournal.LoyaltyProgramId , LoyaltyProgramMemberId 
                                                FROM Voucher 
                                                WHERE Status = 'Redeemed' 
                                                AND Order_Id_Redeem__c IN :OriginalorderIds 
                                                AND Order_Id_Redeem_Channel__c IN: originalChannels 
                                                AND LoyaltyProgramMemberId IN: MemberIds
                                                GROUP BY Order_Id_Redeem__c, Status, TransactionJournal.LoyaltyProgramId,LoyaltyProgramMemberId])
                {   
                    String RedeemOrderId = (String) agg.get('Order_Id_Redeem__c');
                    Decimal FVtotalAmount = (Decimal) agg.get('TotalFaceValue');
                    faceValueTotalsMap.put(RedeemOrderId, FVtotalAmount);
                }
        for (CountVoucherValueReversedInput input : inputs) {
            
            CountVoucherValueReversedOutput output = new CountVoucherValueReversedOutput();
           
            output.originalOrderId = input.originalOrderId; 
            output.TotalFaceValueAmt = faceValueTotalsMap.get(input.originalOrderId);
            outputList.add(output);
        }
        System.debug('CountVoucherReversalValueAction:outputList: ' + outputList);
        return outputList;
    }
    
    public class CountVoucherValueReversedInput {
         @InvocableVariable public String originalChannel;
         @InvocableVariable public String originalOrderId;
         @InvocableVariable public String MemberId;
    }
    
    public class CountVoucherValueReversedOutput {
        @InvocableVariable public String originalOrderId;
        @InvocableVariable public Decimal TotalFaceValueAmt;
    }
    
    
}