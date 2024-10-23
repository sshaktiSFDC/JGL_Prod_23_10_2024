//TEST class only DO NOT Deploy!
public with sharing class DebugLoyaltyProcessAction {

    @InvocableMethod(label='Debug Loyalty Process')
    public static List<String> debugLoyaltyProcess(List<DebugInput> inputs) {
        List<String> outputs = new List<String>();
        for (DebugInput debug : inputs) {
            if (String.isNotBlank(debug.message1)) {
                System.debug('DebugLoyaltyProcessAction Message1 = ' + debug.message1);
            }
            if (String.isNotBlank(debug.message2)) {
                System.debug('DebugLoyaltyProcessAction Message2 = ' + debug.message2);
            }
            if (String.isNotBlank(debug.message3)) {
                System.debug('DebugLoyaltyProcessAction Message3 = ' + debug.message3);
            }
            if (String.isNotBlank(debug.message4)) {
                System.debug('DebugLoyaltyProcessAction Message4 = ' + debug.message4);
            }
            if (String.isNotBlank(debug.message5)) {
                System.debug('DebugLoyaltyProcessAction Message5 = ' + debug.message5);
            }

            outputs.add(debug.message1);
        }

        return outputs;
    }

    public class DebugInput {
        @InvocableVariable public String message1;
        @InvocableVariable public String message2;
        @InvocableVariable public String message3;
        @InvocableVariable public String message4;
        @InvocableVariable public String message5;
    }
}