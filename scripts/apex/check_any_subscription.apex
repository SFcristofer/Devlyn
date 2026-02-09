// Intentamos traer CUALQUIER registro de la tabla de suscripciones
try {
    // Probamos sin campos específicos para ver si la tabla existe y tiene datos
    String q = 'SELECT Id FROM VTEX_Subscription__dlm LIMIT 1';
    List<SObject> res = Database.query(q);
    if (!res.isEmpty()) {
        System.debug('TABLA_SUBS: La tabla existe y tiene al menos un registro.');
    } else {
        System.debug('TABLA_SUBS: La tabla existe pero está VACÍA.');
    }
} catch(Exception e) {
    System.debug('TABLA_SUBS_ERROR: El objeto VTEX_Subscription__dlm no es accesible o no existe.');
}
