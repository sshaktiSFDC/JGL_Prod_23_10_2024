@isTest
private class ChangeStatusOfVoucherForReturnTest {

    @isTest
    static void testHandleReturnsProcess3() {
        // Test data setup
        List<ChangeStatusOfVoucherForReturnProcess.HandleReturnsProcessInput> inputs = new List<ChangeStatusOfVoucherForReturnProcess.HandleReturnsProcessInput>();
        ChangeStatusOfVoucherForReturnProcess.HandleReturnsProcessInput input = new ChangeStatusOfVoucherForReturnProcess.HandleReturnsProcessInput();
        input.originalChannel = 'Online';
        input.originalOrderId = 'TestOrderId';
        inputs.add(input);

        // Create vouchers to be updated
        List<Voucher> vouchers = new List<Voucher>();
        Voucher voucher = new Voucher();
        voucher.Status = 'Redeemed';
        voucher.Order_Id_Redeem__c = 'TestOrderId';
        voucher.Order_Id_Redeem_Channel__c = 'Online';
        Voucher.EffectiveDate = Date.today();
        // Add more fields initialization if needed
        vouchers.add(voucher);
        insert vouchers;

        Test.startTest();
        // Call the handleReturnsProcess3 method
        ChangeStatusOfVoucherForReturnProcess.handleReturnsProcess3(inputs);
        Test.stopTest();

        // Verify that the vouchers have been updated
        List<Voucher> updatedVouchers = [SELECT Status, RedeemedValue, UseDate, Order_Id_Redeem_Channel__c, Order_Id_Redeem__c FROM Voucher WHERE Id IN :vouchers];
        System.assertEquals('Issued', updatedVouchers[0].Status, 'Voucher status should be updated to Issued');
        // Add more assertions to verify the updated fields if needed
    }
}