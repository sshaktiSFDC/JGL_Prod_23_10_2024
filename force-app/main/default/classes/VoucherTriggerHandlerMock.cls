@isTest
public class VoucherTriggerHandlerMock implements HttpCalloutMock{
	public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"success": true}');
        res.setBody('[{"membershipNumber": "' + 'test' + '", "googleWalletLink":"wwww.play.google.com/test_list", "appleWalletLink":"www.apple-wallet.com/test_link"}]');
            
        return res;
    }
}