// Consulta absoluta para el paciente confirmado
String posId = '13218258';
String sql = 'SELECT * FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE ID_CLIENTE__c = \'' + posId + '\' LIMIT 1';

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    if (results.isEmpty()) {
        System.debug('ERROR: No se pudo recuperar el registro completo para el ID ' + posId);
    } else {
        System.debug('--- EXPEDIENTE TOTAL Y ABSOLUTO ---');
        for (String key : results[0].keySet()) {
            System.debug('CAMPO: ' + key + ' | VALOR: ' + results[0].get(key));
        }
    }
} catch (Exception e) {
    System.debug('ERROR_TECNICO: ' + e.getMessage());
}
