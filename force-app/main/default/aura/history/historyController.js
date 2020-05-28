({
    getHistory : function(component, event, helper) {
        component.set('v.historycolumns', [
            {label: '№ ', fieldName: 'position', type: 'number', initialWidth: 30},
            {label: 'Modified Date', fieldName: 'createdDate', type: 'Date', initialWidth: 160},
            {label: 'Field Name', fieldName: 'fieldName', type: 'text'},
            {label: 'Old Value', fieldName: 'oldValue', type: 'text'},
            {label: 'New Value', fieldName: 'newValue', type: 'text'},
            {label: 'Who Changed', fieldName: 'who', type: 'text'}
        ]);
        
        var recordId = component.get("v.recordId");

        var action = component.get("c.getHistoryForRecord");
        action.setParam("recordId", recordId);

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === 'SUCCESS'){
                var responseObject = JSON.parse(response.getReturnValue());
                component.set("v.history", responseObject);
            } else {
                console.log('Response state: ' + response.getState());
            }
        });

        $A.enqueueAction(action);
    }
})
