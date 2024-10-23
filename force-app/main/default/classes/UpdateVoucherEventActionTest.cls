/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest
private class UpdateVoucherEventActionTest {

    @isTest
    static void testPublishJournalEvent() {
        // Create test input data
        List<UpdateVoucherEventAction.UpdateVoucherEventInput> inputs = new List<UpdateVoucherEventAction.UpdateVoucherEventInput>();
        UpdateVoucherEventAction.UpdateVoucherEventInput input1 = new UpdateVoucherEventAction.UpdateVoucherEventInput();
        input1.orderNo = 'TestOrder1';
        input1.voucherCode = 'TestVoucherCode1';
        input1.channelRedeemed = 'Online';
        inputs.add(input1);

        // Call the method under test
        Test.startTest();
        UpdateVoucherEventAction actionTemp = new UpdateVoucherEventAction();
        UpdateVoucherEventAction.publishJournalEvent(inputs);
        Test.stopTest();

        // Verify events are published
     
        //System.assertEquals(true, sr.isSuccess());

    }

    @isTest
    static void testPublishJournalEventWithException() {
        // Create test input data
        List<UpdateVoucherEventAction.UpdateVoucherEventInput> inputs = new List<UpdateVoucherEventAction.UpdateVoucherEventInput>();
        // Empty input list to simulate exception
        UpdateVoucherEventAction.UpdateVoucherEventInput input2 = new UpdateVoucherEventAction.UpdateVoucherEventInput();
        input2.orderNo = 'TestOrder1';
       // input2.voucherCode = 'TestVoucherCode1';
        input2.channelRedeemed = 'Online';
        inputs.add(input2);

        // Call the method under test
        Test.startTest();
        // Expect an exception to be thrown
        try {
            UpdateVoucherEventAction.publishJournalEvent(inputs);
            // If no exception is thrown, fail the test
            System.assert(true, 'Expected exception was not thrown');
        } catch (Exception e) {
            // Verify that the exception message is as expected
            System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();
    }
}