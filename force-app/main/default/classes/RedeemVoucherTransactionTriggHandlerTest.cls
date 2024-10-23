/**
* @name         : RedeemVoucherTransactionTriggHandlerTest
* @description  : This class contains unit tests for validating the behavior of Apex classes
 * and triggers
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-03-25    
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class RedeemVoucherTransactionTriggHandlerTest {
    
    static testMethod void testAfterInsert() {
        // Create test data
      
        
       // List<RedeemVoucherTransaction__e> events = new List<RedeemVoucherTransaction__e>();
        RedeemVoucherTransaction__e event1 = new RedeemVoucherTransaction__e(
            Voucher_Code_Issued__c = 'TestVoucher1',
            Order_Id_Redeem__c = 'TestOrder1',
            Order_Id_Redeem_Channel__c = 'Online'
        );
       // events.add(event1);
         Database.SaveResult results = EventBus.publish(event1);
        system.debug('Test class result line 25' + results);
        
        // Create test records
        Voucher voucher1 = new Voucher(VoucherCode = 'TestVoucher1', EffectiveDate=Date.today(),Order_Id_Redeem__c = 'TestOrder1');
        insert voucher1;
        
         Contact contact = new Contact();
        contact.LastName = 'Smith';
        contact.Birthdate = Date.Today();
        insert contact;
        
        LoyaltyProgram  loyaltyProgram = new LoyaltyProgram();
         loyaltyProgram.Name = 'Just Shop';
          insert loyaltyProgram;
        
        LoyaltyProgramMember programMember = new LoyaltyProgramMember();
		programMember.MembershipNumber = 'TEST Members1';
		programMember.MemberStatus = 'Active';
		programMember.EnrollmentDate = Date.Today();
        programMember.MemberType = 'Individual';
        programMember.ContactId = contact.Id;
        programMember.ProgramId = loyaltyProgram.Id;
		insert programMember;
        
        JournalType  JournalType = new JournalType();
        		JournalType.Name = 'Accural';
         		insert JournalType;
        
        JournalSubType  JrnlSubType = new JournalSubType();
        JrnlSubType.Name = 'Purchase';
        JrnlSubType.JournalTypeId = JournalType.Id;
         insert JrnlSubType;
        
        JournalSubType  JrnlSubType1 = new JournalSubType();
        JrnlSubType1.Name = 'Voucher';
        JrnlSubType1.JournalTypeId = JournalType.Id;
         insert JrnlSubType1;
        
          TransactionJournal jrnl = new TransactionJournal();
        					jrnl.JournalTypeId = JournalType.Id;
        					jrnl.JournalSubTypeId = JrnlSubType.Id;
                            jrnl.ActivityDate = System.Now();
                            jrnl.JournalDate = System.Now();
                            jrnl.Status = 'Pending';
                            jrnl.LoyaltyProgramId = loyaltyProgram.Id;
                            jrnl.MemberId = programMember.Id;
        					 jrnl.TransactionAmount  = 50;
       					 jrnl.Channel = 'Online';
        					jrnl.VoucherCode = 'TestVoucher1';
       					 jrnl.Order_ID__c = 'TestOrder1';
       					 //jrnl.Order_Item_ID__c = '456';
    
        insert jrnl; 
        
         TransactionJournal jrnl1 = new TransactionJournal();
        					jrnl1.JournalTypeId = JournalType.Id;
        					jrnl1.JournalSubTypeId = JrnlSubType1.Id;
                            jrnl1.ActivityDate = System.Now();
                            jrnl1.JournalDate = System.Now();
                            jrnl1.Status = 'Pending';
                            jrnl1.LoyaltyProgramId = loyaltyProgram.Id;
                            jrnl1.MemberId = programMember.Id;
        					 jrnl1.TransactionAmount  = 50;
       					 jrnl1.Channel = 'Online';
        					jrnl1.VoucherCode = 'TestVoucher1';
       					 jrnl1.Order_ID__c = 'TestOrder1';
       					 //jrnl.Order_Item_ID__c = '456';
    
        insert jrnl1; 
        
        
        Test.startTest();
        // Trigger afterInsert method
        RedeemVoucherTransactionTriggerHandler handler = new RedeemVoucherTransactionTriggerHandler();
        handler.afterInsert();
        Test.stopTest();
        
        // Verify the updates
        Voucher updatedVoucher = [SELECT Id, Order_Id_Redeem__c FROM Voucher WHERE VoucherCode = 'TestVoucher1'];
        System.assertEquals('TestOrder1', updatedVoucher.Order_Id_Redeem__c, 'Order Id should match');
    }
    
    static testMethod void testAfterInsertWithException() {
        // Create test data
        List<RedeemVoucherTransaction__e> events = new List<RedeemVoucherTransaction__e>();
        RedeemVoucherTransaction__e event1 = new RedeemVoucherTransaction__e(
            Voucher_Code_Issued__c = 'TestVoucher1',
            Order_Id_Redeem__c = 'TestOrder1'
        );
        events.add(event1);
        
        // Create test records
        Voucher voucher1 = new Voucher(VoucherCode = 'TestVoucher1', EffectiveDate=Date.today());
        insert voucher1;
        
        // Force an exception by setting an invalid voucher code
        events[0].Voucher_Code_Issued__c = 'InvalidVoucherCode';
        
        Test.startTest();
        // Trigger afterInsert method
        RedeemVoucherTransactionTriggerHandler handler = new RedeemVoucherTransactionTriggerHandler();
        handler.afterInsert();
        Test.stopTest();
        
        // Verify that the voucher record is not updated due to the exception
        Voucher updatedVoucher = [SELECT Id, Order_Id_Redeem__c FROM Voucher WHERE VoucherCode = 'TestVoucher1'];
        System.assertNotEquals('TestOrder1', updatedVoucher.Order_Id_Redeem__c, 'Order Id should not be updated');
    }
}