// Script de diagnóstico profundo para el buscador
try {
    System.debug('--- DESCRIBIENDO CAMPOS DE INDIVIDUAL ---');
    // 1. Verificamos campos reales para no tener errores de columna
    Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('ssot__Individual__dlm').getDescribe().fields.getMap();
    for(String f : fields.keySet()) {
        if(f.contains('name') || f.contains('email') || f.contains('pos')) {
            System.debug('CAMPO_DETECTADO: ' + f);
        }
    }

    // 2. Buscamos a Brayan con una búsqueda ultra-flexible (sin acentos)
    System.debug('--- BUSCANDO A BRAYAN (FLEXIBLE) ---');
    String sql = 'SELECT ss__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM ssot__Individual__dlm WHERE ssot__FirstName__c LIKE \'BRAYAN%\' LIMIT 5';
    List<Map<String, Object>> res = TechProfile360Service.executeDataCloudQuery(sql);
    for(Map<String, Object> r : res) {
        System.debug('REGISTRO_EN_DB: ' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + ' | POS: ' + r.get('Id_POS__c'));
    }
} catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }
