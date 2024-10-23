/**
 * @name         : LoyaltyMemberVoucherRestServiceTest
* @description  : This is test class of LoyaltyMemberVoucherRestService.
* @testClass    : LoyaltyMemberVoucherRestServiceTest
* 2024-03-13        Siddharth Singh      Modified--Bulkify the code
* 2024-03-12    Siddharth Singh         Created
 */
@isTest
private class LoyaltyMemberVoucherRestServiceTest {
    
    public class GlobalConstants {
        public Integer MAX_VOUCHER_RECORDS =200;
    }

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
			Organisation_Settings__c setting = new Organisation_Settings__c();
        setting.Name = 'Test Setting';
        setting.Membership_Prefix__c = '66666666';
        insert setting;
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
                Name = 'Test Voucher Definition',
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

            // Create Promotion
            Promotion promotion = new Promotion(
                Name = 'Test Promotion',
                StartDate = Date.today(),
                IsActive = true,
                LoyaltyProgramId = loyaltyProgram.Id,
                Status = 'InProgress'
            );
            insert promotion;
			
        
        	List<Voucher> LstVoucher = new List<Voucher>();
            // Create Voucher
            Voucher voucher = new Voucher(
                LoyaltyProgramMemberId = loyaltyProgramMember.Id,
                VoucherDefinitionId = voucherDefinition.Id,
                PromotionId = promotion.Id,
                FaceValue = 10,
                RedeemedValue = 1,
                Status = 'Issued',
                VoucherCode = 'TEST123',
                EffectiveDate = Date.today(),
                ExpirationDate = Date.today().addMonths(3)
            );
            LstVoucher.add(voucher);
        	
        Voucher voucher1 = new Voucher(
                LoyaltyProgramMemberId = loyaltyProgramMember.Id,
                VoucherDefinitionId = voucherDefinition.Id,
                PromotionId = promotion.Id,
                FaceValue = 15,
            	RedeemedValue = 1,
                Status = 'Issued',
                VoucherCode = 'TEST123',
                EffectiveDate = Date.today(),
                ExpirationDate = Date.today().addMonths(4)
            	
            );
            LstVoucher.add(voucher1);
        	Insert LstVoucher;
       
        // Set up the RestRequest
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        // The request method
        req.requestURI = '/loyalty/programs/TestProgram/members/66666666001062587/vouchers';
        req.httpMethod = 'GET';

        // Add query parameters
        req.params.put('pageNumber', '1');
        req.params.put('programName', 'TestProgram');
        
        req.params.put('voucherStatus', 'Issued');
        req.params.put('sortBy', 'ExpirationDate');
        req.params.put('sortOrder', 'ASC');

        // Set the RestContext
        RestContext.request = req;
        RestContext.response = res;
        //Test.setMock(HttpCalloutMock.class, new LoyaltyMemberVoucherRestService());
 		Test.startTest();
        
        // Call the REST service method
        LoyaltyMemberVoucherRestService.doGet();
        
        Test.stopTest();
    }
    @isTest
    static void myUnitTest2() {
        
       
       
        // Set up the RestRequest
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        // The request method
        req.requestURI = '/loyalty/programs/TestProgram/members//vouchers';
        req.httpMethod = 'GET';

        // Add query parameters
        req.params.put('pageNumber', '2');
        req.params.put('programName', 'TestProgram');
        
        req.params.put('voucherStatus', 'Issued');
        req.params.put('sortBy', 'ExpirationDate');
        req.params.put('sortOrder', 'ASC');

        // Set the RestContext
        RestContext.request = req;
        RestContext.response = res;
        //Test.setMock(HttpCalloutMock.class, new LoyaltyMemberVoucherRestService());
 		Test.startTest();
        
        // Call the REST service method
        LoyaltyMemberVoucherRestService.doGet();
        
        Test.stopTest();
    }
     
    
}