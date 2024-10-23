/**
* @name         : MemberUpdateEventTrigger
* @description  : This trigger is used to handle logic for Member Enrol to create Event platform event.
* <Date>        <Modified By>       <Brief Description of Change>
* 2024-10-21    Nicholas Then     Created
* 
*/


trigger MemberUpdateEventTrigger on Member_Update_Event__e (after insert) {
				new MemberUpdateEventTriggerHandler().run();
}