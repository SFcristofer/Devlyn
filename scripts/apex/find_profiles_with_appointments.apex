// 1. Buscamos perfiles que tengan Id_TuoTempo__c
List<UnifiedssotIndividualDev2__dlm> profiles = [SELECT Id_TuoTempo__c, ssot__FirstName__c, ssot__LastName__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_TuoTempo__c != null LIMIT 10];

if (profiles.isEmpty()) {
    System.debug('BUSQUEDA_CITAS: No se encontraron perfiles con Id_TuoTempo__c.');
} else {
    for (UnifiedssotIndividualDev2__dlm p : profiles) {
        String ttId = p.Id_TuoTempo__c;
        // 2. Verificamos si tienen citas en TUOTEMPO_CITA__dlm
        try {
            String q = 'SELECT activity_lid__c, start_date__c FROM TUOTEMPO_CITA__dlm WHERE memberid__c = :ttId LIMIT 1';
            List<SObject> citas = Database.query(q);
            if (!citas.isEmpty()) {
                System.debug('PERFIL_CON_CITAS: ' + p.ssot__FirstName__c + ' ' + p.ssot__LastName__c + ' | ID TT: ' + ttId);
            }
        } catch(Exception e) {
            System.debug('ERROR_CONSULTA_CITAS: ' + e.getMessage());
        }
    }
}
