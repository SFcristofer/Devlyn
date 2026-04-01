// Script corregido para encontrar clientes con Nombre, Email e ID POS
System.debug('--- INICIANDO REPORTE FINAL DE CLIENTES 360 ---');

try {
    // 1. Driver Visual
    List<SObject> drivers = Database.query('SELECT ID_CLIENTE__c FROM POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm LIMIT 2');
    for(SObject d : drivers) {
        String posId = (String)d.get('ID_CLIENTE__c');
        List<UnifiedssotIndividualDev2__dlm> p = [SELECT ssot__FirstName__c, ssot__LastName__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = :posId LIMIT 1];
        if(!p.isEmpty()) {
            System.debug('REPORTE_DRIVER: Nombre: ' + p[0].ssot__FirstName__c + ' ' + p[0].ssot__LastName__c + ' | Email: ' + p[0].Email__c + ' | ID POS: ' + posId);
        }
    }

    // 2. Citas
    List<SObject> citas = Database.query('SELECT memberid__c FROM TUOTEMPO_CITA__dlm LIMIT 2');
    for(SObject c : citas) {
        String mId = (String)c.get('memberid__c');
        List<UnifiedssotIndividualDev2__dlm> p = [SELECT ssot__FirstName__c, ssot__LastName__c, Email__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_TuoTempo__c = :mId OR ssot__Id__c = :mId LIMIT 1];
        if(!p.isEmpty()) {
            System.debug('REPORTE_CITAS: Nombre: ' + p[0].ssot__FirstName__c + ' ' + p[0].ssot__LastName__c + ' | Email: ' + p[0].Email__c + ' | ID POS: ' + p[0].Id_POS__c);
        }
    }

    // 3. Marketing
    List<SObject> mkt = Database.query('SELECT ssot__IndividualId__c, ssot__EmailFromAddr__c FROM ssot__EmailEngagement__dlm LIMIT 2');
    for(SObject m : mkt) {
        String indId = (String)m.get('ssot__IndividualId__c');
        String mEmail = (String)m.get('ssot__EmailFromAddr__c');
        List<UnifiedssotIndividualDev2__dlm> p = [SELECT ssot__FirstName__c, ssot__LastName__c, Email__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :indId OR Email__c = :mEmail LIMIT 1];
        if(!p.isEmpty()) {
            System.debug('REPORTE_MARKETING: Nombre: ' + p[0].ssot__FirstName__c + ' ' + p[0].ssot__LastName__c + ' | Email: ' + p[0].Email__c + ' | ID POS: ' + p[0].Id_POS__c);
        }
    }
} catch (Exception e) {
    System.debug('ERROR_REPORTE: ' + e.getMessage());
}
