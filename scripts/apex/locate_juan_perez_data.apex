// Script para encontrar EN QUÉ TABLA están los datos médicos de Juan Pérez
String uniId = '02daf3d6a4f01f33269e7b8b801ef731';
String posId = '12388500';

System.debug('--- LOCALIZANDO TABLA MÉDICA DE JUAN PÉREZ ---');

try {
    // Probamos en Driver Visual
    List<SObject> driver = Database.query('SELECT NIVEL_VISION__c FROM POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm WHERE ID_CLIENTE__c = \'' + uniId + '\' OR ID_CLIENTE__c = \'' + posId + '\' LIMIT 1');
    if(!driver.isEmpty()) System.debug('DATOS_EN_TABLA: Driver Visual');

    // Probamos en Antecedentes
    List<SObject> ant = Database.query('SELECT DIABETES__c FROM POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm WHERE ID_CLIENTE__c = \'' + uniId + '\' OR ID_CLIENTE__c = \'' + posId + '\' LIMIT 1');
    if(!ant.isEmpty()) System.debug('DATOS_EN_TABLA: Antecedentes Médicos');

    // Probamos en Preguntas de Poder
    List<SObject> pow = Database.query('SELECT PROTEGE_SUS_OJOS__c FROM POS_POS_CLIENTE_PREG_PODER__dlm WHERE ID_CLIENTE__c = \'' + uniId + '\' OR ID_CLIENTE__c = \'' + posId + '\' LIMIT 1');
    if(!pow.isEmpty()) System.debug('DATOS_EN_TABLA: Preguntas de Poder');

} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
