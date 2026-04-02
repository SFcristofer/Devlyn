// Script de Búsqueda de Perfil 360 Maestro (Caso de Prueba Perfecto)
String sql = 'SELECT link.UnifiedRecordId__c, count(ord.ssot__Id__c) as total_orders, count(diag.FECHA__c) as total_exams, count(cita.activity_lid__c) as total_citas ' +
             'FROM UnifiedLinkssotIndividualDev2__dlm AS link ' +
             'LEFT JOIN ssot__SalesOrder__dlm AS ord ON link.SourceRecordId__c = ord.ssot__SoldToCustomerId__c ' +
             'LEFT JOIN POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm AS diag ON link.SourceRecordId__c = diag.ID_CLIENTE__c ' +
             'LEFT JOIN TUOTEMPO_CITA__dlm AS cita ON link.SourceRecordId__c = cita.memberid__c ' +
             'GROUP BY link.UnifiedRecordId__c ' +
             'HAVING count(ord.ssot__Id__c) > 0 AND count(diag.FECHA__c) > 0 ' +
             'ORDER BY total_orders DESC, total_exams DESC LIMIT 5';

System.debug('--- BUSCANDO CLIENTE CON PERFIL 360 COMPLETO (TEST CASE) ---');

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    if (!results.isEmpty()) {
        System.debug('CLIENTES_POTENCIALES_ENCONTRADOS: ' + results.size());
        for (Map<String, Object> r : results) {
            System.debug('UNIFIED_ID: ' + r.get('UnifiedRecordId__c') + 
                         ' | ORDENES: ' + r.get('total_orders') + 
                         ' | EXAMENES: ' + r.get('total_exams') + 
                         ' | CITAS: ' + r.get('total_citas'));
        }
    } else {
        System.debug('SIN_RESULTADOS: No se encontró un cliente con datos en todas las tablas simultáneamente.');
    }
} catch (Exception e) {
    System.debug('ERROR_SQL: ' + e.getMessage());
}
