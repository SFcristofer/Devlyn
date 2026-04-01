// Script para encontrar a CUALQUIER persona con diagnóstico médico en Data Cloud
String q = 'SELECT ID_CLIENTE__c, MIOPIA__c, ASTIGMATISMO__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE MIOPIA__c != NULL LIMIT 1';

try {
    System.debug('--- BUSCANDO CUALQUIER REGISTRO MÉDICO REAL ---');
    List<Map<String, Object>> res = TechProfile360Service.executeDataCloudQuery(q);
    if(!res.isEmpty()) {
        System.debug('REGISTRO_ENCONTRADO: ' + JSON.serialize(res[0]));
    } else {
        System.debug('SISTEMA_VACIO: No hay ni un solo registro médico en Data Cloud hoy.');
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
