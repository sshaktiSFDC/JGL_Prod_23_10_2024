import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import searchCustomers from "@salesforce/apex/JgLoyaltyController.searchCustomers";
import dialogbox from 'c/jgDialogbox';

import {
    IsConsoleNavigation,
    getFocusedTabInfo,
    setTabLabel,
    openTab
} from 'lightning/platformWorkspaceApi';

export default class JustGroupCustomerSearch extends NavigationMixin(LightningElement) {
    @track customers;
    searchKey = '';
    @track alwaysOpenNewWindow;
    maxResults = 20;
    showSpinner;

    @wire(IsConsoleNavigation) isConsoleNavigation; //to determine if the current context is within a Salesforce Console app

    connectedCallback() {
        console.error('connectedCallback isConsoleNavigation: ' + this.isConsoleNavigation);

        const alwaysOpenNewWindow = localStorage.getItem('alwaysOpenNewWindow');
        if (alwaysOpenNewWindow !== null) {
            this.alwaysOpenNewWindow = JSON.parse(alwaysOpenNewWindow);
        } else {
            this.alwaysOpenNewWindow = false;
        }
    }

    get resultsFoundInfo() {
        if (this.customers) {
            if (this.customers.length >= this.maxResults) { 
                return 'Returned maximum of ' + this.maxResults + ' customers';
            } else {
                return 'Returned  ' + this.customers.length + ' customer' + (this.customers.length > 1 ? 's' : '');
            }
        }
        return 'No results found';
    }  

    handleInputChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {

        if (this.searchKey === null || this.searchKey === undefined || this.searchKey.trim() === '') {
            return;
        }

        this.showSpinner = true;
        searchCustomers({searchString: encodeURIComponent(this.searchKey)})
        .then(wrapper => {
            this.showSpinner = false;
            if (wrapper.result) {
                //console.log('searchResponse: ' + wrapper.responseJson);
                this.customers = JSON.parse(wrapper.responseJson);
            } else {
                dialogbox.open({
                    icon: 'utility:error',
                    iconName: 'APEX Error',
                    title: 'Error',
                    content : wrapper.lastError,
                    size: 'small'
                }); 
            }
        })
        .catch(error => {
            this.showSpinner = false;
            dialogbox.open({
                icon: 'utility:error',
                iconName: 'Search JavaScript Error',
                title: 'Error',
                content : error,
                size: 'small'
            }); 
        })        
    }

    getCustomerName(customer) {
        let name = "";
        if (customer.firstname) {
            name += customer.firstname.trim();
        }
        if (customer.lastname) {
            if (name) {
                name += " " + customer.lastname.trim();
            } else {
                name = customer.lastname.trim();
            }
        }
        return name; 
    }

    handleAlwaysOpenNewWindow(event) {
        this.alwaysOpenNewWindow = event.target.checked;
        // Save the state in local storage
        localStorage.setItem('alwaysOpenNewWindow', JSON.stringify(this.alwaysOpenNewWindow));
    }

    openMemberRecord(event) { 
        var customerIndex;
        var memberNumber = event.target.dataset.id;
        if (memberNumber === undefined) {
            memberNumber = event.target.parentElement.dataset.id;
            customerIndex = event.target.parentElement.dataset.index;
        } else {
            customerIndex = event.target.dataset.index;
        }

        if (!memberNumber) {
            memberNumber = 'None';
        }

        const customer = this.customers[customerIndex];
        const loyaltyMemberTabLabel = this.getCustomerName(customer);

        if (!this.isConsoleNavigation || this.alwaysOpenNewWindow) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__loyaltyMemberRecord'
                },
                state: {
                    c__customerId: customer.customerId,
                    c__email: encodeURIComponent(customer.email),
                    c__memberNumber: memberNumber
                }
            }, {
                // Specify that it should open in a console tab
                panel: 'primary',  // 'primary' for opening in a new console tab
                navigationLocation: 'RELATED_LIST'  // Can be 'RELATED_LIST' or 'SUBTAB'
            }).then(url => {
                window.open(url, "_blank");
            })
        } else {
            //Console Navigation
            openTab({
                url: '/lightning/cmp/c__loyaltyMemberRecord?c__customerId=' + customer.customerId + '&c__email=' + encodeURIComponent(customer.email) + '&c__memberNumber=' + memberNumber,
                label : loyaltyMemberTabLabel,
                icon : 'utility:lead',
                focus : true
            })
            .catch((error) =>{
                dialogbox.open({
                    icon: 'utility:error',
                    iconName: 'Open Member Console Navigation Error',
                    title: 'Error',
                    content : error,
                    size: 'small'
                });                 
            });
        }
    }

}