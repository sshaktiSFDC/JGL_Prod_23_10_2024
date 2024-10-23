/**
* @name         : CanonicalLoyaltyMemberVoucher
* @description  : Canonical class to generate JSON response payload for Get Member Vouchers
* @testClass    : 
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-03-08    Vince Vuong         Created
* 2024-04-24    Vince Vuong         Added Order Issued and Redeem parameters
*/
public class CanonicalLoyaltyMemberVoucher {

    public Integer voucherCount;
    public List<Vouchers> vouchers;
    
    public class Vouchers {
        public String description;
        public String effectiveDate;
        public String expirationDate;
        public Double faceValue;
        public Boolean isVoucherDefinitionActive;
        public Boolean isVoucherPartiallyRedeemable;
        public Double redeemedValue;
        public Double remainingValue;
        public String status;
        public String type;
        public String useDate;
        public String voucherCode;
        public String voucherDefinition;
        public String voucherId;
        public String voucherNumber;
        public String promotionId;
        public String promotionName;
        
        //Custom attributes
        public Double minimumSpend;
        public String issueOrderID;
        public String issueOrderChannel;
        public String redeemOrderID;
        public String redeemOrderChannel;
    }
}