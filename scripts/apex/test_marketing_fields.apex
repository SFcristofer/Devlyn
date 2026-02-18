List<String> fieldsToTest = new List<String>{
    'ssot__SubjectLineTxt__c', 
    'ssot__EngagementDateTm__c', 
    'ssot__EmailFromAddr__c', 
    'ssot__EngagementTypeId__c',
    'ssot__Id__c'
};

System.debug('--- TEST DE CAMPOS EMAIL ENGAGEMENT ---');
for(String f : fieldsToTest) {
    try {
        String q = 'SELECT ' + f + ' FROM ssot__EmailEngagement__dlm LIMIT 1';
        Database.query(q);
        System.debug('CAMPO_ACTIVO: ' + f);
    } catch(Exception e) {
        System.debug('CAMPO_INACTIVO: ' + f);
    }
}

// Probamos objetos relacionados con Journey
List<String> journeyObjects = new List<String>{'ssot__Journey__dlm', 'ssot__JourneyStep__dlm', 'MC_Journey__dlm'};
for(String obj : journeyObjects) {
    try {
        String q = 'SELECT count() FROM ' + obj;
        Integer c = Database.countQuery(q);
        System.debug('OBJETO_JOURNEY_ENCONTRADO: ' + obj + ' (Registros: ' + c + ')');
    } catch(Exception e) {}
}
