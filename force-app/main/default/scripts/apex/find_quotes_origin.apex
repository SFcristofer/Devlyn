try {
    System.debug('--- BUSCANDO ORIGEN DE COTIZACIONES EN DATA CLOUD ---');
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    List<String> candidates = new List<String>();
    
    // 1. Identificar DMOs candidatos
    for(String name : gd.keySet()) {
        if(name.endsWith('__dlm') && (name.contains('quote') || name.contains('presupuesto') || name.contains('cotizacion'))) {
            candidates.add(name);
        }
    }

    // 2. Verificar cuáles tienen datos
    for(String dmo : candidates) {
        try {
            String q = 'SELECT count() FROM ' + dmo;
            Integer total = Database.countQuery(q);
            if(total > 0) {
                System.debug('¡DMO CON DATOS ENCONTRADO!: ' + dmo + ' (Registros: ' + total + ')');
                // Intentamos ver una muestra para identificar campos de ID y Monto
                String sampleQ = 'SELECT Id FROM ' + dmo + ' LIMIT 1';
                List<SObject> sample = Database.query(sampleQ);
                System.debug('Campos disponibles en ' + dmo + ': ' + sample[0].getPopulatedFieldsAsMap().keySet());
            } else {
                System.debug('DMO vacío: ' + dmo);
            }
        } catch(Exception e) {
            System.debug('Error consultando ' + dmo + ': ' + e.getMessage());
        }
    }
} catch(Exception e) {
    System.debug('Error General: ' + e.getMessage());
}
