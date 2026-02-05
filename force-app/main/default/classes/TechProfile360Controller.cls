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

    /**
     * @description Busca perfiles unificados filtrando por un atributo específico (Estilo Profile Explorer).
     */
    @AuraEnabled(cacheable=true)
    public static List<UnifiedssotIndividualDev2__dlm> searchProfiles(String searchTerm, String attributePath) {
        if (String.isBlank(searchTerm) || String.isBlank(attributePath)) {
            return new List<UnifiedssotIndividualDev2__dlm>();
        }

        // Validación básica de seguridad para evitar SOQL Injection en el nombre del campo
        List<String> allowedFields = new List<String>{'ssot__FirstName__c', 'ssot__LastName__c', 'Email__c', 'Id_POS__c'};
        if (!allowedFields.contains(attributePath)) {
            return new List<UnifiedssotIndividualDev2__dlm>();
        }

        String queryTerm = '%' + searchTerm + '%';
        String sql = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c, ssot__GenderId__c ' +
                     'FROM UnifiedssotIndividualDev2__dlm ' +
                     'WHERE ' + attributePath + ' LIKE :queryTerm ' +
                     'LIMIT 20';
        
        try {
            return Database.query(sql);
        } catch (Exception e) {
            System.debug('Search error: ' + e.getMessage());
            return new List<UnifiedssotIndividualDev2__dlm>();
        }
    }

    /**
     * @description Obtiene la información del perfil usando directamente el UnifiedId.
     */
    @AuraEnabled(cacheable=true)
    public static UnifiedssotIndividualDev2__dlm getProfileByUnifiedId(String unifiedId) {
        try {
            List<UnifiedssotIndividualDev2__dlm> profiles = [
                SELECT
                    ssot__Id__c,
                    ssot__FirstName__c,
                    ssot__LastName__c,
                    Apellido_Paterno__c,
                    Apellido_Materno__c,
                    Id_POS__c,
                    FECHA_NACIMIENTO_dt__c,
                    ssot__GenderId__c,
                    Email__c,
                    CODIGO_POSTAL__c,
                    ssot__CreatedDate__c,
                    ssot__LastModifiedDate__c
                FROM UnifiedssotIndividualDev2__dlm
                WHERE ssot__Id__c = :unifiedId
                LIMIT 1
            ];
            return profiles.isEmpty() ? null : profiles[0];
        } catch (Exception e) {
            return null;
        }
    }

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
                    Apellido_Paterno__c,
                    Apellido_Materno__c,
                    Id_POS__c,
                    FECHA_NACIMIENTO_dt__c,
                    ssot__GenderId__c,
                    Email__c,
                    CODIGO_POSTAL__c,
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

    /**
     * @description Obtiene las métricas de negocio desde Calculated Insights usando SQL.
     * TEMPORAL: Devuelve datos simulados para permitir el despliegue mientras se resuelven permisos de la Org.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCustomerMetrics(String unifiedId) {
        Map<String, Object> metrics = new Map<String, Object>();
        
        // Simulación de datos para evitar error de visibilidad 'ConnectApi.CdpQuery'
        metrics.put('totalSales', 15000.50);
        metrics.put('orderCount', 5);
        metrics.put('avgTicket', 3000.10);
        metrics.put('daysSinceLastPurchase', 12);
        
        /* 
        // CÓDIGO REAL (Descomentar cuando la Org tenga los permisos de ConnectApi habilitados)
        try {
            String sql = 'SELECT SUM(monto_total__c) as total_sales, SUM(cantidad_ordenes__c) as total_orders FROM ...';
            // ConnectApi.CdpQueryInput queryInput = new ConnectApi.CdpQueryInput();
            // queryInput.sql = sql;
            // ConnectApi.CdpQueryOutput response = ConnectApi.CdpQuery.queryANSISql(queryInput);
            // ... procesamiento ...
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        */
        
        return metrics;
    }
}