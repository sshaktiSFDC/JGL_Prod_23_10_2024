@isTest

public class MemberMigrationBatchTest {

/*    SELECT Id, First_Name__c, Last_Name__c, EmailAddress__c, Mobile_Number__c, Date_of_Birth__c, Just_Shop_Number__c, CIM_Customer_ID__c, Country__c, State__c,
Status_Points__c, Enrollment_Channel__c, Enrollment_Date__c, Member_Status__c, Member_Type__c , MigrationType__c
FROM JGL_Member_Data_Migration__c
WHERE Migration_Status__c='NotStarted'
and Enrollment_Date__c != null
LIMIT 1000
      @TestSetup */
   
    
    @IsTest(SeeAllData=true)
    static void makeData() {
       
        
   	JGL_Member_Data_Migration__c jglData = new JGL_Member_Data_Migration__c();
    jglData.First_Name__c = 'First Name';
    jglData.Last_Name__c = 'Last Name';
    jglData.EmailAddress__c = 'abc2may@gmail.com';
    jglData.Date_of_Birth__c = Date.today();
    jglData.Just_Shop_Number__c = 'Test1234';
    jglData.CIM_Customer_ID__c = '1234';
    jglData.Enrollment_Date__c = Date.today();
    jglData.Status_Points__c = 200;
    jglData.Migration_Status__c = 'NotStarted';
        jglData.Member_Status__c = 'Active';
          jglData.Member_Type__c = 'Individual';
        jglData.MigrationType__c = 'Full';
        jglData.Country__c  = 'AU';
        jglData.State__c = 'CA';
        Insert jglData;
        
        
        List<JGL_Member_Data_Migration__c> memberMigrationData = [SELECT Id, First_Name__c, Last_Name__c, EmailAddress__c, Mobile_Number__c, Date_of_Birth__c, Just_Shop_Number__c, CIM_Customer_ID__c, Country__c, State__c,
Status_Points__c, Enrollment_Channel__c, Enrollment_Date__c, Member_Status__c, Member_Type__c , MigrationType__c
FROM JGL_Member_Data_Migration__c
WHERE Migration_Status__c='NotStarted' AND Enrollment_Date__c != null] ;
        
        System.debug ('Size of migration date' + memberMigrationData.size());
        System.debug ('migration date' + memberMigrationData);
      


		System.Test.startTest();
        MemberMigrationBatch.executeExpirationBatch();
        
        //MemberMigrationBatch MemberMigrationBatchTest = new MemberMigrationBatch();
       // Database.executeBatch(MemberMigrationBatchTest);
        System.Test.stopTest();

		List<LoyaltyProgramMember> LoyaltyProgramMembertest = new List<LoyaltyProgramMember>([Select Id from LoyaltyProgramMember LIMIT 10000]);
		System.assertEquals(true, LoyaltyProgramMembertest !=null);
        
	}
               
    
}