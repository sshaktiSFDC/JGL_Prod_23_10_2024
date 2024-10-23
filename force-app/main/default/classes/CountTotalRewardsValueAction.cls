/**
* @name         : CountTotalRewardsValueAction
* @description  : Invocable action to Calculate Total Rewards for Process Rule
* @testClass    : CountTotalRewardsValueActionTest
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-07-31    Nicholas Then     Created
*/



public class CountTotalRewardsValueAction {
 @InvocableMethod(label='CountTotalRewardsValueAction.cls: CountTotalRewardsValue')
     
    public static List<CountTotalRewardsValueOutput> CalcCountTotalRewardsValue(List<CountTotalRewardsValueInput> inputs) {
        system.debug('CountTotalRewardsValueAction.cls: ' + inputs.size());
       
        List<CountTotalRewardsValueOutput> outputList = new List<CountTotalRewardsValueOutput>();
       
        
        Set<String> MemberIds = new Set<String>();
        
        List<Voucher> vouchersToUpdate = new List<Voucher>();
      
        for (CountTotalRewardsValueInput rec : inputs) {

                  MemberIds.add(rec.MemberId);

            }
        
        System.debug('MemberIds = ' + MemberIds);
        
        Map<String, Decimal> TotalRewardsMap = new Map<String, Decimal>();
        
        for (AggregateResult agg : [SELECT Status,SUM(FaceValue)TotalFaceValue,  LoyaltyProgramMemberId 
                                                FROM Voucher 
                                                WHERE Status = 'Issued' 
                                                AND LoyaltyProgramMemberId IN: MemberIds
                                                AND ExpirationDate > TODAY
                                                GROUP BY  Status, LoyaltyProgramMemberId])
                {   
                    String ProgramMemberId = (String)agg.get('LoyaltyProgramMemberId');
                    Decimal totalRewardAmount = (Decimal) agg.get('TotalFaceValue');
                    TotalRewardsMap.put(ProgramMemberId, totalRewardAmount);
                    System.Debug('CountTotalRewardsValueAction.cls: TotalRewardsMap' + TotalRewardsMap);
                }
        
        for (CountTotalRewardsValueInput input : inputs) {
            
            CountTotalRewardsValueOutput output = new CountTotalRewardsValueOutput();
            Id MemberId18 = (Id)input.MemberId;
           
            output.TotalRewardsAmt =  TotalRewardsMap.get(MemberId18);
            outputList.add(output);
        }
        System.debug('CountTotalRewardsValueAction:outputList: ' + outputList);
        return outputList;
    }
    
    public class CountTotalRewardsValueInput {
        
         @InvocableVariable public String MemberId;
    }
    
    public class CountTotalRewardsValueOutput {
       
        @InvocableVariable public Decimal TotalRewardsAmt;
    }
    
    
    
    
    
}