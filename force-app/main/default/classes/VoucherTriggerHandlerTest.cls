/**
* @name         : VoucherTriggerHandlerTest
* @description  : This is test class for VoucherTriggerHandler
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-25    Surya Dixit         Created
* 2024-04-30    Vince Vuong         Cleaned up & commented out unused method
*/
@isTest
private class VoucherTriggerHandlerTest {
    
    private static String email = 'test_user@testing.com';
    
    @isTest
    static void testPreventDummyRewardVouchersCreation() {
        
        VoucherTriggerHandlerMock mock = new VoucherTriggerHandlerMock();
		Test.setMock(HttpCalloutMock.class, mock);
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

        //Create Loyalty Program
        LoyaltyProgram loyaltyProgram = TestDataFactory.createLoyaltyProgram();
        insert loyaltyProgram;
        
        //Create Voucher Definition
        VoucherDefinition vd = TestDataFactory.createVoucherDefinition(loyaltyProgram.Id, GlobalConstants.VOUCHER_DEFINITION_REWARD);
        insert vd;

        /*VoucherDefinition vd = new VoucherDefinition(
            Name = 'Reward Voucher',
            ExpirationType = 'Period',
            EffectiveDate = Date.today(),
            LoyaltyProgramId = loyaltyProgram.Id,
            IsActive = true,
            ExpirationPeriod = 60,
            Minimum_Spend__c = 10, ExpirationPeriodUnit ='Days', Type = 'FixedValue', FaceValue = 15
        );
        insert vd;*/
        
        LoyaltyProgramMember programMember = new LoyaltyProgramMember();
		programMember.MembershipNumber = 'TEST1234';
		programMember.MemberStatus = 'Active';
		programMember.EnrollmentDate = Date.Today();
        programMember.MemberType = 'Individual';
        programMember.ContactId = contact.Id;
        programMember.ProgramId = loyaltyProgram.Id;
		insert programMember;
        
        TransactionJournal jrnl = new TransactionJournal();
        jrnl.JournalTypeId = tjType.Id;
        jrnl.ActivityDate = System.Now();
        jrnl.JournalDate = System.Now();
        jrnl.Status = 'Pending';
        jrnl.LoyaltyProgramId = loyaltyProgram.Id;
        jrnl.MemberId = programMember.Id;
        insert jrnl;
                
        // List<Voucher> vouchers = new List<Voucher>();
        Voucher dummyVoucher = new Voucher(
            VoucherCode = 'DUMMYCODE',
            TransactionJournalId = jrnl.Id,
            VoucherDefinitionId = vd.Id,
            LoyaltyProgramMemberId = programMember.Id,
            Reason = GlobalConstants.DUMMY_REWARD_VOUCHER_REASON
        );
       
        // Insert test data
        Test.startTest();
            // If your code is expected to throw a FIELD_CUSTOM_VALIDATION_EXCEPTION,
            // catch the exception and verify the error message
            try {
                //Create Dummmy Voucher -> Trigger will throw FIELD_CUSTOM_VALIDATION_EXCEPTION
                insert dummyVoucher;
            } 
            catch (DmlException e) {
                String expectedErrorMessage = GlobalConstants.DUMMY_REWARD_VOUCHER_ERROR_MESSAGE;
                System.assert(e.getMessage().contains(expectedErrorMessage), 'Error message does not match');
            }
        Test.stopTest();

        //Verify that no dummy voucher record being created
        System.assert(!Test.isRunningTest() || [SELECT COUNT() FROM Voucher WHERE VoucherCode = 'DUMMYCODE' AND TransactionJournalId =:jrnl.Id] == 0, 'Validation rule violated');

        // Verify that dummy voucher creation is prevented
        //System.assertEquals(True, dummyVoucher !=null, 'Dummy reward voucher creation should have been prevented');
    }
    
    @isTest 
    static void testRestrictedFieldUpdatedByCSAManager() {
        VoucherTriggerHandlerMock mock = new VoucherTriggerHandlerMock();
		Test.setMock(HttpCalloutMock.class, mock);
        User testUser = createTestUser();
        System.debug('testUser: ' + testUser);
        
        System.runAs(testUser) {
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
            
            //Create Loyalty Program
            LoyaltyProgram loyaltyProgram = TestDataFactory.createLoyaltyProgram();
            insert loyaltyProgram;
            
            //Create Voucher Definition
            VoucherDefinition vd = TestDataFactory.createVoucherDefinition(loyaltyProgram.Id, GlobalConstants.VOUCHER_DEFINITION_BIRTHDAY);
            insert vd;
            
            LoyaltyProgramMember programMember = new LoyaltyProgramMember();
            programMember.MembershipNumber = 'TEST1234';
            programMember.MemberStatus = 'Active';
            programMember.EnrollmentDate = Date.Today();
            programMember.MemberType = 'Individual';
            programMember.ContactId = contact.Id;
            programMember.ProgramId = loyaltyProgram.Id;
            insert programMember;
            
            TransactionJournal jrnl = new TransactionJournal();
            jrnl.JournalTypeId = tjType.Id;
            jrnl.ActivityDate = System.Now();
            jrnl.JournalDate = System.Now();
            jrnl.Status = 'Pending';
            jrnl.LoyaltyProgramId = loyaltyProgram.Id;
            jrnl.MemberId = programMember.Id;
            insert jrnl;
            
            // List<Voucher> vouchers = new List<Voucher>();
            Voucher dummyVoucher = new Voucher(
                VoucherCode = 'DUMMYCODE',
                TransactionJournalId = jrnl.Id,
                VoucherDefinitionId = vd.Id,
                LoyaltyProgramMemberId = programMember.Id,
                Reason = 'Test class voucher'
            );
            insert dummyVoucher;
            
            Test.startTest();
            
            try{
                dummyVoucher.Reason = 'This is test class';
                update dummyVoucher;
            } catch(Exception ex) {
                System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Error message does not match');
                System.assertEquals('System.DmlException', ex.getTypeName(), 'Not a DML Exception');
            }
            
            Test.stopTest();
        }
    }
   
    private static User createTestUser() {
		Id CsaRepManagerProfile = [SELECT Id FROM Profile WHERE Name=:GlobalConstants.CSA_REP_MANAGER_PROFILE LIMIT 1][0].Id;
        
        User testUser = new User(
            Alias = 'testuser',
            Email = email,
            EmailEncodingKey = 'UTF-8',
            LastName = 'Manager',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Australia/Perth',
            ProfileId = CsaRepManagerProfile,
            UserName = email
        );
        insert testUser;
        
        PermissionSetGroup psGRec = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'JGL_CSA_Manager_Edit_Access' LIMIT 1];
       
        Test.calculatePermissionSetGroup(new Id[] { psGRec.Id });
        // Assign the Permission Set Group to the user
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetGroupId = psGRec.Id
        );
        insert psa;
        
        
        return testUser;
    }

    
    //NOT REQUIRED
    /*
    @isTest
    static void testProcessMultipleVoucherCodes() {
        // Create test Voucher records
        // 
        Contact contact = new Contact();
        contact.LastName = 'Smith';
        contact.Birthdate = Date.Today();
        insert contact;
        
        JournalType  JournalType = new JournalType();
        JournalType.Name = 'Redemption';
        insert JournalType;
        
        JournalSubType  JrnlSubType = new JournalSubType();
        JrnlSubType.Name = 'Reward';
        JrnlSubType.JournalTypeId = JournalType.Id;
        insert JrnlSubType;
        
        LoyaltyProgram  loyaltyProgram = new LoyaltyProgram();
        loyaltyProgram.Name = 'Just Shop';
        insert loyaltyProgram;
        
        VoucherDefinition vd = new VoucherDefinition(
            Name = 'Birthday Voucher',
            ExpirationType = 'Period',
            EffectiveDate = Date.today(),
            LoyaltyProgramId = loyaltyProgram.Id,
            IsActive = true,
            ExpirationPeriod = 60,
            Minimum_Spend__c = 10, ExpirationPeriodUnit ='Days', Type = 'FixedValue', FaceValue = 15
        );
        insert vd;
        
        LoyaltyProgramMember programMember = new LoyaltyProgramMember();
		programMember.MembershipNumber = 'TEST1234';
		programMember.MemberStatus = 'Active';
		programMember.EnrollmentDate = Date.Today();
        programMember.MemberType = 'Individual';
        programMember.ContactId = contact.Id;
        programMember.ProgramId = loyaltyProgram.Id;
		insert programMember;
        
        TransactionJournal jrnl = new TransactionJournal();
        					jrnl.JournalTypeId = JournalType.Id;
                            jrnl.ActivityDate = System.Now();
                            jrnl.JournalDate = System.Now();
                            jrnl.Status = 'Pending';
                            jrnl.LoyaltyProgramId = loyaltyProgram.Id;
                            jrnl.MemberId = programMember.Id;
    
        insert jrnl; 
        
        List<Voucher> vouchers = new List<Voucher>();
        Voucher voucher1 = new Voucher(
            TransactionJournalId = jrnl.Id,
            Reason = 'TBD'
        );
        Voucher voucher2 = new Voucher(
            TransactionJournalId = jrnl.Id,
            Reason = 'TBD'
        );
        vouchers.add(voucher1);
        vouchers.add(voucher2);

        // Insert test data
        Test.startTest();
        insert vouchers;
        Test.stopTest();
    }
    */

}