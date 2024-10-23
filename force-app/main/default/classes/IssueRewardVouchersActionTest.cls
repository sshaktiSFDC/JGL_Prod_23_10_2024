/**
* @name         : IssueRewardVouchersActionTest
* @description  : This test class is for IssueRewardVouchersAction
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-30    Surya Nath Dixit         Created
*/ 

@isTest
private class IssueRewardVouchersActionTest {

    // Test method to cover positive scenario
    @isTest
    static void testIssueRewardVouchers() {
        // Create test data
        List<LoyaltyProcessFlowWrapper.FlowInput> inputs = new List<LoyaltyProcessFlowWrapper.FlowInput>();
        
         Contact contact = new Contact();
        contact.LastName = 'Smith';
        contact.Birthdate = Date.Today();
        insert contact;
        
        LoyaltyProgram  loyaltyProgram = new LoyaltyProgram();
         loyaltyProgram.Name = 'Just Shop';
          insert loyaltyProgram;
        
         LoyaltyProgramMember programMember = new LoyaltyProgramMember();
		programMember.MembershipNumber = 'TEST1234';
		programMember.MemberStatus = 'Active';
		programMember.EnrollmentDate = Date.Today();
        programMember.MemberType = 'Individual';
        programMember.ContactId = contact.Id;
        programMember.ProgramId = loyaltyProgram.Id;
		insert programMember;
        
        VoucherDefinition vd = new VoucherDefinition(
            Name = 'Reward',
            ExpirationType = 'Period',
            EffectiveDate = Date.today(),
            LoyaltyProgramId = loyaltyProgram.Id,
            IsActive = true,
            ExpirationPeriod = 60,
            Minimum_Spend__c = 10, ExpirationPeriodUnit ='Days', Type = 'FixedValue', FaceValue = 15
        );
        insert vd;

        // Create a test input object
        LoyaltyProcessFlowWrapper.FlowInput input = new LoyaltyProcessFlowWrapper.FlowInput();
        input.memberId = programMember.Id;
        input.totalVouchersToIssue = 3; // Change this value as needed
        input.orderId = 'ABC';
       
        // Add the input object to the list
        inputs.add(input);

        // Call the method to test
        Test.startTest();
        List<LoyaltyProcessFlowWrapper.FlowOutput> outputs = IssueRewardVouchersAction.issueRewardVouchers(inputs);
        Test.stopTest();
        
        
    }

    
}