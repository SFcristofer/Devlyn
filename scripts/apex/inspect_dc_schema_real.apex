// Script para inspeccionar campos y tipos de datos reales
try {
    System.debug('--- INSPECCIONANDO CAMPOS DE CITAS ---');
    String sqlCita = 'SELECT * FROM TUOTEMPO_CITA__dlm LIMIT 1';
    List<Map<String, Object>> resCita = TechProfile360Service.executeDataCloudQuery(sqlCita);
    if(!resCita.isEmpty()) {
        System.debug('CAMPOS_CITAS: ' + resCita[0].keySet());
    }

    System.debug('--- INSPECCIONANDO CAMPOS DE INDIVIDUAL UNIFICADO ---');
    String sqlUni = 'SELECT * FROM UnifiedssotIndividualDev2__dlm LIMIT 1';
    List<Map<String, Object>> resUni = TechProfile360Service.executeDataCloudQuery(sqlUni);
    if(!resUni.isEmpty()) {
        System.debug('CAMPOS_UNIFICADO: ' + resUni[0].keySet());
    }

    // Buscamos si existe algun rastro de "memberid" en la tabla de links
    System.debug('--- INSPECCIONANDO TABLA DE LINKS ---');
    String sqlLink = 'SELECT SourceRecordId__c, UnifiedRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm LIMIT 10';
    List<Map<String, Object>> resLink = TechProfile360Service.executeDataCloudQuery(sqlLink);
    for(Map<String, Object> r : resLink) {
        System.debug('LINK_DATA: Source=' + r.get('SourceRecordId__c') + ' | Unified=' + r.get('UnifiedRecordId__c'));
    }

} catch (Exception e) { System.debug('ERROR_INSPECCION: ' + e.getMessage()); }
