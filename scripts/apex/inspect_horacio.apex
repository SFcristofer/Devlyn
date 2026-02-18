String horacio = '11472417';
try {
    System.debug('--- ANALIZANDO REGISTRO HORACIO ---');
    String q = 'SELECT ssot__Id__c, Id_POS__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = :horacio LIMIT 1';
    List<SObject> recs = Database.query(q);
    if(!recs.isEmpty()) {
        System.debug('HORACIO ENCONTRADO: ' + recs[0].get('ssot__Id__c'));
        // Intentamos ver campos ocultos
        Map<String, Object> fields = recs[0].getPopulatedFieldsAsMap();
        for(String f : fields.keySet()) System.debug('CAMPO: ' + f + ' = ' + fields.get(f));
    }
    
    // Probamos graduación
    String qG = 'SELECT count() FROM POS_POS_CLIENTE_GRAD_PEDIDO_70871439__dlm';
    System.debug('REGISTROS GRADUACION: ' + Database.countQuery(qG));
} catch(Exception e) { System.debug('Error: ' + e.getMessage()); }
