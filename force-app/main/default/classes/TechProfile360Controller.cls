/**
 * @description Controller for Profile 360 View.
 * Extracted exactly from text.txt with Tech prefix added.
 * @author Cristofer Contreras
 * @email cristofer.contreras@technovalue.com.mx
 */
public with sharing class TechProfile360Controller {

    @TestVisible private static List<UnifiedLinkssotIndividualDev2__dlm> mockLinks;
    @TestVisible private static List<UnifiedssotIndividualDev2__dlm> mockProfiles;
    @TestVisible private static List<SObject> mockEngagements;
    @TestVisible private static List<SObject> mockSubs;
    @TestVisible private static List<SObject> mockRfm;
    @TestVisible private static List<SObject> mockCitas;
    @TestVisible private static List<SObject> mockOrders;
    @TestVisible private static List<SObject> mockOrderProducts;
    @TestVisible private static List<SObject> mockStores;
    @TestVisible private static List<SObject> mockAntecedents;
    @TestVisible private static List<SObject> mockDrivers;
    @TestVisible private static List<SObject> mockPowers;
    @TestVisible private static List<SObject> mockDiagnosis;
    @TestVisible private static Boolean forceException = false;

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getMarketingHistory(String unifiedId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        try {
            if (Test.isRunningTest() && forceException) throw new IllegalArgumentException('Forced');
            String engQuery = 'SELECT ssot__SubjectLineTxt__c, ssot__EngagementDateTm__c, ssot__EmailFromAddr__c, ssot__Id__c ' +
                              'FROM ssot__EmailEngagement__dlm ' +
                              'WHERE ssot__IndividualId__c = :unifiedId ' +
                              'ORDER BY ssot__EngagementDateTm__c DESC LIMIT 20';
            List<SObject> engagements = (Test.isRunningTest() && mockEngagements != null) ? mockEngagements : Database.query(engQuery);
            
            if (engagements.isEmpty()) return result;

            // Agrupamos por asunto para simular "Campañas" como pide la UI
            Map<String, Map<String, Object>> campaignsMap = new Map<String, Map<String, Object>>();

            for (SObject e : engagements) {
                String subject = (String)e.get('ssot__SubjectLineTxt__c');
                if (subject == null) subject = 'Sin Asunto';
                
                if (!campaignsMap.containsKey(subject)) {
                    Map<String, Object> camp = new Map<String, Object>();
                    camp.put('nombre', subject);
                    camp.put('journey', 'Marketing Cloud Journey');
                    camp.put('envios', new List<Map<String, Object>>());
                    campaignsMap.put(subject, camp);
                }

                Map<String, Object> envio = new Map<String, Object>();
                envio.put('uniqueKey', e.get('ssot__Id__c'));
                envio.put('tipo', 'Email');
                envio.put('icono', 'utility:email');
                envio.put('asunto', subject);
                envio.put('fechaEnvio', e.get('ssot__EngagementDateTm__c'));
                envio.put('desde', e.get('ssot__EmailFromAddr__c'));
                envio.put('asuntoCompleto', subject);
                envio.put('eventos', new List<Object>()); // En una fase futura traeríamos clicks/opens específicos
                
                ((List<Map<String, Object>>)campaignsMap.get(subject).get('envios')).add(envio);
            }
            
            for (Map<String, Object> camp : campaignsMap.values()) {
                result.add(camp);
            }
        } catch (Exception e) { System.debug('Marketing History Error: ' + e.getMessage()); }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getSubscriptions(String unifiedId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        try {
            if (Test.isRunningTest() && forceException) throw new IllegalArgumentException('Forced');
            String subQuery = 'SELECT Name__c, Status__c, NextPurchaseDate__c, Frequency__c, CreatedDate__c ' +
                              'FROM VTEX_Subscription__dlm ' +
                              'WHERE IndividualId__c = :unifiedId LIMIT 10';
            List<SObject> subs = (Test.isRunningTest() && mockSubs != null) ? mockSubs : Database.query(subQuery);
            for (SObject s : subs) {
                Map<String, Object> m = new Map<String, Object>();
                m.put('nombre', s.get('Name__c'));
                m.put('status', s.get('Status__c'));
                m.put('fechaCreacion', s.get('CreatedDate__c'));
                m.put('frecuencia', s.get('Frequency__c'));
                m.put('proximaCompra', s.get('NextPurchaseDate__c'));
                m.put('productos', new List<Object>()); // Placeholder para productos de suscripción
                result.add(m);
            }
        } catch (Exception e) { System.debug('Sub Error: ' + e.getMessage()); }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMarketingScores(String unifiedId) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            if (Test.isRunningTest() && forceException) throw new IllegalArgumentException('Forced');
            
            // 1. RFM Retail - Intentamos traer los 3 principales
            Map<String, Object> rfmRetail = new Map<String, Object>();
            
            // Solar
            List<SObject> rfmSolar = Database.query('SELECT score__c, label__c FROM RFM_Retail_Solar__cio WHERE unified_individual_id__c = :unifiedId LIMIT 1');
            rfmRetail.put('solares', !rfmSolar.isEmpty() ? rfmSolar[0].get('score__c') : 'N/A');
            rfmRetail.put('solaresLabel', !rfmSolar.isEmpty() ? rfmSolar[0].get('label__c') : 'Sin clasificar');
            
            // Lentes de Contacto (Asumiendo nombre de DMO basado en patrón)
            try {
                List<SObject> rfmLC = Database.query('SELECT score__c, label__c FROM RFM_Retail_LC__cio WHERE unified_individual_id__c = :unifiedId LIMIT 1');
                rfmRetail.put('lentesContacto', !rfmLC.isEmpty() ? rfmLC[0].get('score__c') : 'N/A');
                rfmRetail.put('lentesContactoLabel', !rfmLC.isEmpty() ? rfmLC[0].get('label__c') : 'Sin clasificar');
            } catch(Exception e) { 
                rfmRetail.put('lentesContacto', 'N/A'); 
                rfmRetail.put('lentesContactoLabel', 'N/A');
            }

            // Oftálmicos
            try {
                List<SObject> rfmOft = Database.query('SELECT score__c, label__c FROM RFM_Retail_Oftalmicos__cio WHERE unified_individual_id__c = :unifiedId LIMIT 1');
                rfmRetail.put('oftalmicos', !rfmOft.isEmpty() ? rfmOft[0].get('score__c') : 'N/A');
                rfmRetail.put('oftalmicosLabel', !rfmOft.isEmpty() ? rfmOft[0].get('label__c') : 'Sin clasificar');
            } catch(Exception e) { 
                rfmRetail.put('oftalmicos', 'N/A'); 
                rfmRetail.put('oftalmicosLabel', 'N/A');
            }

            result.put('rfmRetail', rfmRetail);

            // 2. Einstein Score - Mock mejorado o consulta si existe DMO
            Map<String, Object> einstein = new Map<String, Object>();
            einstein.put('propensidadClick', 'Media'); 
            einstein.put('propensidadAbrir', 'Alta');
            result.put('einsteinScore', einstein);

        } catch (Exception e) { System.debug('Marketing Error: ' + e.getMessage()); }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAppointments(String unifiedId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        try {
            if (Test.isRunningTest() && forceException) throw new IllegalArgumentException('Forced');
            // 1. Obtener ID de TuoTempo del perfil
            String profileQuery = 'SELECT Id_TuoTempo__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :unifiedId';
            List<SObject> profiles = (Test.isRunningTest() && mockProfiles != null) ? (List<SObject>)mockProfiles : Database.query(profileQuery);
            if (profiles.isEmpty() || profiles[0].get('Id_TuoTempo__c') == null) return result;
            
            String tuoTempoId = (String)profiles[0].get('Id_TuoTempo__c');

            // 2. Consultar Citas
            String citaQuery = 'SELECT start_date__c, end_date__c, activityTitle__c, areaTitle__c, estatus_cita__c, activity_lid__c ' +
                               'FROM TUOTEMPO_CITA__dlm ' +
                               'WHERE memberid__c = :tuoTempoId ' +
                               'ORDER BY start_date__c DESC LIMIT 20';
            List<SObject> citas = (Test.isRunningTest() && mockCitas != null) ? mockCitas : Database.query(citaQuery);

            for (SObject c : citas) {
                Map<String, Object> citaMap = new Map<String, Object>();
                citaMap.put('citaId', c.get('activity_lid__c'));
                citaMap.put('tipo', c.get('activityTitle__c'));
                citaMap.put('status', c.get('estatus_cita__c'));
                citaMap.put('sucursal', c.get('areaTitle__c'));
                citaMap.put('inicio', c.get('start_date__c'));
                citaMap.put('fin', c.get('end_date__c'));
                result.add(citaMap);
            }
        } catch (Exception e) {
            System.debug('Error in getAppointments: ' + e.getMessage());
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getQuotes(String unifiedId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        // Por ahora devolvemos lista vacía hasta confirmar el DMO exacto de presupuestos
        // pero dejamos el método listo para el LWC
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getOrders(String unifiedId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        
        try {
            if (Test.isRunningTest() && forceException) throw new IllegalArgumentException('Forced');
            // 1. Obtener los POS IDs relacionados al perfil unificado
            String profileQuery = 'SELECT Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :unifiedId';
            List<SObject> profiles = (Test.isRunningTest() && mockProfiles != null) ? (List<SObject>)mockProfiles : Database.query(profileQuery);
            if (profiles.isEmpty()) return result;
            
            List<String> posIds = new List<String>();
            for(SObject p : profiles) {
                if(p.get('Id_POS__c') != null) posIds.add((String)p.get('Id_POS__c'));
            }

            // 2. Consultar Órdenes (Cabecera)
            String ordersQuery = 'SELECT ssot__Id__c, ssot__OrderNumber__c, ssot__CreatedDate__c, ssot__TotalAmount__c, ssot__SalesStoreId__c ' +
                                 'FROM ssot__SalesOrder__dlm ' +
                                 'WHERE ssot__SoldToCustomerId__c IN :posIds ' +
                                 'ORDER BY ssot__CreatedDate__c DESC LIMIT 20';
            List<SObject> orders = (Test.isRunningTest() && mockOrders != null) ? mockOrders : Database.query(ordersQuery);
            
            if (orders.isEmpty()) return result;

            List<String> orderIds = new List<String>();
            for(SObject o : orders) orderIds.add((String)o.get('ssot__Id__c'));

            // 3. Consultar Productos de esas Órdenes
            String productsQuery = 'SELECT ssot__SalesOrderId__c, ssot__ProductId__c, ssot__Description__c, ssot__OrderedQuantity__c, ssot__TotalLineAmount__c ' +
                                   'FROM ssot__SalesOrderProduct__dlm ' +
                                   'WHERE ssot__SalesOrderId__c IN :orderIds';
            List<SObject> allProducts = (Test.isRunningTest() && mockOrderProducts != null) ? mockOrderProducts : Database.query(productsQuery);

            // 4. Consultar Nombres de Sucursales
            List<SObject> stores = (Test.isRunningTest() && mockStores != null) ? mockStores : Database.query('SELECT ssot__Id__c, ssot__Name__c FROM ssot__SalesStore__dlm');
            Map<String, String> storeNames = new Map<String, String>();
            for(SObject s : stores) storeNames.put((String)s.get('ssot__Id__c'), (String)s.get('ssot__Name__c'));

            // 5. Agrupar Productos por Orden y Armar Respuesta
            for (SObject o : orders) {
                String oId = (String)o.get('ssot__Id__c');
                Map<String, Object> orderMap = new Map<String, Object>();
                orderMap.put('ordenId', o.get('ssot__OrderNumber__c') != null ? o.get('ssot__OrderNumber__c') : oId);
                orderMap.put('pedidoId', oId);
                orderMap.put('total', o.get('ssot__TotalAmount__c'));
                orderMap.put('fechaCompra', o.get('ssot__CreatedDate__c'));
                orderMap.put('sucursal', storeNames.get((String)o.get('ssot__SalesStoreId__c')) ?? 'Sucursal Desconocida');
                orderMap.put('status', 'Completado'); // Estatus genérico por ahora
                
                List<Map<String, Object>> productsList = new List<Map<String, Object>>();
                for (SObject p : allProducts) {
                    if (p.get('ssot__SalesOrderId__c') == oId) {
                        Map<String, Object> prodMap = new Map<String, Object>();
                        prodMap.put('nombre', p.get('ssot__Description__c'));
                        prodMap.put('sku', p.get('ssot__ProductId__c'));
                        prodMap.put('cantidad', p.get('ssot__OrderedQuantity__c'));
                        prodMap.put('precioTotal', p.get('ssot__TotalLineAmount__c'));
                        productsList.add(prodMap);
                    }
                }
                orderMap.put('productos', productsList);
                result.add(orderMap);
            }

        } catch (Exception e) {
            System.debug('Error in getOrders: ' + e.getMessage());
        }
        
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMedicalInfo(String unifiedId) {
        Map<String, Object> medicalData = new Map<String, Object>();
        
        try {
            if (Test.isRunningTest() && forceException) throw new IllegalArgumentException('Forced');
            
            // 1. Obtener los POS IDs relacionados al perfil unificado (Patrón que sí funciona en el Sidebar)
            String profileQuery = 'SELECT Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = :unifiedId';
            List<SObject> profiles = (Test.isRunningTest() && mockProfiles != null) ? (List<SObject>)mockProfiles : Database.query(profileQuery);
            
            if (profiles.isEmpty()) return medicalData;
            
            List<String> posIds = new List<String>();
            for(SObject p : profiles) {
                if(p.get('Id_POS__c') != null) posIds.add((String)p.get('Id_POS__c'));
            }

            if (posIds.isEmpty()) return medicalData;

            // 2. Obtener Antecedentes Médicos
            String antQuery = 'SELECT ARDOR_IRRITACION__c, COMEZON__c, DIABETES__c, HIPERTENSION__c, ' +
                              'INFECCION__c, LAGRIMEO__c, LEGANA__c, VISION_BORROSA__c, ' +
                              'RESEQUEDAD_OCULAR__c, NOTAS__c, FECHA__c ' +
                              'FROM POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm ' +
                              'WHERE ID_CLIENTE__c IN :posIds ' +
                              'ORDER BY FECHA__c DESC LIMIT 1';
            List<SObject> antecedents = (Test.isRunningTest() && mockAntecedents != null) ? mockAntecedents : Database.query(antQuery);
            if (!antecedents.isEmpty()) medicalData.put('antecedents', antecedents[0]);

            // 3. Obtener Driver Visual
            String driverQuery = 'SELECT NIVEL_VISION__c, TIPO_USUARIO__c, SOLUCION_VISUAL_BUSCA__c, VALOR_RAZON_VISITA__c, FECHA__c ' +
                                 'FROM POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm ' +
                                 'WHERE ID_CLIENTE__c IN :posIds ' +
                                 'ORDER BY FECHA__c DESC LIMIT 1';
            List<SObject> drivers = (Test.isRunningTest() && mockDrivers != null) ? mockDrivers : Database.query(driverQuery);
            if (!drivers.isEmpty()) medicalData.put('visualDriver', drivers[0]);

            // 4. Obtener Preguntas Poder
            String powerQuery = 'SELECT ACTIVIDAD_AIRE_LIBRE__c, PROTEGE_SUS_OJOS__c, NECESIDAD_PROTECCION__c, FECHA_ALTA__c ' +
                                'FROM POS_POS_CLIENTE_PREG_PODER__dlm ' +
                                'WHERE ID_CLIENTE__c IN :posIds ' +
                                'ORDER BY FECHA_ALTA__c DESC LIMIT 1';
            List<SObject> powerQuestions = (Test.isRunningTest() && mockPowers != null) ? mockPowers : Database.query(powerQuery);
            if (!powerQuestions.isEmpty()) medicalData.put('powerQuestions', powerQuestions[0]);

            // 5. Obtener Último Diagnóstico
            String diagQuery = 'SELECT ASTIGMATISMO__c, HIPERMETROPIA__c, MIOPIA__c, PRESBICIA__c, FECHA__c ' +
                               'FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm ' +
                               'WHERE ID_CLIENTE__c IN :posIds ' +
                               'ORDER BY FECHA__c DESC LIMIT 1';
            List<SObject> diagnosis = (Test.isRunningTest() && mockDiagnosis != null) ? mockDiagnosis : Database.query(diagQuery);
            if (!diagnosis.isEmpty()) medicalData.put('lastDiagnosis', diagnosis[0]);

        } catch (Exception e) {
            System.debug('Error in getMedicalInfo: ' + e.getMessage());
        }
        
        return medicalData;
    }

    /**
     * @description Busca perfiles unificados filtrando por un atributo específico (Estilo Profile Explorer).
     */
    @AuraEnabled(cacheable=true)
    public static List<UnifiedssotIndividualDev2__dlm> searchProfiles(String searchTerm, String attributePath) {
        if (String.isBlank(searchTerm) || String.isBlank(attributePath)) {
            return new List<UnifiedssotIndividualDev2__dlm>();
        }
        
        if (Test.isRunningTest() && forceException) throw new IllegalArgumentException('Forced');

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
            return (Test.isRunningTest() && mockProfiles != null) ? mockProfiles : Database.query(sql);
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
            if (Test.isRunningTest() && forceException) throw new IllegalArgumentException('Forced');
            if (Test.isRunningTest() && mockProfiles != null && !mockProfiles.isEmpty()) return mockProfiles[0];
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
     * @description Obtiene las métricas de negocio desde Calculated Insights o mediante agregación manual.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCustomerMetrics(String unifiedId) {
        if (Test.isRunningTest() && forceException) return new Map<String, Object>();
        Map<String, Object> metrics = new Map<String, Object>();
        
        try {
            List<Map<String, Object>> orders = getOrders(unifiedId);
            
            Decimal totalSales = 0;
            Integer orderCount = 0;
            Decimal retailTotal = 0;
            Decimal ecommerceTotal = 0;
            
            Map<String, Integer> retailCategories = new Map<String, Integer>{'Solares' => 0, 'LentesContacto' => 0, 'Oftalmicos' => 0};
            Map<String, Integer> ecommerceCategories = new Map<String, Integer>{'Solares' => 0, 'LentesContacto' => 0, 'Oftalmicos' => 0};
            
            Date lastPurchase = null;
            String lastBranch = 'N/A';
            String lastCategory = 'N/A';

            if (!orders.isEmpty()) {
                orderCount = orders.size();
                
                for (Integer i = 0; i < orders.size(); i++) {
                    Map<String, Object> o = orders[i];
                    Decimal orderTotal = (Decimal)o.get('total');
                    if (orderTotal != null) totalSales += orderTotal;
                    
                    // Determinar canal (Retail vs Ecommerce)
                    String storeName = (String)o.get('sucursal');
                    Boolean isEcommerce = (storeName != null && (storeName.toLowerCase().contains('ecommerce') || storeName.toLowerCase().contains('vtex') || storeName.toLowerCase().contains('online')));
                    
                    if (isEcommerce) {
                        ecommerceTotal += (orderTotal != null ? orderTotal : 0);
                    } else {
                        retailTotal += (orderTotal != null ? orderTotal : 0);
                    }

                    // Procesar categorías de productos
                    List<Map<String, Object>> products = (List<Map<String, Object>>)o.get('productos');
                    if (products != null) {
                        for (Map<String, Object> p : products) {
                            String productDesc = (String)p.get('nombre');
                            String category = categorizeProduct(productDesc);
                            
                            if (isEcommerce) {
                                if (ecommerceCategories.containsKey(category)) {
                                    ecommerceCategories.put(category, ecommerceCategories.get(category) + 1);
                                }
                            } else {
                                if (retailCategories.containsKey(category)) {
                                    retailCategories.put(category, retailCategories.get(category) + 1);
                                }
                            }
                            
                            // Guardar la categoría del pedido más reciente
                            if (i == 0 && lastCategory == 'N/A') {
                                lastCategory = category;
                            }
                        }
                    }

                    // Última compra y sucursal
                    Datetime dt = (Datetime)o.get('fechaCompra');
                    if (dt != null) {
                        Date d = dt.date();
                        if (lastPurchase == null || d > lastPurchase) {
                            lastPurchase = d;
                            if (i == 0) lastBranch = storeName;
                        }
                    }
                }
            }

            metrics.put('totalSales', totalSales);
            metrics.put('orderCount', orderCount);
            metrics.put('avgTicket', orderCount > 0 ? (totalSales / orderCount).setScale(2) : 0);
            metrics.put('daysSinceLastPurchase', lastPurchase != null ? lastPurchase.daysBetween(Date.today()) : 0);
            metrics.put('lastBranch', lastBranch);
            metrics.put('lastCategory', lastCategory);
            
            // Nuevos campos para el resumen de compras
            metrics.put('retailTotal', retailTotal);
            metrics.put('retailCategories', retailCategories);
            metrics.put('ecommerceTotal', ecommerceTotal);
            metrics.put('ecommerceCategories', ecommerceCategories);

        } catch (Exception e) {
            System.debug('Error calculating metrics: ' + e.getMessage());
            metrics.put('totalSales', 0);
            metrics.put('orderCount', 0);
            metrics.put('retailTotal', 0);
            metrics.put('ecommerceTotal', 0);
        }
        
        return metrics;
    }

    /**
     * @description Helper to categorize products based on description.
     */
    private static String categorizeProduct(String description) {
        if (description == null) return 'Oftalmicos'; // Default
        String d = description.toLowerCase();
        if (d.contains('solar') || d.contains('sol ')) return 'Solares';
        if (d.contains('contacto') || d.contains('lc ') || d.contains('pupilentes')) return 'LentesContacto';
        return 'Oftalmicos';
    }
}