// Script para identificar al dueño del ID Unificado que sí tiene citas
String targetUid = '5f4b044b5a691d76503960ef5782d91e';
try {
    System.debug('--- IDENTIFICANDO PERFIL MAESTRO ---');
    String sql = 'SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c ' +
                 'FROM UnifiedssotIndividualDev2__dlm ' +
                 'WHERE ssot__Id__c = \'' + targetUid + '\' LIMIT 1';
    
    List<Map<String, Object>> res = TechProfile360Service.executeDataCloudQuery(sql);
    if(!res.isEmpty()) {
        System.debug('PERFIL_ENCONTRADO: Name=' + res[0].get('ssot__FirstName__c') + ' ' + res[0].get('ssot__LastName__c') + 
                     ' | IdPOS=' + res[0].get('Id_POS__c') + 
                     ' | Email=' + res[0].get('Email__c'));
    } else {
        // Si no está en unificados, buscamos en el link para ver su ID de origen
        System.debug('BUSCANDO_EN_LINKS...');
        String sqlLink = 'SELECT SourceRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm WHERE UnifiedRecordId__c = \'' + targetUid + '\' LIMIT 5';
        List<Map<String, Object>> resLink = TechProfile360Service.executeDataCloudQuery(sqlLink);
        for(Map<String, Object> r : resLink) {
            System.debug('SOURCE_ID_RELACIONADO: ' + r.get('SourceRecordId__c'));
        }
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
