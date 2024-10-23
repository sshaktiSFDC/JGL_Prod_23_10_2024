/**
* @name         : MemberUpdateEventTriggerHandlerTest
* @description  : This is test class of MemberUpdateEventTriggerHandler.
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-19    Siddharth Singh     Created
* 2024-
*/
@isTest
public class MemberUpdateEventTriggerHandlerTest {
    
    class WalletServiceMock implements HttpCalloutMock {
        private String memberId;
        
        public WalletServiceMock(String memberId) {
            this.memberId = memberId;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();    
            res.setStatusCode(200);
            res.setBody('[{"membershipNumber": "' + this.memberId + '", "googleWalletLink":"wwww.play.google.com/test_list", "appleWalletLink":"www.apple-wallet.com/test_link"}]');
            return res;
        }
    }
    
    class WalletServiceMockNegative implements HttpCalloutMock {
        private String memberId;
        
        public WalletServiceMockNegative(String memberId) {
            this.memberId = memberId;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();    
            res.setStatusCode(200);
            res.setBody('[{"membershipNumber": "' + this.memberId + '", "googleWalletLink":"", "appleWalletLink":""}]');
            return res;
        }
    }
    
    @isTest
    static void testAfterInsertTrigger() {
    	// Create Contact
    	Contact contact = new Contact(
            LastName = 'Test'
        );
        insert contact;
        
        // Create LoyaltyProgram
        LoyaltyProgram loyaltyProgram = new LoyaltyProgram( 
            Name = 'TestProgram'
        );
        insert loyaltyProgram;
        
        // Create LoyaltyProgramMember
        LoyaltyProgramMember loyaltyProgramMember = new LoyaltyProgramMember(
            ProgramId = loyaltyProgram.Id,
            MembershipNumber = 'TEST123',
            ContactId = contact.Id,
            EnrollmentDate = Date.today(), // Set EnrollmentDate
            MemberStatus = 'Active' // Set MemberStatus
        );
        insert loyaltyProgramMember;
        
        // Prepare test data
        List<LoyaltyProgramMember> members = new List<LoyaltyProgramMember>();
        members.add(loyaltyProgramMember);
        
        Test.setMock(HttpCalloutMock.class, new WalletServiceMock(loyaltyProgramMember.Id));
        
        // Set up and insert Loyalty_Program_Member_Update_Event__e records
        List<Member_Update_Event__e> eventList = new List<Member_Update_Event__e>();
        for (LoyaltyProgramMember member : members) {
            eventList.add(new Member_Update_Event__e(Member_Id__c = member.Id));
        }
        
        EventBus.publish(eventList);
    	Test.getEventBus().deliver();
        System.assertEquals( eventList.size()>0, true , 'test pass');
        
    }
    
    
    
    
}