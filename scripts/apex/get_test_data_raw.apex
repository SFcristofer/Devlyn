// Buscamos cualquier cliente que tenga al menos un diagnóstico registrado
String sql = 'SELECT diag.ID_CLIENTE__c, diag.MIOPIA__c, diag.ASTIGMATISMO__c, diag.HIPERMETROPIA__c, diag.PRESBICIA__c, diag.FECHA__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm AS diag LIMIT 1';

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    if (results.isEmpty()) {
        System.debug('AVISO: La tabla de diagnósticos parece estar vacía en esta instancia.');
    } else {
        System.debug('REGISTRO_ENCONTRADO: ' + JSON.serializePretty(results[0]));
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
