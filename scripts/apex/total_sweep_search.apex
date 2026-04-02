// Búsqueda de Barrido Total para Berenice
String targetEmail = 'berenice.perezm@gmail.com';
try {
    System.debug('--- BARRIDO TOTAL PARA: ' + targetEmail + ' ---');

    // 1. Buscar en la tabla de Suscripciones de VTEX
    String sqlVtex = 'SELECT customerId__c, plan_id__c FROM VTEX_Subscription__dlm WHERE customerId__c = \'' + targetEmail + '\' LIMIT 1';
    List<Map<String, Object>> resVtex = TechProfile360Service.executeDataCloudQuery(sqlVtex);
    if(!resVtex.isEmpty()) System.debug('ENCONTRADA_EN_VTEX: CustomerID=' + resVtex[0].get('customerId__c'));

    // 2. Buscar en la tabla de Citas de TuoTempo (sin filtros de JOIN)
    String sqlTuo = 'SELECT memberid__c, activityTitle__c FROM TUOTEMPO_CITA__dlm WHERE memberid__c = \'' + targetEmail + '\' LIMIT 1';
    List<Map<String, Object>> resTuo = TechProfile360Service.executeDataCloudQuery(sqlTuo);
    if(!resTuo.isEmpty()) System.debug('ENCONTRADA_EN_TUOTEMPO: MemberID=' + resTuo[0].get('memberid__c'));

    // 3. Buscar en la tabla de Identidad Individual (Base) usando búsqueda parcial
    String sqlInd = 'SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c FROM ssot__Individual__dlm WHERE Email__c LIKE \'%berenice%\' LIMIT 5';
    List<Map<String, Object>> resInd = TechProfile360Service.executeDataCloudQuery(sqlInd);
    for(Map<String, Object> r : resInd) {
        System.debug('REGISTRO_INDIVIDUAL_PARCIAL: Nombre=' + r.get('ssot__FirstName__c') + ' | Email=' + r.get('Email__c'));
    }

    // 4. Buscar en los Enlaces Unificados (El Puente)
    String sqlLink = 'SELECT UnifiedRecordId__c, SourceRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm WHERE SourceRecordId__c = \'' + targetEmail + '\' LIMIT 1';
    List<Map<String, Object>> resLink = TechProfile360Service.executeDataCloudQuery(sqlLink);
    if(!resLink.isEmpty()) System.debug('VINCULO_ENCONTRADO: UnifiedID=' + resLink[0].get('UnifiedRecordId__c'));

} catch (Exception e) { System.debug('ERROR_BARRIDO: ' + e.getMessage()); }
