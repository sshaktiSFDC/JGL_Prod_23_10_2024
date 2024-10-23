/**
* @name        : PointsExpirationBatchTest
* @description  : This is test class of PointsExpirationBatch class.
* @testClass    : PointsExpirationBatchTest
* 2024-04-08    : Surya Nath Dixit      Created
* 2024-04-08    : Surya Nath Dixit      Modified
 */
@isTest
private class PointsExpirationBatchTest {
    
    @isTest
    static void testBatchExecution() {

        Contact contact = new Contact();
        contact.LastName = 'Smith';
        contact.Birthdate = Date.Today();
        insert contact;

        JournalType  JournalType = new JournalType();
        JournalType.Name = 'Points Expiration';
         insert JournalType;
        
        LoyaltyProgram  loyaltyProgram = new LoyaltyProgram();
         loyaltyProgram.Name = 'Just Shop';
          insert loyaltyProgram;
        
        LoyaltyProgramMember programMember = new LoyaltyProgramMember();
		programMember.MembershipNumber = 'TEST1234';
		programMember.MemberStatus = 'Active';
		programMember.EnrollmentDate = Date.today().addYears(-2);
        programMember.MemberType = 'Individual';
        programMember.ContactId = contact.Id;
        programMember.ProgramId = loyaltyProgram.Id;
       // LastActivityDate = Date.today().addYears(-2);
		insert programMember;

        
        List<LoyaltyProgramMember> XYZ = [Select Id, LastActivityDate from LoyaltyProgramMember where ID =: programMember.Id];
        for(LoyaltyProgramMember lpmu : XYZ){
            lpmu.LastActivityDate = Date.today().addYears(-2);
        }
        update XYZ;

        
            LoyaltyProgramCurrency loyaltyProgramCurrency = new LoyaltyProgramCurrency(
            Name = 'TestPoints',
            LoyaltyProgramId = loyaltyProgram.Id,
            CurrencyType = 'NonQualifying',
            IsActive = true,
            ExpiryModel = 'Activity',
            ExpiryPeriodUnit = 'Years',
            ExpiryPeriodFrequency = 2
            );
            insert loyaltyProgramCurrency;
       

        Test.startTest();
        // Execute the batch
        PointsExpirationBatch.executeUpdateMembersPointBalancesBatch();
        Test.stopTest();
        List<TransactionJournal> TransactionJournal = new List<TransactionJournal>([SELECT Id, MemberId, JournalTypeId,JournalType.name FROM TransactionJournal where JournalType.name='Points Expiration']);
        System.assertEquals(1, TransactionJournal.size());

        
    }
}