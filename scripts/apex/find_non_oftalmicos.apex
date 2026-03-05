List<SObject> nonOftalmicos = Database.query('SELECT ssot__SalesOrderId__c, ssot__Description__c FROM ssot__SalesOrderProduct__dlm WHERE ssot__Description__c LIKE \'%SOLAR%\' OR ssot__Description__c LIKE \'%CONTACTO%\' LIMIT 10');
for(SObject p : nonOftalmicos) {
    String orderId = (String)p.get('ssot__SalesOrderId__c');
    String descripcion = (String)p.get('ssot__Description__c');
    List<SObject> orders = Database.query('SELECT ssot__SoldToCustomerId__c FROM ssot__SalesOrder__dlm WHERE ssot__Id__c = \'' + orderId + '\' LIMIT 1');
    if(!orders.isEmpty()) {
        String posId = (String)orders[0].get('ssot__SoldToCustomerId__c');
        List<UnifiedssotIndividualDev2__dlm> profiles = [SELECT ssot__FirstName__c, ssot__LastName__c, ssot__Id__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = :posId LIMIT 1];
        if(!profiles.isEmpty()) {
            UnifiedssotIndividualDev2__dlm prof = profiles[0];
            System.debug('CLIENTE_ENCONTRADO: ' + prof.ssot__FirstName__c + ' ' + prof.ssot__LastName__c);
            System.debug('ID_POS: ' + prof.Id_POS__c);
            System.debug('ID_UNIFICADO: ' + prof.ssot__Id__c);
            System.debug('PRODUCTO_NO_OFTALMICO: ' + descripcion);
            System.debug('---');
        }
    }
}