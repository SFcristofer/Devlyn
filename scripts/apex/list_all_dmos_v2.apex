// Script para listar ABSOLUTAMENTE TODOS los DMOs en la Org
try {
    System.debug('--- LISTADO MAESTRO DE DMOs ---');
    for(SObject e : Database.query('SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName LIKE \'%__dlm\' ORDER BY QualifiedApiName ASC')) {
        System.debug('DMO_EXISTENTE: ' + e.get('QualifiedApiName'));
    }
} catch(Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
