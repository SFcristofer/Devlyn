Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
for(String sObj : gd.keySet()){
    if(sObj.contains('__dlm') && (sObj.contains('grad') || sObj.contains('receta') || sObj.contains('pos'))){
        System.debug('DMO_FOUND: ' + sObj);
    }
}
