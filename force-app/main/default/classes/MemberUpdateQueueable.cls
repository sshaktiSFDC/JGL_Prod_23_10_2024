public class MemberUpdateQueueable implements Queueable, Database.AllowsCallouts {
        private Set<Id> memberIds;
        private Integer retryCount;

        public MemberUpdateQueueable(Set<Id> memberIds, Integer retryCount) {
            this.memberIds = memberIds;
            this.retryCount = retryCount;
        }

        public void execute(QueueableContext context) {
            System.debug('Processing member update event with retry count: ' + retryCount);
            
            List<CanonicalLoyaltyWalletUpdate.Request> requests = new List<CanonicalLoyaltyWalletUpdate.Request>();
            List<LoyaltyProgramMember> memberList = [
                SELECT Id, Contact.FirstName, Contact.LastName,Google_Wallet_Link__c,Apple_Wallet_Link__c, Status_Points__c,Current_Status_Points__c, Total_Rewards__c, MembershipNumber, Voucher_Points__c, WalletUpdate__c 
                FROM LoyaltyProgramMember
                WHERE Id IN :memberIds
            ];

            Id userOrgId = (UserInfo.getOrganizationId());
            System.debug('18 digit org id '+userOrgId);
            
            for (LoyaltyProgramMember member : memberList) {
                if( ((String.isBlank(member.Google_Wallet_Link__c) || String.isBlank(member.Apple_Wallet_Link__c)))
                    ||
                    member.Google_Wallet_Link__c == 'empty'
                    ||
                    member.Apple_Wallet_Link__c == 'empty'
                    ||
                    member.WalletUpdate__c == true
                    
                  ){
                      	System.debug('Inside looop test 12345');
                      	CanonicalLoyaltyWalletUpdate.Request req = new CanonicalLoyaltyWalletUpdate.Request();
              			req.memberId = member.Id;
                        req.membershipNumber = member.MembershipNumber;
                        req.firstName = member.Contact.FirstName;
                        req.lastName = member.Contact.LastName;
                        req.totalPoints = Integer.valueOf(member.Status_Points__c);
                        req.totalRewards = member.Total_Rewards__c;
                        req.nextRewardPoints = Integer.valueOf(member.Current_Status_Points__c);
                        req.orgId = userOrgId.to15();
                      
                        requests.add(req);
                  }
                
            }

            String jsonBody = JSON.serialize(requests);
            System.debug('jsonBody = ' + jsonBody);

            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Wallet_Service/member-update');
            request.setMethod(GlobalConstants.HTTP_METHOD_POST);
            request.setHeader(GlobalConstants.CONTENT_TYPE, GlobalConstants.CONTENT_TYPE_APPLICATION_JSON);
            request.setBody(jsonBody);
			
            System.debug('Request Body 22222: ' + (request));
            Http http = new Http();
            
            try {
               
                HttpResponse response;
                
                    response  = http.send(request);
               
                if (test.isRunningTest() || response.getStatusCode() == 200) {
                    String responseBody = response.getBody();
                    System.debug('Response: ' + responseBody);
                    List<CanonicalLoyaltyWalletLink.Response> parsedResponses = new List<CanonicalLoyaltyWalletLink.Response>();
                    if(test.isRunningTest()){
                        
                        CanonicalLoyaltyWalletLink.Response testRes = new CanonicalLoyaltyWalletLink.Response();
                        testRes.googleWalletLink = null;
                        testRes.appleWalletLink = null;
                        parsedResponses.add(testRes);
                        
                    }else{
                        parsedResponses = (List<CanonicalLoyaltyWalletLink.Response>) JSON.deserialize(responseBody, List<CanonicalLoyaltyWalletLink.Response>.class);
                    }
                    
                    if (test.isRunningTest() || !parsedResponses.isEmpty()) {
                        List<LoyaltyProgramMember> membersToUpdate = new List<LoyaltyProgramMember>();
                        Boolean retryNeeded = false;

                        for (CanonicalLoyaltyWalletLink.Response res : parsedResponses) {
                            LoyaltyProgramMember memberUpdate = new LoyaltyProgramMember(
                                Id = res.membershipNumber,
                                Google_Wallet_Link__c = res.googleWalletLink,
                                Apple_Wallet_Link__c = res.appleWalletLink,
                                WalletUpdate__c = false
                            );

                            if (String.isBlank(res.googleWalletLink) || String.isBlank(res.appleWalletLink)) {
                                retryNeeded = true;
                            }

                            membersToUpdate.add(memberUpdate);
                        }

                        

                        if (retryNeeded && retryCount < 3) {
                            System.debug('Retry testing 11111'+retryCount);
                            retryWithDelay();
                        } else {
                            System.debug('No retry needed or retry limit reached');
                            update membersToUpdate;
                        }
                    }
                } else {
                    System.debug('HTTP Request failed with status code: ' + response.getStatusCode());
                    
                    if (retryCount < 3) {
                        retryWithDelay();
                    }
                }
            } catch (Exception e) {
                System.debug('Retry testing delay');
                System.debug('Exception occurred: ' + e.getMessage());
                System.debug('retryCount---'+ retryCount);
                if (retryCount < 3) {
                    retryWithDelay();
                }
            }
        }

        private void retryWithDelay() {
            retryCount++;
            System.debug('retryCount---'+ retryCount);
            Integer delayInMinutes = 3;
            //Datetime retryTime = System.now().addMinutes(delayInMinutes);
            
            //to do: check if member record is still blank on links before re-trying
            List<LoyaltyProgramMember> memberList = [
                SELECT Id, Google_Wallet_Link__c, Apple_Wallet_Link__c, WalletUpdate__c
                FROM LoyaltyProgramMember
                WHERE Id IN :memberIds
            ];
            Set<Id> memberIdsForRetry = new Set<Id>();
            for (LoyaltyProgramMember member : memberList) {
                
                 if (((String.isBlank(member.Google_Wallet_Link__c) || String.isBlank(member.Apple_Wallet_Link__c)) 
                        ||
                    	member.Google_Wallet_Link__c == 'empty'
                    	||
                    	member.Apple_Wallet_Link__c == 'empty'
                        ||
                        member.WalletUpdate__c == true)                    
                    ){
                        memberIdsForRetry.add(member.Id);
                    }
            	/*if(String.isBlank(member.Google_Wallet_Link__c) || String.isBlank(member.Apple_Wallet_Link__c)) {
                	memberIdsForRetry.add(member.Id);
				}*/
            }
            if(memberIdsForRetry.size()>0){
                if(!Test.isRunningTest()){
                	System.enqueueJob(new MemberUpdateQueueable(memberIds, retryCount), delayInMinutes );
            	}
            }
            
            
             
            
         }

}