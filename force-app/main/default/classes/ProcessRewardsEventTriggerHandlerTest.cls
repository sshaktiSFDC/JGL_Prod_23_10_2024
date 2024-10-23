/**
* @name         : ProcessRewardsEventTriggerHandlerTest
* @description  : This is test class for ProcessRewardsEventTriggerHandler
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-30    Vince Vuong         Created
*/
@isTest
private class ProcessRewardsEventTriggerHandlerTest {

	@testSetup
	static void setup() {
        //Create organisation settings
        Organisation_Settings__c settings = Organisation_Settings__c.getOrgDefaults();
        settings.Voucher_Points_Target_Value__c = 200;
        upsert settings Organisation_Settings__c.Id;

    }

    @isTest
    static void testAfterInsertTrigger() {

        // Prepare test data
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
            Name = GlobalConstants.JOURNAL_TYPE_REDEMPTION,
            ProcessType = 'Loyalty'
        );
        insert tjType;

        //Create journal subTypes
        JournalSubType tjSubType = new JournalSubType(
            Name = GlobalConstants.JOURNAL_SUBTYPE_REWARD,
            JournalTypeId = tjType.Id
        );
        insert tjSubType;

        //Create Transaction Journal for Reversal
        TransactionJournal journal = new TransactionJournal();
        journal.LoyaltyProgramId = program.Id;
        journal.MemberId = members[0].Id;
        journal.ActivityDate = System.Now();
        journal.Order_ID__c = 'REDEMPTION-ORDER-123';
        journal.Order_Item_ID__c = 'ITEM-1';
        journal.TransactionAmount = 400;
        journal.JournalTypeId = tjType.Id;
        journal.JournalSubTypeId = tjSubType.Id;
        journal.Status = GlobalConstants.JOURNAL_STATUS_PROCESSED;
        insert journal;

        //Create ledger with Debit Points
        LoyaltyLedger ledger = new LoyaltyLedger();
        ledger.TransactionJournalId = journal.Id;
        ledger.Points = journal.TransactionAmount;
        ledger.LoyaltyProgramMemberId = members[0].Id;
        ledger.EventType = 'Debit';
        ledger.Flow = 'TEST123';
        insert ledger;

        // Set up and insert Loyalty_Program_Member_Update_Event__e records
        List<Process_Rewards_Event__e> events = new List<Process_Rewards_Event__e>();

        //Publish event for Issue vouchers
        Process_Rewards_Event__e event1 = new Process_Rewards_Event__e();
        event1.Member_Id__c = members[0].Id;
        event1.Program_ID__c = program.Id;
        event1.Order_No__c = 'TEST-ORDER-888';
        event1.Order_Item_No__c = '1';
        event1.Total_Rewards__c = 10;
        event1.Total_Debit_Points__c = 10;
        event1.TotalVouchersToIssue__c = 2;
        event1.Channel__c = 'Online';
        event1.Event_Type__c = '';
        events.add(event1);
        
        //Publish event for Redemption
        Process_Rewards_Event__e event2 = new Process_Rewards_Event__e();
        event2.Member_Id__c = members[0].Id;
        event2.Program_ID__c = program.Id;
        event2.Order_No__c = 'REDEMPTION-ORDER-123';
        event2.Order_Item_No__c = 'ITEM-1';
        event2.Total_Rewards__c = 10;
        event2.Total_Debit_Points__c = 400;
        event2.TotalVouchersToIssue__c = 1;
        event2.Channel__c = 'Online';
        event2.Event_Type__c = 'Redemption';
        events.add(event2);

        if (!events.isEmpty()) {
            // Call method to publish events
            List<Database.SaveResult> results = EventBus.publish(events);

            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
        }

        Test.startTest();

            //ProcessRewardsEventTriggerHandler handler = new ProcessRewardsEventTriggerHandler();
            //handler.afterInsert();
        
        Test.stopTest();
        
        // Add assertions if needed
    }

}