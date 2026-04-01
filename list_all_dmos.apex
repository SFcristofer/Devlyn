Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
for(String sObj : gd.keySet()) {
    if(sObj.endsWith('__dlm')) {
        System.debug('DMO_ACTIVO: ' + sObj);
    }
}
