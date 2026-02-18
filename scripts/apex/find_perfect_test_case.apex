try {
    // 1. Buscamos IDs que tengan engagement real
    String engQ = 'SELECT ssot__IndividualId__c, ssot__SubjectLineTxt__c FROM ssot__EmailEngagement__dlm WHERE ssot__SubjectLineTxt__c != null LIMIT 20';
    List<SObject> engs = Database.query(engQ);
    
    Set<String> potentialIds = new Set<String>();
    for(SObject e : engs) potentialIds.add((String)e.get('ssot__IndividualId__c'));

    System.debug('--- ANALIZANDO CANDIDATOS ---');
    
    // 2. Buscamos si esos IDs existen en el Perfil Unificado como Id_POS__c o UnifiedId
    List<UnifiedssotIndividualDev2__dlm> validProfiles = [
        SELECT Id_POS__c, ssot__Id__c, ssot__FirstName__c, ssot__LastName__c 
        FROM UnifiedssotIndividualDev2__dlm 
        WHERE (Id_POS__c IN :potentialIds OR ssot__Id__c IN :potentialIds) 
        LIMIT 5
    ];

    if(validProfiles.isEmpty()) {
        System.debug('No se encontró cruce directo. Buscando cualquier perfil con datos...');
        // Si no hay cruce, listamos los IDs de marketing para que el usuario los pruebe directamente en el buscador
        for(SObject e : engs) {
            System.debug('ID CON MARKETING (Prueba este en el buscador): ' + e.get('ssot__IndividualId__c') + ' | Asunto: ' + e.get('ssot__SubjectLineTxt__c'));
        }
    } else {
        for(UnifiedssotIndividualDev2__dlm p : validProfiles) {
            System.debug('¡CANDIDATO ENCONTRADO!');
            System.debug('Nombre: ' + p.ssot__FirstName__c + ' ' + p.ssot__LastName__c);
            System.debug('ID POS para buscar: ' + p.Id_POS__c);
            System.debug('Unified ID: ' + p.ssot__Id__c);
        }
    }
} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
}
