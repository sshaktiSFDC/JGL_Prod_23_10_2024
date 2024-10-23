/**
* @name         : GlobalConstants
* @description  : Global class to store all hardcoded values
                  NOTE: Please use UPPERCASE to define your constant variables!
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-02-12    Vince Vuong         Created
* 2024-03-13    Siddharth Singh     Added new constants
*/ 
public without sharing class GlobalConstants {

    //Record Type IDs
    public static final ID RT_BUSINESS_ACCOUNT_ID  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
    public static final ID RT_PERSON_ACCOUNT_ID  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

    //
    public static final String LOYALTY_PROGRAM_NAME         = 'Just Shop';
    public static final String VOUCHER_DEFINITION_REWARD    = 'Reward';
    public static final String VOUCHER_DEFINITION_BIRTHDAY  = 'Birthday Reward';
    public static final String VOUCHER_DEFINITION_WELCOME   = 'Welcome Reward';
    public static final String VOUCHER_DEFINITION_ADHOC     = 'Ad Hoc Reward';

    //Program Members
    public static final String MEMBER_STATUS_ACTIVE     = 'Active';
    public static final String MEMBER_STATUS_INACTIVE   = 'Inactive';

    //Vouchers
    public static final String VOUCHER_STATUS_ISSUED     = 'Issued';
    public static final String VOUCHER_STATUS_EXPIRED    = 'Expired';
    public static final String VOUCHER_STATUS_REDEEMED   = 'Redeemed';

    public static final String DUMMY_REWARD_VOUCHER_REASON          = 'TBD';
    public static final String DUMMY_REWARD_VOUCHER_ERROR_MESSAGE   = 'DO NOT create dummy reward vouchers';

    // Declaring a global variable of type Integer for pagination in custom REST API
    public static final Integer MAX_VOUCHER_RECORDS   = 200;

    //Rest Service Custom Status Codes
    public static final Integer HTTP_STATUS_CODE_OK                       = 200;
    public static final Integer HTTP_STATUS_CODE_BAD_REQUEST              = 400;
    public static final Integer HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR    = 500;

    public static final String CONTENT_TYPE                        = 'Content-Type';
    public static final String CONTENT_TYPE_APPLICATION_JSON       = 'application/json';
    public static final String HTTP_METHOD_GET                     = 'GET';
    public static final String HTTP_METHOD_POST                    = 'POST';
    
    //Transaction Journals
    public static final String JOURNAL_STATUS_PENDING   = 'Pending';
    public static final String JOURNAL_STATUS_PROCESSED   = 'Processed';

    public static final String JOURNAL_TYPE_ACCRUAL   = 'Accrual';
    public static final String JOURNAL_TYPE_RETURNS   = 'Returns';
    public static final String JOURNAL_TYPE_REDEMPTION   = 'Redemption';
    public static final String JOURNAL_TYPE_MANUALPOINTSADJUSTMENT   = 'Manual Points Adjustment';

    public static final String JOURNAL_SUBTYPE_PURCHASE             = 'Purchase';
    public static final String JOURNAL_SUBTYPE_MEMBER_ENROLLMENT    = 'Enrollment';
    public static final String JOURNAL_SUBTYPE_VOUCHER      = 'Voucher';
    public static final String JOURNAL_SUBTYPE_REWARD       = 'Reward';
    public static final String JOURNAL_SUBTYPE_REVERSAL     = 'Reversal';
    public static final String JOURNAL_SUBTYPE_MEMBER_MIGRATION    = 'Member Migration';

    //Program Currencies
    public static final String CURRENCY_TIER_POINTS         = 'Tier Points';
    public static final String CURRENCY_POSITIVE_BALANCE    = 'Positive Balance';
    public static final String CURRENCY_NEGATIVE_BALANCE    = 'Negative Balance';
    
    //Birthday Voucher Code
    public static final String BIRTHDAY_VOUCHER_CODE_SUFFIX   = 'BDAY';
    
    //Runtime Settings
    public static final Integer REWARD_VOUCHER_TARGET_POINTS = (Integer)Organisation_Settings__c.getOrgDefaults().Voucher_Points_Target_Value__c;

    //SObject Name
    public static final String LOYALTY_PROGRAM_MEMBER_NAME = 'LoyaltyProgramMember';
    public static final String ACCOUNT_NAME = 'Account';
    
    //Profile
    public static final String CSA_REP_MANAGER_PROFILE = 'JGL Customer Service Manager';
}