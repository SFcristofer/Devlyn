// Script para obtener los datos de búsqueda exactos del ID con citas
String targetUid = '5f4b044b5a691d76503960ef5782d91e';
try {
    System.debug('--- EXTRACCION DE DATOS DE BUSQUEDA ---');
    String sql = 'SELECT ssot__FirstName__c, ssot__LastName__c, Email__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c = \'' + targetUid + '\'';
    List<Map<String, Object>> res = TechProfile360Service.executeDataCloudQuery(sql);
    
    if(!res.isEmpty()) {
        System.debug('BUSCAR_COMO_NOMBRE: ' + res[0].get('ssot__FirstName__c') + ' ' + res[0].get('ssot__LastName__c'));
        System.debug('BUSCAR_COMO_EMAIL: ' + res[0].get('Email__c'));
        System.debug('BUSCAR_COMO_POSID: ' + res[0].get('Id_POS__c'));
    } else {
        System.debug('EL_ID_NO_ESTA_EN_UNIFICADOS. Buscando en tabla Individual...');
        String sqlInd = 'SELECT ssot__FirstName__c, ssot__LastName__c, ssot__Email__c, Id_POS__c FROM ssot__Individual__dlm WHERE ssot__Id__c = \'' + targetUid + '\'';
        List<Map<String, Object>> resInd = TechProfile360Service.executeDataCloudQuery(sqlInd);
        if(!resInd.isEmpty()) {
            System.debug('INDIVIDUAL_NOMBRE: ' + resInd[0].get('ssot__FirstName__c'));
            System.debug('INDIVIDUAL_EMAIL: ' + resInd[0].get('ssot__Email__c'));
        }
    }
} catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }
