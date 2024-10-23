/**
* @name         : IssueRewardVouchersAction
* @description  : 
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-10    Vince Vuong         Created
*/ 
public without sharing class IssueRewardVouchersAction {

    @InvocableMethod(label='Issue Reward Vouchers')
    public static List<LoyaltyProcessFlowWrapper.FlowOutput> issueRewardVouchers(List<LoyaltyProcessFlowWrapper.FlowInput> inputs) {

        System.debug('IssueRewardVouchersAction count = ' + inputs.size());
        System.debug('inputs = ' +  inputs);

        //List<Process_Rewards_Event__e> events = new List<Process_Rewards_Event__e>();
        List<LoyaltyProcessFlowWrapper.FlowOutput> outputs = new List<LoyaltyProcessFlowWrapper.FlowOutput>();
        List<LoyaltyManagement.IssueVoucherInput> issueVoucherList = new List<LoyaltyManagement.IssueVoucherInput>();

        for (LoyaltyProcessFlowWrapper.FlowInput rec : inputs) {
            LoyaltyProcessFlowWrapper.FlowOutput output = new LoyaltyProcessFlowWrapper.FlowOutput();

            //Loop through # of vouchers to create
            for(Integer count = 1; count <= rec.totalVouchersToIssue; count++) {
                LoyaltyManagement.IssueVoucherInputBuilder voucher = new LoyaltyManagement.IssueVoucherInputBuilder();
                voucher.setLoyaltyProgramMemberId(rec.memberId);
                voucher.setProgramName(GlobalConstants.LOYALTY_PROGRAM_NAME);
                voucher.setVoucherDefinitionName(GlobalConstants.VOUCHER_DEFINITION_REWARD);
                //voucher.setJournalId(rec.Id);

                //Optional fields
  	            //voucher.setEffectiveDate(effectiveDate);
  	            //voucher.setExpiryDate(expirationDate);
	            //voucher.setFaceValue(10);

                issueVoucherList.add(voucher.build());
            }

            outputs.add(output);
        }
        System.debug('issueVoucherList = ' + issueVoucherList);

        // Insert vouchers outside the loop
        if (!issueVoucherList.isEmpty()) {
            // insert vouchersToInsert;
            List<LoyaltyManagement.IssueVoucherOutput> issueVoucherActionResults = LoyaltyManagement.LoyaltyResources.issueVoucher(issueVoucherList); 
            System.debug(issueVoucherActionResults);
            System.debug('Issue Voucher Successful Operation:'+ issueVoucherActionResults.get(0));

            //TODO: Stamp Order ID and Order Item ID against vouchers issued
            List<Id> voucherIds = new List<Id>();
            for(LoyaltyManagement.IssueVoucherOutput rec : issueVoucherActionResults) {
                if (rec.isSuccess()) {
                    voucherIds.add(rec.getVoucherId());
                }
            }
            System.debug('voucherIds = ' + voucherIds);

            List<Voucher> vouchersToUpdate = new List<Voucher>();
            for(Id voucherId : voucherIds) {
                vouchersToUpdate.add( new Voucher(
                    Id = voucherId,
                    Order_Id_Issue__c = inputs[0].orderId
                ));
            }
            System.debug('vouchersToUpdate = ' + vouchersToUpdate);

            if (!vouchersToUpdate.isEmpty()){
                update vouchersToUpdate;
            }
        }

        return outputs;
    }
}