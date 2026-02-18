try {
    System.debug('--- AUDITORIA DEFINITIVA DE PRESUPUESTOS ---');
    
    // 1. Buscamos en SalesOrder registros con cualquier DataSourceId
    String q = 'SELECT ssot__DataSourceId__c, ssot__SoldToCustomerId__c, ssot__OrderNumber__c FROM ssot__SalesOrder__dlm WHERE ssot__DataSourceId__c != null LIMIT 50';
    List<SObject> orders = Database.query(q);
    
    Map<String, Integer> sourceCounts = new Map<String, Integer>();
    List<String> validIds = new List<String>();
    
    for(SObject o : orders) {
        String src = (String)o.get('ssot__DataSourceId__c');
        sourceCounts.put(src, (sourceCounts.containsKey(src) ? sourceCounts.get(src) + 1 : 1));
        
        // Si encontramos tu etiqueta, guardamos el ID para dártelo
        if(src.contains('PRESUPUESTO')) {
            validIds.add((String)o.get('ssot__SoldToCustomerId__c') + ' (Order: ' + o.get('ssot__OrderNumber__c') + ')');
        }
    }
    
    System.debug('ORÍGENES ENCONTRADOS: ' + sourceCounts);
    
    if(validIds.isEmpty()) {
        System.debug('RESULTADO: No se encontraron registros con la etiqueta POS_POS_PRESUPUESTO en los primeros 50.');
    } else {
        System.debug('¡ÉXITO! IDs CON PRESUPUESTOS ENCONTRADOS: ' + validIds);
    }
} catch(Exception e) {
    System.debug('ERROR EN AUDITORIA: ' + e.getMessage());
}