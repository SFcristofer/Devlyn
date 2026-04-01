String posId = '13227215';
System.debug('--- BUSCANDO CUALQUIER DATO PARA EL CLIENTE ' + posId + ' ---');

// 1. Buscamos en el Individuo Unificado para ver si el ID existe realmente
String q1 = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c LIKE \'%' + posId + '%\' LIMIT 1';

// 2. Buscamos en Ventas para ver si tiene historial
String q2 = 'SELECT ssot__OrderNumber__c, ssot__TotalAmount__c FROM ssot__SalesOrder__dlm WHERE ssot__SoldToCustomerId__c LIKE \'%' + posId + '%\' LIMIT 1';

try {
    List<Map<String, Object>> res1 = TechProfile360Service.executeDataCloudQuery(q1);
    System.debug('PERFIL_UNIFICADO: ' + (res1.isEmpty() ? 'NO EXISTE' : JSON.serialize(res1[0])));

    List<Map<String, Object>> res2 = TechProfile360Service.executeDataCloudQuery(q2);
    System.debug('HISTORIAL_VENTAS: ' + (res2.isEmpty() ? 'SIN VENTAS' : JSON.serialize(res2[0])));
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
