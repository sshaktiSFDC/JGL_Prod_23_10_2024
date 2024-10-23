/**
* @name         : LoyaltyWalletLinksRestService
* @description  : Custom REST service to return Wallet links for members
* @testClass    : LoyaltyWalletLinksRestServiceTest
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-03-15    Vince Vuong         Created
* 2024-04-29    Vince Vuong         Updated callout to use Named Credential
*/
@RestResource(urlMapping='/loyalty/programs/*/members/*/wallet-links')
global with sharing class LoyaltyWalletLinksRestService {
    
    @HttpGet
    global static void doGet() {
        try {
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;
            
            String[] urls = request.requestURI.split('/');
            System.debug('paramssss---'+request.params);
            System.debug('request URI---'+request.requestURI);
            System.debug('urls----'+urls);
                    
            //URL = /loyalty/programs/NTO/members/M1/wallet-links    
            String programName = EncodingUtil.urlDecode(urls[3], 'UTF-8');
            String membershipNumber = urls[5]; //'TEST123';
            System.debug('memberShipNumber----'+membershipNumber);
            membershipNumber = membershipNumber.trim();
            

            //Retrieve member details
            LoyaltyProgramMember[] members = [SELECT Id, Google_Wallet_Link__c, Apple_Wallet_Link__c, MemberStatus,Unique_ID__c, MembershipNumber, Contact.FirstName, Contact.LastName, Contact.Email, Contact.MobilePhone, Current_Status_Points__c, Total_Rewards__c
                                            FROM LoyaltyProgramMember
                                            WHERE MembershipNumber = :membershipNumber];
			
            LoyaltyProgramMember member = (members.size() > 0) ? members[0] : null;
            

            //Check mandatory fields
            Boolean validRequest = true;
            Bypass_Automation__c  walletsetting = Bypass_Automation__c.getInstance(UserInfo.getUserId());
            Boolean walletcall = walletsetting.WalletCallOut__c ;
           
            // if( !((String.isBlank(member.Google_Wallet_Link__c) || String.isBlank(member.Apple_Wallet_Link__c)))) 
            if (    !((String.isBlank(member.Google_Wallet_Link__c) || String.isBlank(member.Apple_Wallet_Link__c)))
                    &&
                    member.Google_Wallet_Link__c != 'empty'
                    && 
                    member.Apple_Wallet_Link__c != 'empty'
                    &&
                    walletcall == false
                    )
            {
                
                system.debug('in If condition as the links exist');
            	CanonicalLoyaltyWalletLink.Response payload = new CanonicalLoyaltyWalletLink.Response();
                payload.membershipNumber = member.MembershipNumber;
                payload.googleWalletLink = member.Google_Wallet_Link__c;
                payload.appleWalletLink = member.Apple_Wallet_Link__c;
                
                //Send back response payload
           		RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(payload,true));
            	RestContext.response.addHeader(GlobalConstants.CONTENT_TYPE, GlobalConstants.CONTENT_TYPE_APPLICATION_JSON);
                return; 
            }

            
            system.debug('Links do not exist so outside if');
            List<String> errorMessages = new List<String>();
            Id userOrgId = UserInfo.getOrganizationId();
            if (String.isBlank(programName)) {
                errorMessages.add('Invalid loyalty program');
                validRequest = false;
            }
            System.debug('memberShipNumber222'+membershipNumber);
            System.debug('member'+members);
            if (String.isBlank(membershipNumber) || member == null) {
                errorMessages.add('Invalid membership number');
                validRequest = false;
            }
           
            if (!validRequest) {
                RestContext.response.statuscode = GlobalConstants.HTTP_STATUS_CODE_BAD_REQUEST;
                RestContext.response.responseBody = Blob.valueOf(String.join(errorMessages,'.'));
                return;
            }

            //Generate request payload
            CanonicalLoyaltyWalletLink.Request requestCanonical = new CanonicalLoyaltyWalletLink.Request();
            requestCanonical.memberId = member.Id;            
            requestCanonical.membershipNumber = membershipNumber;
            requestCanonical.firstName = member.Contact.FirstName;
            requestCanonical.lastName = member.Contact.LastName;
            requestCanonical.nextRewardPoints = (Integer)member.Current_Status_Points__c;
            requestCanonical.totalRewards = member.Total_Rewards__c;
            requestCanonical.orgId = userOrgId.to15();

            String requestPayload = JSON.serialize(requestCanonical);
            System.debug('requestPayload = ' + requestPayload);

            //Make API callout to Wallet Service to retrieve wallet links per member
            //Send latest member details to Wallet Service to generate passes
            CanonicalLoyaltyWalletLink.Response payload = new CanonicalLoyaltyWalletLink.Response();
            payload = makeCallout(membershipNumber, requestPayload);
            System.debug('payload = ' + payload);

            //String googleWalletLink = 'https://pay.google.com/gp/v/save/eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJteS1zZXJ2aWNlLWFjY291bnRAZWhjLXZ2dW9uZy01MWZiZGEuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLCJhdWQiOiJnb29nbGUiLCJvcmlnaW5zIjpbIiJdLCJ0eXAiOiJzYXZldG93YWxsZXQiLCJwYXlsb2FkIjp7ImdlbmVyaWNDbGFzc2VzIjpbeyJpZCI6IjMzODgwMDAwMDAwMjIzMTUyODguR2VuZXJpY0NsYXNzRGVtbyIsImNsYXNzVGVtcGxhdGVJbmZvIjp7ImNhcmRUZW1wbGF0ZU92ZXJyaWRlIjp7ImNhcmRSb3dUZW1wbGF0ZUluZm9zIjpbeyJ0d29JdGVtcyI6eyJzdGFydEl0ZW0iOnsiZmlyc3RWYWx1ZSI6eyJmaWVsZHMiOlt7ImZpZWxkUGF0aCI6Im9iamVjdC50ZXh0TW9kdWxlc0RhdGFbXCJwb2ludHNcIl0ifV19fSwiZW5kSXRlbSI6eyJmaXJzdFZhbHVlIjp7ImZpZWxkcyI6W3siZmllbGRQYXRoIjoib2JqZWN0LnRleHRNb2R1bGVzRGF0YVtcInZvdWNoZXJzXCJdIn1dfX19fV19fX1dLCJnZW5lcmljT2JqZWN0cyI6W3siaWQiOiIzMzg4MDAwMDAwMDIyMzE1Mjg4LkdlbmVyaWNDbGFzc0RlbW8tOTA3OTUzZGNiZDAxYWQ2OGRiMWYxOWJlMjg2OTM2ZjQiLCJjbGFzc0lkIjoiMzM4ODAwMDAwMDAyMjMxNTI4OC5HZW5lcmljQ2xhc3NEZW1vIiwic3RhdGUiOiJBQ1RJVkUiLCJsb2dvIjp7InNvdXJjZVVyaSI6eyJ1cmkiOiJodHRwczovL3N0b3JhZ2UuZ29vZ2xlYXBpcy5jb20vd2FsbGV0LWxhYi10b29scy1jb2RlbGFiLWFydGlmYWN0cy1wdWJsaWMvcGFzc19nb29nbGVfbG9nby5qcGcifSwiY29udGVudERlc2NyaXB0aW9uIjp7ImRlZmF1bHRWYWx1ZSI6eyJsYW5ndWFnZSI6ImVuLVVTIiwidmFsdWUiOiJMT0dPX0lNQUdFX0RFU0NSSVBUSU9OIn19fSwiY2FyZFRpdGxlIjp7ImRlZmF1bHRWYWx1ZSI6eyJsYW5ndWFnZSI6ImVuLVVTIiwidmFsdWUiOiJEZW1vIEdvb2dsZSBQYXNzIn19LCJzdWJoZWFkZXIiOnsiZGVmYXVsdFZhbHVlIjp7Imxhbmd1YWdlIjoiZW4tVVMiLCJ2YWx1ZSI6IlNpbHZlciJ9fSwiaGVhZGVyIjp7ImRlZmF1bHRWYWx1ZSI6eyJsYW5ndWFnZSI6ImVuLVVTIiwidmFsdWUiOiJOZXcgTWVtYmVyIn19LCJ0ZXh0TW9kdWxlc0RhdGEiOlt7ImlkIjoicG9pbnRzIiwiaGVhZGVyIjoiUE9JTlRTIiwiYm9keSI6IjAifSx7ImlkIjoidm91Y2hlcnMiLCJoZWFkZXIiOiJWT1VDSEVSUyIsImJvZHkiOiIwIn1dLCJiYXJjb2RlIjp7InR5cGUiOiJDT0RFXzEyOCIsInZhbHVlIjoiQkFSQ09ERV9WQUxVRSIsImFsdGVybmF0ZVRleHQiOiIyNzkxMDAwMDAwMDkxIn0sImhleEJhY2tncm91bmRDb2xvciI6IiM0Mjg1ZjQiLCJoZXJvSW1hZ2UiOnsic291cmNlVXJpIjp7InVyaSI6Imh0dHBzOi8vc3RvcmFnZS5nb29nbGVhcGlzLmNvbS93YWxsZXQtbGFiLXRvb2xzLWNvZGVsYWItYXJ0aWZhY3RzLXB1YmxpYy9nb29nbGUtaW8taGVyby1kZW1vLW9ubHkucG5nIn0sImNvbnRlbnREZXNjcmlwdGlvbiI6eyJkZWZhdWx0VmFsdWUiOnsibGFuZ3VhZ2UiOiJlbi1VUyIsInZhbHVlIjoiSEVST19JTUFHRV9ERVNDUklQVElPTiJ9fX19XX0sImlhdCI6MTcxMDQ3OTY2MX0.ebZO3J8O0ErvOE0Q5t-lh4Bj0yJ2qYNCZkR7A7EEIKqyUl0HHdzroSCOBpiTpGhb1GatDuRSoO32yyy5edPrZ8AtGDmH4XDACnqKKIAB-hX15ON3jGkaqdx9LuzeJUDwkzMCE658jjgWO3hy0RQ4HNE5yZUdsxm3gclT3ZixFNotSI3rN0ItZ8zvaBV4btBb-dD8DXXsHnylkjfBPjHfG3h1peIFlXcjpFMigEm01i2dwN312kYZG4z4I8ZQ57e_rtKp1YV9ptAFZQUCPu_zHzoOMgvIb_X3DCMqMjhrjDTLX0j_WbPh4C7Mb6ELPD07aMXNsnsu82d8W_HnF0eayQ';
            //String appleWalletLink = 'https://custom-wallet-service-c0b0cdc04d4e.herokuapp.com/apple-pass-generic/TEST123/907953dcbd01ad68db1f19be286936f4';

            if (payload != null) {
                //Store wallet links against member record
                update new LoyaltyProgramMember(
                    Id = member.Id,
                    Apple_Wallet_Link__c = payload.appleWalletLink,
                    Google_Wallet_Link__c = payload.googleWalletLink
                );
            }

            //Send back response payload
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(payload,true));
            RestContext.response.addHeader(GlobalConstants.CONTENT_TYPE, GlobalConstants.CONTENT_TYPE_APPLICATION_JSON);

        } catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
            System.debug('Exception: ' + ex.getStackTraceString());
            RestContext.response.statuscode = 500; // Internal Server Error
            RestContext.response.responseBody = Blob.valueOf(ex.getMessage() + ' - ' + ex.getStackTraceString());
        }
    }

    //Make call out to Wallet Service
    private static CanonicalLoyaltyWalletLink.Response makeCallout(String membershipNumber, String payload) {
        CanonicalLoyaltyWalletLink.Response result = null;
        Http http = new Http();
        String errorMessage = null;
        Long callTime;

        try {
            callTime = System.currentTimeMillis();

            //Request
            HttpRequest req = new HttpRequest(); 
            req.setHeader(GlobalConstants.CONTENT_TYPE, GlobalConstants.CONTENT_TYPE_APPLICATION_JSON);
            req.setMethod(GlobalConstants.HTTP_METHOD_POST);

            //Set environment & endpoint
            String endpoint = 'callout:Wallet_Service/get-wallet-links/' + membershipNumber;
            req.setEndpoint(endpoint);
                    
            //Set environment specific timeout
            //req.setTimeout(getTimeOut(environment));

            // Set the body as a JSON object
            req.setBody(payload);
            System.debug('Request = ' + req);

            //Send request
            HttpResponse response = http.send(req);
            System.debug('response = ' + response);

            String responseBody = response.getBody();
            System.debug('responseBody = ' + responseBody);

            // If the request is successful, parse the JSON response.
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                //Parse response
                result = (CanonicalLoyaltyWalletLink.Response) JSON.deserialize(responseBody, CanonicalLoyaltyWalletLink.Response.class);
            }
        
        }catch (System.Exception ex) {
            result = null;
            System.debug('An error occurred: ' + ex.getMessage());
            System.debug('Exception: ' + ex.getStackTraceString());

        }finally {
            callTime = System.currentTimeMillis() - callTime;
        }
        return result;
    }
}