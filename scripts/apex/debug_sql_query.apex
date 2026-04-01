// Script para ejecutar la Query Maestra (DMO + DLM) sugerida
String sql = 'SELECT u.ssot__FirstName__c, u.ssot__LastName__c, d.MIOPIA__c, d.ASTIGMATISMO__c ' +
             'FROM UnifiedssotIndividualDev2__dlm u ' +
             'JOIN POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm d ON u.ssot__Id__c = d.ID_CLIENTE__c ' +
             'WHERE u.Id_POS__c = \'12388500\' LIMIT 1';

System.debug('--- EJECUTANDO QUERY MAESTRA DE DATACLOUD (DMO JOIN DLM) ---');

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    
    if (results.isEmpty()) {
        System.debug('RESULTADO_SQL: Vacío. Esto confirma que el ID Unificado de Juan Pérez no tiene un registro vinculado en la tabla de Diagnóstico hoy.');
        
        // Prueba de diagnóstico: ¿Existe el ID de Juan Pérez en la tabla de diagnóstico pero con otro campo?
        String checkDlm = 'SELECT ID_CLIENTE__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE ID_CLIENTE__c LIKE \'%12388500%\' LIMIT 1';
        List<Map<String, Object>> resDlm = TechProfile360Service.executeDataCloudQuery(checkDlm);
        if(!resDlm.isEmpty()) {
            System.debug('DETECCIÓN_CRÍTICA: El ID existe en Diagnóstico pero como POS ID, no como Unified ID. El JOIN falló por desajuste de llaves.');
        }
    } else {
        System.debug('RESULTADO_SQL_EXITO: ' + JSON.serialize(results[0]));
    }
} catch (Exception e) {
    System.debug('ERROR_SQL_MAESTRO: ' + e.getMessage());
}
