try {
    String q = 'SELECT ssot__OrderStatusId__c FROM ssot__SalesOrder__dlm LIMIT 1';
    Database.query(q);
    System.debug('FIELD_CHECK: ssot__OrderStatusId__c existe');
} catch(Exception e) {
    System.debug('FIELD_CHECK: Error - ' + e.getMessage());
}
