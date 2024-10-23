public class JgLoyaltyController {

    /*
    class LoyaltyMemberExtPreferences {
        public boolean email;
        public boolean sms;
    }
    class LoyaltyMemberExtAttributes {
        public String name;	//enrolmentBrand
        public String value;	//EJNZ
    }

    public class LoyaltyMemberExt {
        //Used to hold API results of LoyaltyMember
        public String email;	//junittest_http_1725402277565@jjh.com.au
        public String loyaltyProgram;	//Just Shop
        public String memberNumber;	//2791000000133
        public String mobile;	//0404040404
        public String dob;	//1967-09-20
        public String firstname;	//Craig
        public String lastname;	//Perring
        public String country;	//AU
        public String state;	//VIC
        public String enrolmentDate;	//2024-09-03T22:24:39.000Z
        public String enrolmentChannel;	//POS
        public Integer pointsBalance;	//50
        public Integer pointsToNextVoucher;	//150
        public String rewardsAvailable;	//$0
        public String customerSummary;	//Customer <b>Craig Perring</b></br>Points to next reward <b>150</b></br>Rewards available <b>$0</b>
        public LoyaltyMemberExtPreferences preferences;
        public LoyaltyMemberExtAttributes[] attributes;
        public Integer customerId;	//2
    }
    */

    public class ResultWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public Boolean result;
        @AuraEnabled public Integer statusCode;
        @AuraEnabled public String lastError;
        @AuraEnabled public String responseJson;

        public ResultWrapper(String name) {
            this.name = name;
            System.Debug(name + ' Start');
        }  
               
        public void SetResponse(HttpResponse res) {
            result = false; 
            statusCode = res.getStatusCode();
            responseJson = res.getBody();
            if (statusCode == 200 || statusCode == 204) { //200 GET, 204 PATCH
                //Process the response is successful
                result = true;                  
                System.debug(name + ' Successful Response: ' + responseJson);
            } else if (statusCode == 400) {
                lastError = 'Validation Error(s): \n\n' + res.getBody();
            } else if (statusCode == 403) {
                lastError = 'A 403 Forbidden error. The server understood the request, but it refuses to authorize';                
            } else {
                lastError = name + ' Status Code: ' + res.getStatusCode() + ' Error message: ' + responseJson;
                System.debug(lastError);
            }              
        }  

        public void SetException(Exception e) {
            result = false;
            lastError = name + ' Exception: ' + e.getMessage() + ' line: ' + e.getLineNumber();
            System.debug(lastError);
        }
    }

    @AuraEnabled(cacheable=true) public static string getCurrentSalesforceUserAlias() {
        //Keeping it simple here as there is always a user
        String currentUserAlias = [SELECT Alias FROM User WHERE Id = :UserInfo.getUserId()].Alias;
        return currentUserAlias;
    }

    @AuraEnabled public static ResultWrapper getCustomer(String email, Boolean getLoyalty) {
        ResultWrapper wrapper = new ResultWrapper('Get Customer');
        try {

            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            String endPointUrl = System.Label.JUST_GROUP_CIM_URL_PREFIX + '/customer?email=' + email + '&loyalty=' + getLoyalty;

            req.setEndpoint(endPointUrl);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Basic c2ZtY3VzZXI6c2ZtY3VzM3I=');
            
            HttpResponse res = http.send(req);
            wrapper.SetResponse(res);
        }
        catch (Exception e) {
            wrapper.SetException(e);
        }
        return wrapper;
    }

    @AuraEnabled public static ResultWrapper updateCustomer(String payload) {
        ResultWrapper wrapper = new ResultWrapper('Update Customer');
        try {
            
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            String endPointUrl = System.Label.JUST_GROUP_CIM_URL_PREFIX + '/customer';

            req.setEndpoint(endPointUrl);
            req.setHeader('Content-Type', 'application/json'); 
            req.setMethod('POST');
            req.setHeader('Authorization', 'Basic c2ZtY3VzZXI6c2ZtY3VzM3I=');

            // Set the request body with the data you want to update (JSON format)
            req.setBody(payload);  
            
            HttpResponse res = http.send(req);
            wrapper.SetResponse(res);
        }
        catch (Exception e) {
            wrapper.SetException(e);
        }
        return wrapper;
    }

    @AuraEnabled public static ResultWrapper searchCustomers(String searchString) {    
        ResultWrapper wrapper = new ResultWrapper('Search Customers');
        try {
            
            HttpRequest req = new HttpRequest();
            Http http = new Http();

            String endPointUrl = System.Label.JUST_GROUP_CIM_URL_PREFIX + '/customer/search?criteria=' + searchString;
            req.setEndpoint(endPointUrl);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Basic c2ZtY3VzZXI6c2ZtY3VzM3I=');
            
            HttpResponse res = http.send(req);
            wrapper.SetResponse(res);
        }
        catch (Exception e) {
            wrapper.SetException(e);
        }
        return wrapper;
    }

    @AuraEnabled public static ResultWrapper getSalesforceLoyaltyMember(String memberNumber) {    
        ResultWrapper wrapper = new ResultWrapper('Get Salesforce Loyalty Program Member');
        try {
            // SOQL query to find LoyaltyProgramMember records based on the MembershipNumber or Contact's details
            List<LoyaltyProgramMember> loyaltyMembers = [SELECT Id, AccountId, Program.Name, MembershipNumber, Contact.AccountId, Contact.FirstName, Contact.LastName, Contact.Email  
                                                         FROM LoyaltyProgramMember 
                                                         WHERE MembershipNumber = :memberNumber];
            if (loyaltyMembers.Size() > 0) {
                wrapper.statusCode = 200;
                wrapper.responseJson = JSON.serialize(loyaltyMembers[0]);
                wrapper.result = true;
            } else {
                wrapper.statusCode = 400;
                wrapper.lastError = 'Loyalty Member not found for Membership Number: ' + memberNumber;
                wrapper.result = false;
            } 
        }
        catch (Exception e) {
            wrapper.SetException(e);
        }
        return wrapper;
    }    
    
    /* not used searches customers using customer API - does not get from Salesforce
    @AuraEnabled public static SearchWrapper searchLoyaltyMemebers(String searchTerm) {    
        SearchWrapper wrapper = new SearchWrapper();
        try {
            // SOQL query to find LoyaltyProgramMember records based on the MembershipNumber or Contact's details
            wrapper.loyaltyMembers = [SELECT Id, MembershipNumber, Program.Name, Contact.FirstName, Contact.LastName, Contact.Email
                                                         FROM LoyaltyProgramMember 
                                                         WHERE MembershipNumber = :searchTerm 
                                                         OR Contact.FirstName LIKE :('%' + searchTerm + '%') 
                                                         OR Contact.LastName LIKE :('%' + searchTerm + '%')
                                                         OR Contact.Email LIKE :('%' + searchTerm + '%')];
            
            wrapper.result = true;
        }
        catch (Exception e) {
            wrapper.result = false;
            wrapper.lastError = 'Exception occured searchLoyaltyMemebers: ' + e.getMessage() + ' line: ' + e.getLineNumber();
        }
        return wrapper;
    }
    */

    /* not used gets member details using customer API
    @AuraEnabled public static MemberWrapper getLoyaltyMemeber(String memberNumber) {
        //Gets Loyalty Memeber Using Api
        MemberWrapper wrapper = new MemberWrapper();
        try {
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            string endPointUrl = 'https://services.test.justgroup.com.au/cim/uat/loyalty/justshop/' + memberNumber;
            req.setEndpoint(endPointUrl);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Basic c2ZtY3VzZXI6c2ZtY3VzM3I=');
            
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 301) {
                String newLocation = res.getHeader('Location');
                System.debug('Redirect to: ' + newLocation);
                req.setEndpoint(newLocation); // Set the new location for the request
                res = http.send(req); // Send the request to the new location
            }

            if (res.getStatusCode() == 200) {
                //Process the response if successful
                wrapper.result = true;  
                wrapper.responseJson = res.getBody();
                              
                System.debug('Response: ' + wrapper.responseJson);
            } else {
                //Handle the error if failed
                wrapper.result = false;  
                wrapper.lastError = 'getLoyaltyMemeberApi for programName = "' + programName + '" memberNumber = "' + memberNumber + '" failed with status code: ' + res.getStatusCode() + ' Error message: ' + res.getBody() + ' at endPoint: ' + endPointUrl;
                System.debug('Request failed with status code: ' + res.getStatusCode());
                System.debug('Error message: ' + res.getStatus());
            }

        }

        catch (Exception e) {
            wrapper.result = false;
            wrapper.lastError = ' getLoyaltyMemeberApi APEX Exception: ' + e.getMessage() + ' line: ' + e.getLineNumber();
        }
        return wrapper;
    }
    */

    @AuraEnabled public static ResultWrapper updateLoyaltyMember(String memberNumber, String payload) {
        ResultWrapper wrapper = new ResultWrapper('Update Loyalty Member');
        try {
            // Create an HTTP request instance
            HttpRequest req = new HttpRequest();
            Http http = new Http();

            // Set the endpoint URL for the PATCH request
            String endPointUrl = System.Label.JUST_GROUP_CIM_URL_PREFIX + '/loyalty/justshop/' + memberNumber;

            // Set the method to PATCH
            req.setMethod('PATCH');
            req.setHeader('Content-Type', 'application/json');            
            req.setHeader('Authorization', 'Basic c2ZtY3VzZXI6c2ZtY3VzM3I=');
            
            // Set the endpoint URL
            req.setEndpoint(endPointUrl);
            
            // Set the request body with the data you want to update (JSON format)
            req.setBody(payload);

            // Send the HTTP PATCH request and get the response
            HttpResponse res = http.send(req);
            wrapper.SetResponse(res);
        }
        catch (Exception e) {
            wrapper.SetException(e);
        }
        return wrapper;
    }


    
    
}