@isTest
public class CountTotalRewardsValueActionTest {
    static string testMemberId;
    
    @testSetup
    private static void setup(){
        //Create Loyalty Program
        LoyaltyProgram program = TestDataFactory.createLoyaltyProgram();
        insert program;

        //Create Contacts
        List<Contact> contacts = TestDataFactory.createContacts(1);
        insert contacts;

        //Create Individual Program Members
        List<LoyaltyProgramMember> members = TestDataFactory.createIndividualMembers(program.Id, contacts[0].Id, 1);
        insert members;
        testMemberId = members[0].Id;
        
        //Create journal Types
        JournalType tjType = new JournalType(
            Name = 'Accrual',
            ProcessType = 'Loyalty'
        );
        insert tjType;

        //Create journal subTypes
        JournalSubType tjSubType = new JournalSubType(
            Name = 'Purchase',
            JournalTypeId = tjType.Id
        );
        insert tjSubType;

        //Create Transaction Journal for Reversal
        List<TransactionJournal> journals = new List<TransactionJournal>();

        TransactionJournal tj1 = new TransactionJournal();
        tj1.LoyaltyProgramId = program.Id;
        tj1.MemberId = members[0].Id;
        tj1.ActivityDate = System.Now();
        tj1.Order_ID__c = 'TEST-ORDER-123';
        tj1.Order_Item_ID__c = 'ITEM-1';
        tj1.TransactionAmount = 1.00;
        tj1.JournalTypeId = tjType.Id;
        tj1.JournalSubTypeId = tjSubType.Id;
        tj1.Status = GlobalConstants.JOURNAL_STATUS_PROCESSED;
        journals.add(tj1);

        TransactionJournal tj2 = new TransactionJournal();
        tj2.LoyaltyProgramId = program.Id;
        tj2.MemberId = members[0].Id;
        tj2.ActivityDate = System.Now();
        tj2.Order_ID__c = 'TEST-ORDER-123';
        tj2.Order_Item_ID__c = 'ITEM-2';
        tj2.TransactionAmount = 1.00;
        tj2.JournalTypeId = tjType.Id;
        tj2.JournalSubTypeId = tjSubType.Id;
        tj2.Status = GlobalConstants.JOURNAL_STATUS_PROCESSED;
        journals.add(tj2);
        insert journals;
        
        //Create Vouchers
        List<Voucher> vouchers = new List<Voucher>();
                        Voucher voucher1 = new Voucher();
                        voucher1.LoyaltyProgramMemberId  = members[0].Id;
                        //voucher1.TransactionJournal.LoyaltyProgramId = program.Id;
                        voucher1.Status = 'Issued';
                        voucher1.FaceValue = 10;
                        voucher1.UseDate = null;
                        voucher1.Order_Id_Redeem_Channel__c = 'POS';
                        voucher1.Order_Id_Redeem__c = 'TEST-ORDER-123';
        				voucher1.EffectiveDate = Date.today();
        				voucher1.ExpirationDate = Date.today().addDays(2);
        				voucher1.FaceValue = 200;
                        vouchers.add(voucher1);
     
        Voucher voucher2 = new Voucher();
                        voucher2.Status = 'Issued';
                        voucher2.LoyaltyProgramMemberId  = members[0].Id;    
                        //voucher2.TransactionJournal.LoyaltyProgramId = program.Id;
                        voucher2.FaceValue = 10;
                        voucher2.UseDate = null;
                        voucher2.Order_Id_Redeem_Channel__c = 'POS';
                        voucher2.Order_Id_Redeem__c = 'TEST-ORDER-123';
        				voucher2.EffectiveDate = Date.today();
        				voucher2.ExpirationDate = Date.today().addDays(2);
                        voucher1.FaceValue = 200;
        				vouchers.add(voucher2);
        				insert vouchers;
    }
    
    @isTest
    private static void test_CalcCountTotalRewardsValue() {
        List<LoyaltyProgramMember> member = [SELECT Id FROM LoyaltyProgramMember];
        CountTotalRewardsValueAction.CountTotalRewardsValueInput input = new CountTotalRewardsValueAction.CountTotalRewardsValueInput();
        input.MemberId = member[0].Id;
        
        Test.startTest();
        List<CountTotalRewardsValueAction.CountTotalRewardsValueOutput> outputs = CountTotalRewardsValueAction.CalcCountTotalRewardsValue(new List<CountTotalRewardsValueAction.CountTotalRewardsValueInput> {input});
        Test.stopTest();
        
        System.assertNotEquals(null, outputs, 'Outputs should not be null');
    }
}