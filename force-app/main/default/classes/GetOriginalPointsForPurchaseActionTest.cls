@isTest
private class GetOriginalPointsForPurchaseActionTest {
    
    @isTest
    static void testHandleReturnsProcess1() {
        // Create test data
        // 
        
        
        
        
        
        
        // Mock data to be queried
        // 
      
         Contact contact = new Contact();
        contact.LastName = 'Smith';
        contact.Birthdate = Date.Today();
        insert contact;
        
        
        
                JournalType  JournalType = new JournalType();
        		JournalType.Name = GlobalConstants.JOURNAL_TYPE_ACCRUAL;
         		insert JournalType;
        
        JournalSubType  JrnlSubType = new JournalSubType();
        JrnlSubType.Name = GlobalConstants.JOURNAL_SUBTYPE_PURCHASE;
        JrnlSubType.JournalTypeId = JournalType.Id;
         insert JrnlSubType;
        
        

        
          LoyaltyProgram  loyaltyProgram = new LoyaltyProgram();
         loyaltyProgram.Name = 'Just Shop';
          insert loyaltyProgram;
        
        LoyaltyProgramMember programMember = new LoyaltyProgramMember();
		programMember.MembershipNumber = 'TEST Members';
		programMember.MemberStatus = 'Active';
		programMember.EnrollmentDate = Date.Today();
        programMember.MemberType = 'Individual';
        programMember.ContactId = contact.Id;
        programMember.ProgramId = loyaltyProgram.Id;
		insert programMember;
     //SELECT Id,Transaction_Amount_Rounded__c , Channel , Order_ID__c , Order_Item_ID__c , (SELECT Points FROM TransactionJournalLedger) 
     //FROM TransactionJournal where Order_ID__c IN: originalOrderIds 
     //AND JournalSubTypeId =: JournalSUBTypeId AND Order_Item_ID__c IN: originalOrderItemIds AND Channel IN:originalChannels AND Status = 'Processed'   
         TransactionJournal jrnl = new TransactionJournal();
        					jrnl.JournalTypeId = JournalType.Id;
        					jrnl.JournalSubTypeId = JrnlSubType.Id;
                            jrnl.ActivityDate = System.Now();
                            jrnl.JournalDate = System.Now();
                            jrnl.Status = 'Processed';
                            jrnl.LoyaltyProgramId = loyaltyProgram.Id;
                            jrnl.MemberId = programMember.Id;
        					 jrnl.TransactionAmount  = 50;
       					 jrnl.Channel = 'Online';
       					 jrnl.Order_ID__c = '123';
       					 jrnl.Order_Item_ID__c = '456';
    
        insert jrnl; 
        
        
        
        system.debug('jrnl is : ' + jrnl);
        
         List<LoyaltyLedger> ledgersList = new List<LoyaltyLedger>();
         LoyaltyLedger ledger = new LoyaltyLedger();
        ledger.Points = 10;
        ledger.TransactionJournalId = jrnl.Id;
        ledgersList.add(ledger);
		Insert ledgersList;
         system.debug('ledgersList is : ' + ledgersList);
        
		List<GetOriginalPointsForPurchaseAction.HandleReturnsProcessInput> inputs = new List<GetOriginalPointsForPurchaseAction.HandleReturnsProcessInput>();
        GetOriginalPointsForPurchaseAction.HandleReturnsProcessInput input1 = new GetOriginalPointsForPurchaseAction.HandleReturnsProcessInput();
        input1.originalChannel = 'Online';
        input1.originalOrderId = '123';
        input1.originalOrderItemId = '456';
        input1.TransactionAmount = 100;
		input1.memberId = programMember.Id;
        inputs.add(input1);      
        
        // Call the method to be tested
        Test.startTest();
        List<GetOriginalPointsForPurchaseAction.HandleReturnsProcessOutput> outputs = GetOriginalPointsForPurchaseAction.handleReturnsProcess1(inputs);
        Test.stopTest();
        
        // Verify the output
        System.assertEquals(10, ledgersList[0].Points);
    }
}