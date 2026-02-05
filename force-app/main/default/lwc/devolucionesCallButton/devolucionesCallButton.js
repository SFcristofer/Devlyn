import { LightningElement, track, wire, api } from 'lwc';
import getProductDev from '@salesforce/apex/DataCloudSQLControler.getProductDev';

export default class devolucionesCallButton extends LightningElement {

    @track showDev = 'Ver Info';
    @track isVisible = false;
    @api recordId;
    @track cdpData = [];
    @track isLoading = false;

    
    handleClick(event){
        
        const label = event.target.label;

        if(label=== 'Ver Info'){
            this.showDev = 'Esconder Info';
            this.isVisible = true;
            this.isLoading = true;
            getProductDev({recordId: this.recordId}).then((result)=> {
                this.cdpData = result;
                this.isLoading = false;
            })
            .catch((error)=>{
                this.cdpData = undefined;
                this.isLoading = false;
            });
        }
        else if(label === 'Esconder Info'){
            this.showDev = 'Ver Info';
            this.isVisible = false;
            this.isLoading = false;
        }
    }
}