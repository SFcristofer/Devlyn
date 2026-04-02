// Script para localizar la ubicación real de un cliente (Unificado vs Individual)
String term = 'mvalenciag68@gmail.com';
try {
    System.debug('--- INVESTIGANDO UBICACIÓN DE: ' + term + ' ---');
    
    // 1. ¿Está en Unificados?
    List<SObject> uni = Database.query('SELECT ssot__Id__c FROM UnifiedssotIndividualDev2__dlm WHERE Email__c = \'' + term + '\' LIMIT 1');
    System.debug('¿EN_UNIFICADOS?: ' + (!uni.isEmpty()));

    // 2. ¿Está en Individual (Base)?
    List<SObject> ind = Database.query('SELECT ssot__Id__c FROM ssot__Individual__dlm WHERE ssot__Email__c = \'' + term + '\' LIMIT 1');
    System.debug('¿EN_INDIVIDUAL?: ' + (!ind.isEmpty()));

    // 3. ¿Tiene citas?
    String sqlCita = 'SELECT count(activity_lid__c) as c FROM TUOTEMPO_CITA__dlm WHERE memberid__c = \'' + term + '\'';
    List<Map<String, Object>> resCita = TechProfile360Service.executeDataCloudQuery(sqlCita);
    System.debug('CITAS_ENCONTRADAS: ' + resCita[0].get('c'));

} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
