try {
    // Consultamos los campos de relación para ver cuál contiene el ID del Individuo Unificado
    List<SObject> phones = Database.query('SELECT ssot__TelephoneNumber__c, ssot__PartyId__c, rel_1698349102160_end__c FROM UnifiedssotContactPointPhoneDev2__dlm WHERE ssot__TelephoneNumber__c != null LIMIT 5');
    for(SObject p : phones) {
        System.debug('TELÉFONO: ' + p.get('ssot__TelephoneNumber__c'));
        System.debug('  -> ssot__PartyId__c: ' + p.get('ssot__PartyId__c'));
        System.debug('  -> rel_1698349102160_end__c: ' + p.get('rel_1698349102160_end__c'));
    }
} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
}