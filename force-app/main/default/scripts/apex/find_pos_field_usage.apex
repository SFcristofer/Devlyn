try {
    System.debug('--- RASTREANDO Id_POS__c EN LA ORG ---');
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    for(String objName : gd.keySet()) {
        Map<String, Schema.SObjectField> fields = gd.get(objName).getDescribe().fields.getMap();
        if(fields.containsKey('Id_POS__c') || fields.containsKey('id_pos__c')) {
            System.debug('OBJETO CON Id_POS: ' + objName);
            // Si el objeto tiene Id_POS, vemos si tiene registros de cotizaciones
            if(objName.contains('presupuesto') || objName.contains('cotizacion') || objName.contains('quote')) {
                System.debug('¡CANDIDATO DETECTADO!: ' + objName);
            }
        }
    }
} catch(Exception e) {}
