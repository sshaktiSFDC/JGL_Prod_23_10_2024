/**
* @name         : IssueBirthdayVoucherBatchTest
* @description  : Test class for IssueBirthdayVoucherBatch
* @authors		Name					Comments
* 2024-08-12	Shakti Kushwaha Rana    Added TJ update logic
*/
@isTest 
public class IssueBirthdayVoucherBatchTest {
   @TestSetup
    static void makeData() {
        
    	Contact contact = new Contact();
        contact.LastName = 'Test Contacts';
        contact.Birthdate = Date.Today();
        insert contact;
        
        LoyaltyProgram  loyaltyProgram = new LoyaltyProgram();
        loyaltyProgram.Name = GlobalConstants.LOYALTY_PROGRAM_NAME;
        insert loyaltyProgram;
        
        LoyaltyProgramMember programMember = new LoyaltyProgramMember();
		programMember.MembershipNumber = 'TEST Members';
		programMember.MemberStatus = 'Active';
		programMember.EnrollmentDate = Date.Today();
        programMember.MemberType = 'Individual';
        programMember.ContactId = contact.Id;
        programMember.ProgramId = loyaltyProgram.Id;
		insert programMember;

		VoucherDefinition vd = new VoucherDefinition(
            Name = 'Birthday Reward',
            ExpirationType = 'Period',
            EffectiveDate = Date.today(),
            LoyaltyProgramId = loyaltyProgram.Id,
            IsActive = true,
            ExpirationPeriod = 60,
            Minimum_Spend__c = 10, ExpirationPeriodUnit ='Days', Type = 'FixedValue', FaceValue = 15
        );
        insert vd;
        JournalType journalType = new JournalType(Name = 'Redemption');
        insert journalType;
        JournalSubType journalSubType = new JournalSubType(Name = 'Reward', JournalTypeId = journalType.Id);
        insert journalSubType;
    }

	@IsTest
    static void createVoucherTest() {
		IssueBirthdayVouchersBatch.executeBirthdayVouchersBatch();
       	List<Voucher> voucher = new List<Voucher>([Select Id from Voucher]);
		        
	}
    @IsTest
    static void createVoucherAlreadyExist() {
        List<LoyaltyManagement.IssueVoucherInput> issueVoucherList = new List<LoyaltyManagement.IssueVoucherInput>();
        List<LoyaltyProgramMember> loyaltyProgramMemberMap = [Select Id, ProgramId from LoyaltyProgramMember];
        JournalSubType journalSubTypeRecord = [SELECT id, JournalTypeId FROM JournalSubType WHERE name = : GlobalConstants.JOURNAL_SUBTYPE_REWARD AND JournalType.Name =: GlobalConstants.JOURNAL_TYPE_REDEMPTION LIMIT 1];
        TransactionJournal newTJ = new TransactionJournal();
        newTJ.LoyaltyProgramId = loyaltyProgramMemberMap[0].ProgramId;
        newTJ.MemberId = loyaltyProgramMemberMap[0].id;
        if(journalSubTypeRecord != null && journalSubTypeRecord.id != null && journalSubTypeRecord.JournalTypeId !=null){
            newTJ.JournalSubTypeId = journalSubTypeRecord.id;
            newTJ.JournalTypeId = journalSubTypeRecord.JournalTypeId;
        }
        newTJ.ActivityDate = System.now();
        newTJ.JournalDate = System.now();
        newTJ.Status = GlobalConstants.JOURNAL_STATUS_PROCESSED; 
        insert newTJ;
        
        
        LoyaltyManagement.IssueVoucherInputBuilder voucher = new LoyaltyManagement.IssueVoucherInputBuilder();
        voucher.setLoyaltyProgramMemberId(loyaltyProgramMemberMap[0].Id);
        voucher.setProgramName(GlobalConstants.LOYALTY_PROGRAM_NAME);
        voucher.setVoucherDefinitionName(GlobalConstants.VOUCHER_DEFINITION_BIRTHDAY);
        voucher.setJournalId(newTJ.id);
        issueVoucherList.add(voucher.build());
        if (!issueVoucherList.isEmpty()) {
            List<LoyaltyManagement.IssueVoucherOutput> issueVoucherActionResults = LoyaltyManagement.LoyaltyResources.issueVoucher(issueVoucherList); 
            
        }
        
        List<Voucher> vouchers = new List<Voucher>([Select Id from Voucher]);
        
        IssueBirthdayVouchersBatch.executeBirthdayVouchersBatch();
       	vouchers = new List<Voucher>([Select Id from Voucher]);
		    
	}
    
    @IsTest
    static void createVoucherExpired() {
        List<LoyaltyManagement.IssueVoucherInput> issueVoucherList = new List<LoyaltyManagement.IssueVoucherInput>();
        List<LoyaltyProgramMember> loyaltyProgramMemberMap = [Select Id,ProgramId from LoyaltyProgramMember];
        
        JournalSubType journalSubTypeRecord = [SELECT id, JournalTypeId FROM JournalSubType WHERE name = : GlobalConstants.JOURNAL_SUBTYPE_REWARD AND JournalType.Name =: GlobalConstants.JOURNAL_TYPE_REDEMPTION LIMIT 1];
        TransactionJournal newTJ = new TransactionJournal();
        newTJ.LoyaltyProgramId = loyaltyProgramMemberMap[0].ProgramId;
        newTJ.MemberId = loyaltyProgramMemberMap[0].id;
        if(journalSubTypeRecord != null && journalSubTypeRecord.id != null && journalSubTypeRecord.JournalTypeId !=null){
            newTJ.JournalSubTypeId = journalSubTypeRecord.id;
            newTJ.JournalTypeId = journalSubTypeRecord.JournalTypeId;
        }
        newTJ.ActivityDate = System.now();
        newTJ.JournalDate = System.now();
        newTJ.Status = GlobalConstants.JOURNAL_STATUS_PROCESSED; 
        insert newTJ;
        LoyaltyManagement.IssueVoucherInputBuilder voucher = new LoyaltyManagement.IssueVoucherInputBuilder();
        voucher.setLoyaltyProgramMemberId(loyaltyProgramMemberMap[0].Id);
        voucher.setProgramName(GlobalConstants.LOYALTY_PROGRAM_NAME);
        voucher.setVoucherDefinitionName(GlobalConstants.VOUCHER_DEFINITION_BIRTHDAY);
        voucher.setJournalId(newTJ.id);
        issueVoucherList.add(voucher.build());
        if (!issueVoucherList.isEmpty()) {
            List<LoyaltyManagement.IssueVoucherOutput> issueVoucherActionResults = LoyaltyManagement.LoyaltyResources.issueVoucher(issueVoucherList); 
        }
        
        List<Voucher> vouchers = new List<Voucher>([Select Id, EffectiveDate from Voucher]);
        for(Voucher exixtingVoucher : vouchers){
            exixtingVoucher.Status = 'Expired';
        }
        
        update vouchers;
		
        IssueBirthdayVouchersBatch.executeBirthdayVouchersBatch();
       	vouchers = new List<Voucher>([Select Id from Voucher]);
		
        
	}
    @IsTest
    static void createVoucherEffectiveDatePastYear() {
        // manual voucher create
        List<LoyaltyManagement.IssueVoucherInput> issueVoucherList = new List<LoyaltyManagement.IssueVoucherInput>();
        
        List<LoyaltyProgramMember> loyaltyProgramMemberMap = [Select Id from LoyaltyProgramMember];
        System.Test.startTest();
        LoyaltyManagement.IssueVoucherInputBuilder voucher = new LoyaltyManagement.IssueVoucherInputBuilder();
                voucher.setLoyaltyProgramMemberId(loyaltyProgramMemberMap[0].Id);
                voucher.setProgramName(GlobalConstants.LOYALTY_PROGRAM_NAME);
                voucher.setVoucherDefinitionName(GlobalConstants.VOUCHER_DEFINITION_BIRTHDAY);
                issueVoucherList.add(voucher.build());
        if (!issueVoucherList.isEmpty()) {
                // insert vouchersToInsert;
                List<LoyaltyManagement.IssueVoucherOutput> issueVoucherActionResults = LoyaltyManagement.LoyaltyResources.issueVoucher(issueVoucherList); 
            System.debug(issueVoucherActionResults);
                System.debug('Issue Voucher Successful Operation:'+ issueVoucherActionResults.get(0));
            }
        
        List<Voucher> vouchers = new List<Voucher>([Select Id, EffectiveDate from Voucher]);
        System.assertEquals(1, vouchers.size());
        for(Voucher exixtingVoucher : vouchers){
            exixtingVoucher.EffectiveDate = Date.Today().addDays(-366) ;
        }
        
        update vouchers;
		
        IssueBirthdayVouchersBatch.executeBirthdayVouchersBatch();
       // IssueBirthdayVouchersBatch issueBirthdayVouchersBatch = new IssueBirthdayVouchersBatch();
       // Database.executeBatch(issueBirthdayVouchersBatch);
        System.Test.stopTest();

        //after batch run below list size should be 2
		vouchers = new List<Voucher>([Select Id from Voucher]);
		System.debug(vouchers);
        System.assertEquals(2, vouchers.size());
	}
    
 }