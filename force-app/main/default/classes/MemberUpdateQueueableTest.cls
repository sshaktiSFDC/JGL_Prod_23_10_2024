@isTest
public class MemberUpdateQueueableTest {
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
    public static void testQueuableTestWithoutStartStop(){

		// Create test Voucher records
        Contact contact = new Contact();
        contact.LastName = 'Smith';
        contact.Birthdate = Date.Today();
        insert contact;
        
        //Create journal Types
        JournalType tjType = new JournalType(
            Name = 'Redemption',
            ProcessType = 'Loyalty'
        );
        insert tjType;

        //Create journal subTypes
        JournalSubType tjSubType = new JournalSubType(
            Name = 'Reward',
            JournalTypeId = tjType.Id
        );
        insert tjSubType;
        Test.startTest();
        //Create Loyalty Program
        LoyaltyProgram loyaltyProgram = TestDataFactory.createLoyaltyProgram();
        insert loyaltyProgram;
        
        //Create Voucher Definition
        VoucherDefinition vd = TestDataFactory.createVoucherDefinition(loyaltyProgram.Id, GlobalConstants.VOUCHER_DEFINITION_REWARD);
        insert vd;

                
        LoyaltyProgramMember programMember = new LoyaltyProgramMember();
		programMember.MembershipNumber = 'TEST1234';
		programMember.MemberStatus = 'Active';
		programMember.EnrollmentDate = Date.Today();
        programMember.MemberType = 'Individual';
        programMember.ContactId = contact.Id;
        programMember.ProgramId = loyaltyProgram.Id;
		insert programMember;
        test.stopTest();
        Test.setMock(HttpCalloutMock.class, new WalletServiceMock(programMember.Id));
        Set<Id> memberIds = new Set<Id>();
        memberIds.add(programMember.Id); 
        Id jobId = System.enqueueJob(new MemberUpdateQueueable(memberIds, 1)); 
        System.debug('queuableTestWithoutStartStop [jobId]: ' + jobId);
        System.assertNotEquals('Completed' ,[SELECT Id , Status FROM AsyncApexJob WHERE Id=:jobId][0].Status); 

    }

    /*
    @isTest
    public static void testQueuableTestWithStartStop(){

        Test.startTest();
        Id jobId = System.enqueueJob(new MemberUpdateQueueable());
        System.debug('queuableTestWithStartStop [jobId]: ' + jobId);
        Test.stopTest();

        System.assertEquals('Completed' , [SELECT Id , Status FROM AsyncApexJob WHERE Id=:jobId][0].Status);

    }*/
}