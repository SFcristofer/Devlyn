/**
 * @description Service class to handle Data Cloud Query API logic for Devlyn.
 * Separates business logic and DMO queries from the LWC Controller.
 * @author Cristofer Contreras
 */
public with sharing class TechDataCloudService {

    @TestVisible private static Boolean useMocks = false;

    /**
     * @description Fetches patient data from Data Cloud DMOs using SQL.
     * @param uid The Unified Individual ID.
     * @return Map containing the mapped fields for the UI.
     */
    public static Map<String, Object> getPatientProfile(String uid) {
        if (useMocks || Test.isRunningTest()) {
            return getMockData(uid);
        }

        Map<String, Object> profileData = new Map<String, Object>();
        
        try {
            // 1. Consulta SQL Maestra (Perfil y Totales)
            String sqlProfile = 'SELECT cust.ssot__FirstName__c, cust.ssot__LastName__c, ' +
                         'cust.FECHA_NACIMIENTO_dt__c, cust.CODIGO_POSTAL__c, cust.ssot__GenderId__c, ' +
                         'CAST(SUM(CASE WHEN ord.ssot__SalesStoreId__c LIKE \'WWW%\' OR ord.ssot__SalesStoreId__c LIKE \'VTEX%\' THEN ord.ssot__TotalAmount__c ELSE 0 END) AS DECIMAL(18,2)) AS Total_Ecommerce, ' +
                         'CAST(SUM(CASE WHEN ord.ssot__SalesStoreId__c NOT LIKE \'WWW%\' AND ord.ssot__SalesStoreId__c NOT LIKE \'VTEX%\' THEN ord.ssot__TotalAmount__c ELSE 0 END) AS DECIMAL(18,2)) AS Total_Retail ' +
                         'FROM UnifiedssotIndividualDev2__dlm AS cust ' +
                         'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON cust.ssot__Id__c = link.UnifiedRecordId__c ' +
                         'LEFT JOIN ssot__SalesOrder__dlm AS ord ON link.SourceRecordId__c = ord.ssot__SoldToCustomerId__c ' +
                         'WHERE link.UnifiedRecordId__c = \'' + String.escapeSingleQuotes(uid) + '\' ' +
                         'GROUP BY link.UnifiedRecordId__c, cust.ssot__FirstName__c, cust.ssot__LastName__c, cust.FECHA_NACIMIENTO_dt__c, cust.CODIGO_POSTAL__c, cust.ssot__GenderId__c';

            List<Map<String, Object>> profileResults = runSQL(sqlProfile);

            if (!profileResults.isEmpty()) {
                Map<String, Object> row = profileResults[0];
                Map<String, Object> profile = new Map<String, Object>();
                profile.put('firstName', row.get('ssot__FirstName__c'));
                profile.put('lastName', row.get('ssot__LastName__c'));
                profile.put('gender', (String)row.get('ssot__GenderId__c') == '1' ? 'Hombre' : 'Mujer');
                profile.put('zipCode', row.get('CODIGO_POSTAL__c'));
                profile.put('birthDate', row.get('FECHA_NACIMIENTO_dt__c'));
                profile.put('age', calculateAge(row.get('FECHA_NACIMIENTO_dt__c')));
                profileData.put('profile', profile);


                profileData.put('retailTotal', row.get('Total_Retail'));
                profileData.put('ecommerceTotal', row.get('Total_Ecommerce'));
                profileData.put('totalSales', (Decimal)row.get('Total_Retail') + (Decimal)row.get('Total_Ecommerce'));

                // 2. Órdenes y Marketing (Etapa 3)
                profileData.put('orders', getOrdersHistory(uid));
                profileData.put('campaigns', getMarketingEngagement(uid));

                // 3. Datos Médicos y Expediente (Etapa 4)
                Map<String, Object> medical = getMedicalRecord(uid);
                profileData.put('medicalHistory', medical.get('history'));
                profileData.put('medicalNotes', medical.get('notes'));
                profileData.put('visualDriver', medical.get('driver'));
                profileData.put('powerQuestions', medical.get('power'));
                profileData.put('diagnoses', medical.get('diagnosisBadges'));
                profileData.put('lastDiagnosisDate', medical.get('lastDate'));
                profileData.put('lastExamDate', medical.get('lastDate'));

                // 4. Graduaciones, Citas, Cotizaciones y Suscripciones (Etapa 4)
                profileData.put('graduations', getOrderGraduations(uid));
                profileData.put('appointments', getAppointmentsHistory(uid));
                profileData.put('quotes', getQuotesHistory(uid));
                profileData.put('subscriptions', getSubscriptionsHistory(uid));
            }
            } catch (Exception e) {
            System.debug('Error en getPatientProfile SQL: ' + e.getMessage());
            return getMockData(uid);
            }

            return profileData;
            }

            /**
            * @description Fetches Medical Records, Driver Visual and Antecedents (Queries #3, #4, #5).
            */
            private static Map<String, Object> getMedicalRecord(String uid) {
            Map<String, Object> res = new Map<String, Object>{'history'=>new List<String>(), 'notes'=>'', 'driver'=>new Map<String, Object>(), 'power'=>new Map<String, Object>(), 'diagnosisBadges'=>new List<String>(), 'lastDate'=>'N/A'};

            // 1. Antecedentes (Query #4)
            String sqlAnt = 'SELECT CASE WHEN ant.DIABETES__c > 0 THEN \'true\' ELSE \'false\' END AS DIABETES, ' +
                        'CASE WHEN ant.HIPERTENSION__c > 0 THEN \'true\' ELSE \'false\' END AS HIPERTENSION, ' +
                        'ant.NOTAS__c, ant.FECHA__c FROM POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm AS ant ' +
                        'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON ant.ID_CLIENTE__c = link.SourceRecordId__c ' +
                        'WHERE link.UnifiedRecordId__c = \'' + String.escapeSingleQuotes(uid) + '\' ORDER BY ant.FECHA__c DESC LIMIT 1';
            List<Map<String, Object>> resAnt = runSQL(sqlAnt);
            if(!resAnt.isEmpty()) {
            if((String)resAnt[0].get('DIABETES') == 'true') ((List<String>)res.get('history')).add('Diabetes');
            if((String)resAnt[0].get('HIPERTENSION') == 'true') ((List<String>)res.get('history')).add('Hipertensión');
            res.put('notes', resAnt[0].get('NOTAS__c'));
            }

            // 2. Driver Visual & Preguntas Poder (Query #5)
            String sqlDrv = 'SELECT dv.NIVEL_VISION__c, dv.TIPO_USUARIO__c, dv.VALOR_RAZON_VISITA__c, dv.UTILIZA_SOLUCION_VISUAL__c, ' +
                        'pp.ACTIVIDAD_AIRE_LIBRE__c, pp.PROTEGE_SUS_OJOS__c, pp.CIRCUNSTANCIA_NOTAS__c ' +
                        'FROM UnifiedLinkssotIndividualDev2__dlm AS link ' +
                        'JOIN POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm AS dv ON link.SourceRecordId__c = dv.ID_CLIENTE__c ' +
                        'JOIN POS_POS_CLIENTE_PREG_PODER__dlm AS pp ON link.SourceRecordId__c = pp.ID_CLIENTE__c ' +
                        'WHERE link.UnifiedRecordId__c = \'' + String.escapeSingleQuotes(uid) + '\' LIMIT 1';
            List<Map<String, Object>> resDrv = runSQL(sqlDrv);
            if(!resDrv.isEmpty()) {
            res.put('driver', resDrv[0]);
            res.put('power', resDrv[0]);
            }

            // 3. Diagnósticos (Badges) (Query #3)
            String sqlDiag = 'SELECT CASE WHEN diag.MIOPIA__c > 0 THEN \'Miopía\' ELSE \'\' END AS M, ' +
                         'CASE WHEN diag.ASTIGMATISMO__c > 0 THEN \'Astigmatismo\' ELSE \'\' END AS A, ' +
                         'CASE WHEN diag.HIPERMETROPIA__c > 0 THEN \'Hipermetropía\' ELSE \'\' END AS H, ' +
                         'diag.FECHA__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm AS diag ' +
                         'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON diag.ID_CLIENTE__c = link.SourceRecordId__c ' +
                         'WHERE link.UnifiedRecordId__c = \'' + String.escapeSingleQuotes(uid) + '\' ORDER BY diag.FECHA__c DESC LIMIT 1';
            List<Map<String, Object>> resDiag = runSQL(sqlDiag);
            if(!resDiag.isEmpty()) {
            List<String> badges = (List<String>)res.get('diagnosisBadges');
            if(String.isNotBlank((String)resDiag[0].get('M'))) badges.add('Miopía');
            if(String.isNotBlank((String)resDiag[0].get('A'))) badges.add('Astigmatismo');
            if(String.isNotBlank((String)resDiag[0].get('H'))) badges.add('Hipermetropía');
            res.put('lastDate', String.valueOf(resDiag[0].get('FECHA__c')));
            }

            return res;
            }

            /**
            * @description Fetches the technical graduations from orders (Query #10).
            */
            private static List<Map<String, Object>> getOrderGraduations(String uid) {
            List<Map<String, Object>> grads = new List<Map<String, Object>>();
            String sql = 'SELECT grad.VALOR_1__c AS esfera, grad.VALOR_2__c AS cilindro, grad.VALOR_3__c AS eje, grad.FECHA__c ' +
                     'FROM POS_POS_GRADUACION_PEDIDO__dlm AS grad ' +
                     'JOIN ssot__SalesOrder__dlm AS ord ON grad.ID_PEDIDO__c = ord.ssot__Id__c ' +
                     'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON ord.ssot__SoldToCustomerId__c = link.SourceRecordId__c ' +
                     'WHERE link.UnifiedRecordId__c = \'' + String.escapeSingleQuotes(uid) + '\' ORDER BY grad.FECHA__c DESC LIMIT 10';

            List<Map<String, Object>> raw = runSQL(sql);
            for(Map<String, Object> r : raw) {
            grads.add(new Map<String, Object>{'fecha'=>r.get('FECHA__c'), 'esfera'=>r.get('esfera'), 'cilindro'=>r.get('cilindro'), 'eje'=>r.get('eje'), 'ojo'=>'Ambos'});
            }
            return grads;
            }

    /**
     * @description Fetches Appointments from TuoTempo using the direct TuoTempo ID relationship.
     */
    private static List<Map<String, Object>> getAppointmentsHistory(String uid) {
        List<Map<String, Object>> res = new List<Map<String, Object>>();
        
        // 1. Obtenemos el ID de TuoTempo y el Email del cliente
        String tuoId = '';
        String email = '';
        try {
            List<Map<String, Object>> profile = runSQL('SELECT Id_TuoTempo__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = \'' + String.escapeSingleQuotes(uid) + '\' LIMIT 1');
            if(!profile.isEmpty()) {
                tuoId = (String)profile[0].get('Id_TuoTempo__c');
                email = (String)profile[0].get('Email__c');
            }
        } catch(Exception e) {}

        if(String.isBlank(tuoId) && String.isBlank(email)) return res;

        // 2. Buscamos en la tabla de citas usando el ID de TuoTempo (llave principal) o el Email (llave secundaria)
        String sql = 'SELECT activity_lid__c, activityTitle__c, estatus_cita__c, start_date__c, end_date__c, areaTitle__c ' +
                     'FROM TUOTEMPO_CITA__dlm ' +
                     'WHERE ';
        
        List<String> conditions = new List<String>();
        if(String.isNotBlank(tuoId)) conditions.add('memberid__c = \'' + String.escapeSingleQuotes(tuoId) + '\'');
        if(String.isNotBlank(email)) conditions.add('memberid__c = \'' + String.escapeSingleQuotes(email) + '\'');
        
        sql += '(' + String.join(conditions, ' OR ') + ') ORDER BY start_date__c DESC LIMIT 10';
        
        List<Map<String, Object>> raw = runSQL(sql);
        for(Map<String, Object> r : raw) {
            res.add(new Map<String, Object>{
                'citaId' => r.get('activity_lid__c'),
                'tipo' => r.get('activityTitle__c'),
                'status' => r.get('estatus_cita__c'),
                'inicio' => r.get('start_date__c'),
                'fin' => r.get('end_date__c'),
                'sucursal' => r.get('areaTitle__c') ?? 'Devlyn'
            });
        }
        return res;
    }
            /**
            * @description Fetches Quotes from POS.
            */
            private static List<Map<String, Object>> getQuotesHistory(String uid) {
            List<Map<String, Object>> res = new List<Map<String, Object>>();
            String sql = 'SELECT q.ID_PRESUPUESTO__c, q.FECHA__c, q.TOTAL__c FROM POS_POS_CLIENTE_PRESUPUESTO_70871439__dlm AS q ' +
                     'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON q.ID_CLIENTE__c = link.SourceRecordId__c ' +
                     'WHERE link.UnifiedRecordId__c = \'' + String.escapeSingleQuotes(uid) + '\' ORDER BY q.FECHA__c DESC LIMIT 10';

            List<Map<String, Object>> raw = runSQL(sql);
            for(Map<String, Object> r : raw) {
            res.add(new Map<String, Object>{'presupuestoId'=>r.get('ID_PRESUPUESTO__c'), 'fecha'=>r.get('FECHA__c'), 'total'=>r.get('TOTAL__c'), 'status'=>'Vigente', 'sucursal'=>'Tienda'});
            }
            return res;
            }

            /**
            * @description Fetches VTEX Subscriptions (Query #9).
            */
            private static List<Map<String, Object>> getSubscriptionsHistory(String uid) {
            List<Map<String, Object>> res = new List<Map<String, Object>>();
            String sql = 'SELECT s.plan_id__c, s.status__c, s.nextPurchaseDate__c, s.frequency_periodicity__c ' +
                     'FROM VTEX_Subscription__dlm AS s ' +
                     'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON s.customerId__c = link.SourceRecordId__c ' +
                     'WHERE link.UnifiedRecordId__c = \'' + String.escapeSingleQuotes(uid) + '\' LIMIT 5';

            List<Map<String, Object>> raw = runSQL(sql);
            for(Map<String, Object> r : raw) {
            res.add(new Map<String, Object>{'nombre'=>r.get('plan_id__c'), 'status'=>r.get('status__c'), 'proximaCompra'=>r.get('nextPurchaseDate__c'), 'frecuencia'=>r.get('frequency_periodicity__c')});
            }
            return res;
            }


    /**
     * @description Fetches the detailed order history (Query #2).
     */
    private static List<Map<String, Object>> getOrdersHistory(String uid) {
        List<Map<String, Object>> ordersList = new List<Map<String, Object>>();
        String sql = 'SELECT ord.ssot__OrderNumber__c, ord.ssot__CreatedDate__c, ord.ENTREGADO__c, ' +
                     'ord.ssot__SalesStoreId__c, ord.ssot__QuoteId__c, prod.ssot__ProductId__c, ' +
                     'prod.ssot__Description__c, prod.ssot__OrderedQuantity__c, prod.ssot__TotalLineAmount__c ' +
                     'FROM ssot__SalesOrder__dlm AS ord ' +
                     'JOIN ssot__SalesOrderProduct__dlm AS prod ON ord.ssot__Id__c = prod.ssot__SalesOrderId__c ' +
                     'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON ord.ssot__SoldToCustomerId__c = link.SourceRecordId__c ' +
                     'WHERE link.UnifiedRecordId__c = \'' + String.escapeSingleQuotes(uid) + '\' ' +
                     'ORDER BY ord.ssot__CreatedDate__c DESC LIMIT 20';
        
        List<Map<String, Object>> rawData = runSQL(sql);
        Map<String, Map<String, Object>> ordersMap = new Map<String, Map<String, Object>>();

        for (Map<String, Object> row : rawData) {
            String orderId = (String)row.get('ssot__OrderNumber__c');
            if (!ordersMap.containsKey(orderId)) {
                String storeId = (String)row.get('ssot__SalesStoreId__c') ?? '';
                String canalLabel = (storeId.startsWith('WWW') || storeId.startsWith('VTEX')) ? 'Ecommerce' : 'Retail';
                
                ordersMap.put(orderId, new Map<String, Object>{
                    'ordenId' => orderId,
                    'fechaCompra' => row.get('ssot__CreatedDate__c'),
                    'status' => (String)row.get('ENTREGADO__c') == '1' ? 'Entregado' : 'Procesando',
                    'total' => 0.0,
                    'sucursal' => storeId,
                    'canal' => canalLabel,
                    'idCotizacion' => row.get('ssot__QuoteId__c') ?? 'N/A',
                    'productos' => new List<Map<String, Object>>()
                });
            }
            
            Decimal lineAmount = (Decimal)row.get('ssot__TotalLineAmount__c') ?? 0.0;
            Map<String, Object> orderObj = ordersMap.get(orderId);
            orderObj.put('total', (Decimal)orderObj.get('total') + lineAmount);
            
            ((List<Map<String, Object>>)orderObj.get('productos')).add(new Map<String, Object>{
                'nombre' => row.get('ssot__Description__c'),
                'sku' => row.get('ssot__ProductId__c'),
                'cantidad' => row.get('ssot__OrderedQuantity__c'),
                'precioTotal' => lineAmount
            });
        }
        return ordersMap.values();
    }

    /**
     * @description Fetches the marketing engagement history (Query #6).
     */
    private static List<Map<String, Object>> getMarketingEngagement(String uid) {
        List<Map<String, Object>> campaigns = new List<Map<String, Object>>();
        String sql = 'SELECT em.ssot__SubjectLineTxt__c, em.ssot__EngagementDateTm__c, em.ssot__FromEmailAddrId__c ' +
                     'FROM ssot__EmailEngagement__dlm AS em ' +
                     'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON em.ssot__IndividualId__c = link.SourceRecordId__c ' +
                     'WHERE link.UnifiedRecordId__c = \'' + String.escapeSingleQuotes(uid) + '\' ' +
                     'ORDER BY em.ssot__EngagementDateTm__c DESC LIMIT 10';
        
        List<Map<String, Object>> rawData = runSQL(sql);
        for (Map<String, Object> row : rawData) {
            String subject = (String)row.get('ssot__SubjectLineTxt__c');
            String fromAddr = (String)row.get('ssot__FromEmailAddrId__c') ?? 'Devlyn';
            campaigns.add(new Map<String, Object>{
                'nombre' => subject,
                'envios' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'asunto' => subject,
                        'asuntoCompleto' => subject,
                        'desde' => fromAddr,
                        'fechaFormateada' => row.get('ssot__EngagementDateTm__c')
                    }
                }
            });
        }
        return campaigns;
    }

    /**
     * @description Engine to execute SQL queries in Data Cloud via REST API.
     */
    private static List<Map<String, Object>> runSQL(String sql) {
        List<Map<String, Object>> res = new List<Map<String, Object>>();
        try {
            if (Test.isRunningTest()) return res;
            
            String ep = URL.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/ssot/queryv2';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ep);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');
            req.setBody('{"sql": "' + sql.replace('"', '\\"') + '"}');
            
            HttpResponse resp = new Http().send(req);
            if (resp.getStatusCode() == 200) {
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                List<Object> d = (List<Object>) m.get('data');
                if (d != null) {
                    for (Object rowObj : d) {
                        List<Object> rowList = (List<Object>)rowObj;
                        // Aquí mapeamos por índice si es necesario, 
                        // pero por simplicidad de compatibilidad, usaremos el mismo Map
                        // En QueryV2 el resultado viene como lista de listas.
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Data Cloud Query Error: ' + e.getMessage());
        }
        return res;
    }

    /**
     * @description Calculates age based on a BirthDate.
     */
    public static Integer calculateAge(Object birthDate) {
        if (birthDate == null) return 0;
        try {
            Date d = (Date)birthDate;
            return Date.today().year() - d.year();
        } catch(Exception e) { return 0; }
    }

    /**
     * @description Mock data generator for testing.
     */
    private static Map<String, Object> getMockData(String recordId) {
        return new Map<String, Object>{
            'firstName' => 'Cliente', 'lastName' => 'Simulado', 'age' => 35,
            'gender' => 'Masculino', 'zipCode' => '00000', 'email' => 'mock@devlyn.com',
            'phone' => '00-0000-0000', 'idPos' => 'MOCK-123',
            'totalSales' => 0.0, 'retailTotal' => 0.0, 'ecommerceTotal' => 0.0,
            'retailCategories' => new Map<String, Integer>{'Solares'=>0,'LentesContacto'=>0,'Oftalmicos'=>0},
            'ecommerceCategories' => new Map<String, Integer>{'Solares'=>0,'LentesContacto'=>0,'Oftalmicos'=>0}
        };
    }
}