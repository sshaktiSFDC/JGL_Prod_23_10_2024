@IsTest
public class JgLoyaltyControllerTest {

    Static String customerResponseApiData = 
    '{"email":"2kimoliver@gmail.com",'
    + '"firstname":"Kim",'
    + '"lastname":"Oliver",'
    + '"dob":"1963-07-20",'
    + '"mobile":"0424242526",'
    + '"country":"AU",'
    + '"state":"NSW",'
    + '"customerId":39694,'
    + '"subscriptions":[{"subscription":"JustJeans","allowEmail":true,"subscriptionCustomerId":5038730}],'
    + '"loyaltyPrograms":[{"loyaltyProgram":"Just Shop","memberNumber":"2791000036616",'
    + '"enrolmentDate":"2015-08-27T01:25:13.000Z",'
    + '"enrolmentChannel":"POS",'
    + '"pointsBalance":150,'
    + '"pointsToNextVoucher":50,'
    + '"rewardsAvailable":"$0",'
    + '"customerSummary":"Customer <b>Kim Oliver</b></br>Points to next reward <b>50</b></br>Rewards available <b>$0</b>",'
    + '"preferences":{"email":true,"sms":false},'
    + '"attributes":[{"name":"enrolmentBrand","value":"JJ"},{"name":"enrolmentStore","value":"123"}]}],'
    + '"gender":"F"}';

    Static String loyaltyMemberResponseApiData = '{"memberNumber": "2791000036616", "lastname": "Oliver", "country":"AU"}';

    Static String salesforceLoyaltyMemberResponseData = 
    '{"attributes":{"type":"LoyaltyProgramMember",'
    + '"url":"/services/data/v62.0/sobjects/LoyaltyProgramMember/0lM920000000RGQEA2"},'
    + '"Id":"0lM920000000RGQEA2",'
    + '"ProgramId":"0lp92000000001dAAA",'
    + '"MembershipNumber":"2791000036616",'
    + '"ContactId":"0039200000asy7ZAAQ",'
    + '"Program":{"attributes":{"type":"LoyaltyProgram",'
    + '"url":"/services/data/v62.0/sobjects/LoyaltyProgram/0lp92000000001dAAA"},'
    + '"Name":"Just Shop","Id":"0lp92000000001dAAA"},'
    + '"Contact":{"attributes":{"type":"Contact",'
    + '"url":"/services/data/v62.0/sobjects/Contact/0039200000asy7ZAAQ"},'
    + '"AccountId":"0019200000ZOCbwAAH",'
    + '"FirstName":"Kim","LastName":"Oliver",'
    + '"Email":"2kimoliver@gmail.com","Id":"0039200000asy7ZAAQ"}}';

    Static String searchApiResponseData = '[{"email":"@kevinjanehahn@gmail.com","firstname":"Jane","lastname":"Hahn","customerId":64}]';

    //Implement the HttpCalloutMock interface to simulate an HTTP response
    class MockHttpCalloutResponse implements HttpCalloutMock {
        Integer statusCode;
        String responseBody;

        public MockHttpCalloutResponse(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setBody(responseBody);
            return response;
        }
    }
    
    static LoyaltyProgramMember createTestLoyaltyProgramMember(String memberNumber) {
        //Create a test Contact to associate with the LoyaltyProgramMember
        Contact testContact = new Contact(
            FirstName = 'Kim',
            LastName = 'Oliver',
            Email = '2kimoliver@gmail.com'
        );
        insert testContact;

        LoyaltyProgram testLoyaltyProgram = new LoyaltyProgram(
            Name = 'Just Shop'
        );
        insert testLoyaltyProgram;

        //Create a test LoyaltyProgramMember
        LoyaltyProgramMember testLoyaltyProgramMember = new LoyaltyProgramMember(
            MembershipNumber = memberNumber,
            ContactId = testContact.Id,
            ProgramId = testLoyaltyProgram.Id,
            EnrollmentDate = Date.today(),
            MemberStatus = 'Active'
        );

        insert testLoyaltyProgramMember;
        return testLoyaltyProgramMember;
    }

    @isTest static void resultWrapperExceptionTest() {
        JgLoyaltyController.ResultWrapper wrapper = new JgLoyaltyController.ResultWrapper('resultWrapperExceptionTest');
        try {
            //Generate exception
            Integer denominator = 0;
            Integer value = 1 / denominator;
        }
        catch (Exception e) {
            wrapper.SetException(e);
        }
    }

    @isTest static void getCurrentSalesforceUserAliasTest() {
        string currentUserAlias = JgLoyaltyController.getCurrentSalesforceUserAlias();
        System.assertNotEquals(null, currentUserAlias, 'Expected a non-null currentUserAlias');
    }    

    @isTest static void getCustomerTest() {
        //Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse(200, customerResponseApiData));
        
        String email = '2kimoliver@gmail.com';
        Boolean getLoyalty = true;

        //Call the method
        JgLoyaltyController.ResultWrapper wrapper = JgLoyaltyController.getCustomer(email, getLoyalty);
        
        //Verify the response
        System.assertEquals(200, wrapper.statusCode, 'Expected a 200 status code');
        System.assertNotEquals(null, wrapper.responseJson, 'Expected a non-null response body');
    }

    @isTest static void updateCustomerTest() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse(200, customerResponseApiData));

        //customer update json is same format as customerApiData
        JgLoyaltyController.ResultWrapper wrapper = JgLoyaltyController.updateCustomer(customerResponseApiData);

        System.assertEquals(200, wrapper.statusCode, 'Expected a 200 status code');
        System.assertNotEquals(null, wrapper.responseJson, 'Expected a non-null response body');
    }

    @isTest static void searchCustomersTest() {

        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse(200, searchApiResponseData));
        JgLoyaltyController.ResultWrapper wrapper = JgLoyaltyController.searchCustomers('test');
        System.assertEquals(200, wrapper.statusCode, 'Expected a 200 status code');
        System.assertNotEquals(null, wrapper.responseJson, 'Expected a non-null response body');

        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse(400, 'test error'));
        wrapper = JgLoyaltyController.searchCustomers('test');
        System.assertEquals(400, wrapper.statusCode, 'Expected a 400 status code');
        System.assertNotEquals(null, wrapper.responseJson, 'Expected a non-null response body');

        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse(403, 'test error 403'));
        wrapper = JgLoyaltyController.searchCustomers('test');
        System.assertEquals(403, wrapper.statusCode, 'Expected a 403 status code');
        System.assertNotEquals(null, wrapper.responseJson, 'Expected a non-null response body');

        //Test Other Error
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse(600, 'test error 600'));
        wrapper = JgLoyaltyController.searchCustomers('test');
        System.assertEquals(600, wrapper.statusCode, 'Expected a 600 status code');
        System.assertNotEquals(null, wrapper.responseJson, 'Expected a non-null response body');        
    }

    @isTest static void updateLoyaltyMemberTest() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse(200, loyaltyMemberResponseApiData));

        //customer update json is same format as customerApiData
        JgLoyaltyController.ResultWrapper wrapper = JgLoyaltyController.updateLoyaltyMember('testmemberNumber', loyaltyMemberResponseApiData);

        System.assertEquals(200, wrapper.statusCode, 'Expected a 200 status code');
        System.assertNotEquals(null, wrapper.responseJson, 'Expected a non-null response body');
    }

    @isTest static void getSalesforceLoyaltyMemberTest() {
        String testMemberNumber = '2791000036616';
        //Create and insert a test member
		LoyaltyProgramMember testLoyaltyMember = createTestLoyaltyProgramMember(testMemberNumber);

        //Member number from above gets updated somewhere so we need to get by id and use the MembershipNumber
        List<LoyaltyProgramMember> loyaltyMembers = [
            SELECT Id, AccountId, Program.Name, MembershipNumber, Contact.AccountId, Contact.FirstName, Contact.LastName, Contact.Email  
            FROM LoyaltyProgramMember 
            WHERE Id =: testLoyaltyMember.Id
        ];
        System.assertNotEquals(0, loyaltyMembers.Size(), 'Unable to get testLoyaltyMember');
        
        //Use first one (is only one) for testing
        JgLoyaltyController.ResultWrapper wrapper = JgLoyaltyController.getSalesforceLoyaltyMember(loyaltyMembers[0].MembershipNumber);
        
        System.assertEquals(200, wrapper.statusCode, 'Expected a 200 status code');
        System.assertNotEquals(null, wrapper.responseJson, 'Expected a non-null responseJson');
    }

    

}