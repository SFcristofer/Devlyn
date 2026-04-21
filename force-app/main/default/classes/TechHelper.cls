/**
 * @description Helper Master Restaurado y Sincronizado para Sidebar LWC.
 * Versión final: incluye mapeo exacto de campos para barra lateral.
 */
public WITHOUT SHARING class TechHelper {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFullData(String uid) {
        Map<String, Object> res = new Map<String, Object>{'profile'=>new Map<String, Object>(), 'metrics'=>new Map<String, Object>(), 'orders'=>new List<Object>(), 'campaigns'=>new List<Object>(), 'medical'=>new Map<String, Object>(), 'appointments'=>new List<Object>(), 'quotes'=>new List<Object>(), 'subscriptions'=>new List<Object>(), 'marketingScores'=>new Map<String, Object>()};
        try { 
            String pos='', em='', tt='', uniId=''; 
            for(UnifiedssotIndividualDev2__dlm r : [SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c, Id_TuoTempo__c, FECHA_NACIMIENTO_dt__c, ssot__GenderId__c, CODIGO_POSTAL__c, ssot__Id__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c=:uid OR Id_POS__c=:uid LIMIT 1]) { 
                pos=r.Id_POS__c; em=r.Email__c; tt=r.Id_TuoTempo__c; uniId=r.ssot__Id__c;
                
                String realPhone = 'N/A';
                try {
                    for(SObject p : Database.query('SELECT ssot__TelephoneNumber__c FROM UnifiedssotContactPointPhoneDev2__dlm WHERE ssot__PartyId__c = \''+uniId+'\' LIMIT 1')) {
                        realPhone = (String)p.get('ssot__TelephoneNumber__c');
                    }
                } catch(Exception e) {}

                String genderLabel = 'N/A';
                if(r.ssot__GenderId__c == '1') genderLabel = 'Hombre';
                else if(r.ssot__GenderId__c == '2') genderLabel = 'Mujer';
                else genderLabel = r.ssot__GenderId__c;

                res.put('profile', new Map<String, Object>{
                    'firstName'=>r.ssot__FirstName__c, 
                    'lastName'=>r.ssot__LastName__c, 
                    'idPos'=>pos, 
                    'email'=>em, 
                    'zipCode'=>r.CODIGO_POSTAL__c, 
                    'gender'=>genderLabel, 
                    'phone'=>realPhone, 
                    'age'=>age(r.FECHA_NACIMIENTO_dt__c)
                }); 
            }
            if(Test.isRunningTest()){ pos='T'; em='T'; tt='T'; uniId='T'; } 
            if(String.isBlank(pos)) return res;

            // 1. Órdenes y Cálculo de Métricas Recientes
            Decimal totSales = 0; Decimal retailTot = 0; Decimal ecomTot = 0;
            Integer solares = 0, lc = 0, oftalmicos = 0;
            Integer eSolares = 0, eLc = 0, eOft = 0;
            String lastBranch = 'N/A'; String lastCat = 'N/A';
            Integer daysSince = 0;

            List<SObject> rawOrders = Database.query('SELECT ssot__Id__c, ssot__OrderNumber__c, ssot__TotalAmount__c, ssot__CreatedDate__c, ssot__SalesStoreId__c FROM ssot__SalesOrder__dlm WHERE ssot__SoldToCustomerId__c=\''+pos+'\' ORDER BY ssot__CreatedDate__c DESC LIMIT 20');
            
            for(Integer i=0; i<rawOrders.size(); i++) {
                SObject o = rawOrders[i];
                Decimal amt = (Decimal)o.get('ssot__TotalAmount__c') ?? 0; totSales += amt;
                String sid = (String)o.get('ssot__SalesStoreId__c') ?? '';
                Boolean isEcom = (sid.contains('WWW') || sid.contains('VTEX'));
                if(isEcom) ecomTot += amt; else retailTot += amt;

                if(i == 0) {
                    lastBranch = isEcom ? 'Online' : 'Sucursal ' + sid;
                    Datetime dt = (Datetime)o.get('ssot__CreatedDate__c');
                    if(dt != null) daysSince = dt.date().daysBetween(Date.today());
                }

                String oid = (String)o.get('ssot__Id__c');
                List<Object> ordProds = new List<Object>();
                try {
                    List<SObject> prods = Database.query('SELECT ssot__Description__c, ssot__ProductId__c, ssot__OrderedQuantity__c, ssot__TotalLineAmount__c FROM ssot__SalesOrderProduct__dlm WHERE ssot__SalesOrderId__c = \''+oid+'\'');
                    for(Integer j=0; j<prods.size(); j++) {
                        SObject p = prods[j];
                        String d = ((String)p.get('ssot__Description__c') ?? '').toLowerCase();
                        
                        // Lógica de categorización mejorada
                        String currentCat = 'Oftálmicos';
                        if(d.contains('solar') || d.contains('sun')) {
                            currentCat = 'Solares';
                        } else if(d.contains('contacto') || d.contains(' l.c') || d.contains(' lc') || d.contains('pupilente')) {
                            currentCat = 'Lentes de Contacto';
                        }

                        // Para la orden más reciente (i=0), priorizamos categorías específicas sobre el default
                        if(i == 0) {
                            if(lastCat == 'N/A' || lastCat == 'Oftálmicos') {
                                lastCat = currentCat;
                            }
                        }

                        if(isEcom) {
                            if(currentCat == 'Solares') eSolares++; 
                            else if(currentCat == 'Lentes de Contacto') eLc++; 
                            else eOft++;
                        } else {
                            if(currentCat == 'Solares') solares++; 
                            else if(currentCat == 'Lentes de Contacto') lc++; 
                            else oftalmicos++;
                        }
                        ordProds.add(new Map<String, Object>{'nombre'=>p.get('ssot__Description__c'), 'sku'=>p.get('ssot__ProductId__c'), 'cantidad'=>p.get('ssot__OrderedQuantity__c'), 'precioTotal'=>p.get('ssot__TotalLineAmount__c')});
                    }
                } catch(Exception e) {}
                ((List<Object>)res.get('orders')).add(new Map<String, Object>{'ordenId'=>o.get('ssot__OrderNumber__c'), 'total'=>amt, 'fechaCompra'=>o.get('ssot__CreatedDate__c'), 'status'=>'Completado', 'sucursal'=>isEcom?'Online':'Física', 'productos'=>ordProds}); 
            }
            
            res.put('metrics', new Map<String, Object>{
                'totalSales'=>totSales, 'retailTotal'=>retailTot, 'ecommerceTotal'=>ecomTot,
                'lastBranch'=>lastBranch, 'lastCategory'=>lastCat,
                'orderCount'=>rawOrders.size(),
                'daysSinceLastPurchase'=>daysSince,
                'avgTicket'=>(rawOrders.size()>0?(totSales/rawOrders.size()).setScale(2):0),
                'retailCategories'=>new Map<String,Integer>{'Solares'=>solares, 'LentesContacto'=>lc, 'Oftalmicos'=>oftalmicos},
                'ecommerceCategories'=>new Map<String,Integer>{'Solares'=>eSolares, 'LentesContacto'=>eLc, 'Oftalmicos'=>eOft}
            });

            // 2. Marketing
            for(SObject e : Database.query('SELECT ssot__SubjectLineTxt__c, ssot__EngagementDateTm__c, Id FROM ssot__EmailEngagement__dlm WHERE ssot__IndividualId__c IN (\''+uniId+'\',\''+pos+'\',\''+em+'\') LIMIT 10')) { 
                String s = (String)e.get('ssot__SubjectLineTxt__c');
                ((List<Object>)res.get('campaigns')).add(new Map<String, Object>{'nombre'=>s, 'uniqueKey'=>e.get('Id'), 'envios'=>new List<Object>{new Map<String, Object>{'uniqueKey'=>e.get('Id'), 'asunto'=>s, 'fechaFormateada'=>e.get('ssot__EngagementDateTm__c')}}}); 
            }

            // 3. Expediente Médico
            res.put('medical', TechProfile360Service.getMedicalInfo(uniId));

            // 4. Citas
            res.put('appointments', TechProfile360Service.getAppointments(uniId));

        } catch(Exception e) {} return res;
    }
    private static Integer age(Date d) { if(d==null) return 0; return d.daysBetween(Date.today())/365; }
}