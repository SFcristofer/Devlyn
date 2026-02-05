import { LightningElement, track, wire, api } from 'lwc';
import getPregPoder from '@salesforce/apex/DataCloudSQLControler.getPregPoder';


export default class pregPodCallButton extends LightningElement {
    @track showPP = 'Ver Info';
    @track isVisible = false;
    @api recordId;
    @track cdpData = [];
    @track isLoading = false;
    
    handleClick(event){
        
        const label = event.target.label;

        if(label=== 'Ver Info'){
            this.showPP = 'Esconder Info';
            this.isVisible = true;
            this.isLoading = true;
           getPregPoder({recordId: this.recordId}).then((result)=> {
                this.cdpData = result;
                this.isLoading = false;
            })
            .catch((error)=>{
                this.cdpData = undefined;
                this.isLoading = false;
            });
        }
        else if(label === 'Esconder Info'){
            this.showPP = 'Ver Info';
            this.isVisible = false;
            this.isLoading = false;
        }
    }
}