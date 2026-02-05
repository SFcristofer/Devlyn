/**
 * @description Controller for Profile 360 View.
 * Extracted exactly from text.txt with Tech prefix added.
 * @author Cristofer Contreras
 * @email cristofer.contreras@technovalue.com.mx
 */
public with sharing class TechProfile360Controller {

    @TestVisible private static List<UnifiedLinkssotIndividualDev2__dlm> mockLinks;
    @TestVisible private static List<UnifiedssotIndividualDev2__dlm> mockProfiles;
    @TestVisible private static Boolean forceException = false;

    @AuraEnabled(cacheable=true)
    public static UnifiedssotIndividualDev2__dlm getProfileInfo(Id recordId) {
 
        try {
            if (Test.isRunningTest() && forceException) {
                throw new AuraHandledException('Forced Error');
            }
            // 1️⃣ Obtener el UnifiedRecordId desde el Link
            List<UnifiedLinkssotIndividualDev2__dlm> links = (Test.isRunningTest() && mockLinks != null) ? mockLinks : [
                SELECT UnifiedRecordId__c
                FROM UnifiedLinkssotIndividualDev2__dlm
                WHERE SourceRecordId__c = :recordId
                LIMIT 1
            ];
 
            if (links.isEmpty() || links[0].UnifiedRecordId__c == null) {
                return null;
            }
 
            String unifiedId = links[0].UnifiedRecordId__c;

            // 2️⃣ Obtener el perfil unificado
            List<UnifiedssotIndividualDev2__dlm> profiles = (Test.isRunningTest() && mockProfiles != null) ? mockProfiles : [
                SELECT
                    ssot__Id__c,
                    ssot__FirstName__c,
                    ssot__LastName__c,
                    Id_POS__c,
                    ssot__CreatedDate__c,
                    ssot__LastModifiedDate__c
                FROM UnifiedssotIndividualDev2__dlm
                WHERE ssot__Id__c = :unifiedId
                LIMIT 1
            ];
            
            if (profiles.isEmpty()) {
                return null;
            }
 
            return profiles[0];
 
        } catch (Exception e) {
            System.debug('TechProfile360Controller error: ' + e.getMessage());
            return null;
        }
    }
}