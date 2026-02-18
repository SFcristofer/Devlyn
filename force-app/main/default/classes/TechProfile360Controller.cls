public with sharing class TechProfile360Controller {
    @TestVisible private static List<UnifiedssotIndividualDev2__dlm> mockProfiles;
    @TestVisible private static List<SObject> mockOrders;
    @TestVisible private static List<SObject> mockCitas;
    @TestVisible private static List<SObject> mockSubs;

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getOrders(String uid) {
        List<Map<String, Object>> res = new List<Map<String, Object>>();
        try { List<UnifiedssotIndividualDev2__dlm> profs = [SELECT Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :uid LIMIT 1]; if (profs.isEmpty()) return res; String pos = profs[0].Id_POS__c;
            for (SObject o : Database.query('SELECT ssot__Id__c, ssot__OrderNumber__c, ssot__CreatedDate__c, ssot__TotalAmount__c FROM ssot__SalesOrder__dlm WHERE ssot__SoldToCustomerId__c = :pos ORDER BY ssot__CreatedDate__c DESC LIMIT 20')) res.add(new Map<String, Object>{'ordenId' => o.get('ssot__OrderNumber__c'), 'total' => o.get('ssot__TotalAmount__c'), 'fechaCompra' => o.get('ssot__CreatedDate__c'), 'status' => 'Completado', 'sucursal' => 'Devlyn'});
        } catch (Exception e) {} return res;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getSubscriptions(String uid) {
        List<Map<String, Object>> res = new List<Map<String, Object>>();
        try { List<UnifiedssotIndividualDev2__dlm> profs = [SELECT Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :uid LIMIT 1]; if (profs.isEmpty()) return res; String pos = profs[0].Id_POS__c;
            for (SObject s : Database.query('SELECT Id, Status__c, NextPurchaseDate__c FROM VTEX_Subscription__dlm WHERE CustomerId__c = :pos LIMIT 10')) res.add(new Map<String, Object>{'nombre' => 'Suscripción ' + s.get('Id'), 'status' => s.get('Status__c'), 'proximaCompra' => s.get('NextPurchaseDate__c')});
        } catch (Exception e) {} return res;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMedicalInfo(String uid) {
        Map<String, Object> med = new Map<String, Object>();
        try { List<UnifiedssotIndividualDev2__dlm> profs = [SELECT Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :uid LIMIT 1]; if (profs.isEmpty()) return med; String pos = profs[0].Id_POS__c;
            for(SObject d : Database.query('SELECT MIOPIA__c, FECHA__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE ID_CLIENTE__c = :pos ORDER BY FECHA__c DESC LIMIT 1')) med.put('lastDiagnosis', d);
            for(SObject a : Database.query('SELECT DIABETES__c, NOTAS__c FROM POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm WHERE ID_CLIENTE__c = :pos ORDER BY FECHA__c DESC LIMIT 1')) med.put('antecedents', a);
        } catch (Exception e) {} return med;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAppointments(String uid) {
        List<Map<String, Object>> res = new List<Map<String, Object>>();
        try { List<UnifiedssotIndividualDev2__dlm> profs = [SELECT Id_TuoTempo__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :uid LIMIT 1]; if (profs.isEmpty() || profs[0].Id_TuoTempo__c == null) return res; String tt = profs[0].Id_TuoTempo__c;
            for (SObject c : Database.query('SELECT start_date__c, activityTitle__c, estatus_cita__c FROM TUOTEMPO_CITA__dlm WHERE memberid__c = :tt ORDER BY start_date__c DESC LIMIT 10')) res.add(new Map<String, Object>{'tipo' => c.get('activityTitle__c'), 'status' => c.get('estatus_cita__c'), 'inicio' => c.get('start_date__c')});
        } catch (Exception e) {} return res;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCustomerMetrics(String uid) {
        Map<String, Object> met = new Map<String, Object>{'totalSales' => 0, 'orderCount' => 0, 'avgTicket' => 0, 'retailCategories' => new Map<String, Integer>{'Solares'=>0, 'Oftalmicos'=>0, 'LentesContacto'=>0}, 'ecommerceCategories' => new Map<String, Integer>{'Solares'=>0, 'Oftalmicos'=>0, 'LentesContacto'=>0}};
        try { List<Map<String, Object>> ords = getOrders(uid); Decimal tot = 0; for(Map<String, Object> o : ords) tot += (Decimal)o.get('total');
            met.put('totalSales', tot); met.put('orderCount', ords.size()); if(ords.size() > 0) met.put('avgTicket', (tot / ords.size()).setScale(2));
        } catch (Exception e) {} return met;
    }

    @AuraEnabled(cacheable=true)
    public static UnifiedssotIndividualDev2__dlm getProfileByUnifiedId(String uid) { for(UnifiedssotIndividualDev2__dlm p:[SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c, FECHA_NACIMIENTO_dt__c, ssot__GenderId__c, CODIGO_POSTAL__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c=:uid LIMIT 1]) return p; return null; }

    @AuraEnabled(cacheable=true)
    public static UnifiedssotIndividualDev2__dlm getProfileInfo(Id rid) { for(UnifiedLinkssotIndividualDev2__dlm l:[SELECT UnifiedRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm WHERE SourceRecordId__c=:rid LIMIT 1]) return getProfileByUnifiedId(l.UnifiedRecordId__c); return null; }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMarketingScores(String uid) { return new Map<String, Object>{'einsteinScore' => new Map<String, Object>{'propensidadClick'=>'Media', 'propensidadAbrir'=>'Alta'}}; }
}
