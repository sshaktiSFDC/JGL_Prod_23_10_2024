/**
* @name         : ExpireVouchersBatchTest
* @description  : This is test class of ExpireVouchersBatch.
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-03-26    Vince Vuong         Created
* 2024-05-02    Vince Vuong         Added coverage
*/
@isTest
private class ExpireVouchersBatchTest {

    @testSetup
    static void setupTestData() {

        //Create Loyalty Program
        LoyaltyProgram program = TestDataFactory.createLoyaltyProgram();
        insert program;

        //Create Contacts
        List<Contact> contacts = TestDataFactory.createContacts(1);
        insert contacts;

        //Create Individual Program Members
        List<LoyaltyProgramMember> members = TestDataFactory.createIndividualMembers(program.Id, contacts[0].Id, 1);
        insert members;

        //Create Voucher Definition
        VoucherDefinition vDefinition = TestDataFactory.createVoucherDefinition(program.Id, GlobalConstants.VOUCHER_DEFINITION_REWARD);
        insert vDefinition;

        //Create member vouchers
        List<Voucher> vouchers = TestDataFactory.createVouchers(members[0].Id, vDefinition.Id, 5);
        Integer count = 0;
        for(Voucher rec : vouchers) {
            count = count + 1;
            //Set Expiration Date to the past
            rec.ExpirationDate = Date.today().addDays(-1);
            //Override voucher code so easy identification
            rec.VoucherCode = 'EXPIRE-BATCH-TEST' + count;
        }
        insert vouchers;
    }

    @isTest
    static void testExpireVouchersBatch() {
        // Execute the batch
        Test.startTest();
            
            //Call invocable method to execute batch class
            ExpireVouchersBatch.executeExpirationBatch();
            //ExpireVouchersBatch batch = new ExpireVouchersBatch();
            //Id jobId = Database.executeBatch(batch, 200);

        Test.stopTest();

        // Verify the results
        List<Voucher> expiredVouchers = [
            SELECT Id, VoucherCode, Status
            FROM Voucher
            WHERE Status =: GlobalConstants.VOUCHER_STATUS_EXPIRED
            AND VoucherCode LIKE 'EXPIRE-BATCH-TEST%'
        ];

        System.debug('expiredVouchers' + expiredVouchers);
        System.assertEquals(5, expiredVouchers.size(), 'All generated vouchers should have been expired');
    }
}