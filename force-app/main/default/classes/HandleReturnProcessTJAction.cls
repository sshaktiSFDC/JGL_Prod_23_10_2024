/**
* @name         : HandleReturnProcessTJAction
* @description  : Invocable action to process Returns Part 2
* @testClass    : HandleReturnProcessTJActionTest
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-04-09    Siddharth Singh     Created
*/
public class HandleReturnProcessTJAction {
    
    @InvocableMethod(label='HandleReturnProcessTJAction.cls: Handle Returns Process2')
    public static List<HandleReturnsProcessOutput> handleReturnsProcess2(List<HandleReturnsProcessInput> inputs) {
        system.debug(inputs.size());
        List<HandleReturnsProcessOutput> outputList = new List<HandleReturnsProcessOutput>();
        Id JournalSUBTypeId = LoyaltyRuntimeHelper.journalSubTypeIdMappings.get(GlobalConstants.JOURNAL_SUBTYPE_PURCHASE);
        Set<String> originalOrderIds = new Set<String>();
        Set<String> memberIds = new Set<String>();
        for (HandleReturnsProcessInput rec : inputs) {
            originalOrderIds.add(rec.originalOrderId);
            memberIds.add(rec.memberId);
        }
        
         System.debug('HandleReturnProcessTJAction:originalOrderIds: ' + originalOrderIds);
         System.debug('HandleReturnProcessTJAction:memberIds: ' + memberIds);
        
        Map<String, Decimal> orderTotalsMap = new Map<String, Decimal>();
        for (AggregateResult agg : [SELECT Order_ID__c, SUM(Transaction_Amount_Rounded__c)totalAmount 
                                    FROM TransactionJournal WHERE MemberId IN:memberIds AND Order_ID__c IN :originalOrderIds 
                                    AND JournalSubTypeId =: JournalSUBTypeId GROUP BY Order_ID__c]) {
            String orderId = (String) agg.get('Order_ID__c');
            Decimal totalAmount = (Decimal) agg.get('totalAmount');
            orderTotalsMap.put(orderId, totalAmount);
        }
        
        HandleReturnsProcessOutput output = new HandleReturnsProcessOutput();
        output.ConcatenatedoriginalTJAmt = '';
        for (HandleReturnsProcessInput input : inputs) {
           
            output.originalOrderId = input.originalOrderId;
            output.originalTJAmt = orderTotalsMap.get(input.originalOrderId);
            output.ConcatenatedoriginalTJAmt = output.ConcatenatedoriginalTJAmt + input.originalOrderId + '@' + orderTotalsMap.get(input.originalOrderId) + '@';
            outputList.add(output);
        }
        System.debug('HandleReturnProcessTJAction:outputList: ' + outputList);
        return outputList;
    }
    
    public class HandleReturnsProcessInput {
        @InvocableVariable public String originalOrderId;
        @InvocableVariable public String memberId;
    }
    
    public class HandleReturnsProcessOutput {
        @InvocableVariable public String originalOrderId;
        @InvocableVariable public Decimal originalTJAmt;
        @InvocableVariable public String ConcatenatedoriginalTJAmt;
    }
}