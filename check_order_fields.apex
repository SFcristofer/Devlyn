String sql = 'SELECT * FROM ssot__SalesOrder__dlm LIMIT 1';
List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
if(!results.isEmpty()) {
    System.debug('--- CAMPOS REALES DE SALESORDER ---');
    System.debug(JSON.serialize(results[0].keySet()));
} else {
    System.debug('NO HAY REGISTROS');
}
