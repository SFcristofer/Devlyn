// Buscamos objetos en el DATA MODEL (DMO) que no sean del Lake crudo
// Los DMOs suelen estar mapeados y aparecen en la EntityDefinition
try {
    System.debug('--- BUSCANDO OBJETOS EN EL DATA MODEL (DMO) ---');
    // Buscamos cualquier objeto que tenga que ver con Diagnóstico o Salud en el Data Model
    for(SObject e : Database.query('SELECT QualifiedApiName, Label FROM EntityDefinition WHERE (Label LIKE \'%Diagnos%\' OR Label LIKE \'%Examen%\' OR Label LIKE \'%Salud%\') AND QualifiedApiName LIKE \'%__dlm\'')) {
        System.debug('DMO ENCONTRADO: ' + e.get('QualifiedApiName') + ' (Etiqueta: ' + e.get('Label') + ')');
    }
} catch(Exception e) { 
    System.debug('Error: ' + e.getMessage()); 
}
