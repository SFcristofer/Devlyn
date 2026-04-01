// Script para encontrar clientes con marketing REAL y su nombre unificado
String qEngagement = 'SELECT ssot__IndividualId__c, ssot__SubjectLineTxt__c, ssot__EngagementDateTm__c ' +
                     'FROM ssot__EmailEngagement__dlm ' +
                     'WHERE ssot__SubjectLineTxt__c != NULL ' +
                     'ORDER BY ssot__EngagementDateTm__c DESC LIMIT 5';

System.debug('--- BUSCANDO CLIENTES CON MARKETING REAL ---');

try {
    List<Map<String, Object>> engagements = TechProfile360Service.executeDataCloudQuery(qEngagement);
    
    if (engagements.isEmpty()) {
        System.debug('RESULTADO: No hay registros de engagement de marketing en el Lago de Datos hoy.');
    } else {
        for(Map<String, Object> e : engagements) {
            String individualId = (String)e.get('ssot__IndividualId__c');
            // Buscamos el nombre y ID POS de esta persona para dárselo al usuario
            String qName = 'SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = \'' + individualId + '\' LIMIT 1';
            List<Map<String, Object>> names = TechProfile360Service.executeDataCloudQuery(qName);
            
            if(!names.isEmpty()) {
                System.debug('CLIENTE_CON_MARKETING: Name=' + names[0].get('ssot__FirstName__c') + ' ' + names[0].get('ssot__LastName__c') + 
                             ' | POS_ID=' + names[0].get('Id_POS__c') + 
                             ' | UnifiedID=' + individualId +
                             ' | Ultimo_Correo=' + e.get('ssot__SubjectLineTxt__c'));
            } else {
                System.debug('ENGAGEMENT_SIN_PERFIL: ID=' + individualId + ' | Correo=' + e.get('ssot__SubjectLineTxt__c'));
            }
        }
    }
} catch (Exception ex) {
    System.debug('ERROR: ' + ex.getMessage());
}
