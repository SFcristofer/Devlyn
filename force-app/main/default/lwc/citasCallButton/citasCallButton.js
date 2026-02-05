import { LightningElement, track, wire, api } from 'lwc';
import getCitas from '@salesforce/apex/DataCloudSQLControler.getCitas';

export default class CitasCallButton extends LightningElement {
    @track showCita = 'Ver Info';
    @track isVisible = false;
    @api recordId;
    @track cdpData = [];
    @track cdpProducto;
    @track isLoading = false;
    @api selectedRowIdGral;
    
    handleClick(event){
        
        const label = event.target.label;

        if(label=== 'Ver Info'){
            this.showCita = 'Esconder Info';
            this.isVisible = true;
            this.isLoading = true;
           getCitas({recordId: this.recordId}).then((result)=> {
                this.cdpData = result;
                this.isLoading = false;
            })
            .catch((error)=>{
                this.cdpData = undefined;
                this.isLoading = false;
            });
        }
        else if(label === 'Esconder Info'){
            this.showCita = 'Ver Info';
            this.isVisible = false;
            this.isLoading = false;
        }
    }
}