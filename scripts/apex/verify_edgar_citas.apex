// Script de Rastreo de Identidad Real para Citas
try {
    System.debug('--- BUSCANDO COINCIDENCIA REAL DE CITAS ---');
    // 1. Buscamos citas y su vínculo unificado en un solo paso
    String sql = 'SELECT ind.ssot__FirstName__c, ind.ssot__LastName__c, ind.Id_POS__c, ind.ssot__Id__c, count(cita.activity_lid__c) as c ' +
                 'FROM TUOTEMPO_CITA__dlm AS cita ' +
                 'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON cita.memberid__c = link.SourceRecordId__c ' +
                 'JOIN UnifiedssotIndividualDev2__dlm AS ind ON link.UnifiedRecordId__c = ind.ssot__Id__c ' +
                 'GROUP BY ind.ssot__FirstName__c, ind.ssot__LastName__c, ind.Id_POS__c, ind.ssot__Id__c ' +
                 'ORDER BY c DESC LIMIT 3';
    
    List<Map<String, Object>> res = TechProfile360Service.executeDataCloudQuery(sql);
    
    if(!res.isEmpty()) {
        for(Map<String, Object> r : res) {
            System.debug('REGISTRO_VALIDO: ' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + 
                         ' | POS_ID: ' + r.get('Id_POS__c') + 
                         ' | UnifiedID: ' + r.get('ssot__Id__c') + 
                         ' | Citas: ' + r.get('c'));
        }
    } else {
        System.debug('NO_HAY_CRUCES_UNIFICADOS. Buscando en tabla Individual base...');
        String sqlInd = 'SELECT ind.ssot__FirstName__c, ind.ssot__LastName__c, ind.Id_POS__c, count(cita.activity_lid__c) as c ' +
                        'FROM TUOTEMPO_CITA__dlm AS cita ' +
                        'JOIN ssot__Individual__dlm AS ind ON cita.memberid__c = ind.ssot__Id__c ' +
                        'GROUP BY ind.ssot__FirstName__c, ind.ssot__LastName__c, ind.Id_POS__c ORDER BY c DESC LIMIT 3';
        List<Map<String, Object>> resInd = TechProfile360Service.executeDataCloudQuery(sqlInd);
        for(Map<String, Object> r : resInd) {
            System.debug('REGISTRO_INDIVIDUAL: ' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + 
                         ' | POS_ID: ' + r.get('Id_POS__c') + ' | Citas: ' + r.get('c'));
        }
    }
} catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }
