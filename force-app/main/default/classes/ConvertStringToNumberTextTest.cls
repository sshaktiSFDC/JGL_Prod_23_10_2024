/**
* @name         : ConvertStringToNumberTextTest
* @description  : This is test class of ConvertStringToNumberText class
* @testClass    : 
* <Date>        <Created By>       <Brief Description of Change>
* 2024-04-23    Surya Nath Dixit         Created
*/

@isTest
public class ConvertStringToNumberTextTest {
    @isTest
    static void testConvertStringtoNumbers() {
        // Create test data
        List<ConvertStringToNumberText.HandleStringInput> inputs = new List<ConvertStringToNumberText.HandleStringInput>();
        ConvertStringToNumberText.HandleStringInput input1 = new ConvertStringToNumberText.HandleStringInput();
        input1.orderItemId = 'ABC123';
        inputs.add(input1);
        

        // Call the method
        Test.startTest();
        List<ConvertStringToNumberText.HandleStringOutput> outputs = ConvertStringToNumberText.convertStringtoNumbers(inputs);
        Test.stopTest();
        system.debug('Outputs is : ' + outputs);
        system.debug('outputs[0] is ' + outputs[0].OrderItemNumberText);
       

        // Verify the output
        System.assertEquals(1, outputs.size(), 'Output size should be 1');
        System.assertEquals('123', outputs[0].OrderItemNumberText, 'OrderItemNumberText should be 123');
      
        
    }
}