String query = 'SELECT * FROM ssot__SalesOrderProduct__dlm LIMIT 1';
// Como no podemos hacer SELECT *, intentaremos listar campos conocidos y buscar errores
try {
    Database.query('SELECT ESFERA__c FROM ssot__SalesOrderProduct__dlm LIMIT 1');
    System.debug('CAMPO_ENCONTRADO: ESFERA__c en ssot__SalesOrderProduct__dlm');
} catch(Exception e) {
    System.debug('CAMPO_NO_ENCONTRADO: ' + e.getMessage());
}
