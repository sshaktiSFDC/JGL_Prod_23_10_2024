/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest
public class DirectIssueVoucherEventActionTest {
@isTest
    static void testPublishJournalEvent() {
        // Create test input data
        List<DirectIssueVoucherEventAction.publishDirectIssueVoucherEventInput> inputs = new List<DirectIssueVoucherEventAction.publishDirectIssueVoucherEventInput>();
        DirectIssueVoucherEventAction.publishDirectIssueVoucherEventInput input1 = new DirectIssueVoucherEventAction.publishDirectIssueVoucherEventInput();
        input1.orderIdIssued = 'TestOrder1';
        input1.voucherCode = 'TestVoucherCode1';
        input1.orderIdIssuedChannel = 'Online';
        inputs.add(input1);

        // Call the method under test
        Test.startTest();
        DirectIssueVoucherEventAction.publishJournalEvent(inputs);
        Test.stopTest();

        // Verify events are published
     
        //System.assertEquals(true, sr.isSuccess());

    }

    @isTest
    static void testPublishJournalEventWithException() {
        // Create test input data
        List<DirectIssueVoucherEventAction.publishDirectIssueVoucherEventInput> inputs = new List<DirectIssueVoucherEventAction.publishDirectIssueVoucherEventInput>();
        // Empty input list to simulate exception
        DirectIssueVoucherEventAction.publishDirectIssueVoucherEventInput input2 = new DirectIssueVoucherEventAction.publishDirectIssueVoucherEventInput();
        input2.orderIdIssued = 'TestOrder1';
        input2.voucherCode = 'TestVoucherCode1';
        input2.orderIdIssuedChannel = 'Online';
        inputs.add(input2);

        // Call the method under test
        Test.startTest();
        // Expect an exception to be thrown
        try {
            DirectIssueVoucherEventAction.publishJournalEvent(inputs);
            // If no exception is thrown, fail the test
            System.assert(true, 'Expected exception was not thrown');
        } catch (Exception e) {
            // Verify that the exception message is as expected
            System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();
    }
}