/**
* @name         : MemberUpdateEventTriggerHandler
* @description  : Handler class for Member Update Event platform event.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-04-17    Siddharth Singh     Created
*/
public class MemberUpdateEventTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {

        
        Set<Id> newPEEventsMemberIds = new Set<Id>();
        for (Member_Update_Event__e newEvent : (List<Member_Update_Event__e>)Trigger.new) {
            newPEEventsMemberIds.add(newEvent.Member_Id__c);
        }
        System.debug('newPEEventsMemberIds = ' + newPEEventsMemberIds);
        
        if(!newPEEventsMemberIds.isEmpty()){
          System.enqueueJob(new MemberUpdateQueueable(newPEEventsMemberIds, 0));
        }
        
    }
    
    
}