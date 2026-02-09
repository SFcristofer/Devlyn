// Buscamos envíos reales de Marketing Cloud
try {
    String q = 'SELECT ssot__SubjectLineTxt__c, ssot__EngagementDateTm__c, ssot__IndividualId__c FROM ssot__EmailEngagement__dlm LIMIT 5';
    List<SObject> results = Database.query(q);
    if (!results.isEmpty()) {
        System.debug('MARKETING_DATA: Encontrados ' + results.size() + ' envíos. Ejemplo: ' + results[0].get('ssot__SubjectLineTxt__c'));
        System.debug('MARKETING_ID_EJEMPLO: ' + results[0].get('ssot__IndividualId__c'));
    } else {
        System.debug('MARKETING_DATA: No hay historial de engagement en ssot__EmailEngagement__dlm.');
    }
} catch(Exception e) {
    System.debug('MARKETING_ERROR: ' + e.getMessage());
}
