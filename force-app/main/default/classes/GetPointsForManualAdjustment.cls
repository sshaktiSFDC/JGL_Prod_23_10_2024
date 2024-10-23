public class GetPointsForManualAdjustment {

    
    @InvocableMethod(label='Cls: GetPointsForManualAdjustment: ExtractPointsAdjAndType ')
    
    public static List<ExtractPointsAdjustmentOutput> ExtractPointsAdjAndType(List<ExtractPointsAdjustmentInput> inputs) {
 
    System.debug('ExtractPointsAdjAndType Action:' + inputs);
    System.debug('ExtractPointsAdjAndType Action size:' + inputs.size());
    
    List<ExtractPointsAdjustmentOutput> outputList = new List<ExtractPointsAdjustmentOutput>();
    
  
    Id JournalTypeId = LoyaltyRuntimeHelper.journalTypeIdMappings.get(GlobalConstants.JOURNAL_TYPE_MANUALPOINTSADJUSTMENT);
    Set<String> memberIds = new Set<String>();
    Set<String> journalIds = new Set<String>();
   
   
   
    for (ExtractPointsAdjustmentInput rec : inputs) {
        
        memberIds.add(rec.memberId);
        journalIds.add(rec.journalId);

            for(TransactionJournal tj : [SELECT Id, (SELECT Points, EventType FROM TransactionJournalLedger) 
                                         FROM TransactionJournal 
                                         where  JournalTypeId =: JournalTypeId 
                                         AND Id IN: journalIds 
                                         AND MemberId IN:memberIds 
                                         AND Status = 'Processed']) {
          
                  
                    Integer totalLineItemLedgerPoints = 0;
                    String adjustmentEventType = '';
              
                
                    // ledger level for each Journal:
                    for(LoyaltyLedger led : tj.TransactionJournalLedger) {
                    
                    System.debug('Points: ' + (Integer)Math.roundToLong(led.Points));
                    totalLineItemLedgerPoints += (Integer)Math.roundToLong(led.Points);
                    adjustmentEventType = led.EventType;    
                     }
                   
             ExtractPointsAdjustmentOutput output = new ExtractPointsAdjustmentOutput();
          
             output.LedgerPoints = totalLineItemLedgerPoints;
             output.EventType = adjustmentEventType;
			 System.debug('ExtractPointsAdjAndType output : '+ output);
             outputList.add(output);
                
            }
           
    }
             System.debug(outputList);
             System.debug('ExtractPointsAdjAndType output size: '+ outputList.size());
             return outputList;
            


    }

        public class ExtractPointsAdjustmentInput {
           
            @InvocableVariable public String memberId;
            @InvocableVariable public String journalId;
           
        }
        
        public class ExtractPointsAdjustmentOutput {
           
           
           
            @InvocableVariable public String EventType;
            @InvocableVariable public Integer LedgerPoints;
  
          }
}