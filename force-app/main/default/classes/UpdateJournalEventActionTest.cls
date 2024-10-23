/**
* @name         : UpdateJournalEventActionTest
* @description  : This is test class of UpdateJournalEventAction.
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-03-25    Vince Vuong         Created
* 2024-04-30    Surya Nath Dixit    Created test class logic
*/
@isTest
private class UpdateJournalEventActionTest {

    //TODO


    @isTest
    static void testPublishJournalEvent() {
        // Create test data
        List<UpdateJournalEventAction.UpdateJournalEventInput> inputs = new List<UpdateJournalEventAction.UpdateJournalEventInput>();
        UpdateJournalEventAction.UpdateJournalEventInput input = new UpdateJournalEventAction.UpdateJournalEventInput();
        input.orderNo = '123';
        input.orderItemNo = '456';
        input.runningBalance = 100;
        input.pointsType = 'Credit';
        input.voucherCode = 'ABC123';
        inputs.add(input);

        // Test publishing journal event
        Test.startTest();
        UpdateJournalEventAction.publishJournalEvent(inputs);
        Test.stopTest();

        // Verify results
        //List<Transaction_Journal_Update__e> events = [SELECT Id FROM Transaction_Journal_Update__e];
       // System.assertEquals(1, events.size(), 'Event should be published');
    }
}