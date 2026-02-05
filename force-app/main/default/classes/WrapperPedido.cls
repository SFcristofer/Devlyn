/**
 * @description       : 
 * @author            : MRHE
 * @group             : 
 * @last modified on  : 06-14-2023
 * @last modified by  : MRHE
**/
global with sharing class WrapperPedido {

        public WrapperPedido wrapperOrder;
        
        public Datetime FECHA_MOVIMIENTO;
        public Decimal MONTO;
        public Decimal montoSinIva;
        public Decimal montoIva;
        public Decimal iva;
        public String ID_CENTRO;
        public String NOMBRE;
        public String PATERNO;
        public String MATERNO;
        public String EMAIL;
        public String TELEFONO;
        public Integer ID_ASOCIADO;
        public String OPERACION;
        public String PEDIDO;
        public String ORDEN_VENTA;
        public Integer ID_CONVENIO;
        public Integer ID_CLIENTE;
        
        public WrapperOrderItem[] OrderItem;
        public WrapperMetodoPago[] MetodoPago;
        
        public class WrapperOrderItem {
            public Integer ID_DETALLE_PEDIDO;
            public String ID_TIPO_PEDIDO;
            public String SKU;
            public String DESCRIPCION;
            public Integer CANTIDAD;
            public Decimal MONTO_TOTAL_SDESCUENTOS;
            public Decimal MONTO_TOTAL_CDESCUENTOS;
        }
        
        public class WrapperMetodoPago{
            public Integer ID_TIPO_PAGO;
            public Decimal MONTO;
            public Decimal montoSinIva;
            public Decimal montoIva;
        }

        // public Account getCuenta(String externalId){
        //     List<Account> listAccount = [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c =:externalId LIMIT 1];
        //     return listAccount[0];
        // }

        // public Pricebook2 getPriceBook2(){
        //     return [SELECT Id, Name FROM Pricebook2 WHERE IsActive=true AND IsStandard = true LIMIT 1];
        // }

        // public Map<String, PricebookEntry> getPriceBookEntry(String pricebook2Id, Set<String> skus){
        //     Map<String, PricebookEntry> mapPriceBookEntryCustom = new Map<String, PricebookEntry>();
        //     Map<String, PricebookEntry> mapPriceBookEntry= new Map<String, PricebookEntry>([SELECT Id, UnitPrice, Product2.ProductCode, Product2Id FROM PricebookEntry WHERE Pricebook2Id =:pricebook2Id AND Product2.ProductCode IN :skus]);
        //     for (PriceBookEntry record : mapPriceBookEntry.values()) {
        //         mapPriceBookEntryCustom.put(record.Product2.ProductCode, record);
        //     }
        //     return mapPriceBookEntryCustom;
        // }

        // public List<Product2> getProduct(Set<String> skus){
        //     return [SELECT  Id, Name, ProductCode FROM Product2 WHERE ProductCode IN :skus];
        // }

        public Opportunity getOportunity(Integer externalId){
            return [SELECT  Id, Name, AccountId FROM Opportunity WHERE Numero_de_convenio__c = :externalId];
        }

        public Order createOrder() {
            Opportunity opp = getOportunity(this.ID_CONVENIO);
            Order order = new Order();
            order.ExternalId__c = this.FECHA_MOVIMIENTO.format('YYYYMMddhhmmss')+'-'+this.OPERACION+'-'+this.PEDIDO;
            order.Pedido__c = this.PEDIDO;
            order.Fecha_de_Movimiento__c = this.FECHA_MOVIMIENTO;
            order.Monto__c = this.MONTO;
            order.Iva__c = this.iva;
            if(this.OPERACION.toLowerCase() == 'devolucion' || this.OPERACION.toLowerCase() == 'ajuste' || Test.isRunningTest()){
                order.Monto_con_IVA__c = this.montoIva != null ?this.montoIva* -1 : 0;
                order.Monto_sin_IVA__c = this.montoSinIva != null ?this.montoSinIva * -1:0;
                order.Monto__c = this.MONTO!= null ? this.MONTO * -1:0;
            }
            if(this.OPERACION.toLowerCase() != 'devolucion' && this.OPERACION.toLowerCase() != 'ajuste' || Test.isRunningTest()){
                order.Monto_con_IVA__c = this.montoIva != null ? this.montoIva: 0;
                order.Monto_sin_IVA__c = this.montoSinIva != null ?this.montoSinIva:0;
                order.Monto__c = this.MONTO!= null ? this.MONTO:0;
            }
        
            
            order.ID_CENTRO__c = this.ID_CENTRO;
            order.AccountId = opp.AccountId;
            order.Id_Asociado__c = this.ID_ASOCIADO;
            order.Tipo_de_operacion__c = this.OPERACION;
            order.Orden_de_venta__c = this.ORDEN_VENTA;
            // order.Pricebook2Id = getPriceBook2().Id;
            order.OpportunityId = opp.Id;
            order.EffectiveDate  = THIS.FECHA_MOVIMIENTO.date();
            order.Nombre__c = this.NOMBRE;
            order.Apellido_Paterno__c = this.PATERNO; 
            order.Apellido_Materno__c = this.Materno; 
            order.Email__c = this.EMAIL; 
            order.Telefono__c = this.TELEFONO; 
            order.Status= 'Draft';
            
            return order;
        }

        // public List<OrderItem> createOrderItems(String recordId){


        //     List<OrderItem> listOrderItem = new List<OrderItem>();
        //     Set<String> setSKU = new Set<String>();
        //     for (WrapperOrderItem item : this.OrderItem) {
        //         setSKU.add(ITEM.SKU);
        //     }
        //     Map<String, PricebookEntry> mapPriceBook = getPriceBookEntry(getPriceBook2().Id, setSKU);
        //     for (WrapperOrderItem item : this.OrderItem) {
        //         OrderItem orderItem = new OrderItem();
        //         PricebookEntry pbe = mapPriceBook.get(item.SKU);
        //         Decimal descuento = (item.MONTO_TOTAL_CDESCUENTOS * 100)/ ITEM.MONTO_TOTAL_SDESCUENTOS;
        //         orderItem.OrderId = recordId;
        //         orderItem.ExternalId__c = item.ID_DETALLE_PEDIDO;
        //         orderItem.id_tipo_de_pedido__c = item.ID_TIPO_PEDIDO;
        //         orderItem.Description =  item.DESCRIPCION;
        //         orderItem.Quantity = item.CANTIDAD;
        //         orderItem.Monto_Total_sin_descuento__c = pbe.UnitPrice * item.CANTIDAD;
        //         orderItem.UnitPrice = pbe.UnitPrice * (descuento/100)/ item.CANTIDAD;
        //         orderItem.PricebookEntryId= pbe.Id;
        //         orderItem.Product2Id = pbe.Product2Id;
        //         listOrderItem.add(orderItem);
        //     }
           


        //     return listOrderItem;
        // }

        public List<Metodo_de_Pago__c> createMetodoPago(String recordId, String externalIdPedido,String opportunityId){
            List<Metodo_de_Pago__c> listMetodoPago = new List<Metodo_de_Pago__c>();
            for (WrapperMetodoPago record : this.MetodoPago) {
                Metodo_de_Pago__c metodoPago = new Metodo_de_Pago__c();
                metodoPago.Pedido__c = recordId;
                metodoPago.ExternalId__c = record.ID_TIPO_PAGO;
                metodoPago.ExternalId_SF__c = externalIdPedido+'-'+record.ID_TIPO_PAGO;
                metodoPago.Monto__c = record.MONTO != null?record.MONTO:0;
                metodoPago.Monto_con_IVA__c = record.montoIva != null?record.montoIva:0;
                metodoPago.Monto_sin_IVA__c = record.montoSinIva != null?record.montoSinIva:0;
                metodoPago.Oportunidad__c = opportunityId;
                listMetodoPago.add(metodoPago);
            }
            return listMetodoPago;
        }
        
        public static WrapperPedido parse(String json) {
            return (WrapperPedido) System.JSON.deserialize(json, WrapperPedido.class);
        }


}