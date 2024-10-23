@isTest
public class WalletServiceCalloutTest {
	@testSetup
    static void testSetup() {
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
        
       System.debug('programMember---->'+ programMember);
        
    }
    
    @isTest
    static void testSyncLogMessage() {
        LoyaltyProgramMember programMember = [Select Id,MembershipNumber from LoyaltyProgramMember  limit 1];
        String message = 'Test Message';
        String status = 'Success';
        String memberId = programMember.Id; // Use a valid member ID
        
        // Call the method to be tested
        Test.setMock(HttpCalloutMock.class, new WalletServiceCalloutMock());
        WalletServiceCallout.WalletRequest ww = new WalletServiceCallout.WalletRequest();
        ww.memberId = programMember.id;
        ww.lastName = 'Test';
        ww.firstName = 'test';
        ww.membershipNumber = programMember.MembershipNumber;
        ww.nextRewardPoints = 10;
        ww.totalRewards = 10 ;
        List<WalletServiceCallout.WalletRequest> payload = new List<WalletServiceCallout.WalletRequest>();
        payload.add(ww);
        try{
        Test.startTest();
        WalletServiceCallout.makeCallout(payload);
        Test.stopTest();  
        }catch(Exception ex){
            
        }
    }
}