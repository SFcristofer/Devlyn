try {
    // Buscamos los primeros 3 IDs que sí tengan actividad de marketing
    String q = 'SELECT ssot__IndividualId__c, ssot__SubjectLineTxt__c FROM ssot__EmailEngagement__dlm WHERE ssot__SubjectLineTxt__c != null LIMIT 3';
    List<SObject> samples = Database.query(q);
    
    System.debug('--- IDS CON MARKETING REAL ---');
    for(SObject s : samples) {
        System.debug('ID ENCONTRADO: ' + s.get('ssot__IndividualId__c') + ' | Correo: ' + s.get('ssot__SubjectLineTxt__c'));
    }
} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
}
