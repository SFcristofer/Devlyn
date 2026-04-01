// Script to get 360 search data using SOQL
try {
    List<SObject> profiles = Database.query('SELECT ssot__FirstName__c, ssot__LastName__c, Email__c, Id_POS__c, Id_TuoTempo__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_TuoTempo__c IN (\'sc166186dce81231\', \'sc163ed4e39a64cb\', \'sc164a5cbdfaf3f1\', \'sc16397d89d3ac80\', \'sc165cbc7d492d76\')');
    
    System.debug('--- FICHA 360: CLIENTES CON CITAS (VIA SOQL) ---');
    for (SObject p : profiles) {
        System.debug('CLIENTE: ' + p.get('ssot__FirstName__c') + ' ' + p.get('ssot__LastName__c'));
        System.debug('EMAIL: ' + p.get('Email__c'));
        System.debug('ID_POS: ' + p.get('Id_POS__c'));
        System.debug('ID_TUOTEMPO: ' + p.get('Id_TuoTempo__c'));
        System.debug('---------------------------------------');
    }
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}
