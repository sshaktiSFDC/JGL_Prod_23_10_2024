/**
* @name         : ProcessRewardsActionTest
* @description  : This is the test class of ProcessRewardsAction.
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-24    Surya Nath Dixit         Created
*/ 

@isTest
private class ProcessRewardsActionTest {

    @isTest
    static void testProcessRewards() {
        // Test data setup
        // 
       
         Contact contact = new Contact();
        contact.LastName = 'Test Contact';
        contact.Birthdate = Date.Today();
        insert contact;
        
        LoyaltyProgram  loyaltyProgram = new LoyaltyProgram();
         loyaltyProgram.Name = 'Just Shop';
          insert loyaltyProgram;
        
        
        LoyaltyProgramMember programMember = new LoyaltyProgramMember();
		programMember.MembershipNumber = 'TEST Member';
		programMember.MemberStatus = 'Active';
		programMember.EnrollmentDate = Date.Today();
        programMember.MemberType = 'Individual';
        programMember.ContactId = contact.Id;
        programMember.ProgramId = loyaltyProgram.Id;
		insert programMember;
        
        
        List<LoyaltyProcessFlowWrapper.FlowInput> inputs = new List<LoyaltyProcessFlowWrapper.FlowInput>();
        LoyaltyProcessFlowWrapper.FlowInput input = new LoyaltyProcessFlowWrapper.FlowInput();
        input.memberId = programMember.Id;
        input.programId = loyaltyProgram.Id;
        input.orderId = 'TestOrderId';
        input.orderItemId = 'TestOrderItemId';
        input.totalRewards = 100;
        input.totalPointsToDebit = 50;
        input.totalVouchersToIssue = 2;
        input.eventType = 'TestEventType';
        input.channel = 'TestChannel';
        inputs.add(input);

        Test.startTest();
        // Call the processRewards method
        List<LoyaltyProcessFlowWrapper.FlowOutput> outputs = ProcessRewardsAction.processRewards(inputs);
        Test.stopTest();

        // Add assertions to verify the behavior
        System.assertEquals(1, outputs.size(), 'Output list should contain one item');
        LoyaltyProcessFlowWrapper.FlowOutput output = outputs[0];
        // Add more assertions to verify the output data if needed
    }
}