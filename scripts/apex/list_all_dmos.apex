Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
List<String> dmos = new List<String>();
for(String sObj : gd.keySet()){
    if(sObj.contains('__dlm')){
        dmos.add(sObj);
    }
}
System.debug('ALL_DMOS: ' + String.join(dmos, ', '));
