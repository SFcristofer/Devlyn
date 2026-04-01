// Script de búsqueda de "Golden Records" con datos médicos reales
String query = 'SELECT ID_CLIENTE__c, FECHA__c, MIOPIA__c, ASTIGMATISMO__c, HIPERMETROPIA__c, PRESBICIA__c ' +
               'FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm ' +
               'WHERE MIOPIA__c != NULL OR ASTIGMATISMO__c != NULL ' +
               'ORDER BY FECHA__c DESC LIMIT 5';

System.debug('--- BUSCANDO REGISTROS MÉDICOS REALES EN DATA CLOUD ---');

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(query);
    if (results.isEmpty()) {
        System.debug('RESULTADO: No hay registros con valores de refracción en la tabla de diagnóstico.');
    } else {
        for(Map<String, Object> row : results) {
            System.debug('REGISTRO_ENCONTRADO: ID=' + row.get('ID_CLIENTE__c') + 
                         ' | Fecha=' + row.get('FECHA__c') + 
                         ' | Miopia=' + row.get('MIOPIA__c') + 
                         ' | Astigmatismo=' + row.get('ASTIGMATISMO__c'));
        }
    }
} catch (Exception e) {
    System.debug('ERROR_SQL: ' + e.getMessage());
}
