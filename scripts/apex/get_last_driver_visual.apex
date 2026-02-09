String posId = '12083967';
String query = 'SELECT NIVEL_VISION__c, TIPO_USUARIO__c, SOLUCION_VISUAL_BUSCA__c, VALOR_RAZON_VISITA__c, FECHA__c ' +
               'FROM POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm ' +
               'WHERE ID_CLIENTE__c = :posId ' +
               'ORDER BY FECHA__c DESC LIMIT 1';

List<SObject> results = Database.query(query);
if (!results.isEmpty()) {
    SObject driver = results[0];
    System.debug('DRIVER_VISUAL_REAL: Fecha: ' + driver.get('FECHA__c') + 
                 ' | Nivel Vision: ' + driver.get('NIVEL_VISION__c') + 
                 ' | Tipo Usuario: ' + driver.get('TIPO_USUARIO__c') + 
                 ' | Solucion: ' + driver.get('SOLUCION_VISUAL_BUSCA__c') + 
                 ' | Razon: ' + driver.get('VALOR_RAZON_VISITA__c'));
} else {
    System.debug('DRIVER_VISUAL_REAL: No se encontraron resultados.');
}
