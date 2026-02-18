try {
    String[] dmos = new String[]{'POS_POS_CLIENTE_PRESUPUESTO_70871439__dlm', 'POS_POS_CLIENTE_PRESUPUESTO_708324__dlm'};
    for(String dmo : dmos) {
        try {
            // Buscamos cualquier registro para ver el ID de cliente
            String q = 'SELECT ID_CLIENTE__c, TOTAL__c, FECHA__c FROM ' + dmo + ' LIMIT 5';
            List<SObject> results = Database.query(q);
            if(!results.isEmpty()) {
                System.debug('¡DATOS ENCONTRADOS EN ' + dmo + '!');
                for(SObject s : results) {
                    System.debug('REGISTRO: ID_CLIENTE=' + s.get('ID_CLIENTE__c') + ' | TOTAL=' + s.get('TOTAL__c'));
                }
            } else {
                System.debug('DMO VACÍO: ' + dmo);
            }
        } catch(Exception e) {
            System.debug('DMO NO ACCESIBLE: ' + dmo + ' (' + e.getMessage() + ')');
        }
    }
} catch(Exception e) {}
