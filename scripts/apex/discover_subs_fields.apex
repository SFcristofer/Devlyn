// Obtenemos un registro y extraemos todos sus campos reales
try {
    List<SObject> res = Database.query('SELECT Id FROM VTEX_Subscription__dlm LIMIT 1');
    if (!res.isEmpty()) {
        // Esta es la clave: recuperamos el ID y pedimos un re-query con campos dinámicos si fuera posible, 
        // o intentamos proyectar campos comunes.
        // Dado que __dlm no siempre permite getPopulatedFieldsAsMap de forma limpia, probaremos campos probables uno por uno.
        
        String[] probes = new String[]{'ssot__IndividualId__c', 'ssot__Name__c', 'ssot__StatusId__c', 'CreatedDate__c', 'NextPurchaseDate__c', 'Frequency__c', 'IndividualId__c', 'Name__c', 'Status__c'};
        Map<String, Object> foundFields = new Map<String, Object>();
        
        for(String f : probes) {
            try {
                String q = 'SELECT ' + f + ' FROM VTEX_Subscription__dlm LIMIT 1';
                List<SObject> r = Database.query(q);
                if(!r.isEmpty()) foundFields.put(f, r[0].get(f));
            } catch(Exception e) { /* Campo no existe */ }
        }
        System.debug('CAMPOS_DETECTADOS: ' + foundFields.keySet());
    }
} catch(Exception e) {
    System.debug('ERROR_INSPECCION: ' + e.getMessage());
}
