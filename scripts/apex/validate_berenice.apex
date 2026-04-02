// Script para validar citas y perfil de Berenice
String email = 'berenice.perezm@gmail.com';
try {
    System.debug('--- VALIDANDO DATOS PARA: ' + email + ' ---');
    
    // 1. Buscar Citas directamente por Email en memberid__c
    String sqlCita = 'SELECT count(activity_lid__c) as total, activityTitle__c, areaTitle__c FROM TUOTEMPO_CITA__dlm WHERE memberid__c = \'' + email + '\' GROUP BY activityTitle__c, areaTitle__c';
    List<Map<String, Object>> resCita = TechProfile360Service.executeDataCloudQuery(sqlCita);
    
    if(!resCita.isEmpty()) {
        System.debug('CITAS_ENCONTRADAS: ' + resCita.size() + ' tipos de registros.');
        for(Map<String, Object> r : resCita) {
            System.debug('  -> Servicio: ' + r.get('activityTitle__c') + ' | Sucursal: ' + r.get('areaTitle__c'));
        }
    } else {
        System.debug('SIN_CITAS: No se encontraron registros en TUOTEMPO_CITA__dlm para este correo.');
    }

    // 2. Verificar si el perfil existe para el buscador
    String sqlInd = 'SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM ssot__Individual__dlm WHERE Email__c = \'' + email + '\' LIMIT 1';
    List<Map<String, Object>> resInd = TechProfile360Service.executeDataCloudQuery(sqlInd);
    if(!resInd.isEmpty()) {
        System.debug('PERFIL_ENCONTRADO: ' + resInd[0].get('ssot__FirstName__c') + ' | POS: ' + resInd[0].get('Id_POS__c'));
    } else {
        System.debug('PERFIL_NO_ENCONTRADO: El correo no existe en la tabla Individual base.');
    }

} catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }
