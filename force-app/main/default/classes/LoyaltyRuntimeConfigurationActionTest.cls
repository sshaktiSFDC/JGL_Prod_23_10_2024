/**
* @name         : LoyaltyRuntimeConfigurationActionTest
* @description  : Test class for LoyaltyRuntimeConfigurationAction
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-30    Vince Vuong         Created
*/
@IsTest
private class LoyaltyRuntimeConfigurationActionTest {

    @IsTest
    static void testGetLoyaltyRuntimeConfiguration() {
    
        //Create program
        LoyaltyProgram program = TestDataFactory.createLoyaltyProgram();
        insert program;

        VoucherDefinition voucherDef = TestDataFactory.createVoucherDefinition(program.Id, GlobalConstants.VOUCHER_DEFINITION_REWARD);
        insert voucherDef;

        //Test getting config
        Map<String, VoucherDefinition> voucherMappings = LoyaltyRuntimeConfigurationAction.voucherDefinitionMappings;
        System.assertNotEquals(null, voucherMappings, 'Voucher Definition Mappings should not be null');

        List<String> inputs = new List<String>{ 'Test' };
        List<LoyaltyRuntimeConfigurationAction.LoyaltyRuntimeConfigurationOutput> outputs = LoyaltyRuntimeConfigurationAction.debugTransactionJournals(inputs);
        System.assertNotEquals(null, outputs, 'Output should not be null');
    }
}