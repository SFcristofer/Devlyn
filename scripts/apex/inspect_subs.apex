// Obtenemos un registro para ver qué campos tiene
try {
    String q = 'SELECT Name__c, Status__c, Frequency__c FROM VTEX_Subscription__dlm LIMIT 1';
    List<SObject> res = Database.query(q);
    if (!res.isEmpty()) {
        System.debug('SUBS_DATA: ' + res[0]);
    }
} catch(Exception e) {
    System.debug('SUBS_ERROR: ' + e.getMessage());
}
