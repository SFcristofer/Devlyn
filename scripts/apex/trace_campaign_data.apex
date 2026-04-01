// Script de validación para Query Multicanal de Marketing
String sql = 'SELECT e.ssot__SubjectLineTxt__c, e.ssot__EngagementDateTm__c, e.ssot__Id__c ' +
             'FROM ssot__EmailEngagement__dlm e ' +
             'JOIN UnifiedssotIndividualDev2__dlm i ON e.ssot__IndividualId__c = i.ssot__Id__c ' +
             'WHERE i.Id_POS__c = \'12388500\' OR i.Email__c LIKE \'%jsancjas%\' ' +
             'LIMIT 10';

System.debug('--- VALIDANDO QUERY MULTICANAL DE MARKETING ---');

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    
    if (results.isEmpty()) {
        System.debug('RESULTADO: La query es sintácticamente perfecta (Sin error 400), pero el cliente no tiene interacción de marketing registrada aún en el Lago de Datos.');
    } else {
        System.debug('RESULTADO_EXITO: ' + JSON.serialize(results));
    }
} catch (Exception e) {
    System.debug('ERROR_SINTAXIS_SQL: ' + e.getMessage());
}
