import { LightningElement, api, track } from 'lwc';
import LightningModal from 'lightning/modal';

export default class JgDialogbox extends LightningModal {
    @api icon;
    @api title;
    @api content;
    
    handleOkay() {
        this.close('OK');
    }

    handleCancel() {
        this.close('Cancel');
    }
}