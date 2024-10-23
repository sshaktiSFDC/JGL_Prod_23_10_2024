/**
* @name         : CanonicalLoyaltyWalletLink
* @description  : Canonical class to generate JSON response payload for Member Wallet links
* @testClass    : TODO
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-03-15    Vince Vuong         Created
*/
public class CanonicalLoyaltyWalletLink {
    //Request payload to pass to Wallet Service to generate passes
    public class Request {
        public String memberId{get;set;}
        public String membershipNumber{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        public Integer nextRewardPoints{get;set;}
        public Decimal totalRewards{get;set;}
        public String orgId{get;set;}
    }

    //Response payload from Wallet Service and Custom REST API
    public class Response {
        public String googleWalletLink{get;set;}
        public String appleWalletLink{get;set;}
        public String membershipNumber{get;set;}
       
    }
}