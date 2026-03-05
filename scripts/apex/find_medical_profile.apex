// Script para encontrar un perfil con expediente médico (Diagnósticos/Graduaciones)
System.debug('--- INICIANDO BÚSQUEDA DE EXPEDIENTE MÉDICO ---');

// 1. Buscamos en el objeto de Diagnósticos Unificados (si existe con ese nombre según los scripts del repo)
// Intentaremos con nombres comunes de DMOs médicos en este proyecto
try {
    List<SObject> diags = Database.query('SELECT ssot__IndividualId__c, ssot__CreatedDateTm__c FROM ssot__MedicalDiagnostic__dlm ORDER BY ssot__CreatedDateTm__c DESC LIMIT 20');
    
    for(SObject d : diags) {
        String indId = (String)d.get('ssot__IndividualId__c');
        if(String.isBlank(indId)) continue;

        // Buscamos el perfil unificado asociado
        List<UnifiedssotIndividualDev2__dlm> profiles = [SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c, ssot__Id__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :indId OR Id_POS__c = :indId LIMIT 1];
        
        if(!profiles.isEmpty()) {
            UnifiedssotIndividualDev2__dlm p = profiles[0];
            System.debug('PACIENTE_CON_DIAGNOSTICO: ' + p.ssot__FirstName__c + ' ' + p.ssot__LastName__c + ' | ID: ' + p.Id_POS__c);
            
            // Verificamos si tiene también graduaciones (EyeExam / ClinicalResult)
            // Según la estructura típica de Devlyn en Data Cloud
            try {
                List<SObject> grad = Database.query('SELECT Id FROM ssot__ClinicalResult__dlm WHERE ssot__IndividualId__c = \'' + indId + '\' LIMIT 1');
                if(!grad.isEmpty()) {
                    System.debug('>> ESTE PACIENTE TIENE EXPEDIENTE COMPLETO (DIAG + GRAD)');
                    break; 
                }
            } catch(Exception e2) {}
        }
    }
} catch(Exception e) {
    System.debug('Error en búsqueda: ' + e.getMessage());
}
