// Script de Auditoría Profunda de Datos Médicos en Data Cloud
Map<String, String> tables = new Map<String, String>{
    'Diagnóstico' => 'POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm',
    'Antecedentes' => 'POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm',
    'Driver Visual' => 'POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm',
    'Preguntas Poder' => 'POS_POS_CLIENTE_PREG_PODER__dlm'
};

System.debug('--- INICIANDO AUDITORÍA DE DATOS REALES ---');

for (String label : tables.keySet()) {
    String table = tables.get(label);
    String countQuery = 'SELECT count(*) as total FROM ' + table;
    String dataQuery = 'SELECT ID_CLIENTE__c, FECHA__c FROM ' + table + ' ORDER BY FECHA__c DESC LIMIT 3';
    
    try {
        List<Map<String, Object>> countRes = TechProfile360Service.executeDataCloudQuery(countQuery);
        Object total = (countRes.isEmpty()) ? 0 : countRes[0].get('total');
        System.debug('TABLA: ' + label + ' | TOTAL REGISTROS: ' + total);
        
        if (Integer.valueOf(total) > 0) {
            List<Map<String, Object>> dataRes = TechProfile360Service.executeDataCloudQuery(dataQuery);
            System.debug('EJEMPLOS REALES (' + label + '): ' + JSON.serialize(dataRes));
        }
    } catch (Exception e) {
        System.debug('ERROR EN TABLA ' + label + ': ' + e.getMessage());
    }
}
