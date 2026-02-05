import { LightningElement, track, wire, api } from 'lwc';
import getCitas from '@salesforce/apex/DataCloudSQLControler.getGraduacion';


export default class graduacionCallButton extends LightningElement {
    @track showGrad = 'Ver Info';
    @track isVisible = false;
    @api recordId;
    @track cdpData = [];
    @track cdpProducto;
    @api selectedRowIdGral;
    @track isLoading = false;
    
    handleClick(event){
        
        const label = event.target.label;

        if(label=== 'Ver Info'){
            this.showGrad = 'Esconder Info';
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
            this.showGrad = 'Ver Info';
            this.isVisible = false;
            this.isLoading = false;
        }
    }
}