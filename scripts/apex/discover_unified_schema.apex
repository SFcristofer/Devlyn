// Script to discover available fields by querying one full record
String query = 'SELECT * FROM UnifiedssotIndividualDev2__dlm WHERE Id_TuoTempo__c IS NOT NULL LIMIT 1';

try {
    ConnectApi.CdpQueryInput queryInput = new ConnectApi.CdpQueryInput();
    queryInput.sql = query;
    
    ConnectApi.CdpQueryOutput response = ConnectApi.CdpQuery.queryANSISql(queryInput);
    
    if (response != null && response.data != null && !response.data.isEmpty()) {
        System.debug('--- ESTRUCTURA DE REGISTRO UNIFICADO ---');
        System.debug(JSON.serializePretty(response.data[0]));
    }
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}
