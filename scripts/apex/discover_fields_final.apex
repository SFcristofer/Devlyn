try {
    // 1. Verificamos DMO de Graduaciones
    for(String dmo : new String[]{'POS_POS_CLIENTE_GRAD_PEDIDO_70871439__dlm', 'POS_POS_CLIENTE_GRADUACION_PEDIDO_708324__dlm'}) {
        try {
            Integer c = Database.countQuery('SELECT count() FROM ' + dmo);
            if(c > 0) System.debug('GRAD_DMO_ACTIVO: ' + dmo + ' (' + c + ' registros)');
        } catch(Exception e) {}
    }

    // 2. Buscamos campo de teléfono en Perfil
    String q = 'SELECT ssot__Id__c FROM UnifiedssotIndividualDev2__dlm LIMIT 1';
    List<SObject> profiles = Database.query(q);
    if(!profiles.isEmpty()) {
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('UnifiedssotIndividualDev2__dlm').getDescribe().fields.getMap();
        for(String f : fields.keySet()) {
            if(f.toLowerCase().contains('phone') || f.toLowerCase().contains('tel')) {
                System.debug('CAMPO DE TELÉFONO ENCONTRADO: ' + f);
            }
        }
    }
} catch(Exception e) { System.debug('Error: ' + e.getMessage()); }
