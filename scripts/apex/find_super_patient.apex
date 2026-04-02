// Script para encontrar al "Súper Paciente" (Salud + Graduaciones Reales)
String sql = 'SELECT link.UnifiedRecordId__c, count(ant.FECHA__c) as total_antecedentes, count(grad.FECHA__c) as total_graduaciones ' +
             'FROM UnifiedLinkssotIndividualDev2__dlm AS link ' +
             'JOIN POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm AS ant ON link.SourceRecordId__c = ant.ID_CLIENTE__c ' +
             'JOIN ssot__SalesOrder__dlm AS ord ON link.SourceRecordId__c = ord.ssot__SoldToCustomerId__c ' +
             'JOIN POS_POS_GRADUACION_PEDIDO__dlm AS grad ON ord.ssot__Id__c = grad.ID_PEDIDO__c ' +
             'GROUP BY link.UnifiedRecordId__c ' +
             'HAVING count(ant.FECHA__c) > 0 AND count(grad.FECHA__c) > 0 ' +
             'LIMIT 3';

System.debug('--- BUSCANDO CLIENTE CON EXPEDIENTE COMPLETO (SALUD + GRADUACIÓN) ---');

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    if (!results.isEmpty()) {
        for (Map<String, Object> r : results) {
            System.debug('SUPER_PACIENTE_ENCONTRADO: UnifiedID=' + r.get('UnifiedRecordId__c') + 
                         ' | Antecedentes=' + r.get('total_antecedentes') + 
                         ' | Graduaciones=' + r.get('total_graduaciones'));
        }
    } else {
        // Si no hay cruce perfecto, buscaremos el mejor ID de Antecedentes con Notas
        System.debug('SIN_CRUCE_PERFECTO: Buscando el mejor ID con Notas Médicas...');
        String sqlNotes = 'SELECT ID_CLIENTE__c, NOTAS__c FROM POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm WHERE NOTAS__c != \'\' ORDER BY FECHA__c DESC LIMIT 1';
        List<Map<String, Object>> resNotes = TechProfile360Service.executeDataCloudQuery(sqlNotes);
        if(!resNotes.isEmpty()) {
            System.debug('MEJOR_ID_NOTAS (POS ID): ' + resNotes[0].get('ID_CLIENTE__c') + ' | Notas: ' + resNotes[0].get('NOTAS__c'));
        }
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
