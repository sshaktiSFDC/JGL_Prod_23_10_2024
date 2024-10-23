/**
* @name         : LoyaltyProgramMemberTriggerHandlerTest
* @description  : This is test class of LoyaltyProgramMemberTriggerHandler.
* @testClass    : 
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-03-13    Siddharth Singh     Created
*/
@isTest
private class LoyaltyProgramMemberTriggerHandlerTest {

    @isTest
    static void testAfterInsert() {
        // Create test data
        // Create Contact
 
        Contact contact = new Contact(
            LastName = 'Test'
        );
        insert contact;
        
        // Create LoyaltyProgram
        LoyaltyProgram loyaltyProgram = new LoyaltyProgram(
            Name = 'TestProgram2'
            
        );
        insert loyaltyProgram;

        List<LoyaltyProgramMember> testMembers = new List<LoyaltyProgramMember>();
        for (Integer i = 0; i < 5; i++) {
            LoyaltyProgramMember member = new LoyaltyProgramMember(
                ProgramId = loyaltyProgram.Id,
                MembershipNumber = 'M11'+i,
                ContactId = contact.Id,
                EnrollmentDate = Date.today(), // Set EnrollmentDate
                MemberStatus = 'Active' // Set MemberStatus
            );
            testMembers.add(member);
        }
        insert testMembers;
       
        
        

        // Call the afterInsert method
       /* Test.startTest();
        LoyaltyProgramMemberTriggerHandler.generateMembershipNumbers(testMembers);
        
        Test.stopTest();*/

    }
     @isTest
    static void testAfterInsert2() {
        // Create test data
        // Create Contact
 
        Contact contact = new Contact(
            LastName = 'Test'
        );
        insert contact;
        
        
        
        // Create LoyaltyProgram
        LoyaltyProgram loyaltyProgram = new LoyaltyProgram(
            Name = 'TestProgram2'
            
        );
        insert loyaltyProgram;

        List<LoyaltyProgramMember> testMembers = new List<LoyaltyProgramMember>();
        for (Integer i = 0; i < 5; i++) {
            LoyaltyProgramMember member = new LoyaltyProgramMember(
                ProgramId = loyaltyProgram.Id,
                MembershipNumber = 'M11'+i,
                ContactId = contact.Id,
                EnrollmentDate = Date.today(), // Set EnrollmentDate
                MemberStatus = 'Active' // Set MemberStatus
            );
            testMembers.add(member);
        }
        insert testMembers;
        List<LoyaltyProgramMember> testMembers2 = new List<LoyaltyProgramMember>();
        for(LoyaltyProgramMember lpm : testMembers){
            LoyaltyProgramMember temp = new LoyaltyProgramMember();
            temp.Total_Rewards__c = 100;
            temp.id = lpm.id;
            testMembers2.add(temp);
        }
        update testMembers2;
        
        //VoucherTriggerHandlerMock mock = new VoucherTriggerHandlerMock();
		//Test.setMock(HttpCalloutMock.class, mock);

        // Call the afterInsert method
        Test.startTest();
        LoyaltyProgramMemberTriggerHandler ll = new LoyaltyProgramMemberTriggerHandler();
        ll.isMemberRecordChanged(testMembers);
        Test.stopTest();

    }
   
    
}