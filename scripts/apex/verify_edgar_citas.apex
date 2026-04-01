// Final verification for Edgar Aldy Hernandez
String targetId = 'sc166186dce81231';
try {
    List<SObject> citas = Database.query('SELECT activityTitle__c, estatus_cita__c, start_date__c FROM TUOTEMPO_CITA__dlm WHERE memberid__c = \'' + targetId + '\'');
    System.debug('CITAS PARA EDGAR ALDY HERNANDEZ:');
    for (SObject c : citas) {
        System.debug('Servicio: ' + c.get('activityTitle__c') + ' | Status: ' + c.get('estatus_cita__c') + ' | Fecha: ' + c.get('start_date__c'));
    }
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}
