// Obtenemos una orden real para inspeccionar sus datos
String q = 'SELECT ssot__Id__c, ssot__OrderNumber__c, ssot__TotalAmount__c, ssot__CreatedDate__c FROM ssot__SalesOrder__dlm WHERE ssot__TotalAmount__c != null LIMIT 1';
List<SObject> orders = Database.query(q);
if(!orders.isEmpty()) {
    System.debug('ORDEN_INSPECCION: ' + orders[0]);
    String orderId = (String)orders[0].get('ssot__Id__c');
    
    // Inspeccionamos sus productos
    String qProd = 'SELECT ssot__ProductId__c, ssot__Description__c, ssot__OrderedQuantity__c, ssot__TotalLineAmount__c FROM ssot__SalesOrderProduct__dlm WHERE ssot__SalesOrderId__c = :orderId';
    List<SObject> products = Database.query(qProd);
    for(SObject p : products) {
        System.debug('PRODUCTO_INSPECCION: ' + p);
    }
}
