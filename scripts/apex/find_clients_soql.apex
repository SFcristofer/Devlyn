// Script to find clients with appointments using SOQL
try {
    List<SObject> profiles = Database.query('SELECT Id_TuoTempo__c, ssot__FirstName__c, ssot__LastName__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_TuoTempo__c != NULL LIMIT 20');
    
    if (profiles.isEmpty()) {
        System.debug('No se encontraron perfiles unificados con Id_TuoTempo__c.');
    } else {
        System.debug('--- PERFILES UNIFICADOS ENCONTRADOS ---');
        for (SObject p : profiles) {
            String ttId = (String)p.get('Id_TuoTempo__c');
            String nombre = (String)p.get('ssot__FirstName__c');
            String apellido = (String)p.get('ssot__LastName__c');
            System.debug('Perfil: ' + nombre + ' ' + apellido + ' | ID TuoTempo: ' + ttId);
            
            // Ahora intentamos buscar sus citas
            try {
                String citaQuery = 'SELECT activityTitle__c, estatus_cita__c FROM TUOTEMPO_CITA__dlm WHERE memberid__c = \'' + ttId + '\' LIMIT 1';
                List<SObject> citas = Database.query(citaQuery);
                if (!citas.isEmpty()) {
                    SObject c = citas[0];
                    System.debug('>>> CITA ENCONTRADA: ' + c.get('activityTitle__c') + ' | Status: ' + c.get('estatus_cita__c'));
                }
            } catch (Exception e2) {
                System.debug('Error buscando citas para ' + ttId + ': ' + e2.getMessage());
            }
        }
    }
} catch (Exception e) {
    System.debug('Error buscando perfiles: ' + e.getMessage());
}
