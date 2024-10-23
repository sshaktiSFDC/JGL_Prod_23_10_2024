/**
* @name         : LoyaltyRuntimeHelper
* @description  : Class to return loyaty runtime configuration to be used across the program.
* <Date>        <Modified By>     	<Brief Description of Change>
* 2024-04-04    Vince Vuong         Created
*/ 
public without sharing class LoyaltyRuntimeHelper {

    //Return Loyalty Program ID
    public static Id loyaltyProgramId {
        get {
            if (loyaltyProgramId == null) {
                List<LoyaltyProgram> programs = [SELECT Id, Name FROM LoyaltyProgram WHERE Name = :GlobalConstants.LOYALTY_PROGRAM_NAME];
                loyaltyProgramId = (programs.size() > 0) ? programs[0].Id : null;
            }
            return loyaltyProgramId;
        }
        private set;
    }

    //Return mappings of Journal Types
    public static Map<String, Id> journalTypeIdMappings {
        get {
            if (journalTypeIdMappings == null) {
                journalTypeIdMappings = new Map<String, Id>();
                for(JournalType rec : [SELECT Id, Name FROM JournalType]) {
                    journalTypeIdMappings.put(rec.Name, rec.Id);
                }
            }
            return journalTypeIdMappings;
        }
        private set;
    }

    //Return mappings of Journal Sub Types
    public static Map<String, Id> journalSubTypeIdMappings {
        get {
            if (journalSubTypeIdMappings == null) {
                journalSubTypeIdMappings = new Map<String, Id>();
                for(JournalSubType rec : [SELECT Id, Name FROM JournalSubType]) {
                    journalSubTypeIdMappings.put(rec.Name, rec.Id);
                }
            }
            return journalSubTypeIdMappings;
        }
        private set;
    }

    //Return mappings of Voucher definition IDs
    public static Map<String, Id> voucherDefinitionIdMappings {
        get {
            if (voucherDefinitionIdMappings == null) {
                voucherDefinitionIdMappings = new Map<String, Id>();
                for(VoucherDefinition rec : [SELECT Id, Name FROM VoucherDefinition]) {
                    voucherDefinitionIdMappings.put(rec.Name, rec.Id);
                }
            }
            return voucherDefinitionIdMappings;
        }
        private set;
    }

}