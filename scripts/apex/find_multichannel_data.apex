// Script para encontrar clientes con Citas, Marketing y Driver Visual
System.debug('--- INICIANDO BÚSQUEDA MULTICANAL ---');

try {
    // 1. Buscar Driver Visual (Cualquiera con datos)
    List<SObject> drivers = Database.query('SELECT ID_CLIENTE__c, NIVEL_VISION__c, TIPO_USUARIO__c FROM POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm LIMIT 5');
    for(SObject d : drivers) {
        System.debug('DRIVER_VISUAL_ENCONTRADO: ID_POS: ' + d.get('ID_CLIENTE__c') + ' | Vision: ' + d.get('NIVEL_VISION__c'));
    }

    // 2. Buscar Citas (TuoTempo)
    List<SObject> citas = Database.query('SELECT memberid__c, activityTitle__c, areaTitle__c FROM TUOTEMPO_CITA__dlm LIMIT 5');
    for(SObject c : citas) {
        System.debug('CITA_ENCONTRADA: MemberID: ' + c.get('memberid__c') + ' | Tipo: ' + c.get('activityTitle__c'));
    }

    // 3. Buscar Marketing (Email Engagement)
    List<SObject> mkt = Database.query('SELECT ssot__IndividualId__c, ssot__SubjectLineTxt__c FROM ssot__EmailEngagement__dlm LIMIT 5');
    for(SObject m : mkt) {
        System.debug('MARKETING_ENCONTRADO: IndividualID: ' + m.get('ssot__IndividualId__c') + ' | Subject: ' + m.get('ssot__SubjectLineTxt__c'));
    }

} catch (Exception e) {
    System.debug('ERROR_BUSQUEDA: ' + e.getMessage());
}
