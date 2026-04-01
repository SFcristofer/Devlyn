// Script to check if TUOTEMPO_CITA__dlm has data
String query = 'SELECT memberid__c, activityTitle__c, estatus_cita__c FROM TUOTEMPO_CITA__dlm LIMIT 5';

try {
    ConnectApi.CdpQueryInput queryInput = new ConnectApi.CdpQueryInput();
    queryInput.sql = query;
    
    ConnectApi.CdpQueryOutput response = ConnectApi.CdpQuery.queryANSISql(queryInput);
    
    if (response != null && response.data != null && !response.data.isEmpty()) {
        System.debug('--- CITAS ENCONTRADAS EN DATA CLOUD ---');
        for (Object row : response.data) {
            Map<String, Object> rowData = (Map<String, Object>)row;
            System.debug('ID TuoTempo: ' + rowData.get('memberid__c'));
            System.debug('Servicio: ' + rowData.get('activityTitle__c'));
            System.debug('Status: ' + rowData.get('estatus_cita__c'));
            System.debug('---------------------------------------');
        }
    } else {
        System.debug('No se encontraron registros en TUOTEMPO_CITA__dlm.');
    }
} catch (Exception e) {
    System.debug('Error ejecutando consulta Data Cloud: ' + e.getMessage());
}
