({
    saveOrderPDF : function(component,quoteId) {
        var action = component.get("c.saveCRFPDF");
        
        action.setParams({
            quoteId: quoteId
        });
        
        console.log('quoteId:', JSON.stringify(action));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                console.log('inside success');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "CRF Pdf Saved.",
                    "type": "success"
                });
                toastEvent.fire();
                var navService = component.find("navService");
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: quoteId,
                        actionName: 'view'
                    }
                };
                navService.navigate(pageReference);
            }
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Some error occurred. Please contact your system administrator.",
                    "type": "error"
                });
                toastEvent.fire();
                console.log("Error creating attachment: " + response.getError());
            }
        });
        $A.enqueueAction(action);
        return true;
    }
})