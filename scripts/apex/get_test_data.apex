String sql = 'SELECT diag.ID_CLIENTE__c, diag.MIOPIA__c, diag.ASTIGMATISMO__c, diag.HIPERMETROPIA__c, diag.PRESBICIA__c, diag.FECHA__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm AS diag LEFT JOIN UnifiedssotIndividualDev2__dlm AS cust ON diag.ID_CLIENTE__c = cust.Id_POS__c WHERE (cust.ssot__FirstName__c LIKE \'%13218258%\' OR cust.ssot__LastName__c LIKE \'%13218258%\' OR cust.Email__c LIKE \'%13218258%\' OR diag.ID_CLIENTE__c LIKE \'%13218258%\') ORDER BY diag.FECHA__c DESC LIMIT 1';

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    if (results.isEmpty()) {
        System.debug('RESULTADO_DATA_CLOUD: No se encontraron registros para esta consulta.');
    } else {
        System.debug('RESULTADO_DATA_CLOUD: ' + JSON.serializePretty(results[0]));
    }
} catch (Exception e) {
    System.debug('ERROR_CONSULTA: ' + e.getMessage());
}
