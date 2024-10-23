/**
* @name         : LoyaltyMemberVoucherRestService
* @description  : Canonical class to generate JSON response payload for Get Member Vouchers
* @testClass    : LoyaltyMemberVoucherRestServiceTest
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-03-08    Vince Vuong         Created
* 2024-03-13    Siddharth Singh     Modified--Pagination, Try/Catch and logic to handle voucher to show on specific page
* 2024-03-25    Vince Vuong         Fixed URL decode issue with Program Name
* 2024-03-28    Surya Dixit         Updated logic to map minimum spend from voucher instead of voucher definition
* 2024-04-24    Vince Vuong         Forced response content-type and added Order Issued & Redeemed fields
*/
@RestResource(urlMapping='/loyalty/programs/*/members/*/vouchers')
global without sharing class LoyaltyMemberVoucherRestService {
    
    @HttpGet
    global static void doGet() {
        try {
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;
            
            String[] urls = request.requestURI.split('/');
            //System.debug(request.params);
            //System.debug(request.requestURI);
            System.debug(urls);
                    
            //URL = /loyalty/programs/NTO/members/M1/vouchers    
            String programName = EncodingUtil.urlDecode(urls[3], 'UTF-8');
            String membershipNumber = urls[5]; //'TEST123';
    
            //Query parameters
            Integer pageNumber = request.params.get('pageNumber') != null ? Integer.valueOf(request.params.get('pageNumber')) : 1;
            if(pageNumber == 1){
                pageNumber = 0;
            }
            else{
                pageNumber = pageNumber-1;
                pageNumber *= GlobalConstants.MAX_VOUCHER_RECORDS;
            }
            String voucherStatus = request.params.get('voucherStatus') != null ? request.params.get('voucherStatus') : 'Issued';
            String sortBy = request.params.get('sortBy') != null ? request.params.get('sortBy') : ' ExpirationDate';
            String sortOrder = request.params.get('sortOrder') != null ? request.params.get('sortOrder') : ' ASC';
            
            //String voucherStatus = request.params.get('voucherStatus') != null ? request.params.get('voucherStatus') : 'Issued';
            //System.debug('programName: ' + programName);
            //System.debug('membershipNumber: ' + membershipNumber);
            //System.debug('voucherStatus: ' + voucherStatus);
            //System.debug('sortBy: ' + sortBy);
            //System.debug('sortOrder: ' + sortOrder);
            //System.debug('pageNumber: ' + pageNumber);
            //System.debug('Limit: ' + GlobalConstants.MAX_VOUCHER_RECORDS);                
            
            //Check mandatory fields
            if (String.isBlank(programName) || String.isBlank(membershipNumber)) {
                RestContext.response.statuscode = GlobalConstants.HTTP_STATUS_CODE_BAD_REQUEST;
                return;
            }
            
            List<String> voucherStatuses = new List<String>();
            if (String.isNotBlank(voucherStatus)) {
                voucherStatuses = voucherStatus.split(',');
            }
            
         //   List<LoyaltyProgramMember> tt = [Select id,MembershipNumber from LoyaltyProgramMember WHERE MembershipNumber = :membershipNumber];
        //    SYstem.debug('888888'+tt);
            
            //Add logic to filter on using Member ID in addition to Membership Number!
            String queryString = 'SELECT Id,Name,Minimum_Spend__c,EffectiveDate,ExpirationDate,FaceValue,RedeemedValue,RemainingValue,Status,VoucherCode,PromotionId,Promotion.Name,UseDate,Reason,Order_Id_Issue__c,Order_Id_Issue_Channel__c,Order_Id_Redeem__c,Order_Id_Redeem_Channel__c, ' +
                                    ' VoucherDefinitionId,VoucherDefinition.Name,VoucherDefinition.Description,VoucherDefinition.IsActive,VoucherDefinition.IsPartialRedeemable,VoucherDefinition.Type,VoucherDefinition.Minimum_Spend__c ' +
                                    ' FROM Voucher '+
                                    ' WHERE LoyaltyProgramMember.Program.Name = :programName ' +
                                    ' AND (LoyaltyProgramMember.MembershipNumber = :membershipNumber) '+
                                    ' AND Status = :voucherStatuses ' +
                                    ' ORDER BY ' + sortBy + ' ' + sortOrder +
                                    ' LIMIT ' + GlobalConstants.MAX_VOUCHER_RECORDS  + 
                                    ' OFFSET ' + pageNumber;
            
            System.debug(queryString);
            List<sObject> vouchers = Database.query(queryString);
            System.debug('Voucherrrrrs'+vouchers);
            
            CanonicalLoyaltyMemberVoucher payload = new CanonicalLoyaltyMemberVoucher();
            payload.voucherCount = vouchers.size();
            system.debug('voucherCount = '+payload.voucherCount);
            
            payload.vouchers = new List<CanonicalLoyaltyMemberVoucher.Vouchers>();
            
            for(Voucher rec : (List<Voucher>)vouchers) {
                CanonicalLoyaltyMemberVoucher.Vouchers voucher = new CanonicalLoyaltyMemberVoucher.Vouchers();
                
                //Voucher fields
                voucher.faceValue = rec.FaceValue;            
                voucher.redeemedValue = rec.RedeemedValue;
                voucher.remainingValue = rec.RemainingValue;
                voucher.status = rec.Status;
                voucher.voucherCode = rec.VoucherCode;
                voucher.voucherId = rec.Id;            
                voucher.voucherNumber = rec.Name;
    
                voucher.effectiveDate = String.valueOf(rec.EffectiveDate);
                voucher.expirationDate = String.valueOf(rec.ExpirationDate);
                voucher.useDate = String.valueOf(rec.UseDate);
                
                //Voucher definition fields
                voucher.description = rec.VoucherDefinition.Description;
                voucher.isVoucherDefinitionActive = rec.VoucherDefinition.IsActive;
                voucher.isVoucherPartiallyRedeemable = rec.VoucherDefinition.IsPartialRedeemable;
                voucher.type = rec.VoucherDefinition.Type;
                voucher.voucherDefinition = rec.VoucherDefinition.Name;
                voucher.minimumSpend = rec.Minimum_Spend__c;
                
                //Promotion fields
                voucher.promotionId = rec.PromotionId;
                voucher.promotionName = rec.Promotion.Name;
                
                //Order fields
                voucher.issueOrderID = UtilityHelper.nullString(rec.Order_Id_Issue__c);
                voucher.redeemOrderID = UtilityHelper.nullString(rec.Order_Id_Redeem__c);
                voucher.issueOrderChannel = UtilityHelper.nullString(rec.Order_Id_Issue_Channel__c);
                voucher.redeemOrderChannel = UtilityHelper.nullString(rec.Order_Id_Redeem_Channel__c);

                payload.vouchers.add(voucher);
            }
            
            //Send back response payload
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(payload,true));
            RestContext.response.addHeader(GlobalConstants.CONTENT_TYPE, GlobalConstants.CONTENT_TYPE_APPLICATION_JSON);

        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            RestContext.response.statuscode = GlobalConstants.HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR; // Internal Server Error
            RestContext.response.responseBody = Blob.valueOf('An error occurred. Please try again later.');
        }
    }
}