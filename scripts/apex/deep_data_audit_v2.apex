try {
    String quoteId = '8200424';
    String dmo = 'POS_POS_CLIENTE_PRESUPUESTO_70871439__dlm';
    
    System.debug('--- AUDITORIA DE DATOS: PRESUPUESTO ' + quoteId + ' ---');
    
    // Consultamos el registro sin filtrar por ID de cliente, sino por el ID del presupuesto mismo
    // Probamos con ID_PRESUPUESTO__c
    String q = 'SELECT ID_PRESUPUESTO__c, ID_CLIENTE__c, TOTAL__c, FECHA__c FROM ' + dmo + ' WHERE ID_PRESUPUESTO__c = \'' + quoteId + '\' LIMIT 1';
    
    List<SObject> results = Database.query(q);
    
    if(results.isEmpty()) {
        System.debug('RESULTADO: No se encontró el ID ' + quoteId + ' en el campo ID_PRESUPUESTO__c del DMO ' + dmo);
        
        // Intento 2: Buscar en todos los registros para ver cómo vienen los IDs
        System.debug('--- BUSCANDO FORMATO DE DATOS EN LOS PRIMEROS 5 REGISTROS ---');
        String q2 = 'SELECT ID_PRESUPUESTO__c, ID_CLIENTE__c, TOTAL__c, FECHA__c FROM ' + dmo + ' LIMIT 5';
        List<SObject> samples = Database.query(q2);
        for(SObject s : samples) {
            System.debug('MUESTRA: ID_PRESU=' + s.get('ID_PRESUPUESTO__c') + ' | ID_CLI=' + s.get('ID_CLIENTE__c') + ' | TOTAL=' + s.get('TOTAL__c'));
        }
    } else {
        SObject r = results[0];
        System.debug('¡REGISTRO ENCONTRADO!');
        System.debug('ID_PRESUPUESTO__c: ' + r.get('ID_PRESUPUESTO__c'));
        System.debug('ID_CLIENTE__c: ' + r.get('ID_CLIENTE__c'));
        System.debug('TOTAL__c: ' + r.get('TOTAL__c'));
        System.debug('FECHA__c: ' + r.get('FECHA__c'));
    }
} catch(Exception e) {
    System.debug('ERROR EN AUDITORIA: ' + e.getMessage());
}