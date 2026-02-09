// Buscamos perfiles que tengan suscripciones en VTEX_Subscription__dlm
try {
    String q = 'SELECT IndividualId__c, Name__c, Status__c, Frequency__c FROM VTEX_Subscription__dlm LIMIT 10';
    List<SObject> subs = Database.query(q);
    if (subs.isEmpty()) {
        System.debug('BUSQUEDA_SUBS: No se encontraron suscripciones en la base.');
    } else {
        for (SObject s : subs) {
            String unifiedId = (String)s.get('IndividualId__c');
            // Traer el nombre del perfil unificado
            List<UnifiedssotIndividualDev2__dlm> profiles = [SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :unifiedId LIMIT 1];
            String name = !profiles.isEmpty() ? profiles[0].ssot__FirstName__c + ' ' + profiles[0].ssot__LastName__c : 'Desconocido';
            System.debug('PERFIL_CON_SUSCRIPCION: ' + name + ' | UnifiedID: ' + unifiedId + ' | Plan: ' + s.get('Name__c'));
        }
    }
} catch(Exception e) {
    System.debug('ERROR_CONSULTA_SUBS: ' + e.getMessage());
}
