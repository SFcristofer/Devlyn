// Buscamos los IDs de POS que tengan más órdenes registradas
String query = 'SELECT ssot__SoldToCustomerId__c, COUNT(ssot__Id__c) cnt ' +
               'FROM ssot__SalesOrder__dlm ' +
               'WHERE ssot__SoldToCustomerId__c != null ' +
               'GROUP BY ssot__SoldToCustomerId__c ' +
               'ORDER BY COUNT(ssot__Id__c) DESC ' +
               'LIMIT 10';

List<AggregateResult> results = Database.query(query);
for (AggregateResult ar : results) {
    String posId = (String)ar.get('ssot__SoldToCustomerId__c');
    Integer count = (Integer)ar.get('cnt');
    
    // Obtenemos el nombre del cliente
    List<UnifiedssotIndividualDev2__dlm> names = [SELECT ssot__FirstName__c, ssot__LastName__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = :posId LIMIT 1];
    String name = !names.isEmpty() ? names[0].ssot__FirstName__c + ' ' + names[0].ssot__LastName__c : 'Desconocido';
    
    System.debug('CLIENTE_CON_ORDENES: ' + name + ' | ID POS: ' + posId + ' | Total Ordenes: ' + count);
}
