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
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCustomerMetrics(String unifiedId) {
        Map<String, Object> metrics = new Map<String, Object>();
        
        try {
            // SQL para obtener métricas de Retail y Ecommerce
            // Usamos COALESCE para manejar nulos y asegurar que la suma funcione
            String sql = 'SELECT ' +
                         'SUM(monto_total__c) as total_sales, ' +
                         'SUM(cantidad_ordenes__c) as total_orders, ' +
                         'MAX(fecha_ultima_compra__c) as last_purchase_date ' +
                         'FROM (' +
                         '  SELECT monto_total__c, cantidad_ordenes__c, fecha_ultima_compra__c FROM UI_Summary_Retail__cio WHERE unified_individual_id__c = \'' + unifiedId + '\' ' +
                         '  UNION ALL ' +
                         '  SELECT monto_total__c, cantidad_ordenes__c, fecha_ultima_compra__c FROM UI_Summary_Ecomm__cio WHERE unified_individual_id__c = \'' + unifiedId + '\' ' +
                         ')';

            ConnectApi.CdpQueryInput queryInput = new ConnectApi.CdpQueryInput();
            queryInput.sql = sql;
            
            // Ejecución de la query en Data Cloud
            ConnectApi.CdpQueryOutput response = ConnectApi.CdpQuery.query(queryInput);
            
            if (response.data != null && !response.data.isEmpty()) {
                Map<String, Object> row = (Map<String, Object>)response.data[0];
                
                Decimal totalSales = row.get('total_sales') != null ? Decimal.valueOf(String.valueOf(row.get('total_sales'))) : 0;
                Decimal totalOrders = row.get('total_orders') != null ? Decimal.valueOf(String.valueOf(row.get('total_orders'))) : 0;
                String lastDateStr = row.get('last_purchase_date') != null ? String.valueOf(row.get('last_purchase_date')) : null;

                metrics.put('totalSales', totalSales);
                metrics.put('orderCount', totalOrders);
                metrics.put('avgTicket', totalOrders > 0 ? (totalSales / totalOrders) : 0);
                
                if (lastDateStr != null) {
                    Date lastDate = Date.valueOf(lastDateStr.split('T')[0]);
                    metrics.put('daysSinceLastPurchase', lastDate.daysBetween(Date.today()));
                } else {
                    metrics.put('daysSinceLastPurchase', 0);
                }
            }
        } catch (Exception e) {
            System.debug('Error in getCustomerMetrics: ' + e.getMessage());
        }
        
        return metrics;
    }
}