// Script para inspeccionar el catálogo de sucursales
String sql = 'SELECT ssot__Id__c, ssot__Name__c FROM ssot__SalesStore__dlm LIMIT 10';

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    if (!results.isEmpty()) {
        for (Map<String, Object> r : results) {
            System.debug('SUCURSAL_DATA_CLOUD: ID=' + r.get('ssot__Id__c') + ' | NOMBRE=' + r.get('ssot__Name__c'));
        }
    } else {
        System.debug('TABLA_VACIA: No hay datos en ssot__SalesStore__dlm');
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
