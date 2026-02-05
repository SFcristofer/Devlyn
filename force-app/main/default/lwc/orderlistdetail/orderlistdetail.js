import {LightningElement, api} from 'lwc';
import getProductData from '@salesforce/apex/DataCloudSQLControler.getProductData';

export default class orderlistdetail extends LightningElement {
    @api cdpProducto;
}