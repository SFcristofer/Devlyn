String targetId = '11472417';
try {
    // Consultamos un registro de Horacio para ver el nombre real de sus columnas
    String q = 'SELECT Id, ssot__SubjectLineTxt__c, ssot__EngagementDateTm__c, ssot__EmailFromAddr__c FROM ssot__EmailEngagement__dlm WHERE ssot__IndividualId__c = :targetId LIMIT 1';
    List<SObject> results = Database.query(q);
    if(!results.isEmpty()) {
        System.debug('--- VALIDACIÓN DE CAMPOS REALES ---');
        Map<String, Object> fields = results[0].getPopulatedFieldsAsMap();
        for(String key : fields.keySet()) {
            System.debug('CAMPO DETECTADO: ' + key + ' | VALOR: ' + fields.get(key));
        }
    }
} catch(Exception e) {
    System.debug('Error en validación: ' + e.getMessage());
}
