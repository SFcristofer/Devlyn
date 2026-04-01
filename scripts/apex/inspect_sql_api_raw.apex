// Script para validar la Query SQL exacta de Mulesoft
String sql = 'SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = \'12388500\' LIMIT 1';

try {
    System.debug('--- PROBANDO QUERY SQL DE MULESOFT ---');
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    
    if (results.isEmpty()) {
        System.debug('RESULTADO_SQL: Vacío (Error de datos en el lago)');
    } else {
        System.debug('RESULTADO_SQL_EXITO: ' + JSON.serialize(results[0]));
    }
} catch (Exception e) {
    System.debug('ERROR_SQL_API: ' + e.getMessage());
}
