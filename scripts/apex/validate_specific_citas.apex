// Script para validar citas de IDs específicos
try {
    List<String> targetIds = new List<String>{'10461454', '11219632', '10669362', '11697401', '11177367'};
    String idsStr = '(\'' + String.join(targetIds, '\',\'') + '\')';
    
    System.debug('--- AUDITORÍA DE CITAS PARA LISTA ESPECÍFICA ---');
    
    // 1. Buscamos en TuoTempo usando el ID de POS directamente en memberid__c
    String sql = 'SELECT memberid__c, count(activity_lid__c) as total FROM TUOTEMPO_CITA__dlm WHERE memberid__c IN ' + idsStr + ' GROUP BY memberid__c';
    List<Map<String, Object>> resDirect = TechProfile360Service.executeDataCloudQuery(sql);
    
    // 2. Buscamos mediante el vínculo de UnifiedLink por si el ID cambió en la unificación
    String sqlLink = 'SELECT link.SourceRecordId__c, count(cita.activity_lid__c) as total ' +
                     'FROM TUOTEMPO_CITA__dlm AS cita ' +
                     'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON cita.memberid__c = link.SourceRecordId__c ' +
                     'WHERE link.SourceRecordId__c IN ' + idsStr + ' GROUP BY link.SourceRecordId__c';
    List<Map<String, Object>> resLink = TechProfile360Service.executeDataCloudQuery(sqlLink);

    Map<String, Integer> resultsMap = new Map<String, Integer>();
    for(Map<String, Object> r : resDirect) resultsMap.put((String)r.get('memberid__c'), Integer.valueOf(r.get('total')));
    for(Map<String, Object> r : resLink) resultsMap.put((String)r.get('SourceRecordId__c'), Integer.valueOf(r.get('total')));

    for(String id : targetIds) {
        Integer count = resultsMap.containsKey(id) ? resultsMap.get(id) : 0;
        System.debug('VALIDACIÓN_ID ' + id + ': Citas Encontradas = ' + count);
    }

} catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }
