/**
* @name         : GenerateVoucherCodesActionTest
* @description  : This is test class of GenerateVoucherCodesAction class
* @testClass    : 
* <Date>        <Created By>       <Brief Description of Change>
* 2024-04-23    Surya Nath Dixit         Created
*/

@isTest
public class GenerateVoucherCodesActionTest {
    @isTest
    static void testGenerateVoucherCodes() {
        // Create test data
        // 
       Contact contact = new Contact();
        contact.LastName = 'Smith';
        contact.Birthdate = Date.Today();
        insert contact;
        
        Organisation_Settings__c setting = new Organisation_Settings__c();
        setting.Name = 'Test Setting';
        setting.Membership_Prefix__c = '66666666';
        insert setting;
        
        LoyaltyProgram  loyaltyProgram = new LoyaltyProgram();
         loyaltyProgram.Name = 'Just Shop';
          insert loyaltyProgram;
        
        LoyaltyProgramMember programMember = new LoyaltyProgramMember();
		programMember.MembershipNumber = 'TEST1234';
		programMember.MemberStatus = 'Active';
		programMember.EnrollmentDate = Date.Today();
        programMember.MemberType = 'Individual';
        programMember.ContactId = contact.Id;
        programMember.ProgramId = loyaltyProgram.Id;
		insert programMember;
        
        VoucherDefinition vd = new VoucherDefinition(
            Name = 'Birthday Voucher',
            ExpirationType = 'Period',
            EffectiveDate = Date.today(),
            LoyaltyProgramId = loyaltyProgram.Id,
            IsActive = true,
            ExpirationPeriod = 60,
            Minimum_Spend__c = 10, ExpirationPeriodUnit ='Days', Type = 'FixedValue', FaceValue = 15
        );
        insert vd;
        
        List<GenerateVoucherCodesAction.GenerateVoucherCodeInput> inputs = new List<GenerateVoucherCodesAction.GenerateVoucherCodeInput>();
        GenerateVoucherCodesAction.GenerateVoucherCodeInput input = new GenerateVoucherCodesAction.GenerateVoucherCodeInput();
        input.voucherDefintionName = vd.Name;
        input.voucherCount = 5;
        input.voucherCodesToGenerate = 29;
        inputs.add(input);
        
        system.debug('Inputs ' + inputs);
        

        // Call the method
        Test.startTest();
        List<GenerateVoucherCodesAction.GenerateVoucherCodeOutput> outputs = GenerateVoucherCodesAction.generateVoucherCodes(inputs);
        Test.stopTest();
        system.debug('Outputs '+ outputs);

        // Verify the output
        System.assertEquals(1, outputs.size(), 'Output size should be 1');
        GenerateVoucherCodesAction.GenerateVoucherCodeOutput output = outputs[0];
        system.debug('outPut ' + output);
        System.assertEquals(29, output.voucherCount, 'Voucher count should be 10');
        System.assertNotEquals(null, output.voucherCodes, 'Voucher codes should not be null');
        List<String> voucherCodesList = output.voucherCodes.split(',');
        System.assertEquals(29, voucherCodesList.size(), 'Number of voucher codes should match the voucher count');
        for (String voucherCode : voucherCodesList) {
            System.assert(voucherCode.length() <= 255, 'Voucher code length should not exceed 255 characters');
        }
    }
}