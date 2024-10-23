@isTest
public class WalletServiceCalloutMock implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('[{"googleWalletLink":"googleWalletLink","appleWalletLink":"appleWalletLink","nextRewardPoints":0,"membershipNumber":"null002014645","memberId":"0lM8r0000000j5BEAQ","lastName":"Smith","firstName":null}]');
       
        //res.setBody(JSON.serialize('test'));
        return res;
       
    }
}