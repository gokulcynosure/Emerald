import { wire, LightningElement, api, track } from 'lwc';
import PLACE from '@salesforce/schema/Tour_Plan__c.District__c'
import getCustomers from "@salesforce/apex/TourPlanController.getCustomers";
import getTourPlan from "@salesforce/apex/TourPlanController.getTourPlan";
import insertPlannedCustomers from "@salesforce/apex/TourPlanController.insertPlannedCustomers";
import { NavigationMixin } from 'lightning/navigation';
import searchAllCustomers from "@salesforce/apex/TourPlanController.searchAllCustomers";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class TourPlan extends NavigationMixin(LightningElement)  {
  queryTerm;
  selectedCustomers = [];
  

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
        }
    }

    objectList =[]
    error;
    @api recordId;
    @wire(getCustomers,{recordId: '$recordId'})
  wiredAccount({ error, data }) {
    if (data) {
      console.log('PLACE'+JSON.stringify(PLACE))
      //this.objectList = data;
      this.picklistInput = data
      this.convertStringToPickList();
    //   for(let x = 0; x < this.picklistInput.length; x++) {
    //     this.picklistInput[x] = {
    //       label: this.picklistInput[x],
    //       value: this.picklistInput[x]
    //     };
    // }
        this.showDropdown = false;
        var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
        var value = this.selectedValue ? (JSON.parse(JSON.stringify(this.selectedValue))) : null;
        var values = this.selectedValues ? (JSON.parse(JSON.stringify(this.selectedValues))) : null;
		if(value || values) {
            var searchString;
        	var count = 0;
            for(var i = 0; i < optionData.length; i++) {
                if(this.multiSelect) {
                    if(values.includes(optionData[i].value)) {
                        optionData[i].selected = true;
                        count++;
                    }  
                } else {
                    if(optionData[i].value == value) {
                        searchString = optionData[i].label;
                    }
                }
            }
            if(this.multiSelect)
                this.searchString = count + ' Option(s) Selected';
            else
                this.searchString = searchString;
        }
        this.value = value;
        this.values = values;
        this.optionData = optionData;
        console.log('this.options'+this.options)

      
      this.error = undefined;
    } else if (error) {
      console.log('PLACE'+JSON.stringify(PLACE))
      this.error = error;
     }
  }

  convertStringToPickList(){
    
    this.options = this.picklistInput.map(item => {
    return {
      label: item,
      value: item
    };
  })
}

  @wire(getTourPlan,{recordId: '$recordId'})
  wiredAccount1({ error, data }) {
    if (data) {
      console.log('PLACE'+JSON.stringify(PLACE))
      this.objectList = data;
      //this.picklistInput = data
      this.error = undefined;
    } else if (error) {
      console.log('PLACE'+JSON.stringify(PLACE))
      this.error = error;
    }
  }
  


  // API Variables
  @api picklistInput =  [];
  @api selectedItems = [];

  // Track Variables
  @track allValues = []; // this will store end result or selected values from picklist
  @track selectedObject = false;
  @track valuesVal = undefined;
  @track searchTerm = '';
  @track showDropdown = false;
  @track itemcounts = 'None Selected';
  @track selectionlimit = 10;
  @track showselectall = false;
  @track errors;
  @track showSuccessMessage = false;

  
  //this function is used to show the dropdown list
  get filteredResults() {
    console.log('this.objectList'+this.picklistInput)
    console.log('this.valuesVal'+this.valuesVal)
      //copying data from parent component to local variables
      if (this.valuesVal == undefined) {
          this.valuesVal = this.picklistInput;
          //below method is used to change the input which we received from parent component
          //we need input in array form, but if it's coming in JSON Object format, then we can use below piece of code to convert object to array
          Object.keys(this.valuesVal).map(profile => {
              this.allValues.push({ Id: profile, Name: this.valuesVal[profile] });
          })

          this.valuesVal = this.allValues.sort(function (a, b) { return a.Id - b.Id });
          this.allValues = [];

          console.log('da ', JSON.stringify(this.valuesVal));
      }

      if (this.valuesVal != null && this.valuesVal.length != 0) {
          if (this.valuesVal) {
              const selectedProfileNames = this.selectedItems.map(profile => profile.Name);
              console.log('selectedProfileNames ', JSON.stringify(selectedProfileNames));
              this.selectedCustomers = selectedProfileNames;
              return this.valuesVal.map(profile => {

                  //below logic is used to show check mark (✓) in dropdown checklist
                  const isChecked = selectedProfileNames.includes(profile.Id);
                  return {
                      ...profile,
                      isChecked
                  };

              }).filter(profile =>
                  profile.Id.toLowerCase().includes(this.searchTerm.toLowerCase())
              ).slice(0, 20);
          } else {
              return [];
          }
      }
  }

  //this function is used to filter/search the dropdown list based on user input
  handleSearch(event) {
    console.log('event.target.value'+event.target.value)
      this.searchTerm = event.target.value;
      this.showDropdown = true;
      this.mouse = false;
      this.focus = false;
      this.blurred = false;
      console.log('this.selectedItems'+this.selectedItems)
      if (this.selectedItems.length != 0) {
          if (this.selectedItems.length >= this.selectionlimit) {
              this.showDropdown = false;
          }
      }
  }

  //this function is used when user check/uncheck/selects (✓) an item in dropdown picklist
  handleSelection(event) {
      const selectedProfileId = event.target.value;
      const isChecked = event.target.checked;

      //if part will run if selected item is less than selection limit
      //else part will run if selected item is equal or more than selection limit
      if (this.selectedItems.length < this.selectionlimit) {

          //below logic is used to show check mark (✓) in dropdown checklist
          if (isChecked) {
              const selectedProfile = this.valuesVal.find(profile => profile.Id === selectedProfileId);
              if (selectedProfile) {
                  this.selectedItems = [...this.selectedItems, selectedProfile];
                  this.allValues.push(selectedProfileId);
              }
          } else {
              this.selectedItems = this.selectedItems.filter(profile => profile.Id !== selectedProfileId);
              this.allValues.splice(this.allValues.indexOf(selectedProfileId), 1);
          }
      } else {

          //below logic is used to when user select/checks (✓) an item in dropdown picklist
          if (isChecked) {
              this.showDropdown = false;
              this.errormessage();
          }
          else {
              this.selectedItems = this.selectedItems.filter(profile => profile.Id !== selectedProfileId);
              this.allValues.splice(this.allValues.indexOf(selectedProfileId), 1);
              this.errormessage();
          }
      }
      this.itemcounts = this.selectedItems.length > 0 ? `${this.selectedItems.length} options selected` : 'None Selected';

      if (this.itemcounts == 'None Selected') {
          this.selectedObject = false;
      } else {
          this.selectedObject = true;
      }
  }

  //custom function used to close/open dropdown picklist
  clickhandler(event) {
      this.mouse = false;
      this.showDropdown = true;
      this.clickHandle = true;
      this.showselectall = true;
  }

  //custom function used to close/open dropdown picklist
  mousehandler(event) {
      this.mouse = true;
      this.dropdownclose();
  }

  //custom function used to close/open dropdown picklist
  blurhandler(event) {
      this.blurred = true;
      this.dropdownclose();
  }

  //custom function used to close/open dropdown picklist
  focuhandler(event) {
      this.focus = true;
  }

  //custom function used to close/open dropdown picklist
  dropdownclose() {
      if (this.mouse == true && this.blurred == true && this.focus == true) {
          this.searchTerm = '';
          this.showDropdown = false;
          this.clickHandle = false;
      }
  }

  //this function is invoked when user deselect/remove (✓) items from dropdown picklist
  handleRemove(event) {
      const valueRemoved = event.target.name;
      this.selectedItems = this.selectedItems.filter(profile => profile.Id !== valueRemoved);
      this.allValues.splice(this.allValues.indexOf(valueRemoved), 1);
      this.itemcounts = this.selectedItems.length > 0 ? `${this.selectedItems.length} options selected` : 'None Selected';
      this.errormessage();

      if (this.itemcounts == 'None Selected') {
          this.selectedObject = false;
      } else {
          this.selectedObject = true;
      }
  }

  //this function is used to deselect/uncheck (✓) all of the items in dropdown picklist
  handleclearall(event) {
      event.preventDefault();
      this.showDropdown = false;
      this.selectedItems = [];
      this.allValues = [];
      this.itemcounts = 'None Selected';
      this.searchTerm = '';
      this.selectionlimit = 10;
      this.errormessage();
      this.selectedObject = false;
  }

  //this function is used to select/check (✓) all of the items in dropdown picklist
  selectall(event) {
      event.preventDefault();

      if (this.valuesVal == undefined) {
          this.valuesVal = this.picklistinput;

          //below method is used to change the input which we received from parent component
          //we need input in array form, but if it's coming in JSON Object format, then we can use below piece of code to convert object to array
          Object.keys(this.valuesVal).map(profile => {
              this.allValues.push({ Id: profile, Name: this.valuesVal[profile] });
          })

          this.valuesVal = this.allValues.sort(function (a, b) { return a.Id - b.Id });
          this.allValues = [];
      }
      this.selectedItems = this.valuesVal;
      this.itemcounts = this.selectedItems.length + ' options selected';
      this.selectionlimit = this.selectedItems.length + 1;
      this.allValues = [];
      this.valuesVal.map((value) => {
          for (let property in value) {
              if (property == 'Id') {
                  this.allValues.push(`${value[property]}`);
              }
          }
      });
      console.log('value of this.allValues ', JSON.stringify(this.allValues));
      this.errormessage();
      this.selectedObject = true;
  }

  //this function is used to show the custom error message when user is trying to select picklist items more than selectionlimit passed by parent component  
  errormessage() {
      this.errors = {
          "Search Objects": "Maximum of " + this.selectionlimit + " items can be selected",
      };
      this.template.querySelectorAll("lightning-input").forEach(item => {
          let label = item.label;
          if (label == 'Search Objects') {

              // if selected items list crosses selection limit, it will through custom error
              if (this.selectedItems.length >= this.selectionlimit) {
                  item.setCustomValidity(this.errors[label]);
              } else {
                  //else part will clear the error
                  item.setCustomValidity("");
              }
              item.reportValidity();
          }
      });
  }
  

//   handleSaveObj(){
//     console.log('this.editObj'+JSON.stringify(this.editObj))
//         updateObjectSelection({id : this.editObj.id, name : this.editObj.name, isSelected : this.editObj.isSelected, apiName : this.editObj.apiName, order : this.editObj.order})
//         .then(result => {
                
            
//         })
//         .catch(error => {
//             // Handle error response
//             console.log('Error : ' + JSON.stringify(error));
//         });
// }

handleSave(){
  const checkedValues = [];
  console.log('selectedValues'+this.optionData)
  for (let i = 0; i < this.optionData.length; i++) {
    if (this.optionData[i].selected) {
      checkedValues.push(this.options[i].value);
    }
  }

  console.log('checkedValues'+checkedValues);
  insertPlannedCustomers({accountNames :checkedValues,recordId:this.recordId})
  .then((result) => {
              
       console.log('accountNames.length()'+result)         
    this.dispatchEvent(new ShowToastEvent({
        title: 'Success!!',
            message:  result+ ' records created',
                variant: 'success'
                    }));
    //this.showSuccessMessage = true;

    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
          attributes: {
              recordId: this.recordId,
                  actionName: 'view'
                      }
  });
    console.log('Ok'+Ok)
}).catch((error) => {
  console.log('Error'+JSON.stringify(error))
});
}

// handleinputSearch(event){
//   console.log('event.target.value'+event.target.value)
//   searchAllCustomers({searchString :event.target.value,recordId:this.recordId})
//   .then((result) => {
//     console.log('result'+result)
//     this.picklistInput = result;
// }).catch((error) => {
//   console.log('Error'+JSON.stringify(error))
// });
// }


@api options ;
    @api selectedValue;
    @api selectedValues = [];
    @api label;
    @api minChar = 2;
    @api disabled = false;
     multiSelect = true;
    @track value;
    @track values = [];
    @track optionData;
    @track searchString;
    @track message;
    @track showDropdown = false;
 
    //  connectedCallback() {
    //     console.log('this.recordId'+this.recordId)
    //     getCustomers({recordId: 'a0D1e000002EIZzEAO'})
    //     .then(result => {
    //         if (result) {
    //             this.picklistInput = result
    //             this.options = this.picklistInput.map(item => {
    //               return {
    //                 label: item,
    //                 value: item
    //               };
    //               console.log('this.options'+this.options)
    //             });
    //             this.showDropdown = false;
    //     var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
    //     var value = this.selectedValue ? (JSON.parse(JSON.stringify(this.selectedValue))) : null;
    //     var values = this.selectedValues ? (JSON.parse(JSON.stringify(this.selectedValues))) : null;
	// 	if(value || values) {
    //         var searchString;
    //     	var count = 0;
    //         for(var i = 0; i < optionData.length; i++) {
    //             if(this.multiSelect) {
    //                 if(values.includes(optionData[i].value)) {
    //                     optionData[i].selected = true;
    //                     count++;
    //                 }  
    //             } else {
    //                 if(optionData[i].value == value) {
    //                     searchString = optionData[i].label;
    //                 }
    //             }
    //         }
    //         if(this.multiSelect)
    //             this.searchString = count + ' Option(s) Selected';
    //         else
    //             this.searchString = searchString;
    //     }
    //     this.value = value;
    //     this.values = values;
    //     this.optionData = optionData;
                
    //           } 
            
    //     })
    //     .catch(error => {
    //         // Handle error response
    //         console.log('Error : ' + JSON.stringify(error));
    //     });
        
    // }
 
    filterOptions(event) {
        this.searchString = event.target.value;
        if( this.searchString && this.searchString.length > 0 ) {
            this.message = '';
            if(this.searchString.length >= this.minChar) {
                var flag = true;
                for(var i = 0; i < this.optionData.length; i++) {
                    if(this.optionData[i].label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
                        this.optionData[i].isVisible = true;
                        flag = false;
                    } else {
                        this.optionData[i].isVisible = false;
                    }
                }
                if(flag) {
                    this.message = "No results found for '" + this.searchString + "'";
                }
            }
            this.showDropdown = true;
        } else {
            this.showDropdown = false;
        }
	}
 
    selectItem(event) {
        var selectedVal = event.currentTarget.dataset.id;
        if(selectedVal) {
            var count = 0;
            var options = JSON.parse(JSON.stringify(this.optionData));
            for(var i = 0; i < options.length; i++) {
                if(options[i].value === selectedVal) {
                    if(this.multiSelect) {
                        if(this.values.includes(options[i].value)) {
                            this.values.splice(this.values.indexOf(options[i].value), 1);
                        } else {
                            this.values.push(options[i].value);
                        }
                        options[i].selected = options[i].selected ? false : true;   
                    } else {
                        this.value = options[i].value;
                        this.searchString = options[i].label;
                    }
                }
                if(options[i].selected) {
                    count++;
                }
            }
            this.optionData = options;
            if(this.multiSelect)
                this.searchString = count + ' Option(s) Selected';
            if(this.multiSelect)
                event.preventDefault();
            else
                this.showDropdown = false;
        }
    }
 
    showOptions() {
        if(this.disabled == false && this.options) {
            this.message = '';
            this.searchString = '';
            var options = JSON.parse(JSON.stringify(this.optionData));
            for(var i = 0; i < options.length; i++) {
                options[i].isVisible = true;
            }
            if(options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
	}
 
    removePill(event) {
        var value = event.currentTarget.name;
        var count = 0;
        var options = JSON.parse(JSON.stringify(this.optionData));
        for(var i = 0; i < options.length; i++) {
            if(options[i].value === value) {
                options[i].selected = false;
                this.values.splice(this.values.indexOf(options[i].value), 1);
            }
            if(options[i].selected) {
                count++;
            }
        }
        this.optionData = options;
        if(this.multiSelect)
            this.searchString = count + ' Option(s) Selected';
    }
 
    blurEvent() {
        var previousLabel;
        var count = 0;
        for(var i = 0; i < this.optionData.length; i++) {
            if(this.optionData[i].value === this.value) {
                previousLabel = this.optionData[i].label;
            }
            if(this.optionData[i].selected) {
                count++;
            }
        }
        if(this.multiSelect)
        	this.searchString = count + ' Option(s) Selected';
        else
        	this.searchString = previousLabel;
        
        this.showDropdown = false;
 
        this.dispatchEvent(new CustomEvent('select', {
            detail: {
                'payloadType' : 'multi-select',
                'payload' : {
                    'value' : this.value,
                    'values' : this.values
                }
            }
        }));
    }


  
}