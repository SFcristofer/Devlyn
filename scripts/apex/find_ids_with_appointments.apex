// Script para encontrar IDs reales con Citas que ya están en el Link Unified
String sql = 'SELECT link.SourceRecordId__c, count(cita.activity_lid__c) as total_citas ' +
             'FROM TUOTEMPO_CITA__dlm AS cita ' +
             'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON cita.memberid__c = link.SourceRecordId__c ' +
             'GROUP BY link.SourceRecordId__c ' +
             'ORDER BY total_citas DESC LIMIT 5';

try {
    System.debug('--- BUSCANDO IDs CON CITAS VINCULADAS ---');
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    if (!results.isEmpty()) {
        for (Map<String, Object> r : results) {
            System.debug('ID_CON_CITAS_ENCONTRADO: POS_ID=' + r.get('SourceRecordId__c') + ' | Citas=' + r.get('total_citas'));
        }
    } else {
        System.debug('SIN_CRUCE: Buscando cualquier ID con citas directamente...');
        String sqlAny = 'SELECT memberid__c, count(activity_lid__c) as c FROM TUOTEMPO_CITA__dlm GROUP BY memberid__c ORDER BY c DESC LIMIT 5';
        List<Map<String, Object>> resAny = TechProfile360Service.executeDataCloudQuery(sqlAny);
        for(Map<String, Object> r : resAny) {
            System.debug('ID_CON_CITAS_DIRECTO: POS_ID=' + r.get('memberid__c') + ' | Citas=' + r.get('c'));
        }
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
