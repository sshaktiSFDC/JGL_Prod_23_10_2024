/**
* @name         : TestDataFactory
* @description  : This class will be used by test classes to generate test data.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-02-12    Vince Vuong         Created
*/
@isTest
public with sharing class TestDataFactory {

    //Person accounts
    public static List<Account> createPersonAccounts(Integer recordCount){
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < recordCount; i++){
            accounts.add(new Account(
                FirstName = 'TestFirst'+i,
                LastName = 'TestLast'+i,
                RecordTypeId = GlobalConstants.RT_PERSON_ACCOUNT_ID
            ));
        }
        return accounts;
    }

    //Business accounts
    public static List<Account> createBusinessAccounts(Integer recordCount){
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < recordCount; i++){
            accounts.add(new Account(
                Name = 'TestFirst'+i,
                RecordTypeId = GlobalConstants.RT_BUSINESS_ACCOUNT_ID
            ));
        }
        return accounts;
    }

    //Create Loyalty Program
    public static LoyaltyProgram createLoyaltyProgram(){
        return new LoyaltyProgram(
            Name = GlobalConstants.LOYALTY_PROGRAM_NAME,
            Status = 'Active',
            Description = 'This is a test loyalty program',
            IsPrimary = true
        );
    }

    //Create Contacts
    public static List<Contact> createContacts(Integer count){
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < count; i++){
            contacts.add( new Contact(
                LastName = 'Test'
            ));
        }
        return contacts;
    }

    //Create Individual Program Members
    public static List<LoyaltyProgramMember> createIndividualMembers(String programId, String contactId, Integer count){
        List<LoyaltyProgramMember> members = new List<LoyaltyProgramMember>();
        for(Integer i = 0; i < count; i++){
            members.add(new LoyaltyProgramMember(
                ProgramId = programId,
                MembershipNumber = 'TestMember'+i,
                ContactId = contactId,
                EnrollmentDate = Date.today(), // Set EnrollmentDate
                MemberStatus = 'Active' // Set MemberStatus
            ));
        }
        return members;
    }

    //Create Voucher Definitions
    public static VoucherDefinition createVoucherDefinition(String programId, String definitionName) {
        return new VoucherDefinition(
            LoyaltyProgramId = programId,
            Name = definitionName,
            Description = 'This is a test voucher definition',
            IsActive = true,
            IsPartialRedeemable = false,
            Type = 'FixedValue',
            FaceValue = 10,
            ExpirationType = 'FixedDate',
            EffectiveDate = Date.today(),
            ExpirationDate = Date.today().addMonths(3),
            Minimum_Spend__c = 20
        );
    }

    // Create Promotion
    public static Promotion createPromotion(String programId, String promotionName) {
        return new Promotion(
            Name = promotionName,
            StartDate = Date.today(),
            IsActive = true,
            LoyaltyProgramId = programId,
            Status = 'InProgress'
        );
    }

    //Create member vouchers
    public static List<Voucher> createVouchers(String memberId, String voucherDefinitionId, Integer count){
        List<Voucher> vouchers = new List<Voucher>();
        for(Integer i = 0; i < count; i++){
            vouchers.add( new Voucher(
                LoyaltyProgramMemberId = memberId,
                VoucherDefinitionId = voucherDefinitionId,
                FaceValue = 10,
                RedeemedValue = 1,
                Status = GlobalConstants.VOUCHER_STATUS_ISSUED,
                VoucherCode = 'TEST123',
                EffectiveDate = Date.today(),
                ExpirationDate = Date.today().addMonths(3)
            ));
        }
        return vouchers;
    }
    
    //Create Loyalty Program Currency
    public static LoyaltyProgramCurrency createLoyaltyProgramCurrency(String name, String currencyType, Id loyaltyProgramId) {
        return new LoyaltyProgramCurrency(
            Name = name,
            CurrencyType = currencyType,
            LoyaltyProgramId = loyaltyProgramId,
            IsActive = true,
            IsPrimary = true
        );
    }
    
    //Create Loyalty Member Currency
    public static LoyaltyMemberCurrency createLoyaltyMemberCurrency(String name, Id memberId, Id programCurrencyId) {
        return new LoyaltyMemberCurrency(
            Name = name,
            LoyaltyMemberId = memberId,
            LoyaltyProgramCurrencyId = programCurrencyId
        );
    }
    
}