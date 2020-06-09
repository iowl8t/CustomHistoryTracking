import { LightningElement, wire, track, api } from 'lwc';
import getFields from '@salesforce/apex/HistoryController.getFields';
import getHistoryForRecord from '@salesforce/apex/HistoryController.getHistoryForRecord';

const columns = [
    {label: '№ ', fieldName: 'position', type: 'number', initialWidth: 30},
    {label: 'Modified Date', fieldName: 'createdDate', type: 'Date', initialWidth: 160},
    {label: 'Field Name', fieldName: 'fieldName', type: 'text'},
    {label: 'Old Value', fieldName: 'oldValue', type: 'text'},
    {label: 'New Value', fieldName: 'newValue', type: 'text'},
    {label: 'Who Changed', fieldName: 'who', type: 'text'}
];


export default class History extends LightningElement {

    @api recordId;
    @track selectedField;
    @track fieldOptions;
    @track historyList;
    @track error;
    columns = columns;

    @wire(getFields, { sObjId: '$recordId' })
    getFields({data,error}) {
        console.log('In getFields: ');
        console.log('data: ' + data);
        console.log('error: ' + error);
        
        if(data) {
            this.fieldOptions = JSON.parse(data);
            this.fieldOptions.unshift( { label: 'All Fields', value: '' } );
        } else {
            this.fieldOptions = null;
        }
    }

    handleSelected(event) {
        console.log('event.detail.value: ' + event.detail.value);
        console.log('event.target.value: ' + event.target.value);
        this.selectedField = event.detail.value;
        console.log('this.selectedField: ' + this.selectedField);
        console.log('recordID: ' + this.recordId);

        if (this.selectedField !== null) {
            let tempId = this.recordId;
            console.log('In   ---   this.selectedField !== null: ' + this.selectedField !== null);
            getHistoryForRecord ( { sObjId: tempId, fieldName: this.selectedField } ) // why do not work when '$recordId' as firsp parameter
                .then(result => {
                    let parsedResult = JSON.parse(result);
                    console.log('result: ' + result);
                    this.historyList = parsedResult;
                })
                .catch(error => {
                    this.error = error;
                });
            }
        }
}