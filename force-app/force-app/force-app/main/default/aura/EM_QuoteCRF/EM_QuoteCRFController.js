({
    saveToOrder : function(cmp, event, helper) {
        console.log('Inside Save');
        var quoteId = cmp.get("v.recordId");
        console.log('quoteId:', quoteId);
        cmp.set("v.showSpinner", true);
        var result = helper.saveOrderPDF(cmp,quoteId);
    }

})