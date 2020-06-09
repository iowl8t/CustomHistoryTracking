import { LightningElement, wire } from 'lwc';

import Id from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import NAME_FIELD from '@salesforce/schema/User.Name';

export default class Selector extends LightningElement {
    selectedProductId;

    handleProductSelected(evt) {
        this.selectedProductId = evt.detail;
    }

    userId = Id;

    @wire(getRecord, { recordId: '$userId', fields: [ NAME_FIELD ]})
    user;
    

    get name() {
        return getFieldValue(this.user.data, NAME_FIELD);
    }

}
