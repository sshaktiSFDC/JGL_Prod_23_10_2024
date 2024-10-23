import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import updateLoyaltyMember from '@salesforce/apex/JgLoyaltyController.updateLoyaltyMember';
import getCustomer from '@salesforce/apex/JgLoyaltyController.getCustomer';
import updateCustomer from '@salesforce/apex/JgLoyaltyController.updateCustomer';
import getCurrentSalesforceUserAlias from '@salesforce/apex/JgLoyaltyController.getCurrentSalesforceUserAlias';
import getSalesforceLoyaltyMember from '@salesforce/apex/JgLoyaltyController.getSalesforceLoyaltyMember';
import dialogbox from 'c/jgDialogbox';

import {
    IsConsoleNavigation,
    getFocusedTabInfo,
    setTabLabel,
    setTabIcon,
    openTab
} from 'lightning/platformWorkspaceApi';

export default class LoyaltyMemberRecord extends NavigationMixin(LightningElement) {
    @track memberNumber;
    @track email;
    @track customerId;
    @track loyaltyMember;
    @track salesforceLoyaltyMember;
    @track customer;
    @track subscriptions;
    @track anyChanges;
    @track emailChanged;
    
    @track showSpinner;

    updatedLoyaltyMember;
    updatedCustomer;

    @track countryOptions;
    @track salesforceUserAlias;

    australianStateOptions = [
        { label: 'Australian Capital Territory', value: 'ACT' },
        { label: 'New South Wales', value: 'NSW' },
        { label: 'Northern Territory', value: 'NT' },
        { label: 'Queensland', value: 'QLD' },
        { label: 'South Australia', value: 'SA' },
        { label: 'Tasmania', value: 'TAS' },
        { label: 'Victoria', value: 'VIC' },
        { label: 'Western Australia', value: 'WA' }
    ];

    brandOptions = [
        { label: 'Dotti Australia', value: 'DT' },
        { label: 'Dotti NZ', value: 'DTNZ' },
        { label: 'Jacqui E Australia', value: 'EJ' },
        { label: 'Jacqui E New Zealand', value: 'EJNZ' },
        { label: 'Just Jeans Australia', value: 'JJ' },
        { label: 'Just Jeans New Zealand', value: 'JJNZ' },
        { label: 'Jay Jays Australia', value: 'MJ' },
        { label: 'Jay Jays New Zealand', value: 'MJNZ' },
        { label: 'Peter Alexander', value: 'PJ' },
        { label: 'Peter Alexander New Zealand', value: 'PJNZ' },
        { label: 'Portmans Australia', value: 'RJ' },
        { label: 'Portmans New Zealand', value: 'RJNZ' },
        { label: 'Smiggle', value: 'SM' },
        { label: 'Smiggle NEW ZEALAND', value: 'SMNZ' }
    ];

    subscriptionNames = ['Dotti', 'Portmans', 'Peter Alexander', 'JacquiE', 'JayJays', 'JustJeans', 'Smiggle'];

    error; 

    get isCountryAustralia() {
        if (!this.customer) {
            return false;
        }
        return this.customer.country == 'AU';
    }
    
    @wire(IsConsoleNavigation) isConsoleNavigation;
    
    @wire(getCurrentSalesforceUserAlias)
    wiredAlias({ error, data }) {
        if (data) {
            this.salesforceUserAlias = data;
        } else if (error) {
            console.error('Error fetching user alias:', error);
        }
    }

    @wire(CurrentPageReference)
    getPageReference(currentPageReference) {
        if (currentPageReference) {
            this.customerId = currentPageReference.state.c__customerId;
            this.email = decodeURIComponent(currentPageReference.state.c__email);
            this.memberNumber = currentPageReference.state.c__memberNumber;
            this.loadCustomer(); 
        }
    } 

    connectedCallback() {
       
    }

    get isAU() {
        return (this.customer && this.customer.country === 'AU');
    }

    get isNZ() {
        return (this.customer && this.customer.country === 'NZ');
    }    

    get isAUorNZ() {
        if (this.customer) {
            return this.customer.country === 'AU' || this.customer.country === 'NZ';
        } 
        return false;
    }

    get isLoyaltyMember() {
        return this.memberNumber != 'None' && this.memberNumber != '' && this.memberNumber != null;
    }

    validateFields() {
        const allInputs = this.template.querySelectorAll('lightning-input');
        let isValid = true;
        allInputs.forEach(input => {
            // Check if the field is valid
            if (!input.reportValidity()) {
                isValid = false;
            }
        });
        return isValid;
    }

    updateQueryParamsEmail(newEmail) {
        //Get the current URL
        const currentUrl = new URL(window.location);

        //Use URLSearchParams to get and modify query parameters
        const params = new URLSearchParams(currentUrl.search);

        //Set or update a query parameter. Update 'c__email'
        params.set('c__email', encodeURIComponent(newEmail));

        //Construct the new URL
        const newUrl = `${currentUrl.pathname}?${params.toString()}`;

        //Use history.pushState to update the URL without reloading the page
        window.history.pushState({}, '', newUrl);
    }

    getSubscriptions(currentSubscriptions) {
        //Gets all subscription objects including allowEmail = false
        let subscriptions = [];
        this.subscriptionNames.forEach(name => {
            if (currentSubscriptions) {
                const subsItem = currentSubscriptions.find(subscriptionItem => subscriptionItem.subscription === name);
                if (subsItem) {
                    subscriptions.push(subsItem);
                } else {
                    subscriptions.push( {subscription: name, allowEmail: false} );
                }
            } else {
                subscriptions.push( {subscription: name, allowEmail: false} );
            }
        })
        return subscriptions;
    }

    getCustomerName(customer) {
        //Not sure if this is required. Check
        if (customer) {
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
        } else {
            return 'customer';
        }
    }  

    getJustGroupError(wrapper) {
        if (wrapper && wrapper.statusCode >= 400) {
            let errorString = "";
            if (wrapper.responseJson) {
                let response = JSON.parse(wrapper.responseJson);
                response.errors.forEach(error => {
                    errorString += ((errorString ? " " : "") + error.message);
                });
                return errorString;
            } else {
                return wrapper.lastError;
            }
        } else {
            return wrapper.lastError;
        }
    }

    getSalesforceLoyaltyProgramMember(memberNumber) {
        this.salesforceLoyaltyMember = undefined;
        if (!memberNumber) {
            return;
        }
        getSalesforceLoyaltyMember({memberNumber: memberNumber})
        .then(wrapper => { 
            if (wrapper.result) {
                //console.log('salesforceLoyaltyMember: ' + wrapper.responseJson);
                this.salesforceLoyaltyMember = JSON.parse(wrapper.responseJson);
            } else {
                dialogbox.open({
                    icon: 'utility:error',
                    iconName: 'Error',
                    title: 'APEX Error',
                    content : this.getJustGroupError(wrapper),
                    size: 'small'
                }); 
            }
        })
        .catch(error => {
            this.showSpinner = false;
            dialogbox.open({
                icon: 'utility:error',
                iconName: 'Error',
                title: 'Get Salesforce Loyalty Program Member JavaScript Error',
                content : error,
                size: 'small'
            });                     
        });
    }

    openLoyaltyMemberAccountView(event) {
        event.preventDefault();        
        if (this.salesforceLoyaltyMember && this.salesforceLoyaltyMember.Contact) {
            if (!this.isConsoleNavigation) {
                //Standard Navigation
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'Account',
                        recordId: this.salesforceLoyaltyMember.Contact.AccountId
                    },
                }).then(url => {
                    // Open the URL in a new window
                    window.open(url, '_blank');
                }).catch(error => {
                    alert('Standard Navigation Error:' + error);
                });
            } else {
                //Console Navigation
                openTab({
                    //url: '/lightning/r/Account/' + this.salesforceLoyaltyMember.Contact.AccountId + '/view',
                    recordId: this.salesforceLoyaltyMember.Contact.AccountId,
                    icon: 'standard:account',
                    focus: true,
                    label: this.getCustomerName(this.customer)
                })
                .catch((error) =>{
                    alert('Console Navigation Error:' + error);
                });
            }
        }
    }

    loadCustomer() {
        this.showSpinner = true;
        getCustomer({email: encodeURIComponent(this.email), getLoyalty: this.isLoyaltyMember})
        .then(wrapper => {
            this.showSpinner = false;
            if (wrapper.result) {

                this.clearChanges();

                this.fetchCountries();

                //console.log('...loadCustomer');
                //console.log('ApiCustomer: ' + wrapper.responseJson);

                this.customer = JSON.parse(wrapper.responseJson);

                this.customer.subscriptions = this.getSubscriptions(this.customer.subscriptions);
                this.subscriptions = this.customer.subscriptions;

                if (this.customer.loyaltyPrograms && this.customer.loyaltyPrograms.length > 0) {
                    this.loyaltyMember = this.customer.loyaltyPrograms[0];
                    this.loyaltyMember.enrolmentBrandName = '';
                    const enrolmentBrand = this.loyaltyMember.attributes.find(attr => attr.name === "enrolmentBrand");
                    if (enrolmentBrand) {
                        const brandOption = this.brandOptions.find(brandOption => brandOption.value === enrolmentBrand.value);
                        if (brandOption) {
                            this.loyaltyMember.enrolmentBrandName = brandOption.label;
                        }
                    }
                    this.getSalesforceLoyaltyProgramMember(this.loyaltyMember.memberNumber);
                }

                setTimeout(() => {
                    //Add a small delay 0.1 secs
                    this.validateFields(); 
                }, 100)                            

                if (this.isConsoleNavigation) {
                    const tabLabel = this.getCustomerName(this.customer); 
                    getFocusedTabInfo()
                    .then(({ tabId }) => {
                        if (tabId) {
                            setTabLabel(tabId, tabLabel)
                            .then(tabInfo => {
                                if (tabInfo) {
                                    //setTabIcon({
                                    //   tabId: tabInfo.tabId,
                                    //    icon: 'utility:lead',
                                    //    iconAlt: tabLabel
                                    //})
                                }
                            });

                        }
                    })
                    .catch(error => {
                        //Minor error
                        console.log('Console Navigation Tab Error: ' + error);
                    });
                }  

            } else {
                dialogbox.open({
                    icon: 'utility:error',
                    iconName: 'Error',
                    title: 'APEX Error',
                    content : this.getJustGroupError(wrapper),
                    size: 'small'
                }); 
            }
        })
        .catch(error => {
            this.showSpinner = false;
            dialogbox.open({
                icon: 'utility:error',
                iconName: 'Error',
                title: 'Get Customer JavaScript Error',
                content : error,
                size: 'small'
            });                     
        });
    }

    clearChanges() {
        this.anyChanges = false;
        this.updatedLoyaltyMember = undefined;
        this.updatedCustomer = undefined;
    }

    checkAnyChanges() {
        this.anyChanges = !(this.updatedLoyaltyMember === undefined && this.updatedCustomer === undefined);
    }

    handleSubscriptionFieldChange(event) {

        //Subscription information is saved in the customer record in this.customer.subscriptions

        if (!this.updatedCustomer) {
            this.updatedCustomer = {email: this.customer.email, customerId: this.customer.customerId };
        }

        const index = event.currentTarget.dataset.index;
        const updatedSubscription = this.customer.subscriptions[index];
        updatedSubscription.allowEmail = event.target.checked;

        if (!this.updatedCustomer.subscriptions) {
            this.updatedCustomer.subscriptions = [];
        }

        const foundIndex = this.updatedCustomer.subscriptions.findIndex(subsItem => subsItem.subscription === updatedSubscription.subscription);
        if (foundIndex > -1) {
            this.updatedCustomer.subscriptions[foundIndex] = updatedSubscription;
        } else {            

            this.updatedCustomer.subscriptions.push(updatedSubscription);
        }

        this.anyChanges = true;

    }

    createUpdatedLoyaltyMemberIfChanges() {
        if (this.updatedLoyaltyMember === undefined) {
            this.updatedLoyaltyMember = {
                loyaltyProgram: this.loyaltyMember.loyaltyProgram, 
                memberNumber: this.loyaltyMember.memberNumber,
                lastname: this.customer.lastname
            };
        }
    }

    handleCustomerFieldChange(event) {
        const { name, value } = event.target;
        if (this.updatedCustomer === undefined) {
            this.updatedCustomer = {email: this.customer.email, customerId: this.customer.customerId};
        }       
        this.updatedCustomer[name] = value;
        this.customer[name] = value;
        this.anyChanges = true;
        if (name === 'country') {
            //Want to display any issues. Need to be delayed to ensure the field has been updated
            setTimeout(() => {
                this.validateFields();
            }, 200); // 2000 milliseconds = 2 seconds
        } else if (name === 'email') {
            //We need to track and reload page with new URL after Save
            this.emailChanged = true;
        }

    }

    handleLoyaltyPreferencesFieldChange(event) {
        this.createUpdatedLoyaltyMemberIfChanges();
        this.loyaltyMember.preferences[event.target.name] = event.target.checked;
        this.updatedLoyaltyMember.preferences = this.loyaltyMember.preferences;
        this.anyChanges = true;
    }

    handleSave() {

        if (!this.validateFields()) return;

        if (this.updatedCustomer && this.updatedLoyaltyMember) {
            //We need to update both but one at a time so we can neatly handle any vaildation or server errors
            this.saveLoyaltyMember(() => {
                //Only update the customer if the loyalty member was updated successfully
                this.saveCustomer();
            });
        } else {
            //Only one of the above is defined
            this.saveCustomer();
            this.saveLoyaltyMember();
        }
    }

    saveLoyaltyMember(onSuccessFunc) {

        if (this.updatedLoyaltyMember) {

            if ((this.updatedLoyaltyMember.country && this.updatedLoyaltyMember.country != 'AU') || this.customer.country != 'AU') {
                this.updatedLoyaltyMember.state = undefined;
            }
            this.showSpinner = true;

            if (this.salesforceUserAlias) {
                this.updatedLoyaltyMember.updateBy = this.salesforceUserAlias;
            } 

            updateLoyaltyMember({memberNumber: this.memberNumber, payload: JSON.stringify(this.updatedLoyaltyMember)})
            .then(wrapper => { 
                this.showSpinner = false;

                if (wrapper.result) {
                    this.updatedLoyaltyMember = undefined;
                    this.checkAnyChanges(); //Updates the "Any Changes" flag

                    if (onSuccessFunc) {
                        onSuccessFunc();
                    }                    
                } else {
                    dialogbox.open({
                        icon: 'utility:error',
                        iconName: 'Error',
                        title: 'Loyalty Member Error',
                        content : this.getJustGroupError(wrapper),
                        size: 'small'
                    });   
                }
            })
            .catch(error => {
                this.showSpinner = false;
                dialogbox.open({
                    icon: 'utility:error',
                    iconName: 'Error',
                    title: 'Get Loyalty Member JavaScript Error',
                    content : JSON.stringify(error),
                    size: 'small'
                });                 
            })
        }
    }

    saveCustomer(onSuccessFunc) {
        if (this.updatedCustomer) {
            this.showSpinner = true;
            if (this.salesforceUserAlias) {
                this.updatedCustomer.updateBy = this.salesforceUserAlias;
            }            
            updateCustomer({payload: JSON.stringify(this.updatedCustomer)})
            .then(wrapper => { 
                this.showSpinner = false;
                if (wrapper.result) {
                    this.updatedCustomer = undefined;
                    this.checkAnyChanges(); //Updates the "Any Changes" flag   
                    
                    if (this.emailChanged) {
                        //Only used in saveCustomer
                        this.emailChanged = false;
                        this.updateQueryParamsEmail(this.customer.email);
                        this.email = this.customer.email;
                    }
                    
                    //if (onSuccessFunc) {
                    //    onSuccessFunc();
                    //}
                } else {
                    dialogbox.open({
                        icon: 'utility:error',
                        iconName: 'Error',
                        title: 'Customer Error',
                        content : this.getJustGroupError(wrapper),
                        size: 'small'
                    });                     
                }
            })
            .catch(error => {
                this.showSpinner = false;
                dialogbox.open({
                    icon: 'utility:error',
                    iconName: 'Error',
                    title: 'Update Customer JavaScript Error',
                    content : JSON.stringify(error),
                    size: 'small'
                });                 
            })
        }
    }

    handleRefresh(event) {
        if (this.anyChanges) {
            alert("You have unsaved changes. Please 'Discard Changes' or 'Save' before refreshing");   
        } else {
            this.loadCustomer();
        }
    }    

    handleDiscardChanges(event) {        
        this.loadCustomer();
    }  
    
    // Method to fetch countries
    fetchCountries() {
        // Check if countryOptions is already loaded
        if (this.countryOptions) {
            // Already loaded
            return;
        }
    
        // URL for REST Countries API
        const url = 'https://restcountries.com/v3.1/all';
        const cacheKey = 'countriesData';
        const cacheTimestampKey = 'countriesDataTimestamp';
        const cacheDuration = 7 * 24 * 60 * 60 * 1000; // 1 week in milliseconds
    
        // Helper function to fetch and store data
        const fetchAndStoreData = () => {
            fetch(url)
            .then((response) => {
                if (!response.ok) {
                    throw new Error('Network response was not ok while retrieving countries');
                }
                return response.json();
            })
            .then((data) => {
                // Extract country name and code
                this.countryOptions = data.map((country) => ({
                    label: country.name.common,  // Get the common name of the country
                    value: country.cca2          // Get the 2-letter country code (ISO 3166-1 alpha-2)
                }))
                .sort((a, b) => {
                    // Sort by label (country name) alphabetically
                    return a.label.localeCompare(b.label);
                });
                
                // Store data and timestamp in local storage
                localStorage.setItem(cacheKey, JSON.stringify(this.countryOptions));
                localStorage.setItem(cacheTimestampKey, Date.now().toString());
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error.message;
                alert(error.message);
                this.countryOptions = JSON.parse(localStorage.getItem(cacheKey)) || [];
            });
        };
    
        // Check if cached data exists and is valid
        const cachedData = localStorage.getItem(cacheKey);
        const cacheTimestamp = localStorage.getItem(cacheTimestampKey);
    
        if (cachedData && cacheTimestamp) {
            const isCacheValid = Date.now() - parseInt(cacheTimestamp, 10) < cacheDuration;
            
            if (isCacheValid) {
                this.countryOptions = JSON.parse(cachedData);
                //console.log('Using cached data:', JSON.stringify(this.countryOptions));
                return;
            }
        }
        
        // If no valid cache or cache is expired, fetch new data
        fetchAndStoreData();
    }

    handleViewUpdates() {
        let displayData = '';
        if (this.updatedLoyaltyMember) {
            displayData += 'Loyalty CHANGES:\n' + JSON.stringify(this.updatedLoyaltyMember);
        }
        if (this.updatedCustomer) {
            displayData += '\n\nCustomer CHANGES:\n' + JSON.stringify(this.updatedCustomer);
        }
        if (displayData != '') {
            alert(displayData);
        } else {
            alert('No updates');
        }
    }
    
}