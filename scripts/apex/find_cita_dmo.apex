// Script para buscar DMOs de Citas por palabras clave
try {
    System.debug('--- BUSCANDO TABLAS DE CITAS POR CLAVE ---');
    String[] keywords = new String[]{'%CITA%', '%APP%', '%VISIT%', '%BOOK%', '%TUO%', '%APPOINTMENT%'};
    for(String kw : keywords) {
        for(SObject e : Database.query('SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName LIKE \''+kw+'\' AND QualifiedApiName LIKE \'%__dlm\'')) {
            System.debug('DMO_POTENCIAL: ' + e.get('QualifiedApiName'));
        }
    }
} catch(Exception e) { System.debug('ERROR: ' + e.getMessage()); }
