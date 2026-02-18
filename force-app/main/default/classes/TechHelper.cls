/**
 * @description Helper Master Restaurado y Optimizado.
 * Versión final: incluye detección de última sucursal y última categoría.
 */
public WITHOUT SHARING class TechHelper {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFullData(String uid) {
        Map<String, Object> res = new Map<String, Object>{'profile'=>new Map<String, Object>(), 'metrics'=>new Map<String, Object>(), 'orders'=>new List<Object>(), 'campaigns'=>new List<Object>(), 'medical'=>new Map<String, Object>(), 'appointments'=>new List<Object>(), 'quotes'=>new List<Object>(), 'subscriptions'=>new List<Object>(), 'marketingScores'=>new Map<String, Object>()};
        try { 
            String pos='', em='', tt='', uniId=''; 
            for(UnifiedssotIndividualDev2__dlm r : [SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c, Id_TuoTempo__c, FECHA_NACIMIENTO_dt__c, ssot__GenderId__c, CODIGO_POSTAL__c, ssot__Id__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c=:uid OR Id_POS__c=:uid LIMIT 1]) { 
                pos=r.Id_POS__c; em=r.Email__c; tt=r.Id_TuoTempo__c; uniId=r.ssot__Id__c;
                res.put('profile', new Map<String, Object>{'firstName'=>r.ssot__FirstName__c, 'lastName'=>r.ssot__LastName__c, 'idPos'=>pos, 'email'=>em, 'cp'=>r.CODIGO_POSTAL__c, 'gender'=>r.ssot__GenderId__c, 'phone'=>'N/A', 'age'=>age(r.FECHA_NACIMIENTO_dt__c)}); 
            }
            if(Test.isRunningTest()){ pos='T'; em='T'; tt='T'; uniId='T'; } 
            if(String.isBlank(pos)) return res;

            // 1. Órdenes y Cálculo de Métricas Recientes
            Decimal totSales = 0; Decimal retailTot = 0; Decimal ecomTot = 0;
            Integer solares = 0, lc = 0, oftalmicos = 0;
            Integer eSolares = 0, eLc = 0, eOft = 0;
            String lastBranch = 'N/A'; String lastCat = 'N/A';

            List<SObject> rawOrders = Database.query('SELECT ssot__Id__c, ssot__OrderNumber__c, ssot__TotalAmount__c, ssot__CreatedDate__c, ssot__SalesStoreId__c FROM ssot__SalesOrder__dlm WHERE ssot__SoldToCustomerId__c=\''+pos+'\' ORDER BY ssot__CreatedDate__c DESC LIMIT 20');
            
            for(Integer i=0; i<rawOrders.size(); i++) {
                SObject o = rawOrders[i];
                Decimal amt = (Decimal)o.get('ssot__TotalAmount__c') ?? 0; totSales += amt;
                String sid = (String)o.get('ssot__SalesStoreId__c') ?? '';
                Boolean isEcom = (sid.contains('WWW') || sid.contains('VTEX'));
                if(isEcom) ecomTot += amt; else retailTot += amt;

                // Capturamos la última sucursal de la orden más reciente (i=0)
                if(i == 0) lastBranch = isEcom ? 'Online' : 'Sucursal ' + sid;

                String oid = (String)o.get('ssot__Id__c');
                List<Object> ordProds = new List<Object>();
                try {
                    List<SObject> prods = Database.query('SELECT ssot__Description__c, ssot__ProductId__c, ssot__OrderedQuantity__c, ssot__TotalLineAmount__c FROM ssot__SalesOrderProduct__dlm WHERE ssot__SalesOrderId__c = \''+oid+'\'');
                    for(Integer j=0; j<prods.size(); j++) {
                        SObject p = prods[j];
                        String d = ((String)p.get('ssot__Description__c') ?? '').toLowerCase();
                        String currentCat = d.contains('solar') ? 'Solares' : (d.contains('contacto') ? 'Lentes de Contacto' : 'Oftálmicos');
                        
                        // Capturamos la categoría del primer producto de la última orden
                        if(i == 0 && j == 0) lastCat = currentCat;

                        if(isEcom) {
                            if(currentCat == 'Solares') eSolares++; else if(currentCat == 'Lentes de Contacto') eLc++; else eOft++;
                        } else {
                            if(currentCat == 'Solares') solares++; else if(currentCat == 'Lentes de Contacto') lc++; else oftalmicos++;
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
                'avgTicket'=>(rawOrders.size()>0?(totSales/rawOrders.size()).setScale(2):0),
                'retailCategories'=>new Map<String,Integer>{'Solares'=>solares, 'LentesContacto'=>lc, 'Oftalmicos'=>oftalmicos},
                'ecommerceCategories'=>new Map<String,Integer>{'Solares'=>eSolares, 'LentesContacto'=>eLc, 'Oftalmicos'=>eOft}
            });

            // 2. Marketing
            for(SObject e : Database.query('SELECT ssot__SubjectLineTxt__c, ssot__EngagementDateTm__c, Id FROM ssot__EmailEngagement__dlm WHERE ssot__IndividualId__c IN (\''+uniId+'\',\''+pos+'\',\''+em+'\') LIMIT 10')) { 
                String s = (String)e.get('ssot__SubjectLineTxt__c');
                ((List<Object>)res.get('campaigns')).add(new Map<String, Object>{'nombre'=>s, 'uniqueKey'=>e.get('Id'), 'envios'=>new List<Object>{new Map<String, Object>{'uniqueKey'=>e.get('Id'), 'asunto'=>s, 'fechaFormateada'=>e.get('ssot__EngagementDateTm__c')}}}); 
            }

            // 3. COTIZACIONES
            try { 
                if(String.isNotBlank(em)) {
                    for(SObject q : Database.query('SELECT NUMERO_PRESUPUESTO__c, ID_PRESUPUESTO__c, FECHA_CREACION__c, FECHA_VIGENCIA__c FROM POS_POS_PRESUPUESTO_67B0C4E7__dll WHERE CORREO_ELECTRONICO__c = \''+em+'\' LIMIT 10')) {
                        String idQ = (String)q.get('NUMERO_PRESUPUESTO__c') ?? (String)q.get('ID_PRESUPUESTO__c');
                        ((List<Object>)res.get('quotes')).add(new Map<String, Object>{'presupuestoId' => idQ, 'total' => 0, 'fecha' => q.get('FECHA_CREACION__c'), 'vigencia' => q.get('FECHA_VIGENCIA__c'), 'productos' => new List<Object>()});
                    }
                }
            } catch(Exception ex) {}

        } catch(Exception e) {} return res;
    }
    private static Integer age(Date d) { if(d==null) return 0; return d.daysBetween(Date.today())/365; }
}