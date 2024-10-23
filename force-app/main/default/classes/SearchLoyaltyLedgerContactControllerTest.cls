@isTest
public class SearchLoyaltyLedgerContactControllerTest {
    @testSetup
    private static void testSetup(){
        List<Account> personAccount = TestDataFactory.createPersonAccounts(1);
        insert personAccount;
        List<Account> perAct = [SELECT Id, PersonContactId from Account WHERE Id IN :personAccount];
        
        LoyaltyProgram lyProgram = TestDataFactory.createLoyaltyProgram();
        insert lyProgram;
        
        LoyaltyProgramCurrency positiveBalance = TestDataFactory.createLoyaltyProgramCurrency(GlobalConstants.CURRENCY_POSITIVE_BALANCE, 'NonQualifying', lyProgram.Id);
        positiveBalance.DoesAllowNegativeBalance = true;
        positiveBalance.ExpiryModel = 'Activity';
        positiveBalance.ExpiryPeriodFrequency = 2;
        positiveBalance.ExpiryPeriodUnit = 'Years';
        insert positiveBalance;
        
        List<LoyaltyProgramMember> members = TestDataFactory.createIndividualMembers(lyProgram.Id, perAct[0].PersonContactId, 1);
        insert members;
        
        LoyaltyMemberCurrency membersCurrency = TestDataFactory.createLoyaltyMemberCurrency(GlobalConstants.CURRENCY_POSITIVE_BALANCE, members[0].Id, positiveBalance.Id);
        insert membersCurrency;
        
        JournalType accrual = new JournalType(
            Name = 'Accrual',
            Description = 'Represents a transaction that accrues points to a loyalty program member\'s balance.',
            ProcessType = 'Loyalty'
        );
        insert accrual;
        
        JournalSubType purchase = new JournalSubType(
            Name = 'Purchase',
            Description = 'Represents transactions that credit points to members for making a purchase.',
            JournalTypeId = accrual.Id
        );
        insert purchase;
        
        TransactionJournal transactionJour = new TransactionJournal(
            MemberId = members[0].Id, 
            LoyaltyProgramId = lyProgram.Id, 
            ActivityDate = Date.today(), 
            JournalDate = Date.today(), 
            JournalTypeId = accrual.Id, 
            JournalSubTypeId = purchase.Id, 
            Status = 'Processed', 
            Brand = 'Jacqui E', 
            TransactionAmount = 149.56, 
            Channel = 'POS', 
            Order_ID__c = '050701329537-t', 
            Order_Item_ID__c = 'd001ll78q-t', 
			Quantity = 2, 
            TransactionLocation = 'EJ:0507:507-CHADSTONE', 
            InvoiceDate = Date.today()
        );
        insert transactionJour;
        
        LoyaltyLedger loyLeg = new LoyaltyLedger(
            LoyaltyProgramMemberId = members[0].Id, 
            TransactionJournalId = transactionJour.Id, 
            LoyaltyProgramCurrencyId = positiveBalance.Id, 
            Points = 150, 
            EventType = 'Credit', 
            ActivityDate = Date.today()
        );
        insert loyLeg;
    }
    
    @isTest
    private static void testGetContactId_success_act() {
        Account personAccount = [SELECT Id, PersonContactId from Account LIMIT 1];
        Test.startTest();
        Id result = SearchLoyaltyLedgerByContactController.getContactId(personAccount.Id);
        Test.stopTest();
        System.assertEquals(personAccount.PersonContactId, result, 'Incorrect contact id.');
    }
    
    @isTest
    private static void testGetContactId_success_member() {
        LoyaltyProgramMember member = [SELECT Id, ContactId FROM LoyaltyProgramMember];
        Test.startTest();
        Id result = SearchLoyaltyLedgerByContactController.getContactId(member.Id);
        Test.stopTest();
        System.assertEquals(member.ContactId, result, 'Incorrect contact id.');
    }
    
    @isTest
    private static void testGetContactId_exception_diffObj() {
        Exception error;
        
        Test.startTest();
        try {
            LoyaltyLedger ledger = [SELECT Id FROM LoyaltyLedger LIMIT 1];
        	Id result = SearchLoyaltyLedgerByContactController.getContactId(ledger.Id);
        } catch(Exception ex) {
            error = ex;
        }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', error.getMessage(), 'unexpected exception occur.');
        System.assertEquals('System.AuraHandledException', error.getTypeName(), 'unexpected exception occur.');
    }
    
    @isTest
    private static void testGetContactId_exception() {
        Exception error;
        
        Test.startTest();
        try {
            Id sampleError;
        	Id result = SearchLoyaltyLedgerByContactController.getContactId(sampleError);
        } catch(Exception ex) {
            error = ex;
        }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', error.getMessage(), 'unexpected exception occur.');
        System.assertEquals('System.AuraHandledException', error.getTypeName(), 'unexpected exception occur.');
    }
    
    @isTest
    private static void testFetchMembershipDetails_success() {
        Account personAccount = [SELECT Id, PersonContactId from Account LIMIT 1];
        Test.startTest();
        List<LoyaltyProgramMember> result = SearchLoyaltyLedgerByContactController.fetchMembershipDetails(personAccount.PersonContactId);
        Test.stopTest();
        System.assertEquals(false, result.isEmpty(), 'No membership details found.');
        System.assertEquals(0, result[0].Total_Rewards__c, 'Rewards not zero.');
	}
    
    @isTest
    private static void testFetchMembershipDetails_noRecord() {
        List<Account> personAccounts = TestDataFactory.createPersonAccounts(1);
        insert personAccounts;
        List<Account> perAct = [SELECT Id, PersonContactId from Account WHERE Id IN :personAccounts];
        Test.startTest();
        List<LoyaltyProgramMember> result = SearchLoyaltyLedgerByContactController.fetchMembershipDetails(perAct[0].PersonContactId);
        Test.stopTest();
        System.assertEquals(true, result.isEmpty(), 'Membership details record found.');
	}   
        
    @isTest 
    private static void testSearchLoyaltyLedger_success_orderId() {
        Account personAccount = [SELECT Id, PersonContactId from Account LIMIT 1];
        Test.startTest();
        List<sObject> result =  SearchLoyaltyLedgerByContactController.searchLoyaltyLedger(personAccount.PersonContactId, null, null, '050701329537-t', null);
        Test.stopTest();
        System.assertEquals(false, result.isEmpty(), 'Loyalty Ledger records not found.');
    }
    
    @isTest 
    private static void testSearchLoyaltyLedger_success_activityDate() {
        Account personAccount = [SELECT Id, PersonContactId from Account LIMIT 1];
        Test.startTest();
        List<sObject> result =  SearchLoyaltyLedgerByContactController.searchLoyaltyLedger(personAccount.PersonContactId, String.valueOf(Date.today().addDays(-2)), String.valueOf(Date.today().addDays(2)), null, null);
        Test.stopTest();
        System.assertEquals(false, result.isEmpty(), 'Loyalty Ledger records not found.');
    }
    
    @isTest 
    private static void testSearchLoyaltyLedger_exception() {
        Account personAccount = [SELECT Id, PersonContactId from Account LIMIT 1];
        Exception error;
        Test.startTest();
        try {
        	List<sObject> result =  SearchLoyaltyLedgerByContactController.searchLoyaltyLedger(personAccount.PersonContactId, 'sample value', 'sample value', null, null);    
        } catch(Exception ex) {
            error = ex;
        }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', error.getMessage(), 'unexpected exception occur.');
        System.assertEquals('System.AuraHandledException', error.getTypeName(), 'unexpected exception occur.');
    }
}