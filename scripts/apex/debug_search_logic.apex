// Script para debuggear el buscador paso a paso
String term = '11130638';
String cleanTerm = term.trim().replace('á','a').replace('é','e').replace('í','i').replace('ó','o').replace('ú','u');
List<String> tokens = cleanTerm.split('\\s+');
Map<String, Object> bindMap = new Map<String, Object>{ 'idsFromPhones' => new List<String>{'NONE'}, 'emailPat' => '%' + cleanTerm + '%' };
for(Integer i=0; i<tokens.size(); i++) bindMap.put('p'+i, '%' + tokens[i].toUpperCase() + '%');

try {
    System.debug('--- DEBUG PASO A PASO DEL BUSCADOR ---');
    
    // 1. Probar Fase 0 (Link)
    String sqlLink = 'SELECT UnifiedRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm WHERE SourceRecordId__c = \'' + term + '\' LIMIT 1';
    List<Map<String, Object>> linkRows = TechProfile360Service.executeDataCloudQuery(sqlLink);
    System.debug('Fase 0 (Link) encontró: ' + linkRows.size());

    // 2. Probar Fase 1 (Unificada)
    String q1 = 'SELECT count() FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c LIKE :p0';
    Integer countUni = Database.countQueryWithBinds(q1, bindMap, AccessLevel.USER_MODE);
    System.debug('Fase 1 (Unificada) encontró: ' + countUni);

    // 3. Probar Fase 4 (Rescate Individual)
    String qRes = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM ssot__Individual__dlm WHERE Id_POS__c LIKE :p0';
    List<SObject> resInd = Database.queryWithBinds(qRes, bindMap, AccessLevel.USER_MODE);
    System.debug('Fase 4 (Rescate) encontró: ' + resInd.size());
    if(!resInd.isEmpty()) {
        System.debug('DATOS_RESCATE: ' + resInd[0].get('ssot__FirstName__c') + ' | POS: ' + resInd[0].get('Id_POS__c'));
    }

} catch (Exception e) { System.debug('ERROR_DEBUG: ' + e.getMessage()); }
