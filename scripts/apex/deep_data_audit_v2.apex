// Script de Inspección de Identidad y Diagnóstico para Juan Pérez
String posId = '12388500';
System.debug('--- INSPECCIONANDO LLAVES DE JUAN PÉREZ ---');

try {
    // 1. Ver exactamente qué tiene el Data Model (DMO)
    String q1 = 'SELECT ssot__Id__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = \'' + posId + '\' LIMIT 1';
    List<Map<String, Object>> res1 = TechProfile360Service.executeDataCloudQuery(q1);
    
    if(!res1.isEmpty()) {
        String uniId = (String)res1[0].get('ssot__Id__c');
        System.debug('DMO_DATA: UnifiedID=' + uniId + ' | POSID=' + res1[0].get('Id_POS__c'));
        
        // 2. Ver exactamente qué tiene la tabla de Diagnóstico (DLM)
        // Buscamos por el ID de POS directamente en la tabla de diagnóstico
        String q2 = 'SELECT ID_CLIENTE__c, MIOPIA__c, ASTIGMATISMO__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE ID_CLIENTE__c LIKE \'%' + posId + '%\' LIMIT 1';
        List<Map<String, Object>> res2 = TechProfile360Service.executeDataCloudQuery(q2);
        
        if(!res2.isEmpty()) {
            System.debug('DLM_DATA: ID_CLIENTE_EN_DIAGNOSTICO=' + res2[0].get('ID_CLIENTE__c'));
        } else {
            // Si no está por POS ID, buscamos por Unified ID
            String q3 = 'SELECT ID_CLIENTE__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE ID_CLIENTE__c = \'' + uniId + '\' LIMIT 1';
            List<Map<String, Object>> res3 = TechProfile360Service.executeDataCloudQuery(q3);
            if(!res3.isEmpty()) {
                System.debug('DLM_DATA: Encontrado por UnifiedID');
            } else {
                System.debug('DLM_DATA: No existe registro en Diagnóstico para ninguna de las dos llaves.');
            }
        }
    } else {
        System.debug('DMO_DATA: No se encontró el ID de POS en el Data Model.');
    }
} catch (Exception e) {
    System.debug('ERROR_INSPECCION: ' + e.getMessage());
}
