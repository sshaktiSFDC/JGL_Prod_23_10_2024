/**
* @name         : ProcessRewardsActionTest
* @description  : This is the test class of ProcessRewardsAction.
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-24    Surya Nath Dixit         Created
*/ 

@isTest
private class ResetReturnTrackingEventActionTest {
    @isTest
    static void testPublishJournalEvent() {
        // Test data setup: Create a list of ResetReturnEAEventInput inputs
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
        
        
        
        List<ResetReturnTrackingEventAction.ResetReturnEAEventInput> inputs = new List<ResetReturnTrackingEventAction.ResetReturnEAEventInput>();
        ResetReturnTrackingEventAction.ResetReturnEAEventInput input = new ResetReturnTrackingEventAction.ResetReturnEAEventInput();
        input.ActivityDate = Datetime.now();
        input.MemberId = programMember.Id;
        input.ProgramId = loyaltyProgram.Id;
        inputs.add(input);
        
        

       // Call the publishJournalEvent method
        Test.startTest();
        ResetReturnTrackingEventAction.publishJournalEvent(inputs);
        Test.stopTest();

       /* // Verify that Reset_Return_Tracking_EA__e events are published
        List<Reset_Return_Tracking_EA__e> publishedEvents = [SELECT Id FROM Reset_Return_Tracking_EA__e];
        System.assertEquals(1, publishedEvents.size(), 'One Reset_Return_Tracking_EA__e event should be published');
        Reset_Return_Tracking_EA__e publishedEvent = publishedEvents[0];

        // Perform additional assertions if needed
        System.assertEquals(input.MemberId, publishedEvent.Member_Id__c, 'MemberId should match');
        System.assertEquals(input.ProgramId, publishedEvent.Program_Id__c, 'ProgramId should match');
        System.assertEquals(input.ActivityDate, publishedEvent.Activity_Date__c, 'ActivityDate should match');*/
        
    }
}