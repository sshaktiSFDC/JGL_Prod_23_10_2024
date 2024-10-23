/**
* @name         : MemberMigrationBatch
* @description  : Batch class to migration the members Full and Delta, Updated Contact Id and Member Id
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-10             Created
*/ 

global inherited sharing class MemberMigrationBatch implements Database.Batchable<sObject>, Database.Stateful {

    //Invocable Method to be invoked from Flow
    @InvocableMethod(label='Loyalty Member Migration')
    global static void executeExpirationBatch() {
        Id jobId = Database.executeBatch(new MemberMigrationBatch());
    }

    Static Integer NumberOfRecordsProcessed = 0;
    Static Integer NumberOfTransactionJournalCreated = 0;
  
    //  journalType=rec.id;

    //Start method
    global Database.QueryLocator start(Database.BatchableContext bc) {
		
        String MigQuery ='';
        if(test.isRunningTest()){
            MigQuery = System.Label.MigrationQuery + ' LIMIT 1';
        }
        else{
            MigQuery = System.Label.MigrationQuery + ' LIMIT 5000';
        }
           
        System.debug('Query' + MigQuery);
        return Database.getQueryLocator(MigQuery);


    }

    //Execute method
    global void execute(Database.BatchableContext bc, List<JGL_Member_Data_Migration__c> memberMigrationData) {

        List<TransactionJournal> journals = new List<TransactionJournal>();

        List<JournalSubType> jrnlId = new List<JournalSubType>([SELECT Id,JournalTypeId FROM JournalSubType where Name = 'Member Migration']);
        Id addIds = jrnlId[0].id ;      
       
        List<JGL_Member_Data_Migration__c> updateStatus = new List<JGL_Member_Data_Migration__c>();

        for (JGL_Member_Data_Migration__c migratedData : memberMigrationData) {
            System.debug('Migration Type: ' + migratedData.MigrationType__c + 'Member:' + migratedData.Just_Shop_Number__c);

            if ( migratedData.MigrationType__c.equals('Full')){
                ConnectApi.MemberContactInput contact = new ConnectApi.MemberContactInput();
                contact.additionalContactFieldValues = new Map<String, String>();


                contact.additionalContactFieldValues.put('PersonMobilePhone',migratedData.Mobile_Number__c );
                contact.additionalContactFieldValues.put('CIM_Customer_ID__pc',migratedData.CIM_Customer_ID__c);

                if(migratedData.Date_of_Birth__c != null){

                    contact.additionalContactFieldValues.put('PersonBirthdate',String.valueOf(migratedData.Date_of_Birth__c) );

                    //contact.additionalContactFieldValues.put('PersonBirthdate',String.valueOf(migratedData.Date_of_Birth__c) );
                }

                contact.allowDuplicateRecords = false;
                contact.lastName = migratedData.Last_Name__c;
                contact.FirstName = migratedData.First_Name__c;
                contact.Email = migratedData.EmailAddress__c;

                ConnectApi.IndividualMemberInput member = new ConnectApi.IndividualMemberInput();
                member.associatedContactDetails = contact;

                member.enrollmentDate = migratedData.Enrollment_Date__c;
                // member.membershipNumber = migratedData.Just_Shop_Number__c;
                member.membershipNumber = migratedData.Just_Shop_Number__c;
                member.memberStatus = migratedData.Member_Status__c;
                member.enrollmentChannel = ConnectApi.EnrollmentChannelResource.Pos;

                member.additionalMemberFieldValues = new Map<String, String>{
                    //'Status_Points__c' => String.valueOf(migratedData.Status_Points__c),
                    'Country__c' => migratedData.Country__c,
                    'State__c' => migratedData.State__c
                };
                ConnectApi.IndividualMemberOutput output;

                
                try{
                    System.debug('Before the API : ');
                    output = ConnectApi.LoyaltyManagementConnect.enrollIndividualMember(GlobalConstants.LOYALTY_PROGRAM_NAME, member);
                    System.debug('After Calling the API:' + output);
                    System.debug('After Calling the API:Memberid' + output.loyaltyProgramMemberId);
                    System.debug('After Calling the API:ContactId' + output.contactId);

                    if (( output.contactId != null) && (output.loyaltyProgramMemberId != null)) {
                    
                        migratedData.Migration_Status__c = 'Success';
                        migratedData.ContactId__c = output.contactId ;
                        migratedData.Loyalty_Program_MemberId__c = output.loyaltyProgramMemberId;

                        System.debug('Contact Created : '+ output.contactId );
                        
                        	
						/*
                        journals.add(new TransactionJournal(
                        JournalTypeId = jrnlId[0].JournalTypeId,
                        JournalSubTypeId = jrnlId[0].id ,
                        ActivityDate = System.Now(),
                        JournalDate = migratedData.Enrollment_Date__c,
                        Status = 'Pending',
                        LoyaltyProgramId = LoyaltyRuntimeHelper.loyaltyProgramId,
                        MemberId = output.loyaltyProgramMemberId,
              			TransactionAmount = migratedData.Status_Points__c
                        ));*/
                        journals.add(new TransactionJournal(
                        JournalTypeId = jrnlId[0].JournalTypeId,
                        JournalSubTypeId = jrnlId[0].id ,
                        ActivityDate = System.Now(),
                        JournalDate = migratedData.Enrollment_Date__c,
                        Status = 'Pending',
                        LoyaltyProgramId = LoyaltyRuntimeHelper.loyaltyProgramId,
                        MemberId = output.loyaltyProgramMemberId
              			));

                    }  else {
                        migratedData.Migration_Status__c = 'Error';
                        migratedData.Migration_Error__c = 'Unable to create there records using conectAPI';
                        system.debug('Unable to create there records using connectAPI');

                    } 
                    	

                }
                Catch(Exception ex){ migratedData.Migration_Status__c = 'Error';String errorMessage = ex.getMessage();if (errorMessage != null && errorMessage.length() > 254) {migratedData.Migration_Error__c = errorMessage.substring(0, 254); } else {migratedData.Migration_Error__c = errorMessage;}

                }
                updateStatus.add(migratedData);

            }
            else {
// TODO Handle the update the logic
/* Query the memeber, person. 
update
*/
            }
            
        }
        
        if(!updateStatus.isEmpty())
        {
            update updateStatus;
            system.debug('Updated : '+ updateStatus.size());
            NumberOfRecordsProcessed += updateStatus.size();

        }

    
        if (!journals.isEmpty()) {
            insert journals;
            NumberOfTransactionJournalCreated += journals.size();
        }
       
      
    }
    

    //Finish method
    global void finish(Database.BatchableContext bc) {
        // Any cleanup or post-processing logic can be added here if needed
        system.debug('NumberOfRecordsProcessed:' +NumberOfRecordsProcessed );
        system.debug('NumberOfTransactionJournalCreated:' +NumberOfTransactionJournalCreated );

    }
}