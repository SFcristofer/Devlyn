// Script para encontrar un usuario real con datos de Driver Visual
String sql = 'SELECT cust.ssot__FirstName__c, cust.ssot__LastName__c, cust.Email__c, dv.ID_CLIENTE__c, dv.NIVEL_VISION__c, dv.TIPO_USUARIO__c, dv.FECHA__c FROM POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm AS dv LEFT JOIN UnifiedssotIndividualDev2__dlm AS cust ON dv.ID_CLIENTE__c = cust.Id_POS__c WHERE dv.NIVEL_VISION__c != \'0\' AND dv.TIPO_USUARIO__c != \'0\' AND cust.ssot__FirstName__c IS NOT NULL LIMIT 1';

String ep = URL.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/ssot/queryv2';
HttpRequest req = new HttpRequest();
req.setEndpoint(ep);
req.setMethod('POST');
req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
req.setHeader('Content-Type', 'application/json');
req.setBody('{"sql": "' + sql.replace('"', '\\"') + '"}');

try {
    HttpResponse resp = new Http().send(req);
    System.debug('--- RESULTADO DE DATA CLOUD ---');
    System.debug(resp.getBody());
    System.debug('------------------------------');
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}
