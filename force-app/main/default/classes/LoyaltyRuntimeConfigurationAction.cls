/**
* @name         : LoyaltyRuntimeConfigurationAction
* @description  : This class is used to Handle the event for Loyalty Program Member Trigger.
* @testClass    : LoyaltyRuntimeConfigurationActionTest
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-05    Vince Vuong         Created
* 2024-04-30    Vince Vuong         Removed hardcoded value
*/
public with sharing class LoyaltyRuntimeConfigurationAction {

    //Return mappings of Voucher Definition
    public static Map<String, VoucherDefinition> voucherDefinitionMappings {
        get {
            if (voucherDefinitionMappings == null) {
                voucherDefinitionMappings = new Map<String, VoucherDefinition>();
                for(VoucherDefinition rec : [SELECT Id, Name, FaceValue, Minimum_Spend__c FROM VoucherDefinition WHERE IsActive=True]) {
                    voucherDefinitionMappings.put(rec.Name, rec);
                }
            }
            //system.debug('Line no 12' + voucherDefinitionMappings);
            return voucherDefinitionMappings;
        }
        private set;
    }

    @InvocableMethod(label='Get Loyalty Runtime Configuration')
    public static List<LoyaltyRuntimeConfigurationOutput> debugTransactionJournals(List<String> inputs) {
        //System.debug('LoyaltyRuntimeConfigurationAction count = ' + inputs.size());

        List<LoyaltyRuntimeConfigurationOutput> outputs = new List<LoyaltyRuntimeConfigurationOutput>();
        for (String rec : inputs) {
            LoyaltyRuntimeConfigurationOutput output = new LoyaltyRuntimeConfigurationOutput();
            output.loyaltyProgramName = GlobalConstants.LOYALTY_PROGRAM_NAME;
            output.voucherRewardDefinitionName = GlobalConstants.VOUCHER_DEFINITION_REWARD;

            //Retrieve value from global constants
            output.voucherRewardTargetPoints = GlobalConstants.REWARD_VOUCHER_TARGET_POINTS;

            if (voucherDefinitionMappings.containsKey(GlobalConstants.VOUCHER_DEFINITION_REWARD)) {
                output.voucherRewardFaceValue = voucherDefinitionMappings.get(GlobalConstants.VOUCHER_DEFINITION_REWARD).FaceValue;
            }

            outputs.add(output);
        }
        return outputs;
    }

    public class LoyaltyRuntimeConfigurationOutput {
        @InvocableVariable public String loyaltyProgramName;
        @InvocableVariable public String voucherRewardDefinitionName;
        @InvocableVariable public Integer voucherRewardTargetPoints;
        @InvocableVariable public Decimal voucherRewardFaceValue;
    }
}