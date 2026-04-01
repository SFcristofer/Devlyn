// Script to get full contact details for clients with appointments
String query = 'SELECT u.ssot__FirstName__c AS Nombre, u.ssot__LastName__c AS Apellido, u.Id_POS__c AS ID_Tienda, u.Id_TuoTempo__c AS ID_Citas, u.email__c AS Correo, u.phone__c AS Telefono ' +
               'FROM UnifiedssotIndividualDev2__dlm AS u ' +
               'WHERE u.Id_TuoTempo__c IN (\'sc166186dce81231\', \'sc163ed4e39a64cb\', \'sc164a5cbdfaf3f1\')';

try {
    ConnectApi.CdpQueryInput queryInput = new ConnectApi.CdpQueryInput();
    queryInput.sql = query;
    
    ConnectApi.CdpQueryOutput response = ConnectApi.CdpQuery.queryANSISql(queryInput);
    
    if (response != null && response.data != null && !response.data.isEmpty()) {
        System.debug('--- DATOS COMPLETOS 360 PARA CLIENTES CON CITAS ---');
        for (Object row : response.data) {
            Map<String, Object> rowData = (Map<String, Object>)row;
            System.debug('NOMBRE COMPLETO: ' + rowData.get('Nombre') + ' ' + rowData.get('Apellido'));
            System.debug('ID POS (Tienda): ' + rowData.get('ID_Tienda'));
            System.debug('ID TUOTEMPO: ' + rowData.get('ID_Citas'));
            System.debug('CORREO: ' + rowData.get('Correo'));
            System.debug('TELÉFONO: ' + rowData.get('Telefono'));
            System.debug('---------------------------------------');
        }
    } else {
        // If query failed with full fields, try basic fields only to avoid errors
        System.debug('Fallo consulta detallada, intentando campos base...');
        String queryBase = 'SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Id_TuoTempo__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_TuoTempo__c IS NOT NULL LIMIT 5';
        queryInput.sql = queryBase;
        response = ConnectApi.CdpQuery.queryANSISql(queryInput);
        if (response != null && response.data != null) {
            for (Object row : response.data) {
                System.debug('REGISTRO_BASE: ' + JSON.serialize(row));
            }
        }
    }
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}
