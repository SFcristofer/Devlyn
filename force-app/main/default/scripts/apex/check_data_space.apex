String targetId = '11472417';
try {
    // Intentamos identificar el Data Space de los registros
    String q = 'SELECT ssot__IndividualId__c, ssot__SubjectLineTxt__c FROM ssot__EmailEngagement__dlm WHERE ssot__IndividualId__c = :targetId LIMIT 1';
    List<SObject> results = Database.query(q);
    
    if(!results.isEmpty()) {
        // En algunas versiones, el Data Space se puede ver en el campo DataSourceId o metadatos de la organización
        System.debug('¡REGISTRO CONFIRMADO PARA HORACIO!');
        System.debug('Si tú ves 0 y yo veo este registro, confirma que tienes el Permission Set "Data Cloud Apex API".');
    } else {
        System.debug('No se encontraron registros en el contexto actual.');
    }
} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
}
