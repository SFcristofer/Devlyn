try {
    System.debug('--- INSPECCIÓN DE CAMPOS PERFIL ---');
    String q = 'SELECT Id_POS__c FROM UnifiedssotIndividualDev2__dlm LIMIT 1';
    List<SObject> recs = Database.query(q);
    if(!recs.isEmpty()) {
        Map<String, Object> fields = recs[0].getPopulatedFieldsAsMap();
        System.debug('CAMPOS DISPONIBLES: ' + fields.keySet());
    }
    
    System.debug('--- BUSCANDO OBJETOS DE EXAMEN ---');
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    for(String name : gd.keySet()) {
        if(name.contains('examen') && name.endsWith('__dlm')) {
            System.debug('POSIBLE DMO DE EXAMEN: ' + name);
        }
    }
} catch(Exception e) { System.debug('Error: ' + e.getMessage()); }
