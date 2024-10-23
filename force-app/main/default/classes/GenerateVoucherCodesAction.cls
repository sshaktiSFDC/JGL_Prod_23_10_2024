/**
* @name         : GenerateVoucherCodesAction
* @description  : Custom REST service to return Wallet links for members
* @testClass    : GenerateVoucherCodesActionTest
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-03-27    Vince Vuong         Created
*/
public with sharing class GenerateVoucherCodesAction {

    @InvocableMethod(label='Generate Voucher Codes')
    public static List<GenerateVoucherCodeOutput> generateVoucherCodes(List<GenerateVoucherCodeInput> inputs) {
        List<GenerateVoucherCodeOutput> outputs = new List<GenerateVoucherCodeOutput>();
        try {
            for (GenerateVoucherCodeInput rec : inputs) {
                List<String> codes = UtilityHelper.generateVoucherCodes(rec.voucherDefintionName, rec.voucherCodesToGenerate);
                String voucherCodes = '';
                if (codes.size() > 0 ) {
                    //voucherCodes = (codes.size() == 1) ? codes[0] : '['+String.join(codes,',')+']';
                    voucherCodes = (codes.size() == 1) ? codes[0] : String.join(codes,',');
                     system.debug('Voucher Codes'+ voucherCodes);
                        system.debug('Voucher Codes length'+ voucherCodes.length());
                    if (voucherCodes.length() > 255) {
                        system.debug('Voucher Codes'+ voucherCodes);
                        system.debug('Voucher Codes length'+ voucherCodes.length());
                        voucherCodes = voucherCodes.substring(0,255);
                    }
                }
                
                GenerateVoucherCodeOutput output = new GenerateVoucherCodeOutput();
                output.voucherCount = codes.size();
                output.voucherCodes = voucherCodes;
                outputs.add(output);
            }
        }
        catch(Exception ex) {
            System.debug(ex);
        }
        return outputs;
    }

    public class GenerateVoucherCodeInput {
        @InvocableVariable(required=true) public String voucherDefintionName;
        @InvocableVariable(required=true) public Integer voucherCount;
        @InvocableVariable(required=true) public Integer voucherCodesToGenerate;
    }

    public class GenerateVoucherCodeOutput {
        @InvocableVariable public Integer voucherCount;
        //@InvocableVariable public List<String> voucherCodes;
        @InvocableVariable public String voucherCodes;
    }

}