// Script to find real clients with appointments in Data Cloud using the SQL API
String query = 'SELECT u.ssot__FirstName__c AS Nombre, u.ssot__LastName__c AS Apellido, u.Id_TuoTempo__c AS ID_Citas, cita.activityTitle__c AS Servicio, cita.estatus_cita__c AS Status_Cita ' +
               'FROM UnifiedssotIndividualDev2__dlm AS u ' +
               'INNER JOIN TUOTEMPO_CITA__dlm AS cita ON u.Id_TuoTempo__c = cita.memberid__c ' +
               'WHERE u.Id_TuoTempo__c IS NOT NULL ' +
               'LIMIT 5';

try {
    ConnectApi.CdpQueryInput queryInput = new ConnectApi.CdpQueryInput();
    queryInput.sql = query;
    
    ConnectApi.CdpQueryOutput response = ConnectApi.CdpQuery.queryANSISql(queryInput);
    
    if (response != null && response.data != null && !response.data.isEmpty()) {
        System.debug('--- CLIENTES CON CITAS EN DATA CLOUD ---');
        for (Object row : response.data) {
            Map<String, Object> rowData = (Map<String, Object>)row;
            System.debug('Nombre: ' + rowData.get('Nombre') + ' ' + rowData.get('Apellido'));
            System.debug('ID TuoTempo: ' + rowData.get('ID_Citas'));
            System.debug('Servicio: ' + rowData.get('Servicio'));
            System.debug('Status: ' + rowData.get('Status_Cita'));
            System.debug('---------------------------------------');
        }
    } else {
        System.debug('No se encontraron clientes con citas registradas en Data Cloud.');
    }
} catch (Exception e) {
    System.debug('Error ejecutando consulta Data Cloud: ' + e.getMessage());
    System.debug('StackTrace: ' + e.getStackTraceString());
}
