// Consulta Maestra para encontrar clientes con Citas Reales y sus datos de búsqueda
String sql = 'SELECT link.UnifiedRecordId__c, ind.ssot__FirstName__c, ind.ssot__LastName__c, ind.Id_POS__c, ind.Email__c, count(cita.activity_lid__c) as total_citas ' +
             'FROM TUOTEMPO_CITA__dlm AS cita ' +
             'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON cita.memberid__c = link.SourceRecordId__c ' +
             'JOIN UnifiedssotIndividualDev2__dlm AS ind ON link.UnifiedRecordId__c = ind.ssot__Id__c ' +
             'GROUP BY link.UnifiedRecordId__c, ind.ssot__FirstName__c, ind.ssot__LastName__c, ind.Id_POS__c, ind.Email__c ' +
             'ORDER BY total_citas DESC LIMIT 5';

try {
    System.debug('--- BUSCANDO REGISTROS REALES CON CITAS ---');
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    if (!results.isEmpty()) {
        for (Map<String, Object> r : results) {
            System.debug('CLIENTE_CON_CITAS: Nombre=' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + 
                         ' | IdPOS=' + r.get('Id_POS__c') + 
                         ' | Email=' + r.get('Email__c') + 
                         ' | Citas=' + r.get('total_citas') +
                         ' | UnifiedID=' + r.get('UnifiedRecordId__c'));
        }
    } else {
        System.debug('SIN_RESULTADOS: No se encontraron cruces directos. Buscando por tabla base...');
        // Plan B: Buscar en Individual base si la unificada falla
        String sqlB = 'SELECT ind.ssot__FirstName__c, ind.ssot__LastName__c, ind.Id_POS__c, count(cita.activity_lid__c) as c ' +
                      'FROM TUOTEMPO_CITA__dlm AS cita ' +
                      'JOIN ssot__Individual__dlm AS ind ON cita.memberid__c = ind.ssot__Id__c ' +
                      'GROUP BY ind.ssot__FirstName__c, ind.ssot__LastName__c, ind.Id_POS__c ORDER BY c DESC LIMIT 5';
        List<Map<String, Object>> resB = TechProfile360Service.executeDataCloudQuery(sqlB);
        for(Map<String, Object> r : resB) {
            System.debug('CLIENTE_INDIVIDUAL_CON_CITAS: Nombre=' + r.get('ssot__FirstName__c') + ' | ID=' + r.get('Id_POS__c'));
        }
    }
} catch (Exception e) {
    System.debug('ERROR_CRÍTICO: ' + e.getMessage());
}
