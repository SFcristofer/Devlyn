try {
    List<SObject> phones = Database.query('SELECT ssot__TelephoneNumber__c, ssot__FormattedE164PhoneNumber__c, Id FROM UnifiedssotContactPointPhoneDev2__dlm WHERE ssot__TelephoneNumber__c != null LIMIT 10');
    if(phones.isEmpty()) {
        System.debug('PHONE_CHECK: No se encontraron registros en UnifiedssotContactPointPhoneDev2__dlm');
    } else {
        for(SObject p : phones) {
            System.debug('TELÉFONO ENCONTRADO: ' + p.get('ssot__TelephoneNumber__c') + ' (E164: ' + p.get('ssot__FormattedE164PhoneNumber__c') + ')');
        }
    }
} catch(Exception e) {
    System.debug('Error consultando teléfonos: ' + e.getMessage());
}