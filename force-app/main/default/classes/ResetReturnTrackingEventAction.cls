/**
* @name         : HandleReturnProcessTJAction
* @description  : Invocable method to publish PE to reset points for Returns process
* @testClass    : TODO
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-04-09    Siddharth Singh     Created
*/
public class ResetReturnTrackingEventAction {
    
    @InvocableMethod(label='Publish Reset Return Tracking Event' category='TransactionJournal')
    public static void publishJournalEvent (List<ResetReturnEAEventInput> inputs){
        List<Reset_Return_Tracking_EA__e> resetEvents = new List<Reset_Return_Tracking_EA__e>();
        
        
            Reset_Return_Tracking_EA__e rrt = new Reset_Return_Tracking_EA__e();
            rrt.Activity_Date__c = inputs[0].ActivityDate;           
            rrt.Member_Id__c = inputs[0].MemberId;
            rrt.Program_Id__c = inputs[0].ProgramId;
            resetEvents.add(rrt);
        
        
        
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(resetEvents);
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
    
	
    public class ResetReturnEAEventInput {
        @InvocableVariable(label='Activity Date' required=true)
        public Datetime ActivityDate;
        @InvocableVariable(label='Member Id' required=true)
        public String MemberId;
        @InvocableVariable(label='Program Id' required=true)
        public String ProgramId;
    }
}