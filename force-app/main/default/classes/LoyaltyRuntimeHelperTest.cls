/**
* @name         : LoyaltyRuntimeHelperTest
* @description  : This is the test class of LoyaltyRuntimeHelper.
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-24    Surya Nath Dixit         Created
*/ 

@isTest
private class LoyaltyRuntimeHelperTest {

    @isTest
    static void testLoyaltyProgramId() {
        // Test data setup
        LoyaltyProgram program = new LoyaltyProgram(Name = GlobalConstants.LOYALTY_PROGRAM_NAME);
        insert program;

        // Call the getter method
        Test.startTest();
        Id loyaltyProgramId = LoyaltyRuntimeHelper.loyaltyProgramId;
        Test.stopTest();

        // Verify the result
        System.assertEquals(program.Id, loyaltyProgramId, 'Loyalty Program Id should match');
    }

    @isTest
    static void testJournalTypeIdMappings() {
        // Test data setup
        JournalType journalType = new JournalType(Name = 'Test Journal Type');
        insert journalType;

        // Call the getter method
        Test.startTest();
        Map<String, Id> journalTypeIdMappings = LoyaltyRuntimeHelper.journalTypeIdMappings;
        Test.stopTest();

        // Verify the result
        System.assertEquals(1, journalTypeIdMappings.size(), 'Journal Type Id Mappings should contain one entry');
        System.assertEquals(journalType.Id, journalTypeIdMappings.get(journalType.Name), 'Journal Type Id should match');
    }

    @isTest
    static void testJournalSubTypeIdMappings() {
        // Test data setup
        JournalType journalType = new JournalType(Name = 'Test Journal Type');
        insert journalType;

        JournalSubType journalSubType = new JournalSubType(Name = 'Test Journal SubType', JournalTypeId = journalType.Id);
        insert journalSubType;

        // Call the getter method
        Test.startTest();
        Map<String, Id> journalSubTypeIdMappings = LoyaltyRuntimeHelper.journalSubTypeIdMappings;
        Test.stopTest();

        // Verify the result
        System.assertEquals(1, journalSubTypeIdMappings.size(), 'Journal SubType Id Mappings should contain one entry');
        System.assertEquals(journalSubType.Id, journalSubTypeIdMappings.get(journalSubType.Name), 'Journal SubType Id should match');
    }
    
    @isTest
    static void testVoucherDefinitionIdMappings() {
        // Test data setup
       // VoucherDefinition voucherDefinition = new VoucherDefinition(Name = 'Test Voucher Definition');
        //insert voucherDefinition;
        
        LoyaltyProgram program = new LoyaltyProgram(Name = GlobalConstants.LOYALTY_PROGRAM_NAME);
        insert program;
        
        VoucherDefinition voucherDefinition = new VoucherDefinition(
            Name = 'Test Voucher Definition',
            ExpirationType = 'Period',
            EffectiveDate = Date.today(),
            LoyaltyProgramId = program.Id,
            IsActive = true,
            ExpirationPeriod = 60,
            Minimum_Spend__c = 10, ExpirationPeriodUnit ='Days', Type = 'FixedValue', FaceValue = 15
        );
        insert voucherDefinition;
        
        

        // Call the getter method
        Test.startTest();
        Map<String, Id> voucherDefinitionIdMappings = LoyaltyRuntimeHelper.voucherDefinitionIdMappings;
        Test.stopTest();

        // Verify the result
        System.assertEquals(1, voucherDefinitionIdMappings.size(), 'Voucher Definition Id Mappings should contain one entry');
        System.assertEquals(voucherDefinition.Id, voucherDefinitionIdMappings.get(voucherDefinition.Name), 'Voucher Definition Id should match');
    }
}