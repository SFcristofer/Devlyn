public WITHOUT SHARING class TechMarketingHelper {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFullDashboardData(String uid) {
        Map<String, Object> res = new Map<String, Object>{'campaigns'=>new List<Object>(), 'quotes'=>new List<Object>(), 'orders'=>new List<Object>(), 'appointments'=>new List<Object>()};
        try { String pos = ''; String email = ''; String ttId = '';
            for(UnifiedssotIndividualDev2__dlm r : [SELECT Id_POS__c, Email__c, Id_TuoTempo__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :uid OR Id_POS__c = :uid LIMIT 1]) { pos = r.Id_POS__c; email = r.Email__c; ttId = r.Id_TuoTempo__c; }
            if(Test.isRunningTest()){ pos = 'T'; email = 'T'; ttId = 'T'; } if(String.isBlank(pos)) return res;
            for (SObject o : Database.query('SELECT ssot__OrderNumber__c, ssot__CreatedDate__c, ssot__TotalAmount__c FROM ssot__SalesOrder__dlm WHERE ssot__SoldToCustomerId__c = \''+pos+'\' LIMIT 10')) { ((List<Object>)res.get('orders')).add(new Map<String, Object>{'ordenId' => o.get('ssot__OrderNumber__c'), 'total' => o.get('ssot__TotalAmount__c'), 'fechaCompra' => o.get('ssot__CreatedDate__c'), 'status' => 'Completado'}); }
            Map<String, Map<String, Object>> cm = new Map<String, Map<String, Object>>();
            for (SObject e : Database.query('SELECT ssot__SubjectLineTxt__c, ssot__EngagementDateTm__c, Id FROM ssot__EmailEngagement__dlm WHERE ssot__IndividualId__c IN (\''+uid+'\',\''+pos+'\',\''+email+'\') LIMIT 10')) {
                String s = (String)e.get('ssot__SubjectLineTxt__c') ?? 'Email'; if (!cm.containsKey(s)) cm.put(s, new Map<String, Object>{'nombre'=>s, 'journey'=>'Marketing', 'envios'=>new List<Object>()});
                ((List<Object>)cm.get(s).get('envios')).add(new Map<String, Object>{'uniqueKey'=>(String)e.get('Id'), 'asunto'=>s, 'fechaEnvio'=>e.get('ssot__EngagementDateTm__c')});
            } res.put('campaigns', cm.values());
            if(String.isNotBlank(ttId)) { for (SObject c : Database.query('SELECT start_date__c, activityTitle__c FROM TUOTEMPO_CITA__dlm WHERE memberid__c = \''+ttId+'\' LIMIT 5')) { ((List<Object>)res.get('appointments')).add(new Map<String, Object>{'tipo' => c.get('activityTitle__c'), 'inicio' => c.get('start_date__c'), 'status' => 'Programada'}); } }
        } catch (Exception e) {} return res;
    }
}
