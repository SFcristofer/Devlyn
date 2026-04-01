// Script to find profile matching a memberid from appointments
String targetId = 'sc1655d447a68def';
try {
    List<SObject> profiles = Database.query('SELECT ssot__FirstName__c, ssot__LastName__c, Id_TuoTempo__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_TuoTempo__c = \'' + targetId + '\' LIMIT 1');
    if (profiles.isEmpty()) {
        System.debug('No se encontró perfil para Id_TuoTempo__c = ' + targetId);
        // Let's try to find ANY profile with sc... format
        List<SObject> anySc = Database.query('SELECT ssot__FirstName__c, ssot__LastName__c, Id_TuoTempo__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_TuoTempo__c LIKE \'sc%\' LIMIT 5');
        for (SObject p : anySc) {
            System.debug('PERFIL ENCONTRADO CON SC: ' + p.get('ssot__FirstName__c') + ' ' + p.get('ssot__LastName__c') + ' | ID=' + p.get('Id_TuoTempo__c'));
        }
    } else {
        SObject p = profiles[0];
        System.debug('PERFIL ENCONTRADO: ' + p.get('ssot__FirstName__c') + ' ' + p.get('ssot__LastName__c'));
    }
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}
