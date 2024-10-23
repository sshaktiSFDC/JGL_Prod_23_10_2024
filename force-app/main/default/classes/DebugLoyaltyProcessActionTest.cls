/**
* @name         : DebugLoyaltyProcessActionTest
* @description  : This is test class of DebugLoyaltyProcessAction class
* @testClass    : 
* <Date>        <Created By>       <Brief Description of Change>
* 2024-04-23    Surya Nath Dixit         Created
*/

@isTest
public class DebugLoyaltyProcessActionTest {

    @isTest
    static void testDebugLoyaltyProcess() {
        // Create test data
        List<DebugLoyaltyProcessAction.DebugInput> inputs = new List<DebugLoyaltyProcessAction.DebugInput>();
        DebugLoyaltyProcessAction.DebugInput input = new DebugLoyaltyProcessAction.DebugInput();
        input.message1 = 'Message 1';
        input.message2 = 'Message 2';
        input.message3 = 'Message 3';
        input.message4 = 'Message 4';
        input.message5 = 'Message 5';
        inputs.add(input);

        // Call the method
        Test.startTest();
        List<String> outputs = DebugLoyaltyProcessAction.debugLoyaltyProcess(inputs);
        Test.stopTest();

        // Verify the output
        System.assertEquals(1, outputs.size(), 'Output size should be 1');
        System.assertEquals('Message 1', outputs[0], 'Output should match the first input message');
    }
}