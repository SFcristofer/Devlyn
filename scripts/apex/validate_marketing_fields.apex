// Script de validación final para Query de Marketing (Mulesoft Fix)
String unifiedId = '02daf3d6a4f01f33269e7b8b801ef731';
String sql = 'SELECT ssot__SubjectLineTxt__c, ssot__EngagementDateTm__c, ssot__Id__c ' +
             'FROM ssot__EmailEngagement__dlm ' +
             'WHERE ssot__IndividualId__c = \'' + unifiedId + '\' ' +
             'LIMIT 10';

System.debug('--- EJECUTANDO VALIDACIÓN DE MARKETING DATA CLOUD ---');

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    
    if (results.isEmpty()) {
        System.debug('RESULTADO_MARKETING: El registro existe pero no tiene envíos de marketing vinculados en la tabla ssot__EmailEngagement__dlm.');
    } else {
        System.debug('RESULTADO_MARKETING_EXITO: ' + JSON.serialize(results));
    }
} catch (Exception e) {
    System.debug('ERROR_SINTAXIS_SQL: ' + e.getMessage());
}
