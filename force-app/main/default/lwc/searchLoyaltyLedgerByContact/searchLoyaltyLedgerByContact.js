import { LightningElement, api, wire } from 'lwc';
import Toast from 'lightning/toast';

import getContactId from '@salesforce/apex/SearchLoyaltyLedgerByContactController.getContactId';
import fetchMembershipDetails from '@salesforce/apex/SearchLoyaltyLedgerByContactController.fetchMembershipDetails';
import searchLoyaltyLedger from '@salesforce/apex/SearchLoyaltyLedgerByContactController.searchLoyaltyLedger';

export default class SearchLoyaltyLedgerByContact extends LightningElement {
    @api recordId;
    personContactId
    isDataLoading = false;
    isMembershipDetailsLoading = false;
    tableData = []

    columns = [
        { label: 'Journal', fieldName: 'transactionJournalLink', type: 'url', typeAttributes: {label: {fieldName: 'journalNumber'}}, wrapText:true, initialWidth: 100 },
        { label: 'Order Number', fieldName: 'orderNumber', type: 'text', wrapText:true, initialWidth: 150 },
        { label: 'Receipt No', fieldName: 'receiptNo', type: 'text', wrapText:true, initialWidth: 150 },
        { label: 'Order Item', fieldName: 'orderItem', type: 'text', wrapText:true, initialWidth: 120 },
        { label: 'Order Date', fieldName: 'orderDate', type: 'date', wrapText:true, initialWidth: 120 },
        { label: 'Brand', fieldName: 'brand', type: 'text', wrapText:true, initialWidth: 150 },
        { label: 'Store Location', fieldName: 'store', type: 'text', wrapText:true, initialWidth: 150 },
        { label: 'Product Description', fieldName: 'productDescription', type: 'text', wrapText:true, initialWidth: 180 },
        { label: 'Qty', fieldName: 'quantity', type: 'number', wrapText:true, initialWidth: 80 },
        { label: 'Amount', fieldName: 'amount', type: 'currency', wrapText:true, initialWidth: 100 },
        { label: 'Points', fieldName: 'points', type: 'text', wrapText:true, initialWidth: 100 },
        { label: 'Transaction Type', fieldName: 'type', type: 'text', wrapText:true, initialWidth: 180 }
    ];  
    
    membershipDetailModel = {
        membershipNumber: undefined,
        totalRewards: undefined,
        pointsBalance: undefined
    }

    formModel = {
        // fromDate: {label: 'From', value: undefined}}
        fromDate: undefined,
        toDate: undefined,
        orderNumber: undefined,
        receiptNo: undefined
    }

    async connectedCallback() {
        console.log('connected callback called');
        this.isMembershipDetailsLoading = true;
        try {
            const contactId = await getContactId({sObjectRecordId: this.recordId});
            console.log('contactId', contactId);

            if (contactId) {
                this.personContactId = contactId;

                const membershipDetails = await fetchMembershipDetails({contactId: this.personContactId});
                console.log('membershipDetails', membershipDetails);

                if (membershipDetails) {
                    this.membershipDetailModel = {
                        membershipNumber: membershipDetails[0].MembershipNumber,
                        totalRewards: (membershipDetails[0].Total_Rewards__c) ? ('$' + membershipDetails[0].Total_Rewards__c) : undefined,
                        pointsBalance: (membershipDetails[0].Loyalty_Member_Currency) ? membershipDetails[0].Loyalty_Member_Currency[0].PointsBalance : undefined
                    }
                }
                console.log('this.membershipDetailModel', this.membershipDetailModel);
            }
        } catch (error) {
            console.error(error);
            this.showToast('Error', error.message, 'error')
        } finally {
            this.isMembershipDetailsLoading = false;
        }
    }

    handleFieldChange(event) {
        const {name, value} = event.target;
        this.formModel[name] = value;
        console.log(name, this.formModel[name]);
    }

    checkDataValidation() {
        const {fromDate, toDate, orderNumber} = this.formModel;
        let isvalid = true;

        console.log('Check Data Validation', 'isValid', isvalid);
        // if ((fromDate || toDate) && orderNumber) {
        //     console.log('Please provide either "From Date" and "To Date" OR Order Number', fromDate, toDate, orderNumber);
        //     this.showToast('Validation Error', 'Please provide either "From Date" and "To Date" OR Order Number', 'error');
        //     isvalid = false;
        // } else 
        if ((fromDate && !toDate) || (!fromDate && toDate)) {
            console.log('Please provide both "From Date" and "To Date"', fromDate, toDate, orderNumber);
            this.showToast('Validation Error', 'Please provide both "From Date" and "To Date"', 'error');
            isvalid = false;
        }
        
        return isvalid;
    }

    async handleSearchLoyaltyLedgerRecords() {
        const {fromDate, toDate, orderNumber, receiptNo} = this.formModel;
        console.log('receiptNo', this.formModel['receiptNo']);

        try {
            const formDataIsValid = this.checkDataValidation();
            console.log('formDataIsValid', formDataIsValid);
            if (!formDataIsValid) return;

            this.isDataLoading = true;
            const searchedLedgers = await searchLoyaltyLedger({contactId: this.personContactId, fromDate, toDate, orderNumber, receiptNo})
            console.log('searchedLedgers', searchedLedgers)
    
            this.tableData = searchedLedgers.map(data => {
                return {
                    id: data.Id,
                    journalNumber: (data?.TransactionJournal?.Name) ? data?.TransactionJournal?.Name : undefined,
                    transactionJournalLink: (data?.TransactionJournal?.Id) ? '/' + data?.TransactionJournal?.Id : undefined,
                    orderDate: data?.TransactionJournal?.ActivityDate,
                    orderNumber: data?.TransactionJournal?.Order_ID__c,
                    receiptNo: data?.TransactionJournal?.ReceiptNo__c,
                    orderItem: data?.TransactionJournal?.Order_Item_ID__c,
                    brand: data?.TransactionJournal?.Brand,
                    productDescription: data?.TransactionJournal?.Product?.Description,
                    store: data?.TransactionJournal?.TransactionLocation,
                    quantity: data?.TransactionJournal?.Quantity,
                    amount: data?.TransactionJournal?.TransactionAmount,
                    points: (data?.EventType === 'Debit') ? '- ' + data?.Points : '+ ' + data?.Points,
                    type: (data?.TransactionJournal?.JournalType?.Name && data?.TransactionJournal?.JournalSubType?.Name) ? 
                        data?.TransactionJournal?.JournalType?.Name + ' - ' + data?.TransactionJournal?.JournalSubType?.Name : 
                        (data?.TransactionJournal?.JournalType?.Name) ? data?.TransactionJournal?.JournalType?.Name : 
                        (data?.TransactionJournal?.JournalSubType?.Name) ? data?.TransactionJournal?.JournalSubType?.Name : undefined
                }
            });
            console.log('this.tableData', this.tableData);
        } catch (error) {
            console.error('error', JSON.stringify(error));
        } finally {
            this.isDataLoading = false;
        }
    }

    showToast(label, message, variant) {
        Toast.show({ label, message, variant, mode: 'dismissable' });
    }
}