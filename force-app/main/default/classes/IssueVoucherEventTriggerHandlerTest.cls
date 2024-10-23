@isTest
public class IssueVoucherEventTriggerHandlerTest {
    @isTest
    static void myUnitTest() {
        
       

        // Create Contact
 
        	Contact contact = new Contact(
                LastName = 'Test'
            );
        	insert contact;
         // Create LoyaltyProgram
            LoyaltyProgram loyaltyProgram = new LoyaltyProgram(
                Name = 'TestProgram'
                
            );
            insert loyaltyProgram;
        	System.debug(loyaltyProgram);

            // Create LoyaltyProgramMember
            LoyaltyProgramMember loyaltyProgramMember = new LoyaltyProgramMember(
                ProgramId = loyaltyProgram.Id,
                MembershipNumber = 'TEST123',
                ContactId = contact.Id,
                EnrollmentDate = Date.today(), // Set EnrollmentDate
                MemberStatus = 'Active' // Set MemberStatus
            );
            insert loyaltyProgramMember;
        	System.debug(loyaltyProgramMember.membershipNumber);

            // Create VoucherDefinition
            VoucherDefinition voucherDefinition = new VoucherDefinition(
                Name = 'Test Voucher Definition',
                Description = 'This is a test voucher definition',
                IsActive = true,
                IsPartialRedeemable = true,
                Type = 'FixedValue',
                FaceValue = 10,
                ExpirationType = 'FixedDate',
                EffectiveDate = Date.today(),
                ExpirationDate = Date.today().addMonths(3),
                Minimum_Spend__c = 100
            );
            insert voucherDefinition;

           
			
        
        	
//             // Create Voucher
Voucher voucher1 = new Voucher(
                LoyaltyProgramMemberId = loyaltyProgramMember.Id,
                VoucherDefinitionId = voucherDefinition.Id,
                
                FaceValue = 15,
            	RedeemedValue = 1,
                Status = 'Issued',
                VoucherCode = 'TEST123',
                EffectiveDate = Date.today(),
                ExpirationDate = Date.today().addMonths(4)
            	
            );
        	insert voucher1;
        
            

            
Test.startTest();

List<Issue_Voucher_Event__e> journalEvents = new List<Issue_Voucher_Event__e>();
//TODO: Loop through all inputs
//Please add try/catch and handle exception

    Issue_Voucher_Event__e je = new Issue_Voucher_Event__e();
    
    // je.Order_Id_Issued__c = '1234';
     je.Voucher_Code__c = voucher1.VoucherCode;
    // je.Order_Id_Issued_Channel__c = 'Test';
     je.MemberId__c = loyaltyProgramMember.id;


    journalEvents.add(je);


// Call method to publish events
List<Database.SaveResult> results = EventBus.publish(journalEvents);

Test.stopTest();
        }
}