/**
 * @description Helper Master Restaurado y Sincronizado para Sidebar LWC.
 * Versión final: incluye mapeo exacto de campos para barra lateral.
 */
public WITHOUT SHARING class TechHelper {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFullData(String uid) {
        return TechDataCloudService.getPatientProfile(uid);
    }
    private static Integer age(Date d) { if(d==null) return 0; return d.daysBetween(Date.today())/365; }
}