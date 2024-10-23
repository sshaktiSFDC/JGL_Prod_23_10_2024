public class GetOriginalPointsForPurchaseAction {

@InvocableMethod(label='Cls: GetOriginalPointsForPurchaseAction: Handle Return Process And Return Points Credited')
    
public static List<HandleReturnsProcessOutput> handleReturnsProcess1(List<HandleReturnsProcessInput> inputs) {
 
    System.debug('ReturnInputs Action:' + inputs);
    System.debug('ReturnInputs Action size:' + inputs.size());
    
    List<HandleReturnsProcessOutput> outputList = new List<HandleReturnsProcessOutput>();
    
    Id JournalSUBTypeId = LoyaltyRuntimeHelper.journalSubTypeIdMappings.get(GlobalConstants.JOURNAL_SUBTYPE_PURCHASE);
    Id JournalTypeId = LoyaltyRuntimeHelper.journalTypeIdMappings.get(GlobalConstants.JOURNAL_TYPE_ACCRUAL);

    System.debug('GetOriginalPointsForPurchaseAction:JournalSubTypeId:' + JournalSUBTypeId + '; JournalTypeId: ' + JournalTypeId);
    
    Integer perOrdertotalReturnAmount = 0;
    String perOrderReturnChannel = '';
    String returnChannelValueOutput = '';
    String ReturnTransactionOrderId = '' ;
    Set<String> originalOrderIds = new Set<String>();
    Set<String> originalOrderItemIds = new Set<String>();
    Set<String> originalChannels = new Set<String>();
    Set<String> memberIds = new Set<String>();
    Set<String> returnOrderIds = new Set<String>();
    Set<String> returnOrderItemIds = new Set<String>();
    Set<String> returnChannels = new Set<String>();
    Map<String, Integer> OrderIdItemChannelVsAmt = new Map<String, Integer>();
    Map<String, String> returnOrderIdItemChannelVsOriKeys = new Map<String, String>();
    Map<String, String> oriOrderIdItemChannelVsreturnKeys = new Map<String, String>();
    Map<String, String> returnOrderIdItemChannelVsoriOrderIdKeys = new Map<String, String>();
    Map<String, String> returnOrderIdItemChannelVsReturnOrderIdKeys = new Map<String, String>();
    Map<String, Integer> TotalReturnAmountbyOriOrderIdMap = new Map<String, Integer>();
    Map<String, String> OrderIdReturnChannelMap = new Map<String, String>();
   
    for (HandleReturnsProcessInput rec : inputs) {
        originalOrderIds.add(rec.originalOrderId);
        originalChannels.add(rec.originalChannel);
        originalOrderItemIds.add(rec.originalOrderItemId);
        memberIds.add(rec.memberId);
        ReturnTransactionOrderId = (rec.returnOrderId);
        OrderIdItemChannelVsAmt.put(rec.originalOrderId+rec.originalOrderItemId+rec.originalChannel, rec.TransactionAmount);
        returnOrderIdItemChannelVsOriKeys.put(rec.returnOrderId+rec.returnOrderItemId+rec.returnChannel,rec.originalOrderId+rec.originalOrderItemId+rec.originalChannel);
        returnOrderIdItemChannelVsoriOrderIdKeys.put(rec.returnOrderId+rec.returnOrderItemId+rec.returnChannel,rec.originalOrderId);
        returnOrderIdItemChannelVsReturnOrderIdKeys.put(rec.returnOrderId+rec.returnOrderItemId+rec.returnChannel,rec.returnOrderId);
        oriOrderIdItemChannelVsreturnKeys.put(rec.originalOrderId+rec.originalOrderItemId+rec.originalChannel,rec.returnOrderId+rec.returnOrderItemId+rec.returnChannel);
       
        
        
        returnChannelValueOutput = rec.returnChannel;
        
        // group total transaction amount by return OrderId & return Channel by return OrderId
        
        String returnOrderAmtGrpKey = rec.originalOrderId;
        String returnOrderKey = rec.returnOrderId;
          
        
        // this is to extract Total Return Amount by Original Order ID 
           if ( TotalReturnAmountbyOriOrderIdMap.containsKey(returnOrderAmtGrpKey)) {
                
		        perOrdertotalReturnAmount = TotalReturnAmountbyOriOrderIdMap.get(returnOrderAmtGrpKey) + rec.TransactionAmount;
		        TotalReturnAmountbyOriOrderIdMap.put(returnOrderAmtGrpKey,perOrdertotalReturnAmount);
            
	         } else {

		        TotalReturnAmountbyOriOrderIdMap.put(returnOrderAmtGrpKey, rec.TransactionAmount);
      
	         }  
       
        
       // this is to extract Channel value on per Return Order ID - to be used to extract those that did not find matching journals
        if ( OrderIdReturnChannelMap.containsKey(returnOrderKey)) {
                
		        perOrderReturnChannel = OrderIdReturnChannelMap.get(returnOrderKey) ;
		        OrderIdReturnChannelMap.put(returnOrderKey,perOrderReturnChannel);
            
	         } else {

		        OrderIdReturnChannelMap.put(returnOrderKey, rec.returnChannel);
      
	         }  
        
        
    }
      system.debug('Return Action :TotalReturnAmountbyOriOrderIdMap ' + TotalReturnAmountbyOriOrderIdMap);
      system.debug('Return Action :returnOrderIdItemChannelVsoriOrderIdKeys ' + returnOrderIdItemChannelVsoriOrderIdKeys);
      system.debug('Return Action :OrderIdReturnChannelMap ' + OrderIdReturnChannelMap);
    
    Integer LineItemtotalPoints = 0; // this is totalpoints to be reversed for each lineitem 
    Integer PerOrderTotalPoints = 0; // this is totalpoints to be reversed for all lineitems in a single Order  
  
  
  
  
    // this for loop returns all Journals of original order for all (multiple) orders potentially
    Map<String, List<TransactionJournal>> OrderIdJournalsMap = new Map<String, List<TransactionJournal>>(); //map for each Order and its list of lineitem Journals
  
    for(TransactionJournal tj : [SELECT Id,Transaction_Amount_Rounded__c , Channel , Order_ID__c , Order_Item_ID__c , (SELECT Points FROM TransactionJournalLedger) 
                                 FROM TransactionJournal 
                                 where Order_ID__c IN: originalOrderIds 
                                 AND JournalSubTypeId =: JournalSUBTypeId 
                                 AND Order_Item_ID__c IN: originalOrderItemIds 
                                 AND Channel IN:originalChannels 
                                 AND MemberId IN:memberIds 
                                 AND Status = 'Processed']) {
       
      if ( OrderIdJournalsMap.containsKey(tj.Order_ID__c)) {
		    List<TransactionJournal> Journals = OrderIdJournalsMap.get(tj.Order_ID__c);
		    Journals.add(tj);
		    OrderIdJournalsMap.put(tj.Order_ID__c, Journals);
            
	} else {

		OrderIdJournalsMap.put(tj.Order_Id__c, new List<TransactionJournal> {tj});
      
	}  
           
        System.debug('OrderIdJournalsMap size : ' + OrderIdJournalsMap.size());
                                   
       
    }
   

    Map<String,Integer> perOrderOutputMap = new Map<String,Integer>(); // Map for per OrderId total points to be reversed ie originally credited
    Map<String,Integer> OrderIdItemChannelOutputMap = new Map<String,Integer>();//Map for OrderId and lineitem reversal points - likely be multiple lineitems
    
    for (String oriOrderId : OrderIdJournalsMap.keyset()) {
     List<TransactionJournal> perOrderTJs = OrderIdJournalsMap.get(oriOrderId);
    
        for (TransactionJournal pOTJ: perOrderTJs){
          
            Integer totalLineItemJournalPoints = 0;
      
            System.debug('GetOriginalPointsForPurchaseAction:tj.TransactionJournalLedger: ' + pOTJ.TransactionJournalLedger);
            // ledger level for each Journal:
            for(LoyaltyLedger led : pOTJ.TransactionJournalLedger) {
            
            System.debug('Points: ' + (Integer)Math.roundToLong(led.Points));
            totalLineItemJournalPoints += (Integer)Math.roundToLong(led.Points);
            }
        
            // journal level for each Order:   
            String OutputmapKey = pOTJ.Order_ID__c + pOTJ.Order_Item_ID__c + pOTJ.Channel;
           
            
            if (OrderIdItemChannelVsAmt.containsKey(OutputmapKey)) {
                Integer returnTransactionAmount = OrderIdItemChannelVsAmt.get(OutputmapKey);
                // Divide TransactionAmount from the map by Transaction_Amount_Rounded__c and multiply by totalJournalPoints
                System.debug('returnTransactionAmount = ' + returnTransactionAmount);
                System.debug('pOTJ.Transaction_Amount_Rounded__c = ' + pOTJ.Transaction_Amount_Rounded__c);
                System.debug('totalLineItemJournalPoints = ' + totalLineItemJournalPoints);
                
                LineItemtotalPoints = (Integer)Math.roundToLong(((returnTransactionAmount / pOTJ.Transaction_Amount_Rounded__c) * totalLineItemJournalPoints));
             
                PerOrdertotalPoints += (Integer)Math.roundToLong(((returnTransactionAmount / pOTJ.Transaction_Amount_Rounded__c) * totalLineItemJournalPoints));
                
                System.debug('GetOriginalPointsForPurchaseAction:LineItemTotal Points : ' + LineItemtotalPoints);
              }
                
           OrderIdItemChannelOutputMap.put(OutputmapKey,LineItemtotalPoints);
            
              } 
        
        
        //once all journals for each order is calculated - update for per Order total:
        System.debug('GetOriginalPointsForPurchaseAction:PerOrderTotal Points : ' + PerOrdertotalPoints);
        perOrderOutputMap.put(oriOrderId,PerOrdertotalPoints );
    }
   
    //section to handle No Receipt of original order returns
    for (HandleReturnsProcessInput input : inputs ){
         String NoReceiptKey = input.returnOrderId + input.returnOrderItemId + input.returnChannel;
         String MatchingOriKey = returnOrderIdItemChannelVsOriKeys.get(NoReceiptKey) ;
                
       
        
        If (!OrderIdItemChannelOutputMap.containsKey(MatchingOriKey)){
            
            OrderIdItemChannelOutputMap.put(NoReceiptKey,input.TransactionAmount);
        }
        
        
    }        
    
                
                
            HandleReturnsProcessOutput output = new HandleReturnsProcessOutput();
            
            output.ConcatenatedTotalReturnOrderAmount = '';
            output.ConcatenatedOutput = '';
            output.ConcatenatedreturnChannelValue = '';
       
    // OUTPUT1: this section handles output for those lineitems that MATCHED original journals
    
            for (String oriOrderId : OrderIdJournalsMap.keyset())  {    // for each Order in a multiple original order scenario
        
            
                         for (String oriKey : OrderIdItemChannelVsAmt.keyset()){
                             String returnkey = oriOrderIdItemChannelVsreturnKeys.get(oriKey);
                             String originalOrderId = returnOrderIdItemChannelVsoriOrderIdKeys.get(returnkey);
                             String returnOrderId = returnOrderIdItemChannelVsReturnOrderIdKeys.get(returnkey);
                           
                             if (oriKey.contains(oriOrderId)){
                                 
                             for (String perOriOrderIdKey :TotalReturnAmountbyOriOrderIdMap.keyset() ){
                       		 if (perOriOrderIdKey.contains(originalOrderId)){
                   				 
                             output.ConcatenatedTotalReturnOrderAmount = output.ConcatenatedTotalReturnOrderAmount + returnkey + '@' +
                                                               string.valueof(TotalReturnAmountbyOriOrderIdMap.get(perOriOrderIdKey)) + '@'; 
                           
                             output.ConcatenatedreturnChannelValue = output.ConcatenatedreturnChannelValue + returnOrderId + '@' +
                                                               OrderIdReturnChannelMap.get(returnOrderId) + '@';
                                 
                           		  }
                                 
                            
          					 }    
                             

                             output.ConcatenatedOutput = output.ConcatenatedOutput + oriOrderIdItemChannelVsreturnKeys.get(oriKey) +
                                                         oriKey + '@' + OrderIdItemChannelOutputMap.get(oriKey) + '@' ;
                             
                                 System.debug('Returns Action output : '+ output);
                             outputList.add(output);
                            }  
                         }
                         
                     }
             
    // OUTPUT2: this section handles output for those lineitems that had NO-RECEIPT or NON-MATCHED for original journals       
         
            for (String noReceiptkey : returnOrderIdItemChannelVsOriKeys.keyset()){           //this keyset has all lineitems irrespective if there was a journal match found
                String matchingOriKey = returnOrderIdItemChannelVsOriKeys.get(noReceiptkey) ; // get oriKey
                
                
                if (!OrderIdItemChannelOutputMap.containsKey(matchingOriKey)){ 					// using oriKey to filter which ones did not have a match
                 																  system.debug('Return Action: no matching journals found for : ' + noReceiptkey);
                    
                    for (String perOriOrderIdKey :TotalReturnAmountbyOriOrderIdMap.keyset() ){  /*this keyset has the each grouped OriginalOrderId of
                        																		 the multiple original OrderId being returned */
                       
                    if (matchingOriKey.contains(perOriOrderIdKey)){
                    
                   output.ConcatenatedTotalReturnOrderAmount = output.ConcatenatedTotalReturnOrderAmount + perOriOrderIdKey + '@' +
                                                               string.valueof(TotalReturnAmountbyOriOrderIdMap.get(perOriOrderIdKey)) + '@'; 
                           
                   output.ConcatenatedreturnChannelValue = output.ConcatenatedreturnChannelValue + ReturnTransactionOrderId + '@' +
                                                           OrderIdReturnChannelMap.get(ReturnTransactionOrderId) + '@';
                   
                                   
                   system.debug(' output.ConcatenatedreturnChannelValue = ' +  output.ConcatenatedreturnChannelValue);
                        }
          			 }
                   
                   output.ConcatenatedOutput = output.ConcatenatedOutput + noReceiptkey +
                                                         returnOrderIdItemChannelVsOriKeys.get(noReceiptkey) + '@' +
                                                         OrderIdItemChannelOutputMap.get(noReceiptkey) + '@' ;
                  
                   
         
                   System.debug('Returns Action output no receipt: '+ output);
                   outputList.add(output);
               }
        
             }
    
   
    
       
        
    System.debug(outputList);
    System.debug('Returns Action output size: '+ outputList.size());
    return outputList;
            
}



public class HandleReturnsProcessInput {
    @InvocableVariable public String originalChannel;
    @InvocableVariable public String originalOrderId;
    @InvocableVariable public String originalOrderItemId;
    @InvocableVariable public Integer TransactionAmount;
    @InvocableVariable public String memberId;
    @InvocableVariable public String returnChannel;
    @InvocableVariable public String returnOrderId;
    @InvocableVariable public String returnOrderItemId;
}

public class HandleReturnsProcessOutput {
   
   
    @InvocableVariable public String ConcatenatedreturnChannelValue;
    @InvocableVariable public String ConcatenatedTotalReturnOrderAmount;
    @InvocableVariable public String ConcatenatedOutput;
   
   
    
}
}