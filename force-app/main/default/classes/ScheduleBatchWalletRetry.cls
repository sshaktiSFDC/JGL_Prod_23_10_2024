global class ScheduleBatchWalletRetry implements Schedulable  {
    global void execute(SchedulableContext sc) {
        Map<String, Object> flowParams = new Map<String, Object>();
        if(!test.isRunningTest()){
            Flow.Interview.Member_Update_Wallet_Member_Details_and_Points  flow = new Flow.Interview.Member_Update_Wallet_Member_Details_and_Points (flowParams);flow.start();
        }
        
    }

}