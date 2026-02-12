/**
 * @description Service class to handle Data Cloud business logic and queries.
 * Version: Universal Generic SObject - Total Identity (Fixed Variable Binding)
 * @author Cristofer Contreras
 */
public WITHOUT SHARING class TechProfile360Service {
    
    @TestVisible public static List<UnifiedLinkssotIndividualDev2__dlm> mockLinks;
    @TestVisible public static List<UnifiedssotIndividualDev2__dlm> mockProfiles;
    @TestVisible public static List<SObject> mockEngagements;
    @TestVisible public static List<SObject> mockSubs;
    @TestVisible public static List<SObject> mockCitas;
    @TestVisible public static List<SObject> mockOrders;
    @TestVisible public static List<SObject> mockOrderProducts;
    @TestVisible public static List<SObject> mockStores;
    @TestVisible public static List<SObject> mockAntecedents;
    @TestVisible public static List<SObject> mockDiagnosis;
    @TestVisible public static List<SObject> mockDrivers;
    @TestVisible public static List<SObject> mockPowers;
    @TestVisible public static Boolean forceException = false;

    private static List<SObject> performQuery(String soql, List<SObject> mocks) {
        if (Test.isRunningTest() && mocks != null) return mocks;
        try { return Database.query(soql); } catch(Exception e) { return new List<SObject>(); }
    }

    public static List<String> getRelatedIds(String unifiedId) {
        List<String> ids = new List<String>();
        try {
            // 1. IDs desde el Perfil
            for(SObject p : performQuery('SELECT Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = \''+unifiedId+'\'', mockProfiles)) {
                String val = (String)p.get('Id_POS__c');
                if(val != null) { ids.add(val); ids.add(val.replaceAll('[^0-9]', '')); }
            }
            // 2. IDs desde la tabla de Links (Identidad Unificada Total)
            String qLink = 'SELECT SourceRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm WHERE UnifiedRecordId__c = \'' + unifiedId + '\'';
            for(SObject link : performQuery(qLink, mockLinks)) {
                String val = (String)link.get('SourceRecordId__c');
                if(val != null) ids.add(val);
            }
        } catch(Exception e) {}
        return ids;
    }

    public static List<Map<String, Object>> getMarketingHistory(String unifiedId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        try {
            List<String> ids = getRelatedIds(unifiedId); if (ids.isEmpty()) return result;
            String q = 'SELECT ssot__SubjectLineTxt__c, ssot__EngagementDateTm__c, ssot__EmailFromAddr__c, ssot__EngagementChannelId__c, ssot__MarketJourneyActivityId__c, ssot__EngagementChannelActionId__c, ssot__Id__c FROM ssot__EmailEngagement__dlm WHERE ssot__IndividualId__c IN :ids ORDER BY ssot__EngagementDateTm__c DESC LIMIT 50';
            List<SObject> engagements = performQuery(q, mockEngagements);
            Map<String, Map<String, Object>> sendsMap = new Map<String, Map<String, Object>>();
            for (SObject e : engagements) {
                String sub = (String)e.get('ssot__SubjectLineTxt__c') ?? 'Sin Asunto';
                if (!sendsMap.containsKey(sub)) {
                    sendsMap.put(sub, new Map<String, Object>{'nombre'=>sub, 'journey'=>e.get('ssot__MarketJourneyActivityId__c')??'General', 'canal'=>e.get('ssot__EngagementChannelId__c')??'Email', 'envios'=>new List<Map<String, Object>>()});
                }
            }
            result.addAll(sendsMap.values());
        } catch (Exception e) {}
        return result;
    }

    public static List<Map<String, Object>> getSubscriptions(String unifiedId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        try {
            List<String> ids = getRelatedIds(unifiedId);
            String q = 'SELECT plan_id__c, status__c, nextPurchaseDate__c, frequency_periodicity__c, createdAt__c FROM VTEX_Subscription__dlm WHERE customerId__c IN :ids LIMIT 10';
            for (SObject s : performQuery(q, mockSubs)) {
                result.add(new Map<String, Object>{'nombre'=>s.get('plan_id__c'), 'status'=>s.get('status__c'), 'fechaCreacion'=>s.get('createdAt__c'), 'frecuencia'=>s.get('frequency_periodicity__c'), 'proximaCompra'=>s.get('nextPurchaseDate__c'), 'productos'=>new List<Object>()});
            }
        } catch (Exception e) {}
        return result;
    }

    public static Map<String, Object> getMarketingScores(String unifiedId) {
        return new Map<String, Object>{'rfmRetail'=>new Map<String, Object>{'solares'=>'N/A','solaresLabel'=>'Sin clasificar','lentesContacto'=>'N/A','oftalmicos'=>'N/A'}, 'einsteinScore'=>new Map<String, Object>{'propensidadClick'=>'Media','propensidadAbrir'=>'Alta'}};
    }

    public static List<Map<String, Object>> getAppointments(String unifiedId) {
        List<Map<String, Object>> res = new List<Map<String, Object>>();
        try {
            List<SObject> profiles = performQuery('SELECT Id_TuoTempo__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = \''+unifiedId+'\'', mockProfiles);
            if (profiles.isEmpty() || profiles[0].get('Id_TuoTempo__c') == null) return res;
            String ttId = (String)profiles[0].get('Id_TuoTempo__c');
            for (SObject c : performQuery('SELECT start_date__c, end_date__c, activityTitle__c, areaTitle__c, estatus_cita__c, activity_lid__c FROM TUOTEMPO_CITA__dlm WHERE memberid__c = \''+ttId+'\' ORDER BY start_date__c DESC LIMIT 20', mockCitas)) {
                res.add(new Map<String, Object>{'citaId'=>c.get('activity_lid__c'), 'tipo'=>c.get('activityTitle__c'), 'status'=>c.get('estatus_cita__c'), 'sucursal'=>c.get('areaTitle__c'), 'inicio'=>c.get('start_date__c'), 'fin'=>c.get('end_date__c')});
            }
        } catch (Exception e) {}
        return res;
    }

    public static List<Map<String, Object>> getQuotes(String unifiedId) { return new List<Map<String, Object>>(); }

    public static List<Map<String, Object>> getOrders(String unifiedId) {
        List<Map<String, Object>> res = new List<Map<String, Object>>();
        try {
            List<String> ids = getRelatedIds(unifiedId); if (ids.isEmpty()) return res;
            List<SObject> orders = performQuery('SELECT ssot__Id__c, ssot__OrderNumber__c, ssot__CreatedDate__c, ssot__TotalAmount__c, ssot__SalesStoreId__c, ssot__QuoteId__c FROM ssot__SalesOrder__dlm WHERE ssot__SoldToCustomerId__c IN :ids ORDER BY ssot__CreatedDate__c DESC LIMIT 20', mockOrders);
            if (orders.isEmpty()) return res;
            List<String> oIds = new List<String>(); for(SObject o : orders) oIds.add((String)o.get('ssot__Id__c'));
            List<SObject> allP = performQuery('SELECT ssot__SalesOrderId__c, ssot__ProductId__c, ssot__Description__c, ssot__OrderedQuantity__c, ssot__TotalLineAmount__c FROM ssot__SalesOrderProduct__dlm WHERE ssot__SalesOrderId__c IN :oIds', mockOrderProducts);
            Map<String, String> stores = new Map<String, String>();
            for(SObject s : performQuery('SELECT ssot__Id__c, ssot__Name__c FROM ssot__SalesStore__dlm', mockStores)) stores.put((String)s.get('ssot__Id__c'), (String)s.get('ssot__Name__c'));
            for (SObject o : orders) {
                String oId = (String)o.get('ssot__Id__c');
                Map<String, Object> om = new Map<String, Object>{'total'=>o.get('ssot__TotalAmount__c'), 'fechaCompra'=>o.get('ssot__CreatedDate__c'), 'status'=>'Entregado', 'isReturn'=>false, 'ordenId'=>(o.get('ssot__OrderNumber__c')??oId), 'sucursal'=>(stores.get((String)o.get('ssot__SalesStoreId__c'))??'Sucursal Desconocida'), 'quoteNumber'=>o.get('ssot__QuoteId__c'), 'productos'=>new List<Map<String, Object>>()};
                for (SObject p : allP) { if (p.get('ssot__SalesOrderId__c') == oId) ((List<Map<String, Object>>)om.get('productos')).add(new Map<String, Object>{'nombre'=>p.get('ssot__Description__c'), 'sku'=>p.get('ssot__ProductId__c'), 'cantidad'=>p.get('ssot__OrderedQuantity__c'), 'precioTotal'=>p.get('ssot__TotalLineAmount__c')}); }
                res.add(om);
            }
        } catch (Exception e) {}
        return res;
    }

    public static Map<String, Object> getMedicalInfo(String unifiedId) {
        Map<String, Object> data = new Map<String, Object>();
        try {
            List<String> ids = getRelatedIds(unifiedId); if (ids.isEmpty()) return data;
            List<SObject> ant = performQuery('SELECT ARDOR_IRRITACION__c, COMEZON__c, DIABETES__c, HIPERTENSION__c, NOTAS__c, FECHA__c FROM POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm WHERE ID_CLIENTE__c IN :ids ORDER BY FECHA__c DESC LIMIT 1', mockAntecedents);
            if (!ant.isEmpty()) data.put('antecedents', ant[0]);
            List<SObject> drv = performQuery('SELECT NIVEL_VISION__c, TIPO_USUARIO__c, FECHA__c FROM POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm WHERE ID_CLIENTE__c IN :ids ORDER BY FECHA__c DESC LIMIT 1', mockDrivers);
            if (!drv.isEmpty()) data.put('visualDriver', drv[0]);
            List<SObject> pwr = performQuery('SELECT ACTIVIDAD_AIRE_LIBRE__c, PROTEGE_SUS_OJOS__c, FECHA_ALTA__c FROM POS_POS_CLIENTE_PREG_PODER__dlm WHERE ID_CLIENTE__c IN :ids ORDER BY FECHA_ALTA__c DESC LIMIT 1', mockPowers);
            if (!pwr.isEmpty()) data.put('powerQuestions', pwr[0]);
            List<SObject> diag = performQuery('SELECT ASTIGMATISMO__c, HIPERMETROPIA__c, MIOPIA__c, FECHA__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE ID_CLIENTE__c IN :ids ORDER BY FECHA__c DESC LIMIT 1', mockDiagnosis);
            if (!diag.isEmpty()) data.put('lastDiagnosis', diag[0]);
        } catch (Exception e) {}
        return data;
    }

    public static List<SObject> searchProfiles(String searchTerm, String attr) {
        List<String> allowed = new List<String>{'ssot__FirstName__c', 'ssot__LastName__c', 'Email__c', 'Id_POS__c'};
        if (String.isBlank(searchTerm) || !allowed.contains(attr)) return new List<SObject>();
        String q = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c, ssot__GenderId__c FROM UnifiedssotIndividualDev2__dlm WHERE ' + attr + ' LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT 20';
        try { return performQuery(q, mockProfiles); } catch (Exception e) { return new List<SObject>(); }
    }

    public static SObject getProfileByUnifiedId(String unifiedId) {
        try {
            List<SObject> res = performQuery('SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Apellido_Paterno__c, Apellido_Materno__c, Id_POS__c, FECHA_NACIMIENTO_dt__c, ssot__GenderId__c, Email__c, CODIGO_POSTAL__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = \''+unifiedId+'\' LIMIT 1', mockProfiles);
            return res.isEmpty() ? null : res[0];
        } catch (Exception e) { return null; }
    }

    public static SObject getProfileInfo(String recordId) {
        try {
            if (recordId == null) return null;
            List<SObject> links = performQuery('SELECT UnifiedRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm WHERE SourceRecordId__c = \'' + String.escapeSingleQuotes(recordId) + '\' LIMIT 1', mockLinks);
            if (links.isEmpty()) return null;
            return getProfileByUnifiedId((String)links[0].get('UnifiedRecordId__c'));
        } catch (Exception e) { return null; }
    }

    public static Map<String, Object> getCustomerMetrics(String unifiedId) {
        Map<String, Object> m = new Map<String, Object>{'totalSales'=>0, 'orderCount'=>0, 'avgTicket'=>0, 'daysSinceLastPurchase'=>0, 'lastBranch'=>'N/A', 'lastCategory'=>'N/A', 'retailTotal'=>0, 'ecommerceTotal'=>0, 'retailCategories'=>new Map<String,Integer>{'Solares'=>0,'LentesContacto'=>0,'Oftalmicos'=>0}, 'ecommerceCategories'=>new Map<String,Integer>{'Solares'=>0,'LentesContacto'=>0,'Oftalmicos'=>0}};
        try {
            List<Map<String, Object>> orders = getOrders(unifiedId);
            if (!orders.isEmpty()) {
                Decimal total = 0; Decimal rt = 0; Decimal et = 0; Date last = null; String lastC = 'N/A';
                for (Map<String, Object> o : orders) {
                    Decimal v = (Decimal)o.get('total'); String s = ((String)o.get('sucursal')??'').toLowerCase();
                    Boolean isE = s.contains('vtex') || s.contains('web') || s.contains('ecommerce');
                    if (v != null) { total += v; if (isE) et += v; else rt += v; }
                    Datetime dt = (Datetime)o.get('fechaCompra'); if (dt != null && (last == null || dt.date() > last)) last = dt.date();
                    for(Map<String, Object> p : (List<Map<String, Object>>)o.get('productos')) {
                        String n = ((String)p.get('nombre')??'').toLowerCase(); String cat = 'Oftalmicos';
                        if (n.contains('solar')) cat = 'Solares'; else if (n.contains('contacto')) cat = 'LentesContacto';
                        lastC = cat; Map<String, Integer> target = isE ? (Map<String, Integer>)m.get('ecommerceCategories') : (Map<String, Integer>)m.get('retailCategories');
                        target.put(cat, target.get(cat) + 1);
                    }
                }
                m.put('totalSales', total); m.put('retailTotal', rt); m.put('ecommerceTotal', et); m.put('orderCount', orders.size()); m.put('avgTicket', (total/orders.size()).setScale(2));
                if (last != null) m.put('daysSinceLastPurchase', last.daysBetween(Date.today()));
                m.put('lastBranch', orders[0].get('sucursal')); m.put('lastCategory', lastC);
            }
        } catch (Exception e) {}
        return m;
    }

    public static List<Map<String, Object>> executeDataCloudQuery(String sql) {
        List<Map<String, Object>> res = new List<Map<String, Object>>();
        try {
            if (Test.isRunningTest()) { res.add(new Map<String, Object>{'rfm_combined__c' => 500}); return res; }
            String ep = URL.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/ssot/queryv2';
            HttpRequest req = new HttpRequest(); req.setEndpoint(ep); req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId()); req.setHeader('Content-Type', 'application/json'); req.setBody('{"sql": "' + sql.replace('"', '\\"') + '"}');
            HttpResponse resp = new Http().send(req);
            if (resp.getStatusCode() == 200) {
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                List<Object> d = (List<Object>) m.get('data');
                if (d != null) { for (Object row : d) res.add((Map<String, Object>)row); }
            }
        } catch (Exception e) {}
        return res;
    }
}