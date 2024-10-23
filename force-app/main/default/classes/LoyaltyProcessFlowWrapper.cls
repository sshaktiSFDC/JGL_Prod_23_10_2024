/**
* @name         : LoyaltyProcessFlowWrapper
* @description  : Resuable Wrapper class for invoking Flows from Loyalty Processes
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-10    Vince Vuong         Created
* 2024-04-20    Vince Vuong         Added new parameters
*/ 
public without sharing class LoyaltyProcessFlowWrapper {

    //Wrapper class for Flow Inputs
    public class FlowInput {
        //Transaction journal related fields
        @InvocableVariable public ID programId;
        @InvocableVariable public ID memberId;
        @InvocableVariable public String orderId;
        @InvocableVariable public String orderItemId;
        @InvocableVariable public String channel;

        @InvocableVariable public Integer totalRewards;
        @InvocableVariable public Integer totalPointsToDebit;
        @InvocableVariable public Integer totalVouchersToIssue;

        @InvocableVariable public String voucherCodeIssued;
        @InvocableVariable public String voucherFaceValue;
        @InvocableVariable public Integer voucherTargetPoints;

        //Loyalty Process specific inputs
        //Accural - Purchase

        //Redemption - Reward
        @InvocableVariable public Decimal voucherAmount;
        @InvocableVariable public Date transactionDate;
        //Returns

        //Event type whether to split redemption journals or issue vouchers
        @InvocableVariable public String eventType;

        //Payload to store JSON structure
        //@InvocableVariable public String jsonPayload;
    }

    //Wrapper class for Flow Outputs
    public class FlowOutput {
        @InvocableVariable public String loyaltyProgramName;
        @InvocableVariable public String voucherRewardDefinitionName;
        @InvocableVariable public Integer voucherRewardTargetValue;
        @InvocableVariable public Decimal voucherRewardFaceValue;
    }

}