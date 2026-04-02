// Script para encontrar IDs con datos por categoría
try {
    System.debug('--- BUSCANDO IDs POR CATEGORÍA ---');

    // 1. Cliente con más Órdenes (Ecommerce + Retail)
    String q1 = 'SELECT ssot__SoldToCustomerId__c, count(ssot__Id__c) as c FROM ssot__SalesOrder__dlm GROUP BY ssot__SoldToCustomerId__c ORDER BY c DESC LIMIT 1';
    List<Map<String, Object>> res1 = TechProfile360Service.executeDataCloudQuery(q1);
    if(!res1.isEmpty()) System.debug('CLIENTE_CON_VENTAS (POS ID): ' + res1[0].get('ssot__SoldToCustomerId__c') + ' | Compras: ' + res1[0].get('c'));

    // 2. Cliente con Diagnóstico Médico
    String q2 = 'SELECT ID_CLIENTE__c, FECHA__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm ORDER BY FECHA__c DESC LIMIT 1';
    List<Map<String, Object>> res2 = TechProfile360Service.executeDataCloudQuery(q2);
    if(!res2.isEmpty()) System.debug('CLIENTE_CON_DIAGNOSTICO (POS ID): ' + res2[0].get('ID_CLIENTE__c'));

    // 3. Cliente con Citas (TuoTempo)
    String q3 = 'SELECT memberid__c, count(activity_lid__c) as c FROM TUOTEMPO_CITA__dlm GROUP BY memberid__c ORDER BY c DESC LIMIT 1';
    List<Map<String, Object>> res3 = TechProfile360Service.executeDataCloudQuery(q3);
    if(!res3.isEmpty()) System.debug('CLIENTE_CON_CITAS (TT ID): ' + res3[0].get('memberid__c'));

    // 4. Buscar un ID Unificado que tenga al menos algo
    String q4 = 'SELECT UnifiedRecordId__c, SourceRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm LIMIT 5';
    List<Map<String, Object>> res4 = TechProfile360Service.executeDataCloudQuery(q4);
    if(!res4.isEmpty()) {
        for(Map<String, Object> r : res4) {
            System.debug('EJEMPLO_UNIFIED_LINK: Unified=' + r.get('UnifiedRecordId__c') + ' | Source=' + r.get('SourceRecordId__c'));
        }
    }

} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
