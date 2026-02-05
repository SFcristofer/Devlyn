/**
 * @description Controller for Tech Patient 360 LWC. 
 * Delegates data fetching to TechDataCloudService.
 * @author Cristofer Contreras
 * @email cristofer.contreras@technovalue.com.mx
 * @date 2026-01-28
 */
public with sharing class TechPatient360Controller {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPatientData(String recordId) {
        try {
            // Delegation to the specialized Service Class
            return TechDataCloudService.getPatientProfile(recordId);
        } catch (Exception e) {
            throw new AuraHandledException('Error en el servicio de datos: ' + e.getMessage());
        }
    }
}