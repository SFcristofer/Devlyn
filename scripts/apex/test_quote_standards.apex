try {
    String q = 'SELECT ssot__Id__c FROM ssot__SalesQuote__dlm LIMIT 1';
    Database.query(q);
    System.debug('DMO_FOUND: ssot__SalesQuote__dlm');
} catch(Exception e) {
    System.debug('DMO_NOT_FOUND: ssot__SalesQuote__dlm');
}

try {
    String q = 'SELECT ssot__Id__c FROM ssot__Quote__dlm LIMIT 1';
    Database.query(q);
    System.debug('DMO_FOUND: ssot__Quote__dlm');
} catch(Exception e) {
    System.debug('DMO_NOT_FOUND: ssot__Quote__dlm');
}
