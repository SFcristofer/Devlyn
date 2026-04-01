// Simple query to TUOTEMPO_CITA__dlm
try {
    // We try to query any field we suspect exists based on the master query
    List<SObject> citas = Database.query('SELECT memberid__c, activityTitle__c FROM TUOTEMPO_CITA__dlm LIMIT 10');
    if (citas.isEmpty()) {
        System.debug('TUOTEMPO_CITA__dlm está vacía via SOQL.');
    } else {
        for (SObject c : citas) {
            System.debug('CITA: memberid=' + c.get('memberid__c') + ', title=' + c.get('activityTitle__c'));
        }
    }
} catch (Exception e) {
    System.debug('Error en query simple: ' + e.getMessage());
}
