/**
* @name         : IssueBirthdayVouchersBatch
* @description  : 
* @testClass    : IssueBirthdayVouchersBatchTest
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-03-18    Surya Dixit         Created
* 2024-03-22    Vince Vuong         Updated logic
* 2024-08-12	Shakti Kushwaha Rana Added TJ update logic
*/
global inherited sharing class IssueBirthdayVouchersBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    Integer thisMonthcheck = System.today().month();
    String issueVoucherRecordsQuery;
    public Integer vouchersIssued = 0;

    //Define Invocable method to execute this batch class from Schedule-Triggered Flow
    @InvocableMethod(label='Batch Issue Birthday Vouchers')
    global static void executeBirthdayVouchersBatch() {
        Id jobId = Database.executeBatch(new IssueBirthdayVouchersBatch());
    }

    //Constructors

    
    //NOTE: Use a QueryLocator object, the governor limit for the total number of records retrieved by SOQL queries is bypassed
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Get all ACTIVE members who's Birthday in current day/month.
        return Database.getQueryLocator([
            SELECT Id, Birth_Month__c
            FROM LoyaltyProgramMember
            WHERE Is_Birthday_JobToday__c = True
            AND MemberStatus =: GlobalConstants.MEMBER_STATUS_ACTIVE
            AND Program.Name =: GlobalConstants.LOYALTY_PROGRAM_NAME
        ]);
    }
    
    //Execute
    global void execute(Database.BatchableContext bc, List<LoyaltyProgramMember> scope) {
        //Scope - Subset of Active members who's birthday is today!
        try {
            //Get set of member Ids within current batch
            Set<Id> memberIdsSet = new Set<Id>();
            for (LoyaltyProgramMember lm : scope) {
                memberIdsSet.add(lm.Id);
            }
            //Getting the Birthday Voucher which are active for the members this year.
            Integer currentYear = Date.Today().Year();
            List<LoyaltyProgramMember> issuedMember = [SELECT Id, Birth_Month__c
                FROM LoyaltyProgramMember
                WHERE Id IN (
                    SELECT LoyaltyProgramMemberId
                    FROM Voucher
                    WHERE VoucherDefinition.Name =: GlobalConstants.VOUCHER_DEFINITION_BIRTHDAY           
                    AND CALENDAR_YEAR(EffectiveDate) =: currentYear
                )
                AND Birth_Month__c =: thisMonthcheck
                AND Program.Name =: GlobalConstants.LOYALTY_PROGRAM_NAME
                AND id IN: memberIdsSet
            ];
        
            //TODO: We should dedupe based on current member scopes

            Set<Id> issuedMembers = new Set<Id>();  //Created Set, contains Member Ids who are having the vouchers
            Set<Id> memberIds = new Set<Id>(); //Created Set, contains Member Ids who are eligible based on current month birthday.

            for (LoyaltyProgramMember lm : issuedMember) {
                // Check if a voucher already exists for this member
                issuedMembers.add(lm.Id);
            }
            for (LoyaltyProgramMember lm : scope) {
                // If issued voucher member not contains current member(current month) id then add current member to issue an voucher.
                if(!issuedMembers.contains(lm.Id)){
                    memberIds.add(lm.Id);  
                }
            }
            JournalSubType journalSubTypeRecord = [SELECT id, JournalTypeId FROM JournalSubType WHERE name = : GlobalConstants.JOURNAL_SUBTYPE_REWARD AND JournalType.Name =: GlobalConstants.JOURNAL_TYPE_REDEMPTION LIMIT 1];

            List<LoyaltyManagement.IssueVoucherInput> issueVoucherList = new List<LoyaltyManagement.IssueVoucherInput>();
            Map<String,String> memberId_VoucherCodeMap = new Map<String, String>();
            //Create  transactional Journal
            List<TransactionJournal> transactionalJournalList = new List<TransactionJournal>();
            for (LoyaltyProgramMember memberRec: [Select id, ProgramId from LoyaltyProgramMember where id IN : memberIds]) {
                TransactionJournal newTJ = new TransactionJournal();
                newTJ.LoyaltyProgramId = memberRec.ProgramId;
                newTJ.MemberId = memberRec.id;
                String VoucherCode = UtilityHelper.generateVoucherCodes(GlobalConstants.VOUCHER_DEFINITION_BIRTHDAY,1)[0];
                newTJ.VoucherCode = VoucherCode;
                
                memberId_VoucherCodeMap.put(memberRec.id, VoucherCode);
                if(journalSubTypeRecord != null && journalSubTypeRecord.id != null && journalSubTypeRecord.JournalTypeId !=null){
                    newTJ.JournalSubTypeId = journalSubTypeRecord.id;
                	newTJ.JournalTypeId = journalSubTypeRecord.JournalTypeId;
                }
                //TODO: Convert these dates to UTC
                newTJ.ActivityDate = System.now();
                newTJ.JournalDate = System.now();
                newTJ.Order_ID__c = GlobalConstants.BIRTHDAY_VOUCHER_CODE_SUFFIX + VoucherCode;
                //Make sure Status = Processed
                newTJ.Status = GlobalConstants.JOURNAL_STATUS_PROCESSED; 
                transactionalJournalList.add(newTJ);
                
            }
            //Insert. TJ records
            if(transactionalJournalList.size()>0){
                insert transactionalJournalList;
            }
            List<LoyaltyManagement.PointsInput> creditPointsList = new List<LoyaltyManagement.PointsInput>();
            List<String> tJProcessedIds = new List<String>();
            for (TransactionJournal currentTJ : transactionalJournalList){
                LoyaltyManagement.IssueVoucherInputBuilder voucher = new LoyaltyManagement.IssueVoucherInputBuilder();
                voucher.setLoyaltyProgramMemberId(currentTJ.memberId);
                voucher.setProgramName(GlobalConstants.LOYALTY_PROGRAM_NAME);
                voucher.setVoucherDefinitionName(GlobalConstants.VOUCHER_DEFINITION_BIRTHDAY);
                voucher.setJournalId(currentTJ.id);
                voucher.setVoucherCode(memberId_VoucherCodeMap.get(currentTJ.memberId)); //added for testing
                
				issueVoucherList.add(voucher.build());
                tJProcessedIds.add(currentTJ.id);
                
                //Credit 0 Points and generate ledger 
                
                creditPointsList.add(new LoyaltyManagement.PointsInputBuilder()
                .setLoyaltyProgramMemberId(currentTJ.memberId)
                .setProgramName(GlobalConstants.LOYALTY_PROGRAM_NAME)
                .setProgramCurrencyName('Positive Balance')
                .setPoints(0)
                .setJournalId(currentTJ.id)
                .build());
                
            }
            // Insert vouchers outside the loop
            if (!issueVoucherList.isEmpty()) {
                // insert vouchersToInsert;
                List<LoyaltyManagement.IssueVoucherOutput> issueVoucherActionResults = LoyaltyManagement.LoyaltyResources.issueVoucher(issueVoucherList); 
                List<LoyaltyManagement.CreditPointsOutput> creditPointActionResults = LoyaltyManagement.LoyaltyResources.creditPoints(creditPointsList);
            }
            
            // Update TJ
            List<Voucher> updateVoucher = new List<Voucher>();
            for(Voucher currentVoucher : [SELECT id, VoucherCode, TransactionJournalId, TransactionJournal.Order_ID__c from Voucher where TransactionJournalId IN :transactionalJournalList]){
                Voucher current = new Voucher();
                current.id = currentVoucher.id;
                current.Order_Id_Issue__c = currentVoucher.TransactionJournal != null && currentVoucher.TransactionJournal.Order_ID__c !=null ? currentVoucher.TransactionJournal.Order_ID__c : null;
                updateVoucher.add(current);
            }
            if(updateVoucher.size()>0){
                update updateVoucher;
            }
        }catch (Exception ex) {
            System.debug('Following error has been occured'+ ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
    
    //
    global void finish(Database.BatchableContext bc) {
        
        //TODO: Log results somewhere...
        ////How many members in a batch
        //how many voucher got assigned today.
        //capture the log with details.
        
    }
}