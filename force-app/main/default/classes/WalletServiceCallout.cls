/*public class WalletServiceCallout {
    
 @InvocableMethod (callout=true)
    public static List<WalletResponse> makeCallout(List<WalletRequest> payload) {
        // Initialize result list
        System.debug('payload---> '+payload);
        List<WalletResponse> result = new List<WalletResponse>();
        Http http = new Http();
        String errorMessage = null;
        Long callTime;
        System.debug('WalletServiceCallout payload---> '+payload);
        try {
            callTime = System.currentTimeMillis();
            
            // Prepare the request
            HttpRequest req = new HttpRequest(); 
            req.setHeader(GlobalConstants.CONTENT_TYPE, GlobalConstants.CONTENT_TYPE_APPLICATION_JSON);
            req.setMethod(GlobalConstants.HTTP_METHOD_POST);

            // Set environment & endpoint
            String endpoint = 'callout:Wallet_Service/get-wallet-links/' + payload[0].membershipNumber;
            req.setEndpoint(endpoint);
            System.debug('WalletServiceCallout requestPayload = inside' );
            CanonicalLoyaltyWalletLink.Request requestCanonical = new CanonicalLoyaltyWalletLink.Request();
            requestCanonical.memberId = payload[0].memberId;            
            requestCanonical.membershipNumber = payload[0].membershipNumber;
            requestCanonical.firstName = payload[0].firstName;
            requestCanonical.lastName = payload[0].lastName;
            requestCanonical.nextRewardPoints = payload[0].nextRewardPoints;
            requestCanonical.totalRewards =  payload[0].totalRewards;

            String requestPayload = JSON.serialize(requestCanonical);
            System.debug('requestPayload = ' + requestPayload);
            
            // Serialize payload to JSON
           // String requestPayload = JSON.serialize(requestPayload);
            req.setBody(requestPayload);  // Set the body as a JSON object
           System.debug('Request = ' + req);

            // Send the request
            HttpResponse response = http.send(req);
            System.debug('Response = ' + response);

            // Get the response body
            String responseBody = response.getBody();
            System.debug('ResponseBody = ' + responseBody);

            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                // Parse response
                WalletResponse parsedResponse = 
                    (WalletResponse) JSON.deserialize(responseBody, WalletResponse.class);
                callTime = System.currentTimeMillis() - callTime;
                parsedResponse.calltime = String.valueOf(callTime);
                result.add(parsedResponse);  // Add the parsed response to the result list
            } else {
                // Handle non-successful HTTP status codes
                System.debug('Error: Unexpected status code ' + response.getStatusCode());
                errorMessage = 'Failed with status code ' + response.getStatusCode() + ': ' + response.getStatus();
            }
        
        } catch (System.Exception ex) {
            // Handle exception
            System.debug('An error occurred: ' + ex.getMessage());
            System.debug('Exception: ' + ex.getStackTraceString());
            errorMessage = 'Exception: ' + ex.getMessage();
        } finally {
            callTime = System.currentTimeMillis() - callTime;
            System.debug('Call Time: ' + callTime + ' ms');
        }
       // Return the result list (could be empty if no successful response)
        return result;
    }
    
    public class WalletRequest {
        @InvocableVariable
        public String memberId;
        @InvocableVariable
        public String membershipNumber;
        @InvocableVariable
        public String firstName;
        @InvocableVariable
        public String lastName;
        @InvocableVariable
        public Integer nextRewardPoints;
        @InvocableVariable
        public Decimal totalRewards;
    }
    
   public class WalletResponse {
        @InvocableVariable
        public String googleWalletLink;
        @InvocableVariable
        public String appleWalletLink;
        @InvocableVariable
        public String membershipNumber;
       @InvocableVariable
        public String calltime;
    } 
    
    
 
}*/
public class WalletServiceCallout {
    
    @InvocableMethod(callout=true)
    public static void makeCallout(List<WalletRequest> payloadList) {
        
        List<WalletRequest> walletReq = new List<WalletRequest>();
        System.debug('Walletpayload---->'+ payloadList + 'input size:' + payloadList.size());
          for (WalletRequest payload : payloadList) {
          walletReq.add(payload);
          }
        runMemberUpdate(walletReq);
        
      /*  for (WalletRequest payload : payloadList) {
            HttpRequest req = new HttpRequest(); 
            req.setHeader(GlobalConstants.CONTENT_TYPE, GlobalConstants.CONTENT_TYPE_APPLICATION_JSON);
            req.setMethod(GlobalConstants.HTTP_METHOD_POST);

            // Set environment & endpoint
            String endpoint = 'callout:Wallet_Service/get-wallet-links/' + payload.membershipNumber;
            req.setEndpoint(endpoint);

            // Build the request body
            CanonicalLoyaltyWalletLink.Request requestCanonical = new CanonicalLoyaltyWalletLink.Request();
            requestCanonical.memberId = payload.memberId;            
            requestCanonical.membershipNumber = payload.membershipNumber;
            requestCanonical.firstName = payload.firstName;
            requestCanonical.lastName = payload.lastName;
            requestCanonical.nextRewardPoints = payload.nextRewardPoints;
            requestCanonical.totalRewards = payload.totalRewards;

            String requestPayload = JSON.serialize(requestCanonical);
            req.setBody(requestPayload);  // Set the body as a JSON object

            WalletResponse walletResponse = new WalletResponse();
            walletResponse.membershipNumber = payload.membershipNumber;  // Keep track of membership number

            try {
                // Send the request
                callTime = System.currentTimeMillis();
                HttpResponse response = http.send(req);

                // Get the response body
                String responseBody = response.getBody();

                // If the request is successful, parse the JSON response.
                if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                    WalletResponse parsedResponse = (WalletResponse) JSON.deserialize(responseBody, WalletResponse.class);
                    parsedResponse.calltime = String.valueOf(System.currentTimeMillis() - callTime);
                    parsedResponse.membershipNumber = payload.membershipNumber; // Ensure response maps to request
                    result.add(parsedResponse);
                } else {
                    // Handle error response
                    walletResponse.calltime = String.valueOf(System.currentTimeMillis() - callTime);
                    walletResponse.googleWalletLink = 'Error: ' + response.getStatus();
                    walletResponse.appleWalletLink = 'Error: ' + response.getStatus();
                    result.add(walletResponse);
                }
            } catch (System.Exception ex) {
                // Handle exceptions
                walletResponse.calltime = String.valueOf(System.currentTimeMillis() - callTime);
                walletResponse.googleWalletLink = 'Error: ' + ex.getMessage();
                walletResponse.appleWalletLink = 'Error: ' + ex.getMessage();
                result.add(walletResponse);
            }
        }
        */
       // return result;  // Ensure that the size of the result matches the size of the payloadList
    }
    
    
    public static void runMemberUpdate(List<WalletRequest> walletReq){
            String jsonBody = JSON.serialize(walletReq);
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Wallet_Service/member-update');
            request.setMethod(GlobalConstants.HTTP_METHOD_POST);
            request.setHeader(GlobalConstants.CONTENT_TYPE, GlobalConstants.CONTENT_TYPE_APPLICATION_JSON);
            request.setBody(jsonBody);
			
            System.debug('Request Body 22222: ' + (request));
            Http http = new Http();

            try {
                HttpResponse response = http.send(request);
                System.debug('99999----'+response);
                if (response.getStatusCode() == 200) {
                    String responseBody = response.getBody();
                    System.debug('Response: ' + responseBody);
                    
                    List<CanonicalLoyaltyWalletLink.Response> parsedResponses = (List<CanonicalLoyaltyWalletLink.Response>) JSON.deserialize(responseBody, List<CanonicalLoyaltyWalletLink.Response>.class);
                    
                   if (!parsedResponses.isEmpty()) {
                        List<LoyaltyProgramMember> membersToUpdate = new List<LoyaltyProgramMember>();
                        Boolean retryNeeded = false;

                        for (CanonicalLoyaltyWalletLink.Response res : parsedResponses) {
                            LoyaltyProgramMember memberUpdate = new LoyaltyProgramMember(
                                Id = res.membershipNumber,
                                Google_Wallet_Link__c = res.googleWalletLink,
                                Apple_Wallet_Link__c = res.appleWalletLink
                            );

                            if (String.isBlank(res.googleWalletLink) || String.isBlank(res.appleWalletLink)) {
                                retryNeeded = true;
                            }

                            membersToUpdate.add(memberUpdate);
                        }

                        
                            update membersToUpdate;
                    } 
                } else {
                    System.debug('HTTP Request failed with status code: ' + response.getStatusCode());
                    
                }
            } catch (Exception e) {
                System.debug('Retry testing delay');
                System.debug('Exception occurred: ' + e.getMessage());
                
            }

    } 
    
    public class WalletRequest {
        @InvocableVariable
        public String memberId;
        @InvocableVariable
        public String membershipNumber;
        @InvocableVariable
        public String firstName;
        @InvocableVariable
        public String lastName;
        @InvocableVariable
        public Integer nextRewardPoints;
        @InvocableVariable
        public Decimal totalRewards;
        @InvocableVariable
        public Id orgId;
    }
    
    public class WalletResponse {
    
        public String googleWalletLink;
    
        public String appleWalletLink;
 
        public String membershipNumber;
 
        public String calltime;
    } 
}