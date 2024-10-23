/**
* @name         : PointsExpirationBatch
* @description  : 
* @testClass    : PointsExpirationBatchTest //pending
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-04-04    Surya Dixit         Created
* 2024-04-08    Surya Dixit         Updated logic
*/

global class PointsExpirationBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    @InvocableMethod(label='Point Expiration Batch')
    global static void executeUpdateMembersPointBalancesBatch() {
        Id jobId = Database.executeBatch(new PointsExpirationBatch());
    }

    Date today = Date.today();

// Subtract two years from today's date
    Date twoYearsAgo = today.addYears(-2);

   
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status_Points__c
            FROM LoyaltyProgramMember
            WHERE LastActivityDate =: twoYearsAgo
        ]);
    }
    
        
        
        global void execute(Database.BatchableContext bc, List<LoyaltyProgramMember> lpm) {
            try {
                Set<Id> memberIds = new Set<Id>();
                for (LoyaltyProgramMember lpmIds : lpm) {
                    memberIds.add(lpmIds.Id);
                }
    
                Id progId = [SELECT Id FROM LoyaltyProgram LIMIT 1].Id;
                Id jornlTypeId = [SELECT Id FROM JournalType WHERE Name = 'Points Expiration' LIMIT 1].Id;


                List<TransactionJournal> journals = new List<TransactionJournal>();
                // Creating new TransactionJournals for members where it doesn't exist
                for (Id membrId : memberIds) {
                   
                    {
                        system.debug('Inside if condition to create Journal');
                        journals.add(new TransactionJournal(
                            JournalTypeId = jornlTypeId,
                            ActivityDate = System.Now(),
                            JournalDate = System.Now(),
                            Status = 'Pending',
                            LoyaltyProgramId = progId,
                            MemberId = membrId
                        ));
                    }
                    system.debug('Journlas' + journals);
                }
    
                // Bulk insert of new TransactionJournals
                if (!journals.isEmpty()) {
                    system.debug('Journlas inside if' + journals);
                    insert journals;
                }
              

            } catch (Exception e) {
                system.debug('Following error has been occured' + e.getMessage() + ' ' + e.getStackTraceString());
            }
        }
    
        global void finish(Database.BatchableContext bc) {
            // Any cleanup or post-processing logic can be added here if needed
        }
    }