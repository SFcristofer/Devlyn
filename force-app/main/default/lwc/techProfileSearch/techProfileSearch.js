import { LightningElement, track } from 'lwc';
import searchProfilesGlobal from '@salesforce/apex/TechProfile360Controller.searchProfilesGlobal';

const COLUMNS = [
    { label: 'Name', fieldName: 'ssot__FirstName__c', type: 'text' },
    { label: 'Last Name', fieldName: 'ssot__LastName__c', type: 'text' },
    { label: 'Email', fieldName: 'Email__c', type: 'email' },
    { label: 'ID POS', fieldName: 'Id_POS__c', type: 'text' }
];

export default class TechProfileSearch extends LightningElement {
    @track searchTerm = '';
    @track searchResults = [];
    @track isSearching = false;
    columns = COLUMNS;

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    handleSearchAction() {
        if (this.searchTerm && this.searchTerm.length >= 2) {
            this.isSearching = true;
            searchProfilesGlobal({ 
                term: this.searchTerm
            })
                .then(result => {
                    this.searchResults = result;
                    this.isSearching = false;
                })
                .catch(error => {
                    console.error('Search Error:', error);
                    this.isSearching = false;
                });
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            const selectEvent = new CustomEvent('profileselect', {
                detail: { unifiedId: selectedRows[0].ssot__Id__c }
            });
            this.dispatchEvent(selectEvent);
        }
    }

    get isSearchDisabled() {
        return !this.searchTerm || this.searchTerm.length < 2;
    }

    get hasResults() {
        return this.searchResults && this.searchResults.length > 0;
    }

    get noResults() {
        return this.searchTerm && !this.isSearching && this.searchResults.length === 0;
    }
}