// Script para rastrear el nombre real del ID con citas a través del Link
String targetUid = '5f4b044b5a691d76503960ef5782d91e';
try {
    System.debug('--- RASTREANDO IDENTIDAD REAL ---');
    // 1. Buscamos todos los Source IDs vinculados a ese Unified ID
    String sqlLink = 'SELECT SourceRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm WHERE UnifiedRecordId__c = \'' + targetUid + '\'';
    List<Map<String, Object>> links = TechProfile360Service.executeDataCloudQuery(sqlLink);
    
    Set<String> sourceIds = new Set<String>();
    for(Map<String, Object> l : links) sourceIds.add((String)l.get('SourceRecordId__c'));
    
    if(!sourceIds.isEmpty()) {
        System.debug('IDs de origen encontrados: ' + sourceIds);
        // 2. Buscamos los nombres asociados a esos IDs en la tabla Individual
        String idsStr = '(\'' + String.join(new List<String>(sourceIds), '\',\'') + '\')';
        String sqlInd = 'SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c FROM ssot__Individual__dlm WHERE ssot__Id__c IN ' + idsStr;
        List<Map<String, Object>> individuals = TechProfile360Service.executeDataCloudQuery(sqlInd);
        
        for(Map<String, Object> ind : individuals) {
            System.debug('COINCIDENCIA_ENCONTRADA: ' + ind.get('ssot__FirstName__c') + ' ' + ind.get('ssot__LastName__c') + ' | POS_ID: ' + ind.get('Id_POS__c'));
        }
    } else {
        System.debug('No se encontraron links para el ID: ' + targetUid);
    }
} catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }
