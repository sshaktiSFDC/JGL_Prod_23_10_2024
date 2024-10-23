/**
* @name         : WalletServiceLogUtilityTest
* @description  : Test class for WalletServiceLogUtility
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-22    Vince Vuong         Created
*/
@isTest
private class WalletServiceLogUtilityTest {

   /* @isTest
    static void testCreateWalletServiceLog(){

        WalletServiceLogUtility.logMessage('This is a test log message','Success',null);
        WalletServiceLogUtility.commitlog();*/


//Updated logic
//

    @isTest
    static void testSyncLogMessage() {
        // Create test data
        
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
        
        
        String message = 'Test Message';
        String status = 'Success';
        String memberId = programMember.Id; // Use a valid member ID
        
        // Call the method to be tested
        WalletServiceLogUtility.logMessage(message, status, memberId);
        
        
    }
    
    @isTest
    static void testCommitLog() {
        // Create test data
        Contact contact = new Contact();
        contact.LastName = 'Smith1';
        contact.Birthdate = Date.Today();
        insert contact;
        
        LoyaltyProgram  loyaltyProgram = new LoyaltyProgram();
         loyaltyProgram.Name = 'Just Shop';
          insert loyaltyProgram;
        
         LoyaltyProgramMember programMember = new LoyaltyProgramMember();
		programMember.MembershipNumber = 'TEST12345';
		programMember.MemberStatus = 'Active';
		programMember.EnrollmentDate = Date.Today();
        programMember.MemberType = 'Individual';
        programMember.ContactId = contact.Id;
        programMember.ProgramId = loyaltyProgram.Id;
		insert programMember;
        
        
        String message = 'Test Message';
        String status = 'Success';
        String memberId = programMember.Id; // Use a valid member ID
        WalletServiceLogUtility.logMessage(message, status, memberId);
        
        String jsonString = 'Test';
        Boolean isResponseBody = True;
        
        // Call the method to be tested
        Test.startTest();
        WalletServiceLogUtility.commitLog();
        WalletServiceLogUtility.logPrettyServiceJSON(jsonString,isResponseBody);
        WalletServiceLogUtility.isJSON('test');
        WalletServiceLogUtility.logPrettyServiceXML('test');
        Test.stopTest();
        
        
    }
    
    
}