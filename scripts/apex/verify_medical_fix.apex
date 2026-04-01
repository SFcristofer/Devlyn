String sofiaId = '13226925';
String miguelId = '13227215';

System.debug('--- VALIDANDO EXPEDIENTES MÉDICOS REALES ---');

// Query 1: Buscar a Miguel y Sofia en el diagnóstico usando LIKE para ignorar basura en el ID
String qDiag = 'SELECT ID_CLIENTE__c, FECHA__c, MIOPIA__c, ASTIGMATISMO__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE ID_CLIENTE__c LIKE \'%13227215%\' OR ID_CLIENTE__c LIKE \'%13226925%\' LIMIT 5';

// Query 2: Ver cómo están vinculados en la tabla de Identidad para ver si el ID cambió
String qLink = 'SELECT SourceRecordId__c, UnifiedRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm WHERE SourceRecordId__c IN (\''+sofiaId+'\', \''+miguelId+'\')';

try {
    List<Map<String, Object>> diagResults = TechProfile360Service.executeDataCloudQuery(qDiag);
    System.debug('DIAGNOSTICOS_ENCONTRADOS: ' + (diagResults.isEmpty() ? 'NINGUNO' : JSON.serialize(diagResults)));

    List<Map<String, Object>> linkResults = TechProfile360Service.executeDataCloudQuery(qLink);
    System.debug('VINCULOS_IDENTIDAD: ' + (linkResults.isEmpty() ? 'SIN VINCULOS' : JSON.serialize(linkResults)));

} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
