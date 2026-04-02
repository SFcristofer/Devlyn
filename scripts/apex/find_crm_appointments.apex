// Script para buscar Citas en Objetos Estándar de Salesforce (CRM)
try {
    System.debug('--- BUSCANDO CITAS EN OBJETOS ESTÁNDAR ---');
    
    // 1. Service Appointments
    Integer countSA = Database.countQuery('SELECT count() FROM ServiceAppointment');
    System.debug('ServiceAppointments encontrados: ' + countSA);

    // 2. Eventos tipo Cita
    Integer countEv = Database.countQuery('SELECT count() FROM Event WHERE Subject LIKE \'%Cita%\' OR Subject LIKE \'%TuoTempo%\'');
    System.debug('Eventos de Calendario encontrados: ' + countEv);

} catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }
