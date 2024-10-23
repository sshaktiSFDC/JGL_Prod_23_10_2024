public class ConvertStringToNumberText {

     @InvocableMethod(label='Convert String To Number' description='Take OrderId String To Convert to Number' category='TransactionJournal')
       public static List<HandleStringOutput> convertStringtoNumbers (List<HandleStringInput> inputs){
    
    	Integer InputSize = inputs.size();
        System.debug('ConvertString inputs size = ' + InputSize);
        System.debug('ConvertString inputlist = ' + inputs);
           
        List<HandleStringOutput> OutputList = new List<HandleStringOutput>();
        HandleStringOutput Output = new HandleStringOutput();  
           
     
        for (HandleStringInput rec : inputs) {
            
        String OrderItem = rec.orderItemId;
        String n = '';
        for (Integer i=0; i<OrderItem.length(); i++) {
        if (OrderItem.substring(i, i+1).isNumeric()) {
            n += OrderItem.substring(i, i+1);
            }
           
        }
                system.debug('ConvertString n result is = ' + n);
       
                Output.OrderItemNumberText = n;
                OutputList.add(Output);

            }
         System.debug('ConvertString Outputlist = ' + OutputList);
         return OutputList;
        

	}
    
     public class HandleStringInput {
        @InvocableVariable(label='OrderItemNo' description='Order ItemNo of JOurnal' required=false)
        public String orderItemId;

    }

    public class HandleStringOutput {
     @InvocableVariable public String OrderItemNumberText;
       
    }
}