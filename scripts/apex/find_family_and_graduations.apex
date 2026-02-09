// 1. Intentar localizar DMO de Graduaciones
List<String> potentialGradDMOs = new List<String>{
    'POS_POS_CLIENTE_GRADUACION_PEDIDO_708324__dlm',
    'POS_POS_CLIENTE_RECETA_708324__dlm',
    'POS_POS_CLIENTE_GRAD_PEDIDO_70871439__dlm'
};

for(String dmo : potentialGradDMOs) {
    try {
        String q = 'SELECT ID_CLIENTE__c, FECHA__c FROM ' + dmo + ' LIMIT 5';
        List<SObject> results = Database.query(q);
        if(!results.isEmpty()) {
            System.debug('GRAD_DMO_FOUND: ' + dmo + ' | Example ID: ' + results[0].get('ID_CLIENTE__c'));
        }
    } catch(Exception e) { /* Ignorar si no existe */ }
}

// 2. Intentar localizar Relaciones Familiares
try {
    String qFam = 'SELECT ssot__IndividualId__c, ssot__RelatedIndividualId__c, ssot__RelationshipType__c FROM ssot__IndividualRelationship__dlm LIMIT 5';
    List<SObject> famResults = Database.query(qFam);
    if(!famResults.isEmpty()) {
        System.debug('FAM_RELATION_FOUND: ' + famResults[0]);
    }
} catch(Exception e) {
    System.debug('FAM_DMO_NOT_FOUND: ssot__IndividualRelationship__dlm');
}

// 3. Buscar por coincidencia de dirección (Familia implícita)
try {
    String qAddr = 'SELECT ssot__AddressLine1Txt__c, COUNT(ssot__ParentId__c) cnt FROM ssot__ContactPointAddress__dlm GROUP BY ssot__AddressLine1Txt__c HAVING COUNT(ssot__ParentId__c) > 1 LIMIT 5';
    List<AggregateResult> addrResults = Database.query(qAddr);
    if(!addrResults.isEmpty()) {
        System.debug('FAMILIA_POR_DIRECCION: ' + addrResults[0]);
    }
} catch(Exception e) { }
