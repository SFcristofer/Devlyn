import { LightningElement, track, wire, api } from 'lwc';
import getOrderData from '@salesforce/apex/DataCloudSQLControler.getOrderData';
import getProductData from '@salesforce/apex/DataCloudSQLControler.getProductData';
import getProductPayment from '@salesforce/apex/DataCloudSQLControler.getProductPayment';

export default class OrderCallButton extends LightningElement {
    @track showOrders = 'Ver Info';
    @track isVisible = false;
    @api recordId;
    @track cdpData = [];
    @track cdpProducto;
    @track prodPayment;
    @api selectedRowIdGral;
    @track isLoading = false;
    
    handleClick(event){
        
        const label = event.target.label;

        if(label=== 'Ver Info'){
            this.showOrders = 'Esconder Info';
            this.isVisible = true;
            this.isLoading = true;
           getOrderData({recordId: this.recordId}).then((result)=> {
                this.cdpData = result;
                this.isLoading = false;
            })
            .catch((error)=>{
                this.cdpData = undefined;
                this.isLoading = false;
            });
        }
        else if(label === 'Esconder Info'){
            this.showOrders = 'Ver Info';
            this.isVisible = false;
            this.isLoading = false;
        }
    }


    handleRowClick(event){
        event.preventDefault();
        const selectedRowId = event.currentTarget.dataset.id; 

        this.cdpData.forEach(row =>{
            if(row.ssot__Id__c === selectedRowId){
                row.rowSelected = 'selected-row'
            } else {
                row.rowSelected = '';
            }
          });
          this.isLoading = true;
        //window.alert(selectedRowId);
        getProductData({orderId: selectedRowId})
          .then((resultp)=> {
            this.cdpProducto = resultp; 
            this.selectedRowIdGral = selectedRowId;
            this.isLoading = false;
        })
        .catch((error)=>{
            this.cdpProducto = undefined;
        });
        getProductPayment({orderId: selectedRowId})
        .then((resultpp)=> {
          this.prodPayment = resultpp; 
          this.selectedRowIdGral = selectedRowId;
          this.isLoading = false;
      })
      .catch((error)=>{
          this.prodPayment = undefined;
      });

    }
}