String posId = '12083967';
String query = 'SELECT ASTIGMATISMO__c, HIPERMETROPIA__c, MIOPIA__c, PRESBICIA__c, FECHA__c ' +
               'FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm ' +
               'WHERE ID_CLIENTE__c = :posId ' +
               'ORDER BY FECHA__c DESC LIMIT 1';

List<SObject> results = Database.query(query);
if (!results.isEmpty()) {
    SObject diag = results[0];
    System.debug('DIAGNOSTICO_REAL: Fecha: ' + diag.get('FECHA__c') + 
                 ' | Astigmatismo: ' + diag.get('ASTIGMATISMO__c') + 
                 ' | Miopia: ' + diag.get('MIOPIA__c') + 
                 ' | Hipermetropia: ' + diag.get('HIPERMETROPIA__c') + 
                 ' | Presbicia: ' + diag.get('PRESBICIA__c'));
} else {
    System.debug('DIAGNOSTICO_REAL: No se encontraron resultados.');
}
