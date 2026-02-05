import { LightningElement, track, wire, api } from 'lwc';
import getDriVisual from '@salesforce/apex/DataCloudSQLControler.getDriVisual';

export default class drivVisualCallButton extends LightningElement {
    @track showDV = 'Ver Info';
    @track isVisible = false;
    @api recordId;
    @track isLoading = false;
    @track cdpData = [];
    
    handleClick(event){
        
        const label = event.target.label;

        if(label=== 'Ver Info'){
            this.showDV = 'Esconder Info';
            this.isVisible = true;
            this.isLoading = true;
            getDriVisual({recordId: this.recordId}).then((result)=> {
            this.cdpData = result;
            this.isLoading = false;
            })
            .catch((error)=>{
                this.cdpData = undefined;
                this.isLoading = false;
            });
        }
        else if(label === 'Esconder Info'){
            this.showDV = 'Ver Info';
            this.isVisible = false;
            this.isLoading = false;
        }
    }
}