public with sharing class SearchLoyaltyLedgerByContactController {
    
    @AuraEnabled
    public static Id getContactId(Id sObjectRecordId){
        try {
            Id contactId = null;
            
            String sObjectName = String.valueOf(sObjectRecordId.getSObjectType());
            if (sObjectName == GlobalConstants.ACCOUNT_NAME) {
                Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :sObjectRecordId];
                contactId = personAccount.PersonContactId;
            } else if (sObjectName == GlobalConstants.LOYALTY_PROGRAM_MEMBER_NAME) {
                LoyaltyProgramMember programMember = [SELECT Id, ContactId FROM LoyaltyProgramMember WHERE Id = :sObjectRecordId];
                contactId = programMember.ContactId;
            } else {
                throw new AuraHandledException('Component do not support this Sobject');
            }
            
            return contactId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<LoyaltyProgramMember> fetchMembershipDetails(Id contactId){
        try {
            List<LoyaltyProgramMember> loyaltyProgramMembers = new List<LoyaltyProgramMember>();
            loyaltyProgramMembers = [SELECT Id, MembershipNumber, Total_Rewards__c, Current_Status_Points__c, (SELECT Id, Name, PointsBalance FROM Loyalty_Member_Currency WHERE Name=:GlobalConstants.CURRENCY_POSITIVE_BALANCE) FROM LoyaltyProgramMember WHERE ContactId = :contactId];
            return loyaltyProgramMembers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static DateTime convertToOtherTimeZone(DateTime dttime, TimeZone sourceTimezone, String targetTimezone) {
        TimeZone tz = sourceTimezone;//Timezone.getTimeZone(sourceTimezone);
        Integer offset = tz.getOffset(dttime);
        
        // target Timezone.
        TimeZone targetTZ = Timezone.getTimeZone(targetTimezone); 
        integer offsetTotargetTZ = targetTZ.getOffset(dttime);
        integer correction = offsetTotargetTZ- offset;
        
        DateTime targetDT = dttime.addMinutes(correction / (1000 * 60));
        
        return targetDT;
    } 
    
    @AuraEnabled
    public static List<sObject> searchLoyaltyLedger(Id contactId, String fromDate, String toDate, String orderNumber, String receiptNo){
        try { 
            String baseQuery = 'SELECT Id, Points, EventType, ';
            baseQuery += 'TransactionJournal.Name, TransactionJournal.ReceiptNo__c, TransactionJournal.Brand, TransactionJournal.ActivityDate, TransactionJournal.TransactionLocation, TransactionJournal.JournalType.Name, TransactionJournal.JournalSubType.Name, TransactionJournal.Order_ID__c, TransactionJournal.Order_Item_ID__c, TransactionJournal.Product.Description, TransactionJournal.Quantity, TransactionJournal.TransactionAmount';
            baseQuery += ' FROM LoyaltyLedger WHERE LoyaltyProgramMember.ContactId = :contactId ';
            
            String loyaltyLedgerQuey = baseQuery;
            DateTime convertedFromDate;
            DateTime convertedtoDate;
            
            System.debug('contactId---'+contactId);
            System.debug('fromDate---'+fromDate);
            System.debug('toDate----'+toDate);
            System.debug('orderNumber---'+orderNumber);
            System.debug('receiptNo----'+receiptNo);
            
            if (!String.isBlank(fromDate) && !String.isEmpty(fromDate) && !String.isBlank(toDate) && !String.isEmpty(toDate)) {
                TimeZone targetTimeZone = UserInfo.getTimeZone();
                System.debug('targetTimeZone--'+targetTimeZone.getDisplayName());
                System.debug('targetTimeZone--'+targetTimeZone);
                
                DateTime fromDateTime = Date.valueOf(fromDate); 
                System.debug('fromDateTime: ' + fromDateTime);
                convertedFromDate = convertToOtherTimeZone(fromDateTime, targetTimeZone, 'GMT');
                System.debug('convertedFromDate--'+convertedFromDate);
                
                DateTime toDateTime = Date.valueOf(toDate); 
                System.debug('toDateTime: ' + toDateTime);
                convertedtoDate = convertToOtherTimeZone(toDateTime, targetTimeZone, 'GMT').addHours(23).addMinutes(59);
                System.debug('convertedtoDate--'+convertedtoDate);
                
                System.debug('String-final'+String.valueOfGmt(convertedFromDate).replace(' ', 'T')+'+0000');
            	System.debug('String-final_2'+String.valueOfGmt(convertedtoDate).replace(' ', 'T')+'+0000');
            }
            
            if (!String.isBlank(receiptNo) && !String.isEmpty(receiptNo)) {
                loyaltyLedgerQuey += ' AND TransactionJournal.ReceiptNo__c = :receiptNo';
            } else if (!String.isBlank(orderNumber) && !String.isEmpty(orderNumber)) {
                loyaltyLedgerQuey += ' AND TransactionJournal.Order_ID__c = :orderNumber';
            } else if (!String.isBlank(fromDate) && !String.isEmpty(fromDate) && !String.isBlank(toDate) && !String.isEmpty(toDate)) {
                //loyaltyLedgerQuey += ' AND TransactionJournal.ActivityDate >= ' + fromDate + 'T00:00:00.000+0000' + ' AND TransactionJournal.ActivityDate <= ' + toDate + 'T23:59:00.000+0000';
                
                loyaltyLedgerQuey += ' AND TransactionJournal.ActivityDate >= ' + String.valueOfGmt(convertedFromDate).replace(' ', 'T')+'+0000' + ' AND TransactionJournal.ActivityDate <= '+ String.valueOfGmt(convertedtoDate).replace(' ', 'T')+'+0000';
            }  
            loyaltyLedgerQuey += ' ORDER BY TransactionJournal.ActivityDate DESC';
            
            System.debug('loyaltyLedgerQuey-Original ----'+loyaltyLedgerQuey);
            List<sObject> loyaltyRecordsList = Database.query(loyaltyLedgerQuey);
            System.debug('loyaltyRecordsList-Original----'+loyaltyRecordsList);
            
            if (loyaltyRecordsList.isEmpty() && (!String.isBlank(receiptNo) && !String.isEmpty(receiptNo)) && (!String.isBlank(orderNumber) && !String.isEmpty(orderNumber))) {
                loyaltyLedgerQuey = baseQuery + ' AND TransactionJournal.Order_ID__c = :orderNumber';
                loyaltyLedgerQuey += ' ORDER BY TransactionJournal.ActivityDate DESC';
                loyaltyRecordsList = Database.query(loyaltyLedgerQuey);
                System.debug('loyaltyRecordsList-Second-OrderNumber----'+loyaltyRecordsList);
            }
            
            if (loyaltyRecordsList.isEmpty() && 
                ((!String.isBlank(receiptNo) && !String.isEmpty(receiptNo)) || (!String.isBlank(orderNumber) && !String.isEmpty(orderNumber)))
				&& (!String.isBlank(fromDate) && !String.isEmpty(fromDate) && !String.isBlank(toDate) && !String.isEmpty(toDate))) {                        
				loyaltyLedgerQuey = baseQuery + ' AND TransactionJournal.ActivityDate >= ' + String.valueOfGmt(convertedFromDate).replace(' ', 'T')+'+0000' + ' AND TransactionJournal.ActivityDate <= '+ String.valueOfGmt(convertedtoDate).replace(' ', 'T')+'+0000';
				loyaltyLedgerQuey += ' ORDER BY TransactionJournal.ActivityDate DESC';
                loyaltyRecordsList = Database.query(loyaltyLedgerQuey);
                System.debug('loyaltyRecordsList-Third-Dates----'+loyaltyRecordsList);
            } 
            
            return loyaltyRecordsList;
        } catch (Exception e) {
            System.debug('e.getStackTraceString (): ' + e.getStackTraceString());
            System.debug('e.getCause (): ' + e.getCause());
            System.debug('e.getLineNumber (): ' + e.getLineNumber());
            System.debug('e.getMessage (): ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}