// Buscamos DMOs que contengan "Quote" o "Presupuesto"
Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
for(String sObj : gd.keySet()){
    if(sObj.contains('__dlm') && (sObj.contains('quote') || sObj.contains('presupuesto'))){
        System.debug('QUOTE_DMO_FOUND: ' + sObj);
    }
}

// También buscamos en los objetos estándar de Data Cloud para Ventas
try {
    String q = 'SELECT ssot__Id__c FROM ssot__Quote__dlm LIMIT 1';
    Database.query(q);
    System.debug('QUOTE_DMO_STATUS: ssot__Quote__dlm existe');
} catch(Exception e) {
    System.debug('QUOTE_DMO_STATUS: ssot__Quote__dlm no encontrado');
}
