/**
* @name         : RedeemVouchourTransactionTrigger
* @description  : This trigger is used to Handle the event for RedeemVouchourTransactionTrigger Platform Event.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-04-16      Vengad          Created
}
*/

trigger RedeemVoucherTransactionTrigger on RedeemVoucherTransaction__e (After Insert) {
new RedeemVoucherTransactionTriggerHandler().run();
}