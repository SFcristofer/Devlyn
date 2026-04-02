// Script de investigación profunda de Citas
try {
    System.debug('--- INSPECCIONANDO DATOS CRUDOS DE CITAS ---');
    String sql = 'SELECT memberid__c, activityTitle__c, areaTitle__c, start_date__c FROM TUOTEMPO_CITA__dlm LIMIT 5';
    List<Map<String, Object>> res = TechProfile360Service.executeDataCloudQuery(sql);
    
    for(Map<String, Object> r : res) {
        System.debug('CITA_REAL: MemberID=' + r.get('memberid__c') + ' | Servicio=' + r.get('activityTitle__c'));
        
        // Buscamos si este MemberID existe en el Perfil Unificado o en los Links
        String mId = (String)r.get('memberid__c');
        String sqlCheck = 'SELECT UnifiedRecordId__c, SourceRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm WHERE SourceRecordId__c = \'' + mId + '\' OR UnifiedRecordId__c = \'' + mId + '\' LIMIT 1';
        List<Map<String, Object>> linkCheck = TechProfile360Service.executeDataCloudQuery(sqlCheck);
        if(!linkCheck.isEmpty()) {
            System.debug('  -> VINCULADO: Unified=' + linkCheck[0].get('UnifiedRecordId__c') + ' | Source=' + linkCheck[0].get('SourceRecordId__c'));
        } else {
            System.debug('  -> NO VINCULADO EN DATA CLOUD');
        }
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
