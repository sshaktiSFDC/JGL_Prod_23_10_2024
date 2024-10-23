@isTest
public class GetPointsForManualAdjustmentTest {
    
    @testSetup
    static void setup(){
        Contact contact = new Contact();
        contact.LastName = 'Smith';
        contact.Birthdate = Date.Today();
        insert contact;
        
        JournalType  JournalType = new JournalType();
        JournalType.Name = GlobalConstants.JOURNAL_TYPE_MANUALPOINTSADJUSTMENT;
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
    }
    
    @isTest
    static void test_ExtractPointsAdjAndType() {
        LoyaltyProgramMember member = [SELECT Id FROM LoyaltyProgramMember LIMIT 1];
        TransactionJournal journal = [SELECT Id FROM TransactionJournal LIMIT 1];
        
        GetPointsForManualAdjustment.ExtractPointsAdjustmentInput inp = new GetPointsForManualAdjustment.ExtractPointsAdjustmentInput();
        inp.memberId = member.Id;
		inp.journalId = journal.Id;
        
        Test.startTest();
        List<GetPointsForManualAdjustment.ExtractPointsAdjustmentOutput> result = GetPointsForManualAdjustment.ExtractPointsAdjAndType(new List<GetPointsForManualAdjustment.ExtractPointsAdjustmentInput> {inp});
        Test.stopTest();
        
        System.assertEquals(10, result[0].LedgerPoints);
    }
}