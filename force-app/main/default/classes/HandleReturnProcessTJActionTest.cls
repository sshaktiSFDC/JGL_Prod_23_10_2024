/**
* @name         : HandleReturnProcessTJActionTest
* @description  : This is test class for HandleReturnProcessTJAction
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-30    Vince Vuong         Created
*/
@isTest
private class HandleReturnProcessTJActionTest {

	@testSetup
	static void setup() {
        //Create Loyalty Program
        LoyaltyProgram program = TestDataFactory.createLoyaltyProgram();
        insert program;

        //Create Contacts
        List<Contact> contacts = TestDataFactory.createContacts(1);
        insert contacts;

        //Create Individual Program Members
        List<LoyaltyProgramMember> members = TestDataFactory.createIndividualMembers(program.Id, contacts[0].Id, 1);
        insert members;

        //Create journal Types
        JournalType tjType = new JournalType(
            Name = 'Accrual',
            ProcessType = 'Loyalty'
        );
        insert tjType;

        //Create journal subTypes
        JournalSubType tjSubType = new JournalSubType(
            Name = 'Purchase',
            JournalTypeId = tjType.Id
        );
        insert tjSubType;

        //Create Transaction Journal for Reversal
        List<TransactionJournal> journals = new List<TransactionJournal>();

        TransactionJournal tj1 = new TransactionJournal();
        tj1.LoyaltyProgramId = program.Id;
        tj1.MemberId = members[0].Id;
        tj1.ActivityDate = System.Now();
        tj1.Order_ID__c = 'TEST-ORDER-123';
        tj1.Order_Item_ID__c = 'ITEM-1';
        tj1.TransactionAmount = 1.00;
        tj1.JournalTypeId = tjType.Id;
        tj1.JournalSubTypeId = tjSubType.Id;
        tj1.Status = GlobalConstants.JOURNAL_STATUS_PROCESSED;
        journals.add(tj1);

        TransactionJournal tj2 = new TransactionJournal();
        tj2.LoyaltyProgramId = program.Id;
        tj2.MemberId = members[0].Id;
        tj2.ActivityDate = System.Now();
        tj2.Order_ID__c = 'TEST-ORDER-123';
        tj2.Order_Item_ID__c = 'ITEM-2';
        tj2.TransactionAmount = 1.00;
        tj2.JournalTypeId = tjType.Id;
        tj2.JournalSubTypeId = tjSubType.Id;
        tj2.Status = GlobalConstants.JOURNAL_STATUS_PROCESSED;
        journals.add(tj2);

        insert journals;
    }

    @isTest
	static void testHandleReturnProcessTJAction() {
		LoyaltyProgramMember lpm = [select id from LoyaltyProgramMember LIMIT 1][0];
        // Call processTJ method
        Test.startTest();

        List<HandleReturnProcessTJAction.HandleReturnsProcessInput> inputs = new List<HandleReturnProcessTJAction.HandleReturnsProcessInput>();
        HandleReturnProcessTJAction.HandleReturnsProcessInput input = new HandleReturnProcessTJAction.HandleReturnsProcessInput();
        input.originalOrderId = 'TEST-ORDER-123';
        input.memberId = lpm.id;
        inputs.add(input);

        List<HandleReturnProcessTJAction.HandleReturnsProcessOutput> outputs = HandleReturnProcessTJAction.handleReturnsProcess2(inputs);

        Test.stopTest();

        // Asserts
        System.assertNotEquals(null, outputs, 'Outputs should not be null');
    }
}