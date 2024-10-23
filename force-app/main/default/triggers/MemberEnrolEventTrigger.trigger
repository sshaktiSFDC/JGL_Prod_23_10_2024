/**
* @name         : MemberEnrolEventTrigger
* @description  : This trigger is used to handle logic for Member Enrol to create Event platform event.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-09-19    Nicholas Then     Created
* 
*/


trigger MemberEnrolEventTrigger on Member_Enrol_Event__e (after insert) {
      new MemberEnrolEventTriggerHandler().run();
}