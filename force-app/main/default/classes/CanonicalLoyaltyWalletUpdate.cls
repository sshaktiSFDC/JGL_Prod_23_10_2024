/**
* @name         : CanonicalLoyaltyWalletUpdate
* @description  : Canonical class to send member car updates to Wallet Service
* @testClass    : TODO
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-04-17    Vince Vuong         Created
*/
public class CanonicalLoyaltyWalletUpdate {

    //Request payload to pass to Wallet Service to generate passes
    public class Request {
        public String memberId{get;set;}
        public String membershipNumber{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        //public String tierLevel{get;set;}
        public Integer nextRewardPoints{get;set;}
        public Decimal totalRewards{get;set;}
        public Integer totalPoints{get;set;}
        public String orgId{get;set;}
        //public Integer pointsToNextVoucher{get;set;}
    }

    //Response payload from Wallet Service and Custom REST API
    public class Response {
        public String membershipNumber{get;set;}
    }
}