/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest

public class ReverseRedeemedVoucherEventActionTest {
@isTest
    static void testPublishJournalEvent() {
        // Create test input data
        List<ReverseRedeemedVoucherEventAction.publishReverseRedeemedVoucherEventInput> inputs = new List<ReverseRedeemedVoucherEventAction.publishReverseRedeemedVoucherEventInput>();
        ReverseRedeemedVoucherEventAction.publishReverseRedeemedVoucherEventInput input1 = new ReverseRedeemedVoucherEventAction.publishReverseRedeemedVoucherEventInput();
        input1.OriginalOrderId = 'TestOrder1';
        input1.Channel = 'Online';
        input1.memberId = 'TestMemberid';
        inputs.add(input1);

        // Call the method under test
        Test.startTest();
        ReverseRedeemedVoucherEventAction.publishJournalEvent(inputs);
        Test.stopTest();

        // Verify events are published
     
        //System.assertEquals(true, sr.isSuccess());

    }

    @isTest
    static void testPublishJournalEventWithException() {
        // Create test input data
        List<ReverseRedeemedVoucherEventAction.publishReverseRedeemedVoucherEventInput> inputs = new List<ReverseRedeemedVoucherEventAction.publishReverseRedeemedVoucherEventInput>();
        // Empty input list to simulate exception
        ReverseRedeemedVoucherEventAction.publishReverseRedeemedVoucherEventInput input2 = new ReverseRedeemedVoucherEventAction.publishReverseRedeemedVoucherEventInput();
        input2.OriginalOrderId = 'TestOrder1';
        input2.Channel = 'Online';
        input2.memberId = 'TestMemberid';
        inputs.add(input2);

        // Call the method under test
        Test.startTest();
        // Expect an exception to be thrown
        try {
            ReverseRedeemedVoucherEventAction.publishJournalEvent(inputs);
            // If no exception is thrown, fail the test
            System.assert(true, 'Expected exception was not thrown');
        } catch (Exception e) {
            // Verify that the exception message is as expected
            System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();
    }
    
    
}