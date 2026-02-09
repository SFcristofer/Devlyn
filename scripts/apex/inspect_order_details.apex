// 1. Investigar campos en la Cabecera de Orden (ssot__SalesOrder__dlm)
// Buscamos: Cotización, Tipo de Orden (para devoluciones)
try {
    // Intentamos campos comunes de Data Cloud para Quote y Return
    String q = 'SELECT ssot__SourceQuoteId__c, ssot__OrderTypeId__c FROM ssot__SalesOrder__dlm LIMIT 1';
    Database.query(q);
    System.debug('CAMPOS_ORDEN: ssot__SourceQuoteId__c y ssot__OrderTypeId__c existen');
} catch(Exception e) {
    System.debug('CAMPOS_ORDEN_ERROR: ' + e.getMessage());
}

// 2. Investigar campos en el Detalle de Producto (ssot__SalesOrderProduct__dlm)
// Buscamos: Descuentos, Ajustes de precio
try {
    String qProd = 'SELECT ssot__AdjustmentAmount__c FROM ssot__SalesOrderProduct__dlm LIMIT 1';
    Database.query(qProd);
    System.debug('CAMPOS_PRODUCTO: ssot__AdjustmentAmount__c existe');
} catch(Exception e) {
    System.debug('CAMPOS_PRODUCTO_ERROR: ' + e.getMessage());
}
