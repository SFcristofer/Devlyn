// Script para encontrar IDs Unificados con Citas de TuoTempo reales
String sql = 'SELECT cust.ssot__FirstName__c, cust.ssot__LastName__c, cust.Id_POS__c, count(cita.activity_lid__c) as total_citas ' +
             'FROM UnifiedssotIndividualDev2__dlm AS cust ' +
             'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON cust.ssot__Id__c = link.UnifiedRecordId__c ' +
             'JOIN TUOTEMPO_CITA__dlm AS cita ON link.SourceRecordId__c = cita.memberid__c ' +
             'GROUP BY cust.ssot__FirstName__c, cust.ssot__LastName__c, cust.Id_POS__c ' +
             'ORDER BY total_citas DESC LIMIT 5';

System.debug('--- BUSCANDO CLIENTES UNIFICADOS CON CITAS REALES ---');

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    if (!results.isEmpty()) {
        for (Map<String, Object> r : results) {
            System.debug('CLIENTE_CON_CITAS: Name=' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + 
                         ' | IdPOS=' + r.get('Id_POS__c') + 
                         ' | TotalCitas=' + r.get('total_citas'));
        }
    } else {
        System.debug('SIN_RESULTADOS: No hay cruces de unificación con citas en este momento.');
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
