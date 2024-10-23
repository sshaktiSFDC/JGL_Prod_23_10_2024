/**
* @name         : VoucherTriggerHandler
* @description  : This class is used to Handle the event for Loyalty Program Member Trigger.
* @testClass    : VoucherTriggerHandlerTest
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-04    Vince Vuong         Created
* 2024-05-02    Vince Vuong         Commented out unused method
*/
public without sharing class VoucherTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        //Prvent dummy reward vouchers from being created
        preventDummyRewardVouchersCreation(Trigger.New);
    }
    
    public override void beforeUpdate() {
        // check if restricted field is updated by manager
        restrictedFieldUpdatedByCSAManager();
    }

    //public override void afterInsert() {
        //processMultipleVoucherCodes(Trigger.New);
    //}
    
    // This method prevents the CSA Rep Manager user from updating the restricted fields
    private static void restrictedFieldUpdatedByCSAManager() {
        Id loggedInUserId = UserInfo.getProfileId();
        Id CsaRepManagerProfile = [SELECT Id FROM Profile WHERE Name=:GlobalConstants.CSA_REP_MANAGER_PROFILE LIMIT 1][0].Id;
        
        // checking if the logged-in user is CSA Rep Manager
        if (loggedInUserId == CsaRepManagerProfile) {

            // getting the fields from field set
            List<String> restrictedFieldNames = new List<String>();
            for (Schema.FieldSetMember field : SObjectType.Voucher.FieldSets.CSA_Manager_Restricted_Fields.getFields()) {
                restrictedFieldNames.add(field.getFieldPath());
            }
            
            for (Voucher vou : (List<Voucher>) Trigger.new) {
                Voucher oldRec = (Voucher) Trigger.oldMap.get(vou.Id);
                
                // checking if a restricted field is changed
                for (String fieldName : restrictedFieldNames) {
                    if (vou.get(fieldName) != oldRec.get(fieldName)) {
                        if (vou.Is_Voucher_Manually_Created__c && (fieldName == 'Order_Id_Issue__c' || fieldName == 'TransactionJournalId')) {
                            continue;
                        } else {
                            vou.addError('You can only update "Status" and "Expiry Date" on the voucher');
                        }
                    }
                }
            }
        }
        
        for (Voucher vou : (List<Voucher>) Trigger.new) {
            vou.Is_Voucher_Manually_Created__c = false;
        }
    }

    //Method to prevent DUMMY voucher from being created on the platform
    private static void preventDummyRewardVouchersCreation(List<Voucher> newVouchers) {
        //System.debug('VoucherTriggerHandler >> preventDummyRewardVouchersCreation');

        //Loop through new vouchers and prevent dummy reward vouchers from being created
        for(Voucher rec : newVouchers) {
            //System.debug('Voucher = ' + rec);
            //System.debug('VoucherCode = ' + rec.VoucherCode);
            //System.debug('TransactionJournalId = ' + rec.TransactionJournalId);
            //System.debug('VoucherDefinitionId = ' + rec.VoucherDefinitionId);
            //System.debug('Reason = ' + rec.Reason);

            if (rec.VoucherCode != null && rec.TransactionJournalId != null 
               
                && rec.Reason == GlobalConstants.DUMMY_REWARD_VOUCHER_REASON) {
                rec.addError(GlobalConstants.DUMMY_REWARD_VOUCHER_ERROR_MESSAGE);
                System.debug('Found Dummy Voucher = ' + rec);
            }
        }
    }

    //These logic no longer being used
    /*
    private static void processMultipleVoucherCodes(List<Voucher> newVouchers) {
        List<Voucher> vouchersListToUpdate = new List<Voucher>();
        List<Voucher> vouchersListToCreate = new List<Voucher>();
        List<Voucher> vouchersListToDelete = new List<Voucher>();

        try {
            //TODO: Find all newly created vouchers associate with Accrual journals and contains comma-separated values in the Voucher Code
            for(Voucher rec : newVouchers) {
                //Check count of voucher codes
                if (rec.TransactionJournalId != null && rec.Reason == 'TBD') {
                    //TODO: Compare Voucher Definition 
                    vouchersListToDelete.add(rec);
                }
            }
            if (!vouchersListToDelete.isEmpty()) {
                delete vouchersListToDelete;
            }
        }
        catch(Exception ex) {
        }
    }

    @future
    private static void createExtraVouchers(List<Id> voucherIds) {
        //insert vouchers;
    }
    */

}