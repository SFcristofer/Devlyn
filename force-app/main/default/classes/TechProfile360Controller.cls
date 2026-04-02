/**
 * @description Controlador Maestro Devlyn 360 - VERSIÓN ULTRA-FLEXIBLE (RESCATE Y ACENTOS).
 * Soporta búsquedas por N-palabras, acentos, IDs numéricos y rescate en tablas base.
 */
public with sharing class TechProfile360Controller {

    @TestVisible private static List<UnifiedssotIndividualDev2__dlm> mockProfiles;
    @TestVisible private static List<SObject> mockOrders;
    @TestVisible private static List<SObject> mockOrderProducts;
    @TestVisible private static List<SObject> mockEngagements;
    @TestVisible private static List<SObject> mockCitas;
    @TestVisible private static List<SObject> mockQuotes;
    @TestVisible private static List<SObject> mockSubs;

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getProfileData(String uid) {
        Map<String, Object> res = new Map<String, Object>();
        try {
            List<UnifiedssotIndividualDev2__dlm> profs = [SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c, Id_TuoTempo__c, FECHA_NACIMIENTO_dt__c, ssot__GenderId__c, CODIGO_POSTAL__c, ssot__Id__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c=:uid OR Id_POS__c=:uid LIMIT 1];
            if(!profs.isEmpty()) {
                UnifiedssotIndividualDev2__dlm r = profs[0];
                String uniId = r.ssot__Id__c;
                String realPhone = 'N/A';
                try {
                    for(SObject p : Database.query('SELECT ssot__TelephoneNumber__c FROM UnifiedssotContactPointPhoneDev2__dlm WHERE ssot__PartyId__c = \''+uniId+'\' LIMIT 1')) {
                        realPhone = (String)p.get('ssot__TelephoneNumber__c');
                    }
                } catch(Exception e) {}
                res.put('profile', new Map<String, Object>{'firstName'=>toTitleCase(r.ssot__FirstName__c), 'lastName'=>toTitleCase(r.ssot__LastName__c), 'idPos'=>r.Id_POS__c, 'email'=>r.Email__c, 'cp'=>r.CODIGO_POSTAL__c, 'gender'=>r.ssot__GenderId__c, 'age'=>calculateAge(r.FECHA_NACIMIENTO_dt__c), 'phone'=>realPhone});
            }
            return res;
        } catch (Exception e) { return res; }
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> searchProfilesGlobal(String term) {
        if (String.isBlank(term)) return new List<Map<String, Object>>();
        term = term.trim();
        
        // 1. Normalización de términos (Quitar acentos)
        String normalizedTerm = term.replace('á','a').replace('é','e').replace('í','i').replace('ó','o').replace('ú','u')
                                    .replace('Á','A').replace('É','E').replace('Í','I').replace('Ó','O').replace('Ú','U');
        
        Boolean isEmail = normalizedTerm.contains('@');
        List<String> tokens = normalizedTerm.split('\\s+');
        String numericToken = null;
        for(String t : tokens) { if(t.isNumeric()) { numericToken = t; break; } }
        
        Set<String> idsFromPhones = new Set<String>();
        if(!isEmail) {
            for(String t : tokens) {
                String cleanT = t.replaceAll('[^0-9]', '');
                if (cleanT.length() >= 7) {
                    String phoneTerm = '%' + cleanT + '%';
                    try {
                        for(SObject p : Database.query('SELECT ssot__PartyId__c FROM UnifiedssotContactPointPhoneDev2__dlm WHERE ssot__TelephoneNumber__c LIKE :phoneTerm LIMIT 200')) {
                            String indId = (String)p.get('ssot__PartyId__c');
                            if(String.isNotBlank(indId)) idsFromPhones.add(indId);
                        }
                    } catch(Exception e) {}
                }
            }
        }

        // --- FASE 0: PRECISIÓN POR LINK ---
        List<UnifiedssotIndividualDev2__dlm> linkResults = new List<UnifiedssotIndividualDev2__dlm>();
        if (numericToken != null) {
            try {
                String sqlLink = 'SELECT UnifiedRecordId__c FROM UnifiedLinkssotIndividualDev2__dlm WHERE SourceRecordId__c = \'' + String.escapeSingleQuotes(numericToken) + '\' LIMIT 10';
                List<Map<String, Object>> linkRows = TechProfile360Service.executeDataCloudQuery(sqlLink);
                Set<String> idsFromLinks = new Set<String>();
                for(Map<String, Object> l : linkRows) {
                    String uid = (String)l.get('UnifiedRecordId__c');
                    if(String.isNotBlank(uid)) idsFromLinks.add(uid);
                }
                if(!idsFromLinks.isEmpty()) {
                    linkResults = [SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c IN :idsFromLinks LIMIT 10];
                }
            } catch(Exception e) {}
        }

        // --- PREPARACIÓN DE BIND MAP ---
        Map<String, Object> bindMap = new Map<String, Object>{
            'idsFromPhones' => new List<String>{'NONE'},
            'emailPat' => '%' + normalizedTerm + '%'
        };
        for(Integer i=0; i<tokens.size(); i++) bindMap.put('p'+i, '%' + tokens[i].toUpperCase() + '%');
        if(!idsFromPhones.isEmpty()) bindMap.put('idsFromPhones', new List<String>(idsFromPhones));

        // --- FASE 1: BÚSQUEDA UNIFICADA (FLEXIBLE) ---
        List<UnifiedssotIndividualDev2__dlm> precisionResults = new List<UnifiedssotIndividualDev2__dlm>();
        try {
            String q1 = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE ';
            List<String> conds = new List<String>();
            if(isEmail) {
                conds.add('Email__c LIKE :emailPat');
            } else {
                for(Integer i=0; i<tokens.size(); i++) conds.add('(ssot__FirstName__c LIKE :p'+i+' OR ssot__LastName__c LIKE :p'+i+' OR Id_POS__c LIKE :p'+i+')');
            }
            q1 += '(' + String.join(conds, ' OR ') + ') LIMIT 200';
            precisionResults = Database.queryWithBinds(q1, bindMap, AccessLevel.USER_MODE);
        } catch(Exception e) {}

        Map<String, Map<String, Object>> uniqueMap = new Map<String, Map<String, Object>>();
        for(UnifiedssotIndividualDev2__dlm r : linkResults) {
            uniqueMap.put(r.ssot__Id__c, new Map<String, Object>{'ssot__Id__c'=>r.ssot__Id__c, 'ssot__FirstName__c'=>r.ssot__FirstName__c, 'ssot__LastName__c'=>r.ssot__LastName__c, 'Id_POS__c'=>r.Id_POS__c, 'Email__c'=>r.Email__c});
        }
        for(UnifiedssotIndividualDev2__dlm r : precisionResults) {
            if(!uniqueMap.containsKey(r.ssot__Id__c)) uniqueMap.put(r.ssot__Id__c, new Map<String, Object>{'ssot__Id__c'=>r.ssot__Id__c, 'ssot__FirstName__c'=>r.ssot__FirstName__c, 'ssot__LastName__c'=>r.ssot__LastName__c, 'Id_POS__c'=>r.Id_POS__c, 'Email__c'=>r.Email__c});
        }

        // --- FASE 4: RESCATE (ADITIVA) ---
        try {
            String qRes = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM ssot__Individual__dlm WHERE ';
            List<String> resConds = new List<String>();
            for(Integer i=0; i<tokens.size(); i++) resConds.add('(ssot__FirstName__c LIKE :p'+i+' OR ssot__LastName__c LIKE :p'+i+' OR Id_POS__c LIKE :p'+i+')');
            qRes += '(' + String.join(resConds, ' OR ') + ') LIMIT 50';
            List<SObject> resInd = Database.queryWithBinds(qRes, bindMap, AccessLevel.USER_MODE);
            for(SObject r : resInd) {
                String uid = (String)r.get('ssot__Id__c');
                if(!uniqueMap.containsKey(uid)) {
                    uniqueMap.put(uid, new Map<String, Object>{'ssot__Id__c'=>uid, 'ssot__FirstName__c'=>(String)r.get('ssot__FirstName__c'), 'ssot__LastName__c'=>(String)r.get('ssot__LastName__c'), 'Id_POS__c'=>(String)r.get('Id_POS__c'), 'Email__c'=>'N/A'});
                }
            }
        } catch(Exception e) {}

        Map<String, String> phoneMap = new Map<String, String>();
        if(!uniqueMap.isEmpty()) {
            try {
                Set<String> finalIds = uniqueMap.keySet();
                for(SObject p : Database.query('SELECT ssot__TelephoneNumber__c, ssot__PartyId__c FROM UnifiedssotContactPointPhoneDev2__dlm WHERE ssot__PartyId__c IN :finalIds')) {
                    phoneMap.put((String)p.get('ssot__PartyId__c'), (String)p.get('ssot__TelephoneNumber__c'));
                }
            } catch(Exception e) {}
        }

        List<SearchResultWrapper> wrappedResults = new List<SearchResultWrapper>();
        for(Map<String, Object> r : uniqueMap.values()) {
            wrappedResults.add(new SearchResultWrapper(r, tokens, phoneMap.get((String)r.get('ssot__Id__c')), normalizedTerm));
        }
        wrappedResults.sort();

        List<Map<String, Object>> finalResults = new List<Map<String, Object>>();
        for(SearchResultWrapper w : wrappedResults) {
            Map<String, Object> r = w.record;
            finalResults.add(new Map<String, Object>{
                'ssot__Id__c' => r.get('ssot__Id__c'),
                'ssot__FirstName__c' => toTitleCase((String)r.get('ssot__FirstName__c')),
                'ssot__LastName__c' => toTitleCase((String)r.get('ssot__LastName__c')),
                'Email__c' => r.get('Email__c'),
                'Id_POS__c' => r.get('Id_POS__c'),
                'Telefono__c' => phoneMap.get((String)r.get('ssot__Id__c')) ?? 'N/A'
            });
        }
        return finalResults;
    }

    public class SearchResultWrapper implements Comparable {
        public Map<String, Object> record;
        public Integer score;
        public String fullTerm;

        public SearchResultWrapper(Map<String, Object> r, List<String> tokens, String phone, String term) {
            this.record = r;
            this.fullTerm = term.toUpperCase();
            this.score = calculateScore(r, tokens, phone);
        }

        private Integer calculateScore(Map<String, Object> r, List<String> tokens, String phone) {
            Integer s = 0;
            String fn = ((String)r.get('ssot__FirstName__c') ?? '').toUpperCase();
            String ln = ((String)r.get('ssot__LastName__c') ?? '').toUpperCase();
            String fullName = (fn + ' ' + ln).replaceAll('\\s+', ' ').trim();
            for(String t : tokens) {
                String tu = t.toUpperCase();
                if(fullName.contains(tu) || ((String)r.get('Id_POS__c') ?? '').contains(tu)) s += 10000;
            }
            if(fullName == fullTerm) s += 50000;
            return s;
        }

        public Integer compareTo(Object compareTo) {
            SearchResultWrapper other = (SearchResultWrapper)compareTo;
            if (this.score != other.score) return (this.score > other.score) ? -1 : 1;
            return 0;
        }
    }

    private static String toTitleCase(String input) {
        if(String.isBlank(input)) return '';
        List<String> words = input.toLowerCase().split('\\s+');
        List<String> properWords = new List<String>();
        for(String w : words) if(w.length() > 0) properWords.add(w.substring(0,1).toUpperCase() + w.substring(1));
        return String.join(properWords, ' ');
    }

    private static Integer calculateAge(Date dob) { if(dob==null) return 0; return dob.daysBetween(Date.today())/365; }
}
