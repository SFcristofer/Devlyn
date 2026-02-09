String posId = '12083967';
List<UnifiedssotIndividualDev2__dlm> profiles = [SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = :posId LIMIT 1];

if (!profiles.isEmpty()) {
    String unifiedId = profiles[0].ssot__Id__c;
    System.debug('PERFIL_ENCONTRADO: ' + profiles[0].ssot__FirstName__c + ' ' + profiles[0].ssot__LastName__c + ' | UnifiedID: ' + unifiedId);
    
    // Ahora buscamos todos los POS IDs vinculados a este perfil unificado
    List<UnifiedssotIndividualDev2__dlm> allPosIds = [SELECT Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :unifiedId];
    List<String> posIdList = new List<String>();
    for(UnifiedssotIndividualDev2__dlm p : allPosIds) if(p.Id_POS__c != null) posIdList.add(p.Id_POS__c);
    
    System.debug('POS_IDS_VINCULADOS: ' + posIdList);

    // Buscamos diagnósticos para cualquiera de esos IDs
    String diagQuery = 'SELECT ASTIGMATISMO__c, HIPERMETROPIA__c, MIOPIA__c, PRESBICIA__c, FECHA__c, ID_CLIENTE__c ' +
                       'FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm ' +
                       'WHERE ID_CLIENTE__c IN :posIdList ' +
                       'ORDER BY FECHA__c DESC LIMIT 5';
    
    List<SObject> diags = Database.query(diagQuery);
    for(SObject d : diags) {
        System.debug('DIAGNOSTICO_ENCONTRADO: Fecha: ' + d.get('FECHA__c') + ' | Cliente: ' + d.get('ID_CLIENTE__c') + ' | Miopia: ' + d.get('MIOPIA__c'));
    }
    if(diags.isEmpty()) System.debug('DIAGNOSTICO_REAL: No hay diagnósticos para ningún ID vinculado.');
} else {
    System.debug('PERFIL_REAL: No se encontró un perfil unificado con el ID POS ' + posId);
}
