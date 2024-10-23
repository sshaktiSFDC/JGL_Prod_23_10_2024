/**
* @name         : RedeemVoucherTransactionTriggerHandler
* @description  : Trigger Handler to update the voucher additional Fields
* @testClass    : UpdateVoucherEventAction
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-03-25    
*/
public with sharing class RedeemVoucherTransactionTriggerHandler extends TriggerHandler{
    public RedeemVoucherTransactionTriggerHandler() {

    }

    public override void afterInsert() {
        //Subscribe to platform events
        subscribeEvents(Trigger.New);
    }

    private static void subscribeEvents(List<RedeemVoucherTransaction__e> newEvents){
        // List to hold all journals to be created.
        
        System.debug('subscribeEvents >> ' + newEvents);

        List<Voucher> vouchersToUpdate = new List<Voucher>();
        Map<String ,Voucher> mapVoucher = new Map<String,Voucher>();

        //Add Try/Catch and handle exception
        try {

            //Get a list of Voucher Codes issued
            Set<String> voucherCodesIssued = new Set<String>();
            for (RedeemVoucherTransaction__e event : newEvents) {
                if (String.isNotBlank(event.Voucher_Code_Issued__c)) {

                    voucherCodesIssued.add(event.Voucher_Code_Issued__c);
                    Voucher aVou = new Voucher();
                    //aVou.VoucherCode = event.Voucher_Code_Issued__c;
                    aVou.Order_Id_Redeem__c =  event.Order_Id_Redeem__c ;
                    aVou.Order_Id_Redeem_Channel__c =  event.Order_Id_Redeem_Channel__c;
                    System.debug ('Voucher Redemption Input Channel' + event.Order_Id_Redeem_Channel__c + 'Voucher Redemption Output Voucher Channel:' + aVou.Order_Id_Redeem_Channel__c );
                    mapVoucher.put(event.Voucher_Code_Issued__c,aVou); 
                }
            }
            System.debug(voucherCodesIssued);

            Map<String, String> voucherCodesIssuedMappings = new Map<String, String>();
            if (voucherCodesIssued.size() > 0) {
                for (Voucher rec : [SELECT Id, VoucherCode FROM Voucher WHERE VoucherCode IN :voucherCodesIssued]) {
                    rec.Order_Id_Redeem__c = mapVoucher.get(rec.VoucherCode).Order_Id_Redeem__c ;
                    rec.Order_Id_Redeem_Channel__c = mapVoucher.get(rec.VoucherCode).Order_Id_Redeem_Channel__c;

                    vouchersToUpdate.add(rec);

                }
            }
 
            // Update Vouchers
            if (vouchersToUpdate.size() > 0) {
                update vouchersToUpdate;
            }
            
            // this finds and delete the original TJ using Accrual - Purchase subtype; 
            // because within the Purchase subtype process, it has already created the Accrual-Voucher subtype journals
            
            handleDeletionofTJ(voucherCodesIssued,mapVoucher);


        }catch (Exception ex) {
            System.debug('An error occurred while updating publishEvents: ' + ex.getMessage());
        }
    }

    public static void handleDeletionofTJ(Set<String> inputs , Map<String ,Voucher> mapInput ) {
        try{
            Id JournalSUBTypeId = LoyaltyRuntimeHelper.journalSubTypeIdMappings.get(GlobalConstants.JOURNAL_SUBTYPE_PURCHASE);
            Set<String> voucherCodes = new Set<String>();
            List<TransactionJournal> tjsToDelete = new List<TransactionJournal>();
            List<TransactionJournal> tjsToUpdate = new List<TransactionJournal>();
            voucherCodes.addAll(inputs);
            // for (Set<String> rec : inputs) {
            //     voucherCodes.add(rec);
            // }
            List<TransactionJournal> transactionJrnls = [SELECT id, VoucherCode,JournalSubType.Name  FROM TransactionJournal where VoucherCode IN:voucherCodes];

            for(TransactionJournal tj:transactionJrnls){
                if(tj.JournalSubType.Name == GlobalConstants.JOURNAL_SUBTYPE_PURCHASE){
                    tjsToDelete.add(tj);
                }
                else if(tj.JournalSubType.Name == GlobalConstants.JOURNAL_SUBTYPE_VOUCHER){
                    tj.Channel = mapInput.get(tj.VoucherCode).Order_Id_Redeem_Channel__c;
                    tjsToUpdate.add(tj);
                }
            }

            if(!tjsToUpdate.isEmpty()){
                update tjsToUpdate;
            }
            if(!tjsToDelete.isEmpty()){
                delete tjsToDelete;
            }
            
        }
        catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
        
    }
}