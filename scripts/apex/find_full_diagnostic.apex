// Script para encontrar un diagnóstico con todos los campos llenos
String query = 'SELECT ID_CLIENTE__c, FECHA__c, ASTIGMATISMO__c, MIOPIA__c, HIPERMETROPIA__c, PRESBICIA__c ' +
               'FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm ' +
               'WHERE FECHA__c != null ' +
               'AND MIOPIA__c != null ' +
               'AND ASTIGMATISMO__c != null ' +
               'ORDER BY FECHA__c DESC LIMIT 5';

try {
    List<SObject> results = Database.query(query);
    if (results.isEmpty()) {
        System.debug('BUSQUEDA_COMPLETA: No se encontraron registros con TODOS los campos. Intentando búsqueda parcial...');
        // Intento con al menos uno lleno
        results = Database.query('SELECT ID_CLIENTE__c, FECHA__c, ASTIGMATISMO__c, MIOPIA__c, HIPERMETROPIA__c, PRESBICIA__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE FECHA__c != null LIMIT 5');
    }

    for (SObject d : results) {
        String posId = (String)d.get('ID_CLIENTE__c');
        System.debug('CANDIDATO_DIAGNOSTICO: ID_POS: ' + posId + 
                     ' | Fecha: ' + d.get('FECHA__c') + 
                     ' | M: ' + d.get('MIOPIA__c') + 
                     ' | A: ' + d.get('ASTIGMATISMO__c') + 
                     ' | H: ' + d.get('HIPERMETROPIA__c') + 
                     ' | P: ' + d.get('PRESBICIA__c'));
        
        // Buscamos el nombre del cliente
        List<UnifiedssotIndividualDev2__dlm> profiles = [SELECT ssot__FirstName__c, ssot__LastName__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = :posId LIMIT 1];
        if(!profiles.isEmpty()) {
            System.debug('NOMBRE_CLIENTE: ' + profiles[0].ssot__FirstName__c + ' ' + profiles[0].ssot__LastName__c);
        }
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
