// Buscamos IDs de clientes que tengan suscripciones reales
String q = 'SELECT CustomerId__c FROM VTEX_Subscription__dlm WHERE CustomerId__c != null LIMIT 10';
List<SObject> subs = Database.query(q);

if (subs.isEmpty()) {
    System.debug('TEST_SUBS: No se encontraron suscripciones vinculadas a IDs de cliente.');
} else {
    Set<String> posIds = new Set<String>();
    for(SObject s : subs) posIds.add((String)s.get('CustomerId__c'));
    
    // Obtenemos los nombres de estos clientes para que el usuario los reconozca
    List<UnifiedssotIndividualDev2__dlm> profiles = [SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c IN :posIds];
    
    for (UnifiedssotIndividualDev2__dlm p : profiles) {
        System.debug('REGISTRO_CON_SUSCRIPCION: ' + p.ssot__FirstName__c + ' ' + p.ssot__LastName__c + ' | ID POS: ' + p.Id_POS__c);
    }
    
    if(profiles.isEmpty()) {
        System.debug('TEST_SUBS: Las suscripciones existen con IDs: ' + posIds + ' pero esos IDs no están unificados aún.');
    }
}
