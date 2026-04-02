// Script de Búsqueda Inversa: Perfil Unificado -> Con Datos de Salud
String sql = 'SELECT cust.ssot__Id__c, cust.ssot__FirstName__c, cust.ssot__LastName__c, cust.Id_POS__c, count(ant.FECHA__c) as total_ant ' +
             'FROM UnifiedssotIndividualDev2__dlm AS cust ' +
             'JOIN UnifiedLinkssotIndividualDev2__dlm AS link ON cust.ssot__Id__c = link.UnifiedRecordId__c ' +
             'JOIN POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm AS ant ON link.SourceRecordId__c = ant.ID_CLIENTE__c ' +
             'GROUP BY cust.ssot__Id__c, cust.ssot__FirstName__c, cust.ssot__LastName__c, cust.Id_POS__c ' +
             'ORDER BY total_ant DESC LIMIT 3';

System.debug('--- BUSCANDO IDs UNIFICADOS CON DATOS DE SALUD REALES ---');

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    if (!results.isEmpty()) {
        for (Map<String, Object> r : results) {
            System.debug('ID_PARA_BUSCADOR: Name=' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + 
                         ' | IdPOS=' + r.get('Id_POS__c') + 
                         ' | UnifiedID=' + r.get('ssot__Id__c'));
        }
    } else {
        System.debug('SIN_DATOS: No hay cruces de unificación con salud en este momento.');
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
