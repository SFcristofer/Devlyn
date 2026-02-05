import { LightningElement, track, wire, api } from 'lwc';
import getDiagnostico from '@salesforce/apex/DataCloudSQLControler.getDiagnostico';


export default class diagnostCallButton extends LightningElement {
    @track showDiag = 'Ver Info';
    @track isVisible = false;
    @api recordId;
    @track cdpData = [];
    @track isLoading = false;

    
    handleClick(event){
        
        const label = event.target.label;

        if(label=== 'Ver Info'){
            this.showDiag = 'Esconder Info';
            this.isVisible = true;
            this.isLoading = true;
           getDiagnostico({recordId: this.recordId}).then((result)=> {
                this.cdpData = result;
                this.isLoading = false;
            })
            .catch((error)=>{
                this.cdpData = undefined;
                this.isLoading = false;
            });
        }
        else if(label === 'Esconder Info'){
            this.showDiag = 'Ver Info';
            this.isVisible = false;
            this.isLoading = false;
        }
    }
}