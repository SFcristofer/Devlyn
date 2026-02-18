try {
    // 1. Investigamos campos disponibles en Email Engagement
    // Intentamos traer un registro con una consulta amplia para ver qué campos devuelve el motor
    String emailQ = 'SELECT * FROM ssot__EmailEngagement__dlm LIMIT 1';
    // Nota: SELECT * no siempre funciona en DLM, así que probaremos campos probables
    String emailFields = 'SELECT ssot__SubjectLineTxt__c, ssot__EngagementDateTm__c, ssot__EmailFromAddr__c, ssot__EngagementTypeId__c, ssot__Id__c FROM ssot__EmailEngagement__dlm LIMIT 1';
    List<SObject> emailSample = Database.query(emailFields);
    System.debug('--- SCHEMA EMAIL ENGAGEMENT ---');
    if(!emailSample.isEmpty()) {
        System.debug('Campos Reales: ' + JSON.serialize(emailSample[0]));
    }

    // 2. Buscamos el objeto de WhatsApp
    System.debug('--- BUSCANDO OBJETO WHATSAPP ---');
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    for(String sObj : gd.keySet()){
        if(sObj.contains('whatsapp') && sObj.contains('__dlm')){
            System.debug('WhatsApp DMO detectado: ' + sObj);
        }
    }

    // 3. Investigamos el Journey (Marketing Cloud suele guardar esto en un DMO relacionado o campo específico)
    // Buscamos si existe ssot__Journey__dlm o similar
    for(String sObj : gd.keySet()){
        if(sObj.contains('journey') && sObj.contains('__dlm')){
            System.debug('Journey DMO detectado: ' + sObj);
        }
    }

} catch(Exception e) {
    System.debug('Error en inspección: ' + e.getMessage());
}
