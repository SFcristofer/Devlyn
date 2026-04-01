// Script to get 360 search data for clients with appointments
String query = 'SELECT ssot__FirstName__c, ssot__LastName__c, Email__c, Id_POS__c, Id_TuoTempo__c ' +
               'FROM UnifiedssotIndividualDev2__dlm ' +
               'WHERE Id_TuoTempo__c IN (\'sc166186dce81231\', \'sc163ed4e39a64cb\', \'sc164a5cbdfaf3f1\', \'sc16397d89d3ac80\', \'sc165cbc7d492d76\')';

try {
    ConnectApi.CdpQueryInput queryInput = new ConnectApi.CdpQueryInput();
    queryInput.sql = query;
    
    ConnectApi.CdpQueryOutput response = ConnectApi.CdpQuery.queryANSISql(queryInput);
    
    if (response != null && response.data != null) {
        System.debug('--- FICHA 360: CLIENTES CON CITAS ---');
        for (Object row : response.data) {
            Map<String, Object> rowData = (Map<String, Object>)row;
            System.debug('CLIENTE: ' + rowData.get('ssot__FirstName__c') + ' ' + rowData.get('ssot__LastName__c'));
            System.debug('EMAIL: ' + rowData.get('Email__c'));
            System.debug('ID_POS: ' + rowData.get('Id_POS__c'));
            System.debug('ID_TUOTEMPO: ' + rowData.get('Id_TuoTempo__c'));
            System.debug('---------------------------------------');
        }
    }
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}
