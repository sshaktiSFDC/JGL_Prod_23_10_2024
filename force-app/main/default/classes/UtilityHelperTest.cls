/**
* @name         : UtilityHelperTest
* @description  : This is test class of UtilityHelper.
* @testClass    : 
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-03-13    Siddharth Singh     Created
*/
@isTest
private class UtilityHelperTest {

    @isTest
    static void myUnitTest() {
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
        	System.debug(loyaltyProgram);

            // Create LoyaltyProgramMember
            LoyaltyProgramMember loyaltyProgramMember = new LoyaltyProgramMember(
                ProgramId = loyaltyProgram.Id,
                MembershipNumber = 'TEST123',
                ContactId = contact.Id,
                EnrollmentDate = Date.today(), // Set EnrollmentDate
                MemberStatus = 'Active' // Set MemberStatus
            );
            insert loyaltyProgramMember;
        	System.debug(loyaltyProgramMember.membershipNumber);

            // Create VoucherDefinition
            VoucherDefinition voucherDefinition = new VoucherDefinition(
                Name = 'Birthday Voucher',
                Description = 'This is a test voucher definition',
                IsActive = true,
                IsPartialRedeemable = true,
                Type = 'FixedValue',
                FaceValue = 10,
                ExpirationType = 'FixedDate',
                EffectiveDate = Date.today(),
                ExpirationDate = Date.today().addMonths(3),
                Minimum_Spend__c = 100
            );
            insert voucherDefinition;
        JournalType journalType = new JournalType(Name = 'Points Expiration');
        insert journalType;
        JournalSubType journalSubType = new JournalSubType(Name = 'Reward', JournalTypeId = journalType.Id);
        insert journalSubType;
        Set<String> memberNumbers = new Set<String>{ '123456', '987654', '234567' };

        
        Test.startTest();
      
        UtilityHelper.generateMembershipNumbers(memberNumbers);
        UtilityHelper.calculateLuhnCheckDigit('123456789');
        UtilityHelper.generateVoucherCodes('Birthday Voucher',1);
        UtilityHelper.getLoyaltyProgram();
        UtilityHelper.countVoucherCodes('Test');
        UtilityHelper.getVoucherDefinitionId();
        UtilityHelper.getJournalType();
        UtilityHelper.calculateLuhnCheckDigit('5/0');
        Test.stopTest();
        
    }
}