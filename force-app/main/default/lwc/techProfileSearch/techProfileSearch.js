import { LightningElement, track } from 'lwc';
import searchProfiles from '@salesforce/apex/TechProfile360Controller.searchProfiles';

const COLUMNS = [
    { label: 'Name', fieldName: 'ssot__FirstName__c', type: 'text' },
    { label: 'Last Name', fieldName: 'ssot__LastName__c', type: 'text' },
    { label: 'Email', fieldName: 'Email__c', type: 'email' },
    { label: 'ID POS', fieldName: 'Id_POS__c', type: 'text' }
];

export default class TechProfileSearch extends LightningElement {
    @track selectedDataSpace = 'default';
    @track selectedObject = '';
    @track selectedAttribute = '';
    @track searchTerm = '';
    @track searchResults = [];
    @track isSearching = false;
    columns = COLUMNS;

    // Opciones para los Comboboxes
    dataSpaceOptions = [{ label: 'default', value: 'default' }];
    
    objectOptions = [
        { label: 'Unified Individual', value: 'UnifiedIndividual' }
    ];

    attributeOptionsMap = {
        'UnifiedIndividual': [
            { label: 'First Name', value: 'ssot__FirstName__c' },
            { label: 'Last Name', value: 'ssot__LastName__c' },
            { label: 'Email', value: 'Email__c' },
            { label: 'ID POS', value: 'Id_POS__c' }
        ]
    };

    @track attributeOptions = [];

    handleDataSpaceChange(event) {
        this.selectedDataSpace = event.detail.value;
    }

    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
        this.attributeOptions = this.attributeOptionsMap[this.selectedObject] || [];
        this.selectedAttribute = ''; // Reset attribute when object changes
    }

    handleAttributeChange(event) {
        this.selectedAttribute = event.detail.value;
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    handleSearchAction() {
        if (this.selectedAttribute && this.searchTerm) {
            this.isSearching = true;
            searchProfiles({ 
                searchTerm: this.searchTerm, 
                attributePath: this.selectedAttribute 
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

    get isAttributeDisabled() {
        return !this.selectedObject;
    }

    get isSearchDisabled() {
        return !this.selectedAttribute;
    }

    get hasResults() {
        return this.searchResults && this.searchResults.length > 0;
    }

    get noResults() {
        return this.selectedAttribute && this.searchTerm && !this.isSearching && this.searchResults.length === 0;
    }
}