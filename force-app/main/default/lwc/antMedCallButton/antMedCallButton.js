import { LightningElement, track, wire, api } from 'lwc';
import getAntMedico from '@salesforce/apex/DataCloudSQLControler.getAntMedico';

export default class antMedCallButton extends LightningElement {
    @track showAM = 'Ver Info';
    @track isVisible = false;
    @api recordId;
    @track isLoading = false;
    @track cdpData = [];
    
    handleClick(event){
        
        const label = event.target.label;

        if(label=== 'Ver Info'){
            this.showAM = 'Esconder Info';
            this.isVisible = true;
            this.isLoading = true;
           getAntMedico({recordId: this.recordId}).then((result)=> {
                this.cdpData = result;
                this.isLoading = false;
            })
            .catch((error)=>{
                this.cdpData = undefined;
                this.isLoading = false;
            });
        }
        else if(label === 'Esconder Info'){
            this.showAM = 'Ver Info';
            this.isVisible = false;
            this.isLoading = false;
        }
    }
}