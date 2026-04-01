List<String> dmos = new List<String>();
for(String sObj : Schema.getGlobalDescribe().keySet()) {
    if(sObj.endsWith('__dlm')) dmos.add(sObj);
}
System.debug('LISTA_COMPLETA_DMOS: ' + String.join(dmos, ', '));
