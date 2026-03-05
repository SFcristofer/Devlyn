/**
 * @description Controlador Maestro Devlyn 360 - VERSIÓN INTEGRAL RESTAURADA Y OPTIMIZADA.
 * Soporta búsquedas por N-palabras, IDs numéricos y correos electrónicos complejos.
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
        Boolean isEmail = term.contains('@');
        List<String> tokens = term.split('\\s+');
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

        Map<String, String> bindMap = new Map<String, String>();
        for(Integer i=0; i<tokens.size(); i++) bindMap.put('p'+i, '%' + tokens[i].toUpperCase() + '%');

        // --- FASE 1: BÚSQUEDA ESPECIALIZADA ---
        List<UnifiedssotIndividualDev2__dlm> precisionResults = new List<UnifiedssotIndividualDev2__dlm>();
        if(isEmail) {
            // AJUSTE: Búsqueda flexible de email (soporta minúsculas/mayúsculas nativamente)
            String emailPat = '%' + term + '%';
            String emailPatUpper = '%' + term.toUpperCase() + '%';
            bindMap.put('emailPat', emailPat);
            bindMap.put('emailPatUpper', emailPatUpper);
            precisionResults = Database.queryWithBinds('SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE Email__c LIKE :emailPat OR Email__c LIKE :emailPatUpper LIMIT 200', bindMap, AccessLevel.USER_MODE);
        } else {
            String q1 = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE ';
            List<String> andConds = new List<String>();
            for(Integer i=0; i<tokens.size(); i++) andConds.add('(ssot__FirstName__c LIKE :p'+i+' OR ssot__LastName__c LIKE :p'+i+' OR Id_POS__c LIKE :p'+i+' OR Email__c LIKE :p'+i+')');
            q1 += String.join(andConds, ' AND ') + ' LIMIT 200';
            precisionResults = Database.queryWithBinds(q1, bindMap, AccessLevel.USER_MODE);
        }

        // --- FASE 2: PRIORIDAD NUMÉRICA ---
        List<UnifiedssotIndividualDev2__dlm> numericResults = new List<UnifiedssotIndividualDev2__dlm>();
        if(!isEmail && numericToken != null && precisionResults.size() < 200) {
            String numPat = '%' + numericToken + '%';
            bindMap.put('numPat', numPat);
            numericResults = Database.queryWithBinds('SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__FirstName__c LIKE :numPat OR ssot__LastName__c LIKE :numPat OR Id_POS__c LIKE :numPat LIMIT 200', bindMap, AccessLevel.USER_MODE);
        }

        // --- FASE 3: VOLUMEN (OR) ---
        List<UnifiedssotIndividualDev2__dlm> broadResults = new List<UnifiedssotIndividualDev2__dlm>();
        if(!isEmail && precisionResults.size() + numericResults.size() < 200) {
            String qBroad = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE ';
            List<String> orConds = new List<String>();
            for(Integer i=0; i<tokens.size(); i++) orConds.add('(ssot__FirstName__c LIKE :p'+i+' OR ssot__LastName__c LIKE :p'+i+')');
            if(!idsFromPhones.isEmpty()) orConds.add('ssot__Id__c IN :idsFromPhones');
            qBroad += '(' + String.join(orConds, ' OR ') + ') LIMIT 200';
            broadResults = Database.queryWithBinds(qBroad, bindMap, AccessLevel.USER_MODE);
        }

        Map<String, UnifiedssotIndividualDev2__dlm> uniqueMap = new Map<String, UnifiedssotIndividualDev2__dlm>();
        for(UnifiedssotIndividualDev2__dlm r : precisionResults) uniqueMap.put(r.ssot__Id__c, r);
        for(UnifiedssotIndividualDev2__dlm r : numericResults) uniqueMap.put(r.ssot__Id__c, r);
        for(UnifiedssotIndividualDev2__dlm r : broadResults) if(uniqueMap.size() < 200) uniqueMap.put(r.ssot__Id__c, r);

        Set<String> finalIds = uniqueMap.keySet();
        Map<String, String> phoneMap = new Map<String, String>();
        if(!finalIds.isEmpty()) {
            try {
                for(SObject p : Database.query('SELECT ssot__TelephoneNumber__c, ssot__PartyId__c FROM UnifiedssotContactPointPhoneDev2__dlm WHERE ssot__PartyId__c IN :finalIds')) {
                    phoneMap.put((String)p.get('ssot__PartyId__c'), (String)p.get('ssot__TelephoneNumber__c'));
                }
            } catch(Exception e) {}
        }

        List<SearchResultWrapper> wrappedResults = new List<SearchResultWrapper>();
        for(UnifiedssotIndividualDev2__dlm r : uniqueMap.values()) {
            wrappedResults.add(new SearchResultWrapper(r, tokens, phoneMap.get(r.ssot__Id__c), term));
        }
        wrappedResults.sort();

        List<Map<String, Object>> finalResults = new List<Map<String, Object>>();
        for(SearchResultWrapper w : wrappedResults) {
            UnifiedssotIndividualDev2__dlm r = w.record;
            Map<String, Object> m = new Map<String, Object>();
            m.put('ssot__Id__c', r.ssot__Id__c);
            m.put('ssot__FirstName__c', toTitleCase(r.ssot__FirstName__c));
            m.put('ssot__LastName__c', toTitleCase(r.ssot__LastName__c));
            m.put('Email__c', r.Email__c);
            m.put('Id_POS__c', r.Id_POS__c);
            m.put('Telefono__c', phoneMap.containsKey(r.ssot__Id__c) ? phoneMap.get(r.ssot__Id__c) : 'N/A'); 
            finalResults.add(m);
        }
        return finalResults;
    }

    public class SearchResultWrapper implements Comparable {
        public UnifiedssotIndividualDev2__dlm record;
        public Integer score;
        public String fullTerm;

        public SearchResultWrapper(UnifiedssotIndividualDev2__dlm r, List<String> tokens, String phone, String term) {
            this.record = r;
            this.fullTerm = term.toUpperCase();
            this.score = calculateScore(r, tokens, phone);
        }

        private Integer calculateScore(UnifiedssotIndividualDev2__dlm r, List<String> tokens, String phone) {
            Integer s = 0;
            String fn = (r.ssot__FirstName__c ?? '').toUpperCase();
            String ln = (r.ssot__LastName__c ?? '').toUpperCase();
            String email = (r.Email__c ?? '').toUpperCase();
            String fullName = (fn + ' ' + ln).replaceAll('\\s+', ' ').trim();
            List<String> nameParts = fullName.split('\\s+');

            // 1. BONO DE EMAIL (MÁXIMA PRIORIDAD)
            if(fullTerm.contains('@')) {
                if(email == fullTerm) return 500000;
                if(email.contains(fullTerm)) s += 250000;
            }

            // 2. BONO DE COBERTURA Y DENSIDAD
            Integer matchedWords = 0;
            Integer numericMatches = 0;
            for(String t : tokens) {
                String tu = t.toUpperCase();
                if(fullName.contains(tu) || (r.Id_POS__c ?? '').contains(tu) || email.contains(tu)) {
                    matchedWords++;
                    if(t.isNumeric()) numericMatches++;
                }
            }
            if(matchedWords >= tokens.size()) s += 100000;
            else s += (matchedWords * 10000);
            s += (numericMatches * 50000);

            // 3. MATCH DE SECUENCIA
            if(fullName == fullTerm) s += 50000;
            if(fullName.contains(fullTerm)) s += 25000;

            if(!tokens.isEmpty() && fn.startsWith(tokens[0].toUpperCase())) s += 5000;
            s -= (nameParts.size() * 5); 
            return s;
        }

        public Integer compareTo(Object compareTo) {
            SearchResultWrapper other = (SearchResultWrapper)compareTo;
            if (this.score != other.score) return (this.score > other.score) ? -1 : 1;
            String thisFull = ((this.record.ssot__FirstName__c ?? '') + ' ' + (this.record.ssot__LastName__c ?? '')).toUpperCase();
            String otherFull = ((other.record.ssot__FirstName__c ?? '') + ' ' + (other.record.ssot__LastName__c ?? '')).toUpperCase();
            return thisFull.compareTo(otherFull);
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
    private static String categorize(String d) { if(d==null) return 'Oftalmicos'; d=d.toLowerCase(); if(d.contains('solar')) return 'Solares'; if(d.contains('contacto')) return 'LentesContacto'; return 'Oftalmicos'; }
}