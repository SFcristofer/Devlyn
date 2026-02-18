/**
 * @description Clase consolidada para Marketing y Cotizaciones.
 */
public with sharing class TechMarketing360 {

    @TestVisible private static List<SObject> mockData;

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getExtendedData(String unifiedId) {
        Map<String, Object> result = new Map<String, Object>{'campaigns' => new List<Object>(), 'quotes' => new List<Object>()};
        try {
            List<SObject> profiles = (Test.isRunningTest() && mockData != null) ? mockData : [SELECT Id_POS__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :unifiedId LIMIT 1];
            if (profiles.isEmpty()) return result;
            String posId = (String)profiles[0].get('Id_POS__c');
            String email = (String)profiles[0].get('Email__c');
            
            // 1. Campañas
            List<SObject> engs = (Test.isRunningTest() && mockData != null) ? mockData : Database.query('SELECT ssot__SubjectLineTxt__c, ssot__EngagementDateTm__c, ssot__EmailFromAddr__c, ssot__Id__c FROM ssot__EmailEngagement__dlm WHERE ssot__IndividualId__c = :unifiedId OR ssot__IndividualId__c = :posId OR ssot__IndividualId__c = :email LIMIT 20');
            Map<String, Map<String, Object>> cmap = new Map<String, Map<String, Object>>();
            for (SObject e : engs) {
                String sub = (String)e.get('ssot__SubjectLineTxt__c') ?? 'Email';
                if (!cmap.containsKey(sub)) cmap.put(sub, new Map<String, Object>{'nombre'=>sub, 'envios'=>new List<Map<String, Object>>()});
                ((List<Map<String, Object>>)cmap.get(sub).get('envios')).add(new Map<String, Object>{'uniqueKey'=>(String)e.get('ssot__Id__c'), 'asunto'=>sub, 'fechaEnvio'=>e.get('ssot__EngagementDateTm__c')});
            }
            result.put('campaigns', cmap.values());

            // 2. Cotizaciones
            List<SObject> quotes = (Test.isRunningTest() && mockData != null) ? mockData : Database.query('SELECT Id, TOTAL__c, FECHA__c FROM POS_POS_CLIENTE_PRESUPUESTO_70871439__dlm WHERE ID_CLIENTE__c = :posId LIMIT 5');
            List<Map<String, Object>> qlist = new List<Map<String, Object>>();
            for (SObject q : quotes) qlist.add(new Map<String, Object>{'presupuestoId' => q.get('Id'), 'total' => q.get('TOTAL__c'), 'fecha' => q.get('FECHA__c')});
            result.put('quotes', qlist);
            
        } catch (Exception e) {}
        return result;
    }
}
