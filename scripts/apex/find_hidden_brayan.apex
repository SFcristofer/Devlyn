// Script para localizar a Brayan Javier Díaz "escondido"
try {
    System.debug('--- BUSCANDO A BRAYAN EN TODO EL SISTEMA ---');
    String namePart = '%BRAYAN%';
    
    // 1. Buscamos en la tabla base por nombre
    String sqlInd = 'SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c, ssot__Id__c FROM ssot__Individual__dlm WHERE ssot__FirstName__c LIKE \'' + namePart + '\'';
    List<Map<String, Object>> resInd = TechProfile360Service.executeDataCloudQuery(sqlInd);
    
    for(Map<String, Object> r : resInd) {
        System.debug('REGISTRO_BASE: ' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + ' | POS: ' + r.get('Id_POS__c') + ' | ID_SISTEMA: ' + r.get('ssot__Id__c'));
        
        // 2. Buscamos si este ID base está vinculado a algún perfil unificado diferente
        String sourceId = (String)r.get('ssot__Id__c');
        String sqlLink = 'SELECT UnifiedRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm WHERE SourceRecordId__c = \'' + sourceId + '\' LIMIT 1';
        List<Map<String, Object>> resLink = TechProfile360Service.executeDataCloudQuery(sqlLink);
        if(!resLink.isEmpty()) {
            String uid = (String)resLink[0].get('UnifiedRecordId__c');
            String sqlUni = 'SELECT ssot__FirstName__c, ssot__LastName__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = \'' + uid + '\' LIMIT 1';
            List<Map<String, Object>> resUni = TechProfile360Service.executeDataCloudQuery(sqlUni);
            if(!resUni.isEmpty()) {
                System.debug('  -> ESTÁ UNIFICADO BAJO EL NOMBRE: ' + resUni[0].get('ssot__FirstName__c') + ' ' + resUni[0].get('ssot__LastName__c'));
            }
        }
    }
} catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }
