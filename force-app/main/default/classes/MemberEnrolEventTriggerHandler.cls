/**
* @name         : MemberEnrolEventTriggerHandler
* @description  : Handler class for Member Update Event platform events (modified to handle only Create/Enroll.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-04-17    Siddharth Singh     Created
*/
public class MemberEnrolEventTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {

        
        Set<Id> newenrolPEEventsMemberIds = new Set<Id>();
        for (Member_Enrol_Event__e  newEvent : (List<Member_Enrol_Event__e >)Trigger.new) {
            newenrolPEEventsMemberIds.add(newEvent.Member_Id__c);
        }
        System.debug('newenrolPEEventsMemberIds = ' + newenrolPEEventsMemberIds);
        
        if(!newenrolPEEventsMemberIds.isEmpty()){
        //    subscribeEventsAndDoCallout(newenrolPEEventsMemberIds);
        System.enqueueJob(new MemberUpdateQueueable(newenrolPEEventsMemberIds, 0));
        
        }
        
    }
    
  /*  @future(callout=true)
    public static void subscribeEventsAndDoCallout(Set<Id> memberIds){
        System.debug('subscribeEventsAndDoCallout');

        List<CanonicalLoyaltyWalletUpdate.Request> requests = new List<CanonicalLoyaltyWalletUpdate.Request>();        
        List<LoyaltyProgramMember> memberList= [SELECT Id, Contact.FirstName, Contact.LastName, Status_Points__c,Current_Status_Points__c, Total_Rewards__c, MembershipNumber, Voucher_Points__c 
                                                FROM LoyaltyProgramMember
                                                WHERE Id IN:memberIds];
        
        // Construct the Request objects
        for (LoyaltyProgramMember member : memberList) {
            CanonicalLoyaltyWalletUpdate.Request req = new CanonicalLoyaltyWalletUpdate.Request();
            req.memberId = member.Id;
            req.membershipNumber = member.MembershipNumber;
            req.firstName = member.Contact.FirstName;
            req.lastName = member.Contact.LastName;
            //req.tierLevel = 'base';
            req.totalPoints = Integer.valueOf(member.Status_Points__c);
            req.totalRewards = member.Total_Rewards__c;
            req.nextRewardPoints = Integer.valueOf(member.Current_Status_Points__c);
            requests.add(req);
        } 
        
        // Convert requests to JSON
        String jsonBody = JSON.serialize(requests);
        System.debug('jsonBody = ' + jsonBody);

        // Get the endpoint URL from Named Credential
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Wallet_Service/member-update');
        
        request.setMethod(GlobalConstants.HTTP_METHOD_POST);
        request.setHeader(GlobalConstants.CONTENT_TYPE, GlobalConstants.CONTENT_TYPE_APPLICATION_JSON);
        
        request.setBody(jsonBody);
        
        Http http = new Http();
        
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                System.debug('Response: ' + responseBody);
                
                // parsing the json response
                List<WalletServiceResponse> parsedResonses = (List<WalletServiceResponse>) JSON.deserialize(responseBody, List<WalletServiceResponse>.class);
                System.debug('parsedResonses: ' + parsedResonses);
                
                // Checking if the list is empty
                if (!parsedResonses.isEmpty()) {
                    List<LoyaltyProgramMember> members = new List<LoyaltyProgramMember>();
                    
                    // capturing wallet link from response
                    for (WalletServiceResponse res : parsedResonses) {
                        members.add(new LoyaltyProgramMember(
                            Id = res.membershipNumber,
                            Google_Wallet_Link__c = res.googleWalletLink,
                            Apple_Wallet_Link__c = res.appleWalletLink
                        ));
                    }
                    System.debug('members: ' + members);
                    
                    // updating the membership records
                    update members;
                }
            } else {
                System.debug('HTTP Request failed with status code: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }
    
    class WalletServiceResponse {
        public String membershipNumber {get;set;}
        public String googleWalletLink {get;set;}
        public String appleWalletLink {get;set;}
    } */
    
    /*public class Request {
        public String memberId{get;set;}
        public String membershipNumber{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String tierLevel{get;set;}
        public Decimal currentPoints{get;set;}
        public Decimal currentRewards{get;set;}
        public Decimal pointsToNextVoucher{get;set;}
    }*/
}