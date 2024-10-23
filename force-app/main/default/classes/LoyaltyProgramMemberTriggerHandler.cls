/**
* @name         : LoyaltyProgramMemberTriggerHandler
* @description  : This class is used to Handle the event for Loyalty Program Member Trigger.
* @testClass    : LoyaltyProgramMemberTriggerHandlerTest
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-02-12    Vince Vuong         Created
* 2024-03-13    Siddharth Singh     Modified--Bulkify the code
*/
public with sharing class LoyaltyProgramMemberTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
    }
    
    public override void beforeUpdate() {
    }
    
    public override void afterInsert() {
        //Generate membership numbers
        generateMembershipNumbers(Trigger.new);
        isMemberRecordChanged(Trigger.new);
    }
    
    public override void afterUpdate() {
        isMemberRecordChanged(Trigger.new);
    }
    
    //Private method to generate new membership numbers
    @testVisible private static void generateMembershipNumbers(List<LoyaltyProgramMember> newMembers){
        List<LoyaltyProgramMember> listOfMembersToUpdate = new List<LoyaltyProgramMember>();
        Map<String, LoyaltyProgramMember> programMemberMappings = new Map<String, LoyaltyProgramMember>();
        
        // Collect unique IDs from the new members
        Set<Id> LoyaltyProgramMemberIds = new Set<Id>();
        for (LoyaltyProgramMember newMember : newMembers) {
            LoyaltyProgramMemberIds.add(newMember.Id);
        }
        
        for(LoyaltyProgramMember rec : [SELECT Id, MembershipNumber, Unique_ID__c FROM LoyaltyProgramMember WHERE Id IN : LoyaltyProgramMemberIds]){
            programMemberMappings.put(rec.Unique_ID__c, rec);
        }
        
        // gettng the final customer number from the Utility helper 
        Map<String, String> finalNumberMappings = UtilityHelper.generateMembershipNumbers(programMemberMappings.keyset());
        System.debug('finalNumberMappings = ' + finalNumberMappings);
        
        for(LoyaltyProgramMember rec : programMemberMappings.Values()){
            //TODO: Copy current membership number (CIM customer ID) to another field.
            rec.MembershipNumber = finalNumberMappings.get(rec.Unique_ID__c);
            listOfMembersToUpdate.add(rec);
        }
        System.debug('listOfMembersToUpdate = ' + listOfMembersToUpdate);
        
        try {
            if(listOfMembersToUpdate.size()>0){
                update listOfMembersToUpdate;
            }
        }catch (Exception ex) {System.debug('An error occurred while updating LoyaltyProgramMembers: ' + ex.getMessage());}//Logger.error(GlobalConstants.EXCEPTION_MESSAGE_PREFIX + ex.getStackTraceString());} 
    }
    
    //Method to detect whether loyalt member record being updated or changed
    @testVisible private void isMemberRecordChanged(List<LoyaltyProgramMember> members) {
        
        System.System.debug('isMemberRecordChanged');
        
        System.System.debug(Trigger.oldMap);
        System.System.debug(Trigger.new);
        System.debug('size line 67 members --->'+ members.size());
        List<Member_Update_Event__e> memberUpdateEvents = new List<Member_Update_Event__e>();
        List<Member_Enrol_Event__e> memberEnrolEvents = new List<Member_Enrol_Event__e>();
        try{
            for (LoyaltyProgramMember member : members) {
                LoyaltyProgramMember oldObj = Trigger.oldMap != null ? (LoyaltyProgramMember)Trigger.oldMap.get(Member.Id) : null;
                
                if (oldObj != null) {
                    // Check if specific field values have changed
                    if (oldObj.Contact.FirstName != member.Contact.FirstName 
                        || oldObj.Contact.LastName != member.Contact.LastName 
                        || oldObj.Status_Points__c != member.Status_Points__c 
                        || oldObj.Total_Rewards__c != member.Total_Rewards__c
                       )
                    {
                        // Field value has changed
                        Member_Update_Event__e memberPEvent = new Member_Update_Event__e();
                        memberPEvent.Member_Id__c = member.Id;
                        memberUpdateEvents.add(memberPEvent);
                    }
                    
                    // Check if wallet link field values have changed
                    else if (
                        (oldObj.Apple_Wallet_Link__c != member.Apple_Wallet_Link__c   || oldObj.Google_Wallet_Link__c != member.Google_Wallet_Link__c)
                        &&
                        ( String.isBlank(member.Apple_Wallet_Link__c) 
                         ||  String.isBlank(member.Google_Wallet_Link__c)  
                         ||  member.Apple_Wallet_Link__c.contains('empty') 
                         ||  member.Google_Wallet_Link__c.contains('empty') )
                    )
                    { 
                        Member_Enrol_Event__e memberEnrolPEvent = new Member_Enrol_Event__e();
                        memberEnrolPEvent.Member_Id__c = member.Id;
                        memberEnrolPEvent.membershipNo__c = member.MembershipNumber;
                        memberEnrolPEvent.appleWalletLink__c  = member.Apple_Wallet_Link__c  ; 
                        memberEnrolPEvent.googleWalletLink__c   = member.Google_Wallet_Link__c ; 
                        memberEnrolEvents.add(memberEnrolPEvent);
                    }
                    
                }
                
                else {
                        Member_Enrol_Event__e memberEnrolPEvent = new Member_Enrol_Event__e();
                        memberEnrolPEvent.Member_Id__c = member.Id;
                        memberEnrolPEvent.membershipNo__c = member.MembershipNumber;
                        memberEnrolPEvent.appleWalletLink__c  = member.Apple_Wallet_Link__c  ; 
                        memberEnrolPEvent.googleWalletLink__c   = member.Google_Wallet_Link__c ; 
                        memberEnrolEvents.add(memberEnrolPEvent);
                }
                
                // Call method to publish events
                
            }
            if (!memberUpdateEvents.isEmpty())  {
                List<Database.SaveResult> results = EventBus.publish(memberUpdateEvents);
                System.debug('MemberUpdate event published :' + memberUpdateEvents);
                System.debug('results >> ' + results);
                
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
            
            if (!memberEnrolEvents.isEmpty())  {
                List<Database.SaveResult> results = EventBus.publish(memberEnrolEvents);
                
                System.debug('MemberEnrol event published :' + memberEnrolEvents);
                System.debug('results >> ' + results);
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
            memberUpdateEvents.clear();   
            memberEnrolEvents.clear();   
        }    
        catch (Exception ex) {System.debug('An error occurred while Inserting platorm Events: ' + ex.getMessage());}
        
    }
}