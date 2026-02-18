String targetId = '11472417';
try {
    System.debug('--- AUDITORÍA DE DATOS REALES PARA HORACIO ---');
    
    // 1. Rastreamos el ID en las tablas de Engagement
    String[] engagementObjects = new String[]{'ssot__EmailEngagement__dlm', 'ssot__IndividualEngagement__dlm', 'ssot__DeviceEngagement__dlm'};
    for(String obj : engagementObjects) {
        try {
            String q = 'SELECT ssot__IndividualId__c, ssot__SubjectLineTxt__c FROM ' + obj + ' WHERE ssot__IndividualId__c = :targetId OR ssot__IndividualId__c LIKE '%' + targetId + '%' LIMIT 5';
            List<SObject> results = Database.query(q);
            if(!results.isEmpty()) {
                System.debug('DATOS ENCONTRADOS EN ' + obj + ': ' + results.size());
                for(SObject s : results) System.debug(' - Registro: ' + JSON.serialize(s));
            }
        } catch(Exception e) {}
    }

    // 2. Rastreamos el ID en las tablas de RFM (Lealtad)
    String[] rfmObjects = new String[]{'RFM_Retail_Solar__cio', 'RFM_Retail_Oftalmicos__cio', 'RFM_Retail_LC__cio'};
    for(String obj : rfmObjects) {
        try {
            String q = 'SELECT unified_individual_id__c, score__c, label__c FROM ' + obj + ' WHERE unified_individual_id__c = :targetId OR unified_individual_id__c LIKE '%' + targetId + '%' LIMIT 1';
            List<SObject> results = Database.query(q);
            if(!results.isEmpty()) {
                System.debug('RFM ENCONTRADO EN ' + obj + ': ' + JSON.serialize(results[0]));
            }
        } catch(Exception e) {}
    }

} catch(Exception e) {
    System.debug('ERROR GENERAL: ' + e.getMessage());
}
