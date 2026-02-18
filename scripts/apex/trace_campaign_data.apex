String posId = '12259550';
try {
    // 1. Buscamos el perfil completo
    List<UnifiedssotIndividualDev2__dlm> profiles = [SELECT ssot__Id__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = :posId LIMIT 1];
    
    if(profiles.isEmpty()) {
        System.debug('PERFIL_NO_ENCONTRADO: El ID ' + posId + ' no existe en Unified Profiles.');
    } else {
        String uid = profiles[0].ssot__Id__c;
        String email = profiles[0].Email__c;
        System.debug('PERFIL_ENCONTRADO: UnifiedId=' + uid + ' | Email=' + email);

        // 2. Buscamos campañas para este ID específico
        String query = 'SELECT count() FROM ssot__EmailEngagement__dlm WHERE ssot__IndividualId__c = :uid OR ssot__IndividualId__c = :posId OR ssot__IndividualId__c = :email';
        Integer count = Database.countQuery(query);
        System.debug('CONTEO_CAMPAÑAS_PARA_ESTE_ID: ' + count);
    }

    // 3. BÚSQUEDA GLOBAL: Si el anterior falló, buscamos quién SÍ tiene datos
    System.debug('--- BUSCANDO IDs CON DATOS REALES ---');
    String globalQ = 'SELECT ssot__IndividualId__c, ssot__SubjectLineTxt__c FROM ssot__EmailEngagement__dlm WHERE ssot__SubjectLineTxt__c != null LIMIT 5';
    List<SObject> engs = Database.query(globalQ);
    for(SObject e : engs) {
        System.debug('ID_CON_CAMPAÑA_REAL: ' + e.get('ssot__IndividualId__c') + ' | Asunto: ' + e.get('ssot__SubjectLineTxt__c'));
    }

} catch(Exception e) {
    System.debug('ERROR_INVESTIGACION: ' + e.getMessage());
}
