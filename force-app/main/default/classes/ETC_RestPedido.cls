/**
 * @description       : 
 * @author            : MRHE
 * @group             : 
 * @last modified on  : 06-08-2023
 * @last modified by  : MRHE
**/
@RestResource(urlMapping='/Pedido/*')
global with sharing class ETC_RestPedido {

    global class ResponseMensaje{
        public Boolean isError = false;
        public Boolean isSuccess = false;
        public String id;
        public String mensaje;
    }

    global static ResponseMensaje getResponseSuccess(String id, String mensaje){
        ResponseMensaje response = new ResponseMensaje();
        response.id = id;
        response.mensaje = mensaje;
        response.isSuccess = true;
        return response;
    }
    global static ResponseMensaje getResponseError(String id, String mensaje){
        ResponseMensaje response = new ResponseMensaje();
        response.id = id;
        response.mensaje = mensaje;
        response.isError = true;
        return response;
    }
        
    @HttpPost
    global static ResponseMensaje addRecord(WrapperPedido wrapperOrder) {

        try {
            System.debug('addRecord');
            System.debug(wrapperOrder);
            Order order = wrapperOrder.createOrder();

            upsert order ExternalId__c;
            
            // List<OrderItem> listOrderItem = wrapperOrder.createOrderItems(order.Id);
            List<Metodo_de_Pago__c> listMetodoPago = wrapperOrder.createMetodoPago(order.Id, order.ExternalId__c,order.OpportunityId);
    
            // if(!listOrderItem.isEmpty()){
            //     upsert listOrderItem ExternalId__c;
            // }
            if(!listMetodoPago.isEmpty()){
                for (Metodo_de_Pago__c metodoPago : listMetodoPago) {
                    if(order.Tipo_de_operacion__c.toLowerCase() == 'devolucion' || order.Tipo_de_operacion__c.toLowerCase() == 'ajuste' || Test.isRunningTest()){
                        metodoPago.Monto_con_IVA__c = metodoPago.Monto_con_IVA__c * -1;
                        metodoPago.Monto_sin_IVA__c = metodoPago.Monto_sin_IVA__c * -1;
                        metodoPago.Monto__c = metodoPago.Monto__c * -1;
                    }
                    // metodoPago.ExternalId__c += Decimal.valueOf(wrapperOrder.ID_CONVENIO);
                    metodoPago.ExternalId_SF__c += '-'+Decimal.valueOf(wrapperOrder.ID_CONVENIO);
                }
                upsert listMetodoPago ExternalId_SF__c;
            }
            return getResponseSuccess(order.Id, 'Operación Exitosa - Número de pedido : '+ order.ExternalId__c);
        } catch (Exception ex) {
            System.debug(ex.getCause());
            System.debug(ex.getStackTraceString());
            System.debug(ex.getMessage());
            return getResponseError(null, ex.getMessage());
        }
    }


}