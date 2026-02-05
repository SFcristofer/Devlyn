import {LightningElement, api} from 'lwc';
import getProductPayment from '@salesforce/apex/DataCloudSQLControler.getProductPayment';

export default class orderPaymentdetail extends LightningElement {
    @api prodPayment;
}