({
    loadFields : function(component, event, helper) {

        let recordId = component.get("v.recordId");
        let action = component.get("c.getFields");

        action.setParam("recordId", recordId);

        action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === 'SUCCESS'){
                let responseObject = JSON.parse(response.getReturnValue());
                component.set("v.options", responseObject);
            } else {
                console.log('Response state: ' + response.getState());
            }
        });

        $A.enqueueAction(action);
    },


    getHistory : function(component, event, helper) {
        component.set('v.historycolumns', [
            {label: '№ ', fieldName: 'position', type: 'number', initialWidth: 30},
            {label: 'Modified Date', fieldName: 'createdDate', type: 'Date', initialWidth: 160},
            {label: 'Field Name', fieldName: 'fieldName', type: 'text'},
            {label: 'Old Value', fieldName: 'oldValue', type: 'text'},
            {label: 'New Value', fieldName: 'newValue', type: 'text'},
            {label: 'Who Changed', fieldName: 'who', type: 'text'}
        ]);
        
        let fieldName = component.find('select').get("v.value");
        if (fieldName !== 'chooseOne') {
            let recordId = component.get("v.recordId");

            let action = component.get("c.getHistoryForRecord");
            action.setParams({
                "recordId" : recordId,
                "fieldName" : fieldName
            });

            action.setCallback(this, function(response) {
                let state = response.getState();

                if(state === 'SUCCESS'){
                    let responseObject = JSON.parse(response.getReturnValue());
                    component.set("v.history", responseObject);
                } else {
                    component.set("v.history", {});
                }
            });

            $A.enqueueAction(action);
        } else {
            component.set("v.history", {});
        }
    }
})
