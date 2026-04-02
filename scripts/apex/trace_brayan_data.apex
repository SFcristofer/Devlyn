// Script para rastrear a Brayan Javier Díaz y sus citas
try {
    System.debug('--- RASTREANDO A BRAYAN JAVIER DÍAZ ---');
    String nameTerm = '%BRAYAN%JAVIER%DIAZ%';
    
    // 1. Buscar en Individuales (Base)
    String sqlInd = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c FROM ssot__Individual__dlm WHERE ssot__FirstName__c LIKE \'BRAYAN%\' AND ssot__LastName__c LIKE \'%DIAZ%\' LIMIT 5';
    List<Map<String, Object>> resInd = TechProfile360Service.executeDataCloudQuery(sqlInd);
    
    for(Map<String, Object> r : resInd) {
        String uid = (String)r.get('ssot__Id__c');
        String email = (String)r.get('Email__c');
        System.debug('INDIVIDUAL_ENCONTRADO: ' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + ' | ID: ' + uid + ' | POS: ' + r.get('Id_POS__c') + ' | Email: ' + email);
        
        // 2. Buscar Citas para este ID o Email
        String sqlCita = 'SELECT count(activity_lid__c) as c FROM TUOTEMPO_CITA__dlm WHERE memberid__c = \'' + uid + '\' OR memberid__c = \'' + email + '\'';
        List<Map<String, Object>> resCita = TechProfile360Service.executeDataCloudQuery(sqlCita);
        System.debug('  -> CITAS_EN_TUOTEMPO: ' + resCita[0].get('c'));
    }
} catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }
